library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Logic to create the Minecraft Generation Worker
-- States:
-- 0: IDLE (Waiting for manager to start)
-- 1: WORKING (Completing instructions)
-- 2: ERROR_STATE (Error occurred, wait for manager to reset)
-- 3: FINISHED_WAITING (Finished, wait for manager to read results)

-- 1 sign 9 integer 22 fraction

entity worker_logic is
    Port (
        -- Worker Logic
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        worker_state : out STD_LOGIC_VECTOR(3 downto 0);
        should_start : in STD_LOGIC;
        coordinates : in STD_LOGIC_VECTOR(31 downto 0);
        perlin : in STD_LOGIC_VECTOR(31 downto 0);
        program_result : out STD_LOGIC_VECTOR(31 downto 0);
        -- BRAM Signals
        bram_address : out STD_LOGIC_VECTOR(31 downto 0);
        bram_data : in STD_LOGIC_VECTOR(31 downto 0)
    );
end worker_logic;

architecture Behavioral of worker_logic is
    component instructions is
        generic (
            WIDTH: integer := 32
        );
        Port (
            clk: in std_logic;
            reset: in std_logic;
            opcode: in std_logic_vector(7 downto 0);
            x: in std_logic_vector(WIDTH-1 downto 0);
            y: in std_logic_vector(WIDTH-1 downto 0);
            result: out std_logic_vector(WIDTH-1 downto 0);
            result_ready: out std_logic;
            error_occurred: out std_logic
        );
    end component;

    -- States
    type state_type is (
        IDLE,
        WORKING,
        ERROR_STATE,
        FINISHED_WAITING
    );
    signal current_state : state_type := IDLE;
    function state_to_status(state : state_type) return STD_LOGIC_VECTOR is
    begin
        case state is
            when IDLE => return "0000";
            when WORKING => return "0001";
            when ERROR_STATE => return "0010";
            when FINISHED_WAITING => return "0011";
            when others => return "1111";
        end case;
    end function;
    -- Signals
    signal x_coord : STD_LOGIC_VECTOR(7 downto 0);
    signal z_coord : STD_LOGIC_VECTOR(7 downto 0);
    signal y_coord : STD_LOGIC_VECTOR(11 downto 0);
    signal perlin_noise : STD_LOGIC_VECTOR(31 downto 0);
    signal opcode : integer range 0 to 4;
    signal current_instructions : STD_LOGIC_VECTOR(63 downto 0);
    signal should_continue_manager : STD_LOGIC := '0';
    signal bram_address_signal : STD_LOGIC_VECTOR(31 downto 0);
    -- Move Signals
    signal move_to : STD_LOGIC_VECTOR(7 downto 0);
    signal move_from : STD_LOGIC_VECTOR(7 downto 0);
    signal move_to_temp : STD_LOGIC_VECTOR(31 downto 0);
    signal counter_wait : integer := 0;
    signal counter_wait_2 : integer := 0;
    signal bram_counter : integer := 0;
    signal should_read_1 : STD_LOGIC := '0';
    signal should_read_2 : STD_LOGIC := '0';
    -- Registers
    signal s0 : STD_LOGIC_VECTOR(31 downto 0);
    signal s1 : STD_LOGIC_VECTOR(31 downto 0);
    signal Ai0: STD_LOGIC_VECTOR(31 downto 0);
    signal Ai1 : STD_LOGIC_VECTOR(31 downto 0);
    signal AO : STD_LOGIC_VECTOR(31 downto 0);
    signal result : STD_LOGIC_VECTOR(31 downto 0);
    -- ALU Signals
    signal instruction_result : STD_LOGIC_VECTOR(31 downto 0);
    signal instruction_reset : STD_LOGIC := '0';
    signal instruction_result_ready : STD_LOGIC := '0';
    signal instruction_error_occurred : STD_LOGIC := '0';
    signal alu_operation : STD_LOGIC_VECTOR(7 downto 0);
    signal zeroes : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal instruction_1 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal instruction_2 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

