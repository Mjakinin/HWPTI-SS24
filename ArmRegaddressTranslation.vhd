------------------------------------------------------------------------------
--	Paket fuer die Funktionen zur die Abbildung von ARM-Registeradressen
-- 	auf Adressen des physischen Registerspeichers (5-Bit-Adressen)
------------------------------------------------------------------------------
--	Datum:		05.11.2013
--	Version:	0.1
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.ArmTypes.all;

package ArmRegaddressTranslation is
  
	function get_internal_address(
		EXT_ADDRESS: std_logic_vector(3 downto 0); 
		THIS_MODE: std_logic_vector(4 downto 0); 
		USER_BIT : std_logic) 
	return std_logic_vector;

end package ArmRegaddressTranslation;

package body ArmRegAddressTranslation is

function get_internal_address(
	EXT_ADDRESS: std_logic_vector(3 downto 0);
	THIS_MODE: std_logic_vector(4 downto 0); 
	USER_BIT : std_logic) 
	return std_logic_vector 
is

--------------------------------------------------------------------------------		
--	Raum fuer lokale Variablen innerhalb der Funktion
--------------------------------------------------------------------------------
    variable physical_addr : std_logic_vector(4 downto 0);
	begin
--------------------------------------------------------------------------------		
--	Functionscode
--------------------------------------------------------------------------------		
    if(EXT_ADDRESS = R15) then 
        physical_addr := "01111";
    elsif (THIS_MODE = USER or THIS_MODE = SYSTEM or USER_BIT = '1') then
	   physical_addr := "0" & EXT_ADDRESS;
	elsif (THIS_MODE = FIQ) then 
	   if (EXT_ADDRESS = R0 or EXT_ADDRESS = R1 or EXT_ADDRESS = R2 or EXT_ADDRESS = R3 or EXT_ADDRESS = R4 or EXT_ADDRESS = R5 or EXT_ADDRESS = R6 or EXT_ADDRESS = R7) then
	       physical_addr := "0" & EXT_ADDRESS;
	   elsif (EXT_ADDRESS = R8) then
	       physical_addr := "10000";
	   elsif (EXT_ADDRESS = R9) then 
	       physical_addr := "10001";
	   elsif (EXT_ADDRESS = R10) then 
           physical_addr := "10010";
       elsif (EXT_ADDRESS = R11) then 
           physical_addr := "10011";
       elsif (EXT_ADDRESS = R12) then 
           physical_addr := "10100";
       elsif (EXT_ADDRESS = R13) then 
           physical_addr := "10101";
       elsif (EXT_ADDRESS = R14) then 
           physical_addr := "10110";
	   end if;
	elsif THIS_MODE = IRQ then 
	   if (EXT_ADDRESS = R0 or EXT_ADDRESS = R1 or EXT_ADDRESS = R2 or EXT_ADDRESS = R3 or EXT_ADDRESS = R4 or EXT_ADDRESS = R5 or EXT_ADDRESS = R6 or EXT_ADDRESS = R7 or EXT_ADDRESS = R8 or EXT_ADDRESS = R9 or EXT_ADDRESS = R10 or EXT_ADDRESS = R11 or EXT_ADDRESS = R12) then
           physical_addr := "0" & EXT_ADDRESS;
	   elsif EXT_ADDRESS = R13 then 
	       physical_addr := "10111";
	   elsif EXT_ADDRESS = R14 then
	       physical_addr := "11000";
	   end if;
	elsif THIS_MODE = SUPERVISOR then 
	    if (EXT_ADDRESS = R0 or EXT_ADDRESS = R1 or EXT_ADDRESS = R2 or EXT_ADDRESS = R3 or EXT_ADDRESS = R4 or EXT_ADDRESS = R5 or EXT_ADDRESS = R6 or EXT_ADDRESS = R7 or EXT_ADDRESS = R8 or EXT_ADDRESS = R9 or EXT_ADDRESS = R10 or EXT_ADDRESS = R11 or EXT_ADDRESS = R12) then
            physical_addr := "0" & EXT_ADDRESS;
        elsif (EXT_ADDRESS = R13) then 
            physical_addr := "11001";
        elsif (EXT_ADDRESS = R14) then
            physical_addr := "11010";
        end if;
    elsif THIS_MODE = ABORT then
        if (EXT_ADDRESS = R0 or EXT_ADDRESS = R1 or EXT_ADDRESS = R2 or EXT_ADDRESS = R3 or EXT_ADDRESS = R4 or EXT_ADDRESS = R5 or EXT_ADDRESS = R6 or EXT_ADDRESS = R7 or EXT_ADDRESS = R8 or EXT_ADDRESS = R9 or EXT_ADDRESS = R10 or EXT_ADDRESS = R11 or EXT_ADDRESS = R12) then
            physical_addr := "0" & EXT_ADDRESS;
        elsif (EXT_ADDRESS = R13) then 
            physical_addr := "11011";
        elsif (EXT_ADDRESS = R14) then
            physical_addr := "11100";
        end if;
    elsif THIS_MODE = UNDEFINED then
        if (EXT_ADDRESS = R0 or EXT_ADDRESS = R1 or EXT_ADDRESS = R2 or EXT_ADDRESS = R3 or EXT_ADDRESS = R4 or EXT_ADDRESS = R5 or EXT_ADDRESS = R6 or EXT_ADDRESS = R7 or EXT_ADDRESS = R8 or EXT_ADDRESS = R9 or EXT_ADDRESS = R10 or EXT_ADDRESS = R11 or EXT_ADDRESS = R12) then
            physical_addr := "0" & EXT_ADDRESS;
        elsif (EXT_ADDRESS = R13) then 
            physical_addr := "11101";
        elsif (EXT_ADDRESS = R14) then
            physical_addr := "11110";
        end if;
	else 
	   physical_addr := "11111";
	end if;
	
	       
	return physical_addr;			

end function get_internal_address;	
	 
end package body ArmRegAddressTranslation;
