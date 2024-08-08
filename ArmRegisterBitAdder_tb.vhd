--------------------------------------------------------------------------------
--	Testbench-Vorlage des HWPR-Bitaddierers.
--------------------------------------------------------------------------------
--	Datum:		??.??.2013
--	Version:	?.??
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--------------------------------------------------------------------------------
--	In TB_TOOLS kann, wenn gewuenscht die Funktion SLV_TO_STRING() zur
--	Ermittlung der Stringrepraesentation eines std_logic_vektor verwendet
--	werden und SEPARATOR_LINE fuer eine horizontale Trennlinie in Ausgaben.
--------------------------------------------------------------------------------
library work;
use work.TB_TOOLS.all;

entity ArmRegisterBitAdder_TB is
end ArmRegisterBitAdder_TB;

architecture testbench of ArmRegisterBitAdder_tb is 

	component ArmRegisterBitAdder
	port(
		RBA_REGLIST	: in std_logic_vector(15 downto 0);          
		RBA_NR_OF_REGS	: out std_logic_vector(4 downto 0)
		);
	end component ArmRegisterBitAdder;
	
	signal REGLIST : std_logic_vector(15 downto 0) := (others => '0');
    signal NR_OF_REGS : std_logic_vector(4 downto 0);
        
            -- Array für die Testvektoren
            type test_vector_array is array (0 to 16) of std_logic_vector(15 downto 0);
            constant test_vectors : test_vector_array := (
                "0000000000000000", --(00000)
                "0000000000000001", --(00001)
                "0000000000000011", --(00010)
                "0000000000000111", --(00011)
                "0000000000001111", --(00100)
                "0000000000011111", --(00101)
                "0000000000111111", --(00110)
                "0000000001111111", --(00111)
                "0000000011111111", --(01000)
                "0000000111111111", --(01001)
                "0000001111111111", --(01010)
                "0000011111111111", --(01011)
                "0000111111111111", --(01100)
                "0001111111111111", --(01101)
                "0011111111111111", --(01110)
                "0111111111111111", --(01111)
                "1111111111111111"  --(10000)
            );
            
	function count_bits(reglist : std_logic_vector) return integer is
                variable result : integer := 0;
            begin
                for i in reglist'range loop
                    if reglist(i) = '1' then
                        result := result + 1;
                    end if;
                end loop;
            return result;
    end function;
    
begin

        -- Unit Under Test
        UUT: ArmRegisterBitAdder port map(
            RBA_REGLIST => REGLIST,
            RBA_NR_OF_REGS => NR_OF_REGS
        );
    
--	Testprozess
            tb : process is
             --	Testprozess
                   variable error_occurred : boolean := false; --Error
               begin
               
                   wait for 100 ns; --Initialisierung
                                  
                   for i in 0 to 16 loop
                        REGLIST <= test_vectors(i);
                       
                                          
                        wait for 11 ns; --warten, dann überprüfen
                       
                                          
                        assert to_integer(unsigned(NR_OF_REGS)) = count_bits(test_vectors(i))
                           report "Fehler bei Testvektor: " & integer'image(i) & 
                                  " Erwartet: " & integer'image(count_bits(test_vectors(i))) & 
                                  " Erhalten: " & integer'image(to_integer(unsigned(NR_OF_REGS))) & " (" & SLV_TO_STRING(NR_OF_REGS) & ")"

                        severity error;
                        
                        
                        if to_integer(unsigned(NR_OF_REGS)) /= count_bits(test_vectors(i)) then
                            error_occurred := true;
                        end if;

                                  
                        wait for 10 ns; --warten
                       
                                          
                         if not NR_OF_REGS'stable then --sicherstellen, dass sich NR_OF_REGS nicht ändert
                            report "Signal hat sich geändert."
                            severity error;
                            error_occurred := true; --Error
                         end if;
                    end loop;
                      
                   
                    if error_occurred then
                           report "Tests nicht erfolgreich durchgeführt." severity note;
                        else
                           report "Alle Tests erfolgreich durchgeführt." severity error;
                    end if;
                   
                   
		report SEPARATOR_LINE;	
                   report " EOT (END OF TEST) - Diese Fehlermeldung stoppt den Simulator unabhaengig von tatsaechlich aufgetretenen Fehlern!" severity failure; 
           --    Unbegrenztes Anhalten des Testbench Prozess
                   wait;
        end process tb;
    end architecture testbench;