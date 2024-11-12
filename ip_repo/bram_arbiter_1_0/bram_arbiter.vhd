library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity bram_arbiter is
Port (
    clk : in std_logic;
    reset : in std_logic;
    arbiter_state : out std_logic_vector(2 downto 0);
    -- Worker 1 Signals
    worker1_request : in std_logic;
    worker1_rw : in std_logic;
    worker1_address : in std_logic_vector(31 downto 0);
    worker1_data_in : in std_logic_vector(31 downto 0);
    worker1_data_out : out std_logic_vector(31 downto 0);
    worker1_ack : out std_logic;
    -- Worker 2 Signals
    worker2_request : in std_logic;
    worker2_rw : in std_logic;
    worker2_address : in std_logic_vector(31 downto 0);
    worker2_data_in : in std_logic_vector(31 downto 0);
    worker2_data_out : out std_logic_vector(31 downto 0);
    worker2_ack : out std_logic;
    -- BRAM Interface
    addrb : out std_logic_vector(31 downto 0);
    dinb : out std_logic_vector(31 downto 0);
    doutb : in std_logic_vector(31 downto 0);
    rstb : out std_logic;
    web : out std_logic_vector(3 downto 0)
);
end bram_arbiter;

-- Read from BRAM requires:
-- 1. Set addrb for address
-- 2. Set web to "0000"
-- 3. Set rstb to '0'
-- 4. Read doutb
-- Write to BRAM requires:
-- 1. Set addrb and dinb for address/data
-- 2. Set web to "1111"
-- 3. Set rstb to '1'

architecture Behavioral of bram_arbiter is
    type state_type is (IDLE, GRANT_WORKER_1, GRANT_WORKER_2);
    signal current_state : state_type := IDLE;
begin
    process(clk) is
    begin
        if reset = '1' then
            current_state <= IDLE;
            arbiter_state <= "000";
            worker1_ack <= '0';
            worker2_ack <= '0';
        elsif rising_edge(clk) then
            case current_state is
                when IDLE =>
                    arbiter_state <= "000";
                    -- Round Robin Arbiter
                    if worker1_request = '1' then
                        current_state <= GRANT_WORKER_1;
                    elsif worker2_request = '1' then
                        current_state <= GRANT_WORKER_2;
                    end if;
                when GRANT_WORKER_1 =>
                    addrb <= worker1_address;
                    worker1_ack <= '1';
                    if worker1_rw = '1' then
                        -- Write to BRAM
                        arbiter_state <= "001";
                        dinb <= worker1_data_in;
                        web <= "1111";
                        rstb <= '1';
                    else
                        -- Read from BRAM
                        arbiter_state <= "010";
                        worker1_data_out <= doutb;
                        web <= "0000";
                        rstb <= '0';
                    end if;
                    if worker1_request = '0' then
                        current_state <= IDLE;
                        worker1_ack <= '0';
                    end if;
                when GRANT_WORKER_2 =>
                    addrb <= worker2_address;
                    worker2_ack <= '1';
                    if worker2_rw = '1' then
                        -- Write to BRAM
                        arbiter_state <= "011";
                        dinb <= worker2_data_in;
                        web <= "1111";
                    else
                        -- Read from BRAM
                        arbiter_state <= "100";
                        worker2_data_out <= doutb;
                        web <= "0000";
                    end if;
                    if worker2_request = '0' then
                        current_state <= IDLE;
                        worker2_ack <= '0';
                    end if;
            end case;
        end if;
    end process;
end Behavioral;
