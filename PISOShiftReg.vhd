--------------------------------------------------------------------------------
-- PISO-Schieberegister als mÃ¶gliche Grundlage fÃ¼r die Implementierung der RS232-
-- Schnittstelle im Hardwarepraktikum
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity PISOShiftReg is
	generic(
		WIDTH	 : integer := 8
	);
	port(
		CLK	     : in std_logic;
		CLK_EN	 : in std_logic;
		LOAD	 : in std_logic;
		D_IN	 : in std_logic_vector(WIDTH-1 downto 0);
		D_OUT	 : out std_logic;
		LAST_BIT : out std_logic
	);
end entity PISOShiftReg;

architecture behavioral of PISOShiftReg is

begin
    process(CLK)
        variable counter : integer := 0;
        variable shiftedreg : std_logic_vector(WIDTH-1 downto 0);
    begin
        if rising_edge(CLK) and CLK_EN = '1' then --synchron
                if LOAD = '1' then --Taktsynchrones Speichern des Datums in dem Schieberegister, bei 1 = Speichern
                    shiftedreg := D_IN; --speichern
                    LAST_BIT <= '0';
                    counter := 0; --counter zurcksetzen (neues Datum gespeichert)
                    D_OUT <= shiftedreg(counter);
                else -- bei 0 = Schieben
                    if counter < WIDTH then -- wenn das Datum noch nicht komplett herausgeschoben wurde
                        shiftedreg := '0' & shiftedreg(WIDTH-1 downto 1); --schiebeoperation
                        D_OUT <= shiftedreg(0); --zeige das niederwertigste Bit
                        counter := counter + 1; -- inkrementierung des Counters
                        if counter = WIDTH-1 then
                            LAST_BIT <= '1';
                        end if;
                    else
                        D_OUT <= '0'; --Datum schon komplett heraus geschoben
                    end if;
                end if;
          end if;
    end process;
end architecture behavioral;
