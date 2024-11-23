library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Logic to create the Minecraft Generation Worker
-- States:
-- 0: IDLE (Reset BRAM)
-- 1: READY (Wait for BRAM address)
-- 2: WORKING (Complete Instructions)
-- 3: ERROR/Failed (Reset BRAM ->IDLE)
-- 4: FINISHED (Wait for Manager to read data)

-- Worker BRAM
-- Constant Address: 0x40000000
-- Seed Low Address: 0x40000000
-- Seed High Address: 0x40000004
-- Coords Address: bram_address
-- Results Address: bram_address + 4

entity worker_logic is
    Generic (
        BRAM_WIDTH : integer := 32
    );
    Port (
        -- Worker Logic
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        worker_state : out STD_LOGIC_VECTOR(3 downto 0);
        bram_address : in STD_LOGIC_VECTOR(BRAM_WIDTH-1 downto 0);
        worker_read_data : out STD_LOGIC_VECTOR(BRAM_WIDTH-1 downto 0);
        should_continue_manager : in STD_LOGIC;
        -- Arbiter Signals
        worker_request : out STD_LOGIC;
        worker_address : out STD_LOGIC_VECTOR(BRAM_WIDTH-1 downto 0);
        worker_rw : out STD_LOGIC;
        worker_data_in : in STD_LOGIC_VECTOR(BRAM_WIDTH-1 downto 0);
        worker_data_out : out STD_LOGIC_VECTOR(BRAM_WIDTH-1 downto 0);
        worker_ack : in STD_LOGIC
    );
end worker_logic;

architecture Behavioral of worker_logic is

    -- States
    type state_type is (
        IDLE,
        RESET_RESULTS,
        READING_SEED_LOW,
        READING_SEED_HIGH,
        READING_COORDS,
        READY,
        WORKING,
        ERROR_STATE,
        WRITE_RESULTS,
        FINISHED_WAITING
    );
    signal current_state : state_type := IDLE;
    function state_to_status(state : state_type) return STD_LOGIC_VECTOR is
    begin
        case state is
            when IDLE => return "0000";
            when RESET_RESULTS => return "0001";
            when READING_SEED_LOW => return "0010";
            when READING_SEED_HIGH => return "0011";
            when READING_COORDS => return "0100";
            when READY => return "0101";
            when WORKING => return "0110";
            when ERROR_STATE => return "0111";
            when WRITE_RESULTS => return "1000";
            when FINISHED_WAITING => return "1001";
            when others => return "1111";
        end case;
    end function;
    -- Signals
    signal seed_address_constant : STD_LOGIC_VECTOR(31 downto 0) := x"40000000";
    signal world_seed : STD_LOGIC_VECTOR(63 downto 0); -- int64_t
    signal x_coord : STD_LOGIC_VECTOR(7 downto 0); -- int8_t
    signal z_coord : STD_LOGIC_VECTOR(7 downto 0); -- int8_t
    signal y_coord : STD_LOGIC_VECTOR(7 downto 0); -- int8_t
    signal opcode : STD_LOGIC_VECTOR(7 downto 0); -- uint8_t

    signal has_acknowledged : STD_LOGIC := '0';
    signal counter : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal temp_changer : INTEGER := 70;

