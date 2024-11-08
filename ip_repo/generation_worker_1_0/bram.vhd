library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-- Single Port BRAM for the Generation Worker
-- Has 16Kb of memory

entity bram is
    generic (
        SIZE : integer := 1024;
        ADDR_WIDTH : integer := 32;
        WIDTH : integer := 32
    );
    port (
        clk : in std_logic;
        we : in std_logic;
        re : in std_logic;
        addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
        din : in std_logic_vector(WIDTH-1 downto 0);
        dout : out std_logic_vector(WIDTH-1 downto 0)
    );
end entity bram;

architecture Behavioral of bram is
    type ram_type is array(0 to SIZE-1) of std_logic_vector(WIDTH-1 downto 0);
    signal ram : ram_type := (others => (others => '0'));

begin
    process(clk) is
    begin
        if rising_edge(clk) then
            if we = '1' then
                ram(conv_integer(unsigned(addr))) <= din;
            end if;
            if re = '1' then
                dout <= ram(conv_integer(unsigned(addr)));
            end if;
        end if;
    end process;
end architecture Behavioral;
           