begin
    -- Instructions
    ALU: instructions
    generic map (
        WIDTH => 32
    )
    port map (
        clk => clk,
        reset => instruction_reset,
        opcode => alu_operation,
        x => instruction_1,
        y => instruction_2,
        result => instruction_result,
        result_ready => instruction_result_ready,
        error_occurred => instruction_error_occurred
    );

    worker_state <= state_to_status(current_state);
    should_continue_manager <= should_start;
    bram_address <= bram_address_signal;

    -- Worker Logic
    process(clk) is
    begin
        if reset = '1' then
            current_state <= IDLE;
            bram_address_signal <= (others => '0');
        elsif rising_edge(clk) then
            case current_state is
                when IDLE =>
                    -- Stay here until manager says
                    if should_continue_manager = '1' then
                        should_read_1 <= '1';
                        should_read_2 <= '0';
                        current_state <= WORKING;
                    end if;
                    instruction_error_occurred <= '0';
                    counter_wait <= 0;
                    counter_wait_2 <= 0;
                    bram_address_signal <= (others => '0');
                    should_read_1 <= '0';
                    should_read_2 <= '0';
                    x_coord <= coordinates(31 downto 24);
                    z_coord <= coordinates(23 downto 16);
                    y_coord <= coordinates(15 downto 4);
                when WORKING =>
                    if should_read_1 = '1' then
                        current_instructions(63 downto 32) <= bram_data;
                        should_read_1 <= '0';
                        should_read_2 <= '1';
                        bram_address_signal <= std_logic_vector(unsigned(bram_address_signal) + 4); -- Move to next instruction
                    elsif should_read_2 = '1' then
                        current_instructions(31 downto 0) <= bram_data;
                        should_read_2 <= '0';
                    end if;
                    opcode <= to_integer(unsigned(current_instructions(63 downto 56)));
                    case opcode is
                        when 1 =>
                            -- Move
                            move_to <= current_instructions(55 downto 48);
                            move_from <= current_instructions(47 downto 40);
                            if counter_wait = 0 then
                                counter_wait <= 1; -- Let values settle
                            elsif counter_wait = 2 then
                                case move_to is
                                    when "00000000" =>
                                        x_coord <= move_from;
                                    when "00000001" =>
                                        y_coord <= (y_coord'length-1 downto move_from'length => '0') & move_from;
                                    when "00000010" =>
                                        z_coord <= move_from;
                                    when "00000011" =>
                                        perlin_noise <= (perlin_noise'length-1 downto move_from'length => '0') & move_from;
                                    when "00000100" =>
                                        Ai0 <= (Ai0'length-1 downto move_from'length => '0') & move_from;
                                    when "00000101" =>
                                        Ai1 <= (Ai1'length-1 downto move_from'length => '0') & move_from;
                                    when "00000110" =>
                                        AO <= (AO'length-1 downto move_from'length => '0') & move_from;
                                    when "00000111" =>
                                        program_result <= (program_result'length-1 downto move_from'length => '0') & move_from;
                                    when "00001000" =>
                                        s0 <= (s0'length-1 downto move_from'length => '0') & move_from;
                                    when "00001001" =>
                                        s1 <= (s1'length-1 downto move_from'length => '0') & move_from;
                                    when others =>
                                        current_state <= ERROR_STATE;
                                end case;
                                bram_address_signal <= std_logic_vector(unsigned(bram_address_signal) + 4); -- Move to next instruction
                                should_read_1 <= '1';
                            end if;
                        when 2 =>
                            -- Immediate
                            s0 <= current_instructions(31 downto 0);
                            should_read_1 <= '1';
                            bram_address_signal <= std_logic_vector(unsigned(bram_address_signal) + 4); -- Move to next instruction
                        when 3 =>
                            -- ALU Operation
                            alu_operation <= current_instructions(23 downto 16);
                            instruction_1 <= Ai0;
                            instruction_2 <= Ai1;
                            if instruction_result_ready = '1' then
                                if instruction_error_occurred = '1' then
                                    current_state <= ERROR_STATE;
                                else
                                    AO <= instruction_result;
                                    should_read_1 <= '1';
                                    bram_address_signal <= std_logic_vector(unsigned(bram_address_signal) + 4); -- Move to next instruction
                                end if;
                            end if;
                        when 4 =>
                            -- Done!
                            program_result <= result;
                            current_state <= FINISHED_WAITING;
                        when others =>
                            current_state <= ERROR_STATE;
                    end case;
                when FINISHED_WAITING =>
                    -- Waiting for manager to read results
                    if should_continue_manager = '1' then
                        current_state <= IDLE;
                    end if;
                when ERROR_STATE =>
                    -- Wait for help
                    if should_continue_manager = '1' then
                        current_state <= IDLE;
                    end if;
                when others =>
                    current_state <= ERROR_STATE;
            end case;
        end if;
    end process;

end Behavioral;
