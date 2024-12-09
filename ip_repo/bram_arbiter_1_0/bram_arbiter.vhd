library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity bram_arbiter is
Port (
    clk : in std_logic;
    arbiter_state : out std_logic_vector(2 downto 0);
    -- Lead Worker Signals
    worker_address : in std_logic_vector(31 downto 0);
    bram_data_out : out std_logic_vector(32-1 downto 0);
    -- BRAM Interface
    addrb : out std_logic_vector(31 downto 0);
    doutb : in std_logic_vector(32-1 downto 0);
    rstb : out std_logic;
    web : out std_logic_vector(3 downto 0)
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
    -- Number of cycles to wait for BRAM read
    -- constant READ_BRAM_WAIT_CONSTANT : integer := 2;
    -- signal read_bram_wait_counter : integer := 0;

begin
    process(clk) is
    begin
        rstb <= '0';
        bram_data_out <= doutb;
        addrb <= worker_address;
        web <= "0000";
    end process;
end Behavioral;
