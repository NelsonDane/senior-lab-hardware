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
        WIDTH: integer := 32;
        FRACTIONAL_BITS: integer := 22
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
end instructions;

architecture Behavioral of instructions is
    type state_type is (
        IDLE,
        CONSTANT_OP,
        ABS_VALUE_OP,
        SQUARE_OP,
        CUBE_OP,
        HALF_NEGATIVE_OP,
        QUARTER_NEGATIVE_OP,
        SQUEEZE_OP,
        ADD_OP,
        MULTIPLY_OP,
        MIN_OP,
        MAX_OP,
        FINISHED_STATE,
        OVER_UNDER_ADD_CHECK,
        OVER_UNDER_MUL_TEMP,
        OVER_UNDER_MUL_CHECK,
        ERROR_OCCURRED_STATE
    );
    signal current_state: state_type := IDLE;
    -- Constants
    constant MIN_CONSTANT : signed(WIDTH-1 downto 0) := to_signed(-1000000, WIDTH);
    constant MAX_CONSTANT : signed(WIDTH-1 downto 0) := to_signed(1000000, WIDTH);
    constant ONE : signed(WIDTH-1 downto 0) := to_signed(1, WIDTH);
    constant NEG_ONE : signed(WIDTH-1 downto 0) := to_signed(-1, WIDTH);
    constant DIV_24 : signed(WIDTH-1 downto 0) := to_signed(24, WIDTH);
    -- Signals
    signal x_fixed : signed(WIDTH-1 downto 0);
    signal y_fixed : signed(WIDTH-1 downto 0);
    signal result_fixed : signed(WIDTH-1 downto 0);
    signal temp_result_add : signed(WIDTH downto 0); -- One extra bit for overflow
    signal temp_result_mul : signed(WIDTH*2-1 downto 0); -- Double width for multiplication
    signal temp_result_mul_high : signed(WIDTH-1 downto 0); -- Hold the high bits of the multiplication

