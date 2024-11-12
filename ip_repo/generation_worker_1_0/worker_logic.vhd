library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

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
        worker_read_data : out STD_LOGIC_VECTOR(31 downto 0);
        -- Arbiter Signals
        worker_request : out STD_LOGIC;
        worker_address : out STD_LOGIC_VECTOR(31 downto 0);
        worker_rw : out STD_LOGIC;
        worker_data_in : in STD_LOGIC_VECTOR(31 downto 0);
        worker_data_out : out STD_LOGIC_VECTOR(31 downto 0);
        worker_ack : in STD_LOGIC

        -- BRAM
        -- addrb : out std_logic_vector(31 downto 0);
		-- -- clkb : out std_logic;
		-- dinb : out std_logic_vector(31 downto 0);
		-- doutb : in std_logic_vector(31 downto 0);
		-- -- enb : out std_logic;
		-- -- rstb : out std_logic;
		-- web : out STD_LOGIC
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
                -- Write to BRAM
                worker_request <= '1';
                worker_rw <= '1';
                worker_data_out <= x"DEADBEEF";
                worker_read_data <= worker_data_in;
                worker_address <= bram_address;
                worker_state <= "000";
            else
                -- Read from BRAM
                worker_request <= '1';
                worker_rw <= '0';
                worker_data_out <= x"DEADBEEF";
                worker_read_data <= worker_data_in;
                worker_state <= "111";
                worker_address <= bram_address;
            end if;
        end if;


        -- if rising_edge(clk) then
        --     if reset = '1' then
        --         rstb <= '0';
        --         -- web <= "0000";
        --         -- dinb <= (others => '1');
        --         worker_state <= "000";
        --     else
        --         rstb <= '1';
        --         -- web <= "1111";
        --         -- dinb <= x"DEADBEEF";
        --         -- worker_read_data <= doutb; 
        --         worker_state <= "111";
        --     end if;
        -- end if;
        -- -- web <= "1111";
        -- web <= "0";
        -- worker_read_data <= doutb;
        -- -- clkb <= clk;
        -- -- enb <= '1';
        -- addrb <= std_logic_vector(unsigned(bram_address) + 8);
    end process;

end Behavioral;
