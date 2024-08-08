--------------------------------------------------------------------------------
--	Shifter des HWPR-Prozessors, instanziiert einen Barrelshifter.
--------------------------------------------------------------------------------
--	Datum:		??.??.2013
--	Version:	?.?
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


library work;
use work.ArmTypes.all;

entity ArmShifter is
	port (
		SHIFT_OPERAND	: in	std_logic_vector(31 downto 0);
		SHIFT_AMOUNT	: in	std_logic_vector(7 downto 0);
		SHIFT_TYPE_IN	: in	std_logic_vector(1 downto 0);
		SHIFT_C_IN		: in	std_logic;
		SHIFT_RRX		: in	std_logic;
		SHIFT_RESULT	: out	std_logic_vector(31 downto 0);
		SHIFT_C_OUT		: out	std_logic    		
 	);
end entity ArmShifter;

architecture behave of ArmShifter is

    signal mux_ctrl : std_logic_vector(1 downto 0);
    signal arith_shift : std_logic;
    
    signal operand : std_logic_vector(31 downto 0);
    signal carry_in : std_logic;
    
begin

    barrel_shifter : entity work.ArmBarrelShifter
        generic map (
            OPERAND_WIDTH => 32,
            SHIFTER_DEPTH => 8
        )
        port map (
            OPERAND => operand,
            MUX_CTRL => mux_ctrl,
            AMOUNT => SHIFT_AMOUNT,
            ARITH_SHIFT => arith_shift,
            C_IN => carry_in,
            DATA_OUT => SHIFT_RESULT,
            C_OUT => SHIFT_C_OUT
        );
        

    process(SHIFT_TYPE_IN, SHIFT_RRX, SHIFT_OPERAND, SHIFT_C_IN)
    begin
        if SHIFT_RRX = '0' then --RRX = Rotate Right with Extend
            arith_shift <= '0';
            case SHIFT_TYPE_IN is
                when SH_LSL => --Linksshift
                    mux_ctrl <= "01";  
                when SH_LSR =>  --Rechtsshift (logical)
                    mux_ctrl <= "10";     
                when SH_ASR => --Rechtsshift (arithmetic)
                    mux_ctrl <= "10";
                    arith_shift <= '1';   
                when SH_ROR => --Rechtsrotation
                    mux_ctrl <= "11";
                when others =>
                    mux_ctrl <= "00"; --kein Shift
            end case;
            operand <= SHIFT_OPERAND;
            carry_in <= SHIFT_C_IN;
            
        else --wenn SHIFT_RRX = '1'
            mux_ctrl <= "00"; --kein spezifischen "Shift-Modi"
            operand <= SHIFT_C_IN & SHIFT_OPERAND(31 downto 1);
            carry_in <= SHIFT_OPERAND(0);
        end if;
    end process;
end architecture behave;