begin
    x_fixed <= signed(x);
    y_fixed <= signed(y);

    process(clk)
    begin
        if reset = '1' then
            result_fixed <= (others => '0');
            result_ready <= '0';
            error_occurred <= '0';
        elsif rising_edge(clk) then
            case current_state is
                when IDLE =>
                    -- 1: Decode opcode
                    result_ready <= '0';
                    case opcode is
                        when "00000010" =>
                            current_state <= CONSTANT_OP;
                        when "00000111" =>
                            current_state <= ABS_VALUE_OP;
                        when "00001000" =>
                            current_state <= SQUARE_OP;
                        when "00001001" =>
                            current_state <= CUBE_OP;
                        when "00001010" =>
                            current_state <= HALF_NEGATIVE_OP;
                        when "00001011" =>
                            current_state <= QUARTER_NEGATIVE_OP;
                        when "00001100" =>
                            current_state <= SQUEEZE_OP;
                        when "00001101" =>
                            current_state <= ADD_OP;
                        when "00001110" =>
                            current_state <= MULTIPLY_OP;
                        when "00001111" =>
                            current_state <= MIN_OP;
                        when "00010000" =>
                            current_state <= MAX_OP;
                        when others =>
                            -- current_state <= ERROR_OCCURRED_STATE;
                            current_state <= IDLE;
                    end case;
                -- 2: Constant
                when CONSTANT_OP =>
                    if x_fixed < MIN_CONSTANT then
                        result_fixed <= MIN_CONSTANT;
                    elsif x_fixed > MAX_CONSTANT then
                        result_fixed <= MAX_CONSTANT;
                    else
                        result_fixed <= x_fixed;
                    end if;
                    current_state <= FINISHED_STATE;
                -- 7: Absolute Value
                when ABS_VALUE_OP =>
                    result_fixed <= abs(x_fixed);
                    current_state <= FINISHED_STATE;
                -- 8: Square (x^2)
                when SQUARE_OP =>
                    result_fixed <= resize(signed(x_fixed * x_fixed) sra FRACTIONAL_BITS, WIDTH);
                    temp_result_mul <= resize(signed(x_fixed * x_fixed) sra FRACTIONAL_BITS, WIDTH*2);
                    current_state <= OVER_UNDER_MUL_TEMP;
                -- 9: Cube (x^3)
                when CUBE_OP =>
                    result_fixed <= resize(signed(x_fixed * resize(signed(x_fixed * x_fixed) sra FRACTIONAL_BITS, WIDTH*2)) sra FRACTIONAL_BITS, WIDTH);
                    temp_result_mul <= resize(signed(x_fixed * resize(signed(x_fixed * x_fixed) sra FRACTIONAL_BITS, WIDTH*2)) sra FRACTIONAL_BITS, WIDTH*2);
                    current_state <= OVER_UNDER_MUL_TEMP;
                -- 10: Half Negative
                when HALF_NEGATIVE_OP =>
                    if x_fixed < 0 then
                        -- Shift right arithmetic equivalent to divide by 2
                        result_fixed <= resize(x_fixed sra 1, WIDTH);
                        temp_result_mul <= resize(x_fixed sra 1, WIDTH*2);
                        current_state <= OVER_UNDER_MUL_TEMP;
                    else
                        result_fixed <= x_fixed;
                        current_state <= FINISHED_STATE;
                    end if;
                -- 11: Quarter Negative
                when QUARTER_NEGATIVE_OP =>
                    if x_fixed < 0 then
                        -- Shift right arithmetic equivalent to divide by 4
                        result_fixed <= resize(x_fixed sra 2, WIDTH);
                        temp_result_mul <= resize(x_fixed sra 2, WIDTH*2);
                        current_state <= OVER_UNDER_MUL_TEMP;
                    else
                        result_fixed <= x_fixed;
                        current_state <= FINISHED_STATE;
                    end if;
                -- 12: Squeeze
                when SQUEEZE_OP =>
                    -- val = data[in]
                    -- if(val < -1)
                    -- val = -1
                    -- else if(val > 1)
                    -- val = 1

                    -- a = val/2
                    -- b = val * val * val
                    -- b =/ 24
                    -- data[out] = a - b
                    if x_fixed < NEG_ONE then
                        result_fixed <= resize(NEG_ONE sra 1, WIDTH) - resize(signed((NEG_ONE * (2**FRACTIONAL_BITS)) / DIV_24), WIDTH);
                    elsif x_fixed > ONE then
                        result_fixed <= resize(ONE sra 1, WIDTH) - resize(signed((ONE * (2**FRACTIONAL_BITS)) / DIV_24), WIDTH);
                    else
                        result_fixed <= resize((x_fixed sra 1) -
                            signed((x_fixed * signed((x_fixed * x_fixed) sra FRACTIONAL_BITS)) sra (2 * FRACTIONAL_BITS)) / DIV_24, WIDTH);
                    end if;
                    result_ready <= '1';
                    error_occurred <= '0';
                    current_state <= FINISHED_STATE;
                -- 13: Add
                when ADD_OP =>
                    result_fixed <= resize(signed(x_fixed + y_fixed), WIDTH);
                    temp_result_add <= resize(signed(x_fixed + y_fixed), WIDTH+1);
                    current_state <= OVER_UNDER_ADD_CHECK;
                -- 14: Multiply
                when MULTIPLY_OP =>
                    result_fixed <= resize(signed(x_fixed * y_fixed) sra FRACTIONAL_BITS, WIDTH);
                    temp_result_mul <= resize(signed(x_fixed * y_fixed) sra FRACTIONAL_BITS, WIDTH*2);
                    current_state <= OVER_UNDER_MUL_TEMP;
                -- 15: Min
                when MIN_OP =>
                    result_fixed <= minimum(x_fixed, y_fixed);
                    current_state <= FINISHED_STATE;
                -- 16: Max
                when MAX_OP =>
                    result_fixed <= maximum(x_fixed, y_fixed);
                    current_state <= FINISHED_STATE;
                -- Finished
                when FINISHED_STATE =>
                    result_ready <= '1';
                    error_occurred <= '0';
                -- Check for Addition Overflow
                when OVER_UNDER_ADD_CHECK =>
                    if (x_fixed(x_fixed'high) = y_fixed(y_fixed'high)) and
                        (x_fixed(x_fixed'high) /= temp_result_add(temp_result_add'high)) then
                        current_state <= ERROR_OCCURRED_STATE;
                    else
                        current_state <= FINISHED_STATE;
                    end if;
                -- Check for Multiplication/Division Overflow
                when OVER_UNDER_MUL_TEMP =>
                    temp_result_mul_high <= (others => temp_result_mul(temp_result_mul'high));
                    current_state <= OVER_UNDER_MUL_CHECK;
                when OVER_UNDER_MUL_CHECK =>
                    if (temp_result_mul(temp_result_mul'high downto WIDTH) /= temp_result_mul_high) then
                        result_fixed <= temp_result_mul(temp_result_mul'high downto WIDTH);
                        current_state <= ERROR_OCCURRED_STATE;
                    else
                        current_state <= FINISHED_STATE;
                    end if;
                when ERROR_OCCURRED_STATE =>
                    result_ready <= '1';
                    error_occurred <= '1';
                when others =>
                    result_ready <= '1';
                    error_occurred <= '1';
                end case;
            end if;
    end process;

    result <= std_logic_vector(result_fixed);

end Behavioral;