library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Complete Instructions Opcodes
-- 2: constant
-- 7: absolute Value
-- 8: square (x^2)
-- 9: cube (x^3)
-- 10: half_negative
-- 11: quarter_negative
-- 12: squeeze
-- 13: add
-- 14: multiply
-- 15: min
-- 16: max

-- Using 32-bit signed fixed point math

entity instructions is
    generic (
        WIDTH: integer := 32
    );
    Port (
        opcode: in std_logic_vector(7 downto 0);
        x: in std_logic_vector(WIDTH-1 downto 0);
        y: in std_logic_vector(WIDTH-1 downto 0);
        result: out std_logic_vector(WIDTH-1 downto 0);
        result_ready: out std_logic
    );
end instructions;

architecture Behavioral of instructions is
    -- Constants
    constant FRACTIONAL_BITS : integer := 16;
    constant MIN_CONSTANT : signed(WIDTH-1 downto 0) := to_signed(-1000000, WIDTH);
    constant MAX_CONSTANT : signed(WIDTH-1 downto 0) := to_signed(1000000, WIDTH);
    constant ONE : signed(WIDTH-1 downto 0) := to_signed(1, WIDTH);
    constant NEG_ONE : signed(WIDTH-1 downto 0) := to_signed(-1, WIDTH);
    constant DIV_24 : signed(WIDTH-1 downto 0) := to_signed(24, WIDTH);
    -- Signals
    signal x_fixed : signed(WIDTH-1 downto 0);
    signal y_fixed : signed(WIDTH-1 downto 0);
    signal result_fixed : signed(WIDTH-1 downto 0);

begin
    x_fixed <= signed(x);
    y_fixed <= signed(y);

    process(opcode, x_fixed, y_fixed)
    begin
        case opcode is
            -- 2: Constant
            when "00000010" =>
                if x_fixed < MIN_CONSTANT then
                    result_fixed <= MIN_CONSTANT;
                elsif x_fixed > MAX_CONSTANT then
                    result_fixed <= MAX_CONSTANT;
                else
                    result_fixed <= x_fixed;
                end if;
                result_ready <= '1';
            -- 7: Absolute Value
            when "00000111" =>
                result_fixed <= abs(x_fixed);
                result_ready <= '1';
            -- 8: Square (x^2)
            when "00001000" =>
                result_fixed <= resize((x_fixed * x_fixed) srl FRACTIONAL_BITS, WIDTH);
                result_ready <= '1';
            -- 9: Cube (x^3)
            when "00001001" =>
                result_fixed <= resize((x_fixed * x_fixed * x_fixed) srl FRACTIONAL_BITS, WIDTH);
                result_ready <= '1';
            -- 10: Half Negative
            when "00001010" =>
                if x_fixed < 0 then
                    result_fixed <= x_fixed / 2;
                else
                    result_fixed <= x_fixed;
                end if;
                result_ready <= '1';
            -- 11: Quarter Negative
            when "00001011" =>
                if x_fixed < 0 then
                    result_fixed <= x_fixed / 4;
                else
                    result_fixed <= x_fixed;
                end if;
                result_ready <= '1';
            -- 12: Squeeze
            when "00001100" =>
                -- Not tested
                -- val = data[in]
                -- if(val < -1)
                -- val = -1
                -- else if(val > 1)
                -- val = 1

                -- a = val/2
                -- b = val * val * val
                -- b =/ 24
                -- data[out] = a - b
                -- Clamp between -1 and 1
                if x_fixed < NEG_ONE then
                    result_fixed <= resize((NEG_ONE / 2) - ((NEG_ONE * NEG_ONE * NEG_ONE) / DIV_24), WIDTH);
                elsif x_fixed > ONE then
                    result_fixed <= resize((ONE / 2) - ((ONE * ONE * ONE) / DIV_24), WIDTH);
                else
                    result_fixed <= resize((x_fixed / 2) - ((x_fixed * x_fixed * x_fixed) / DIV_24), WIDTH);
                end if;
                result_ready <= '1';
            -- 13: Add
            when "00001101" =>
                result_fixed <= x_fixed + y_fixed;
                result_ready <= '1';
            -- 14: Multiply
            when "00001110" =>
                result_fixed <= resize((x_fixed * y_fixed) srl FRACTIONAL_BITS, WIDTH);
                result_ready <= '1';
            -- 15: Min
            when "00001111" =>
                if x_fixed < y_fixed then
                    result_fixed <= x_fixed;
                else
                    result_fixed <= y_fixed;
                end if;
                result_ready <= '1';
            -- 16: Max
            when "00010000" =>
                if x_fixed > y_fixed then
                    result_fixed <= x_fixed;
                else
                    result_fixed <= y_fixed;
                end if;
                result_ready <= '1';
            when others =>
                result_fixed <= (others => '0');
                result_ready <= '0';
        end case;
    end process;

    result <= std_logic_vector(result_fixed);

end Behavioral;