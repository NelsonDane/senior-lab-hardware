library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

-- Logic to create the Minecraft Generation Worker
-- States:
-- 0:IDLE (Reset BRAM)
-- 1: READY (Wait for BRAM address)
-- 2: WORKING (Complete Instructions)
-- 3: ERROR/Failed (Reset BRAM ->IDLE)
-- 4: FINISHED (Wait for Manager to read data)

entity worker_logic is
    Port (
        -- Worker Logic
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        worker_state : out STD_LOGIC_VECTOR(2 downto 0);
        bram_address : in STD_LOGIC_VECTOR(31 downto 0);
        -- BRAM
        addrb : out std_logic_vector(31 downto 0);
		clkb : out std_logic;
		dinb : out std_logic_vector(31 downto 0);
		doutb : in std_logic_vector(31 downto 0);
		enb : out std_logic;
		rstb : out std_logic;
		web : out std_logic_vector(3 downto 0)
    );
end worker_logic;

architecture Behavioral of worker_logic is

    -- type state_type is (IDLE, READY, WORKING, ERROR, FINISHED);
    -- signal current_state : state_type :=IDLE;

begin
    process(clk) is
    begin
        if rising_edge(clk) then
            if reset = '1' then
                rstb <= '0';
                -- web <= "0000";
                dinb <= (others => '1');
                worker_state <= "000";
            else
                rstb <= '1';
                -- web <= "1111";
                dinb <= x"DEADBEEF";
                worker_state <= "111";
            end if;
        end if;
        web <= "1111";
        clkb <= clk;
        enb <= '1';
        addrb <= bram_address;
    end process;

end Behavioral;
