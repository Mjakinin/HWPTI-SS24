--------------------------------------------------------------------------------
-- 	Barrelshifter fuer LSL, LSR, ASR, ROR mit Shiftweiten von 0 bis 3 (oder 
--	generisch n-1) Bit. 
--------------------------------------------------------------------------------
--	Datum:		??.??.2013
--	Version:	?.?
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
--use ieee.math_real.all;
use ieee.numeric_std.all;


entity ArmBarrelShifter is
--------------------------------------------------------------------------------
--	Breite der Operanden (n) und die Zahl der notwendigen
--	Multiplexerstufen (m) um Shifts von 0 bis n-1 Stellen realisieren zu
--	koennen. Es muss gelten: ???
--------------------------------------------------------------------------------
	generic (OPERAND_WIDTH : integer := 32;--4         --32-Bit-Operanden
			 SHIFTER_DEPTH : integer := 5 --2        --5-Bit, um 0 bis 31 Positionen darzustellen
	 );
	port ( 	OPERAND 	: in std_logic_vector(OPERAND_WIDTH-1 downto 0);	
    		MUX_CTRL 	: in std_logic_vector(1 downto 0);
    		AMOUNT 		: in std_logic_vector(SHIFTER_DEPTH-1 downto 0);	
    		ARITH_SHIFT : in std_logic; 
    		C_IN 		: in std_logic;
           	DATA_OUT 	: out std_logic_vector(OPERAND_WIDTH-1 downto 0);	
    		C_OUT 		: out std_logic
	);
end entity ArmBarrelShifter;

architecture structure of ArmBarrelShifter is

begin

    process(OPERAND, MUX_CTRL, AMOUNT, ARITH_SHIFT, C_IN)
    
        variable temp : std_logic_vector(OPERAND_WIDTH-1 downto 0);
        variable carry_out    : std_logic;
       
    begin
    
        temp := OPERAND;
        carry_out := C_IN;
        
        for i in 0 to to_integer(unsigned(AMOUNT))-1 loop
            case MUX_CTRL is
                when "00" => --Kein Shift
                    temp := temp;
                when "01" => --Linksshift
                    carry_out := temp(OPERAND_WIDTH-1); --Carry steht ganz links im Ergebnis
                    temp := temp(OPERAND_WIDTH-2 downto 0) & '0';
                when "10" => --Rechtsshift
                    carry_out := temp(0); --Carry steht ganz rechts im Ergebnis
                    if ARITH_SHIFT = '1' then
                        temp := temp(OPERAND_WIDTH-1) & temp(OPERAND_WIDTH-1 downto 1);
                    else
                        temp := '0' & temp(OPERAND_WIDTH-1 downto 1);
                    end if;
                when "11" => --Rechtsrotation
                    carry_out := temp(0); --Carry steht ganz rechts im Ergebnis
                    temp := temp(0) & temp(OPERAND_WIDTH-1 downto 1);
                when others =>
                    temp := (others => '0');
            end case;
        end loop;
        DATA_OUT <= temp;
        C_OUT <= carry_out;
    end process;
end architecture structure;