begin
    process(clk) is
    begin
        if reset = '1' then
            current_state <= IDLE;
            worker_request <= '0';
            worker_rw <= '0';
            worker_data_out <= (others => '0');
            worker_address <= (others => '0');
            has_acknowledged <= '0';
        elsif rising_edge(clk) then
            case current_state is
                when IDLE =>
                    -- Stay here until manager says
                    worker_state <= state_to_status(current_state);
                    if should_continue_manager = '1' then
                        current_state <= RESET_RESULTS;
                    end if;
                -- Reset previous results
                -- Manager will reset seed/coords
                when RESET_RESULTS =>
                    worker_state <= state_to_status(current_state);
                    if worker_ack = '1' then
                        if has_acknowledged = '0' then
                            worker_request <= '0';
                            has_acknowledged <= '1';
                        end if;
                    elsif worker_ack = '0' then
                        if has_acknowledged = '1' then
                            has_acknowledged <= '0';
                            current_state <= READING_SEED_LOW;
                        else
                            worker_request <= '1';
                            worker_rw <= '1';
                            worker_data_out <= x"DEADBEEF";
                            worker_address <= std_logic_vector(unsigned(bram_address) + 4);
                        end if;
                    end if;
                -- Seed is split into two 32-bit values
                when READING_SEED_LOW =>
                    worker_state <= state_to_status(current_state);
                    if worker_ack = '1' then
                        if has_acknowledged = '0' then
                            world_seed(31 downto 0) <= worker_data_in;
                            worker_read_data <= worker_data_in;
                            worker_request <= '0';
                            has_acknowledged <= '1';
                        end if;
                    elsif worker_ack = '0' then
                        if has_acknowledged = '1' then
                            has_acknowledged <= '0';
                            current_state <= READING_SEED_HIGH;
                        else
                            worker_request <= '1';
                            worker_rw <= '0';
                            worker_address <= seed_address_constant;
                        end if;
                    end if;
                when READING_SEED_HIGH =>
                    worker_state <= state_to_status(current_state);
                    if worker_ack = '1' then
                        if has_acknowledged = '0' then
                            world_seed(63 downto 32) <= worker_data_in;
                            worker_read_data <= worker_data_in;
                            worker_request <= '0';
                            has_acknowledged <= '1';
                        end if;
                    elsif worker_ack = '0' then
                        if has_acknowledged = '1' then
                            has_acknowledged <= '0';
                            current_state <= READY;
                        else
                            worker_request <= '1';
                            worker_rw <= '0';
                            worker_address <= std_logic_vector(unsigned(seed_address_constant) + 4);
                        end if;
                    end if;
                -- Ready to receive instructions, wait for manager to write
                when READY =>
                    worker_state <= state_to_status(current_state);
                    if should_continue_manager = '0' then
                        current_state <= READING_COORDS;
                    end if;
                -- Read the coordinates/opcode (packed into a single 32-bit vector)
                when READING_COORDS =>
                    worker_state <= state_to_status(current_state);
                    if worker_ack = '1' then
                        if has_acknowledged = '0' then
                            x_coord <= worker_data_in(31 downto 24);
                            y_coord <= worker_data_in(23 downto 16);
                            z_coord <= worker_data_in(15 downto 8);
                            opcode <= worker_data_in(7 downto 0);
                            worker_read_data <= worker_data_in;
                            worker_request <= '0';
                            has_acknowledged <= '1';
                        end if;
                    elsif worker_ack = '0' then
                        if has_acknowledged = '1' then
                            has_acknowledged <= '0';
                            current_state <= WORKING;
                        else
                            worker_request <= '1';
                            worker_rw <= '0';
                            worker_address <= bram_address;
                        end if;
                    end if;
                when WORKING =>
                    -- For now, just increment all by 1 (to test)
                    x_coord <= std_logic_vector(unsigned(x_coord) + 1);
                    y_coord <= std_logic_vector(unsigned(y_coord) + 1);
                    z_coord <= std_logic_vector(unsigned(z_coord) + 1);
                    opcode <= std_logic_vector(unsigned(opcode) + 1);
                    current_state <= WRITE_RESULTS;
                when WRITE_RESULTS =>
                    worker_state <= state_to_status(current_state);
                    if worker_ack = '1' then
                        if has_acknowledged = '0' then
                            worker_request <= '0';
                            has_acknowledged <= '1';
                        end if;
                    elsif worker_ack = '0' then
                        if has_acknowledged = '1' then
                            has_acknowledged <= '0';
                            current_state <= FINISHED_WAITING;
                        else
                            worker_request <= '1';
                            worker_rw <= '1';
                            worker_data_out <= x_coord & y_coord & z_coord & opcode;
                            worker_address <= std_logic_vector(unsigned(bram_address) + 4);
                        end if;
                    end if;
                when FINISHED_WAITING =>
                    worker_state <= state_to_status(current_state);
                    -- Waiting for manager to read results
                    if should_continue_manager = '1' then
                        current_state <= IDLE;
                    end if;
                when ERROR_STATE =>
                    -- Wait for help
                    worker_state <= state_to_status(current_state);
                    -- Wait for manager to reset
                    if should_continue_manager = '1' then
                        current_state <= IDLE;
                    end if;
                when others =>
                    current_state <= ERROR_STATE;
            end case;
        end if;
    end process;

end Behavioral;
