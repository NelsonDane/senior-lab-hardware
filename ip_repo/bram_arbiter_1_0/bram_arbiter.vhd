library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity bram_arbiter is
generic (
    BRAM_WIDTH : integer := 32
);
Port (
    clk : in std_logic;
    reset : in std_logic;
    arbiter_state : out std_logic_vector(2 downto 0);
    -- Worker 1 Signals
    worker1_request : in std_logic;
    worker1_rw : in std_logic;
    worker1_address : in std_logic_vector(BRAM_WIDTH-1 downto 0);
    worker1_data_in : in std_logic_vector(BRAM_WIDTH-1 downto 0);
    worker1_data_out : out std_logic_vector(BRAM_WIDTH-1 downto 0);
    worker1_ack : out std_logic;
    -- Worker 2 Signals
    worker2_request : in std_logic;
    worker2_rw : in std_logic;
    worker2_address : in std_logic_vector(BRAM_WIDTH-1 downto 0);
    worker2_data_in : in std_logic_vector(BRAM_WIDTH-1 downto 0);
    worker2_data_out : out std_logic_vector(BRAM_WIDTH-1 downto 0);
    worker2_ack : out std_logic;
    -- Worker 3 Signals
    worker3_request : in std_logic;
    worker3_rw : in std_logic;
    worker3_address : in std_logic_vector(BRAM_WIDTH-1 downto 0);
    worker3_data_in : in std_logic_vector(BRAM_WIDTH-1 downto 0);
    worker3_data_out : out std_logic_vector(BRAM_WIDTH-1 downto 0);
    worker3_ack : out std_logic;
    -- BRAM Interface
    addrb : out std_logic_vector(BRAM_WIDTH-1 downto 0);
    dinb : out std_logic_vector(BRAM_WIDTH-1 downto 0);
    doutb : in std_logic_vector(BRAM_WIDTH-1 downto 0);
    rstb : out std_logic;
    web : out std_logic_vector(3 downto 0);
    rstb_busy : in std_logic
);
end bram_arbiter;

-- Read from BRAM requires:
-- 1. Set addrb for address
-- 2. Set web to "0000"
-- 3. Wait for doutb to be valid
-- 4. Read doutb
-- Write to BRAM requires:
-- 1. Set addrb and dinb for address/data
-- 2. Set web to "1111"

architecture Behavioral of bram_arbiter is
    type state_type is (IDLE, GRANT_WORKER_1, GRANT_WORKER_2, GRANT_WORKER_3);
    signal current_state : state_type := IDLE;
    function state_to_status(state : state_type) return std_logic_vector is
    begin
        case state is
            when IDLE => return "000";
            when GRANT_WORKER_1 => return "001";
            when GRANT_WORKER_2 => return "010";
            when GRANT_WORKER_3 => return "011";
            when others => return "111";
        end case;
    end function;

    -- Number of cycles to wait for BRAM read
    constant READ_BRAM_WAIT_CONSTANT : integer := 2;
    signal read_bram_wait_counter : integer := 0;

begin
    process(clk) is
    begin
        if reset = '1' then
            current_state <= IDLE;
            arbiter_state <= state_to_status(current_state);
        elsif rising_edge(clk) then
            case current_state is
                when IDLE =>
                    arbiter_state <= state_to_status(current_state);
                    rstb <= '0';
                    worker1_ack <= '0';
                    worker2_ack <= '0';
                    worker3_ack <= '0';
                    read_bram_wait_counter <= 0;
                    web <= "0000";
                    dinb <= (others => '0');
                    -- Round Robin Arbiter
                    if rstb_busy = '0' then
                        if worker1_request = '1' then
                            current_state <= GRANT_WORKER_1;
                        elsif worker2_request = '1' then
                            current_state <= GRANT_WORKER_2;
                        elsif worker3_request = '1' then
                            current_state <= GRANT_WORKER_3;
                        end if;
                    end if;
                when GRANT_WORKER_1 =>
                    arbiter_state <= state_to_status(current_state);
                    addrb <= worker1_address;
                    worker2_ack <= '0';
                    worker3_ack <= '0';
                    worker1_data_out <= doutb;
                    if worker1_rw = '1' then
                        -- Write to BRAM
                        dinb <= worker1_data_in;
                        web <= "1111";
                        if doutb = worker1_data_in then
                            worker1_ack <= '1';
                        end if;
                    else
                        web <= "0000";
                        -- Read from BRAM after waiting
                        if read_bram_wait_counter < READ_BRAM_WAIT_CONSTANT then
                            read_bram_wait_counter <= read_bram_wait_counter + 1;
                        else
                            worker1_ack <= '1';
                        end if;
                    end if;
                    if worker1_request = '0' then
                        current_state <= IDLE;
                        worker1_ack <= '0';
                        read_bram_wait_counter <= 0;
                    end if;
                when GRANT_WORKER_2 =>
                    arbiter_state <= state_to_status(current_state);
                    addrb <= worker2_address;
                    worker1_ack <= '0';
                    worker3_ack <= '0';
                    worker2_data_out <= doutb;
                    if worker2_rw = '1' then
                        -- Write to BRAM
                        dinb <= worker2_data_in;
                        web <= "1111";
                        if doutb = worker2_data_in then
                            worker2_ack <= '1';
                        end if;
                    else
                        web <= "0000";
                        -- Read from BRAM after waiting
                        if read_bram_wait_counter < READ_BRAM_WAIT_CONSTANT then
                            read_bram_wait_counter <= read_bram_wait_counter + 1;
                        else
                            worker2_ack <= '1';
                        end if;
                    end if;
                    if worker2_request = '0' then
                        current_state <= IDLE;
                        worker2_ack <= '0';
                        read_bram_wait_counter <= 0;
                    end if;
                when GRANT_WORKER_3 =>
                    arbiter_state <= state_to_status(current_state);
                    addrb <= worker3_address;
                    worker1_ack <= '0';
                    worker2_ack <= '0';
                    worker3_data_out <= doutb;
                    if worker3_rw = '1' then
                        -- Write to BRAM
                        dinb <= worker3_data_in;
                        web <= "1111";
                        if doutb = worker3_data_in then
                            worker3_ack <= '1';
                        end if;
                    else
                        web <= "0000";
                        -- Read from BRAM after waiting
                        if read_bram_wait_counter < READ_BRAM_WAIT_CONSTANT then
                            read_bram_wait_counter <= read_bram_wait_counter + 1;
                        else
                            worker3_ack <= '1';
                        end if;
                    end if;
                    if worker3_request = '0' then
                        current_state <= IDLE;
                        worker3_ack <= '0';
                        read_bram_wait_counter <= 0;
                    end if;
                when others =>
                    current_state <= IDLE;
                    arbiter_state <= state_to_status(current_state);
            end case;
        end if;
    end process;
end Behavioral;
