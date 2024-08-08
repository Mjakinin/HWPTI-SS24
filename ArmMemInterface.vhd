--------------------------------------------------------------------------------
--	Schnittstelle zur Anbindung des RAM an die Busse des HWPR-Prozessors
--------------------------------------------------------------------------------
--	Datum:		??.??.2013
--	Version:	?.?
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ArmConfiguration.all;
use work.ArmTypes.all;

entity ArmMemInterface is
	generic(
--------------------------------------------------------------------------------
--	Beide Generics sind fuer das HWPR nicht relevant und koennen von
--	Ihnen ignoriert werden.
--------------------------------------------------------------------------------
		SELECT_LINES				: natural range 0 to 2 := 1;
		EXTERNAL_ADDRESS_DECODING_INSTRUCTION : boolean := false);
	port (  RAM_CLK	:  in  std_logic;
		--	Instruction-Interface
       		IDE		:  in std_logic;
			IA		:  in std_logic_vector(31 downto 2);
			ID		: out std_logic_vector(31 downto 0);
			IABORT	: out std_logic;
		--	Data-Interface
			DDE		:  in std_logic;
			DnRW	:  in std_logic;
			DMAS	:  in std_logic_vector(1 downto 0);
			DA 		:  in std_logic_vector(31 downto 0);
			DDIN	:  in std_logic_vector(31 downto 0);
			DDOUT	: out std_logic_vector(31 downto 0);
			DABORT	: out std_logic);
end entity ArmMemInterface;

architecture behave of ArmMemInterface is

    signal ADDRA : std_logic_vector(11 downto 0);
    signal ADDRB : std_logic_vector(11 downto 0);
    signal WEB   : std_logic_vector(3 downto 0);
    signal DOA   : std_logic_vector(31 downto 0);
    signal DOB   : std_logic_vector(31 downto 0);


begin

    ram_inst: entity work.ArmRAMB_4kx32
        port map (
            RAM_CLK => RAM_CLK,
            ENA     => IDE,
            ADDRA   => ADDRA,
            DOA     => DOA,
            ENB     => DDE,
            ADDRB   => ADDRB,
            DIB     => DDIN,
            DOB     => DOB,
            WEB     => WEB
        );

    -- INSTRUKTIONSBUS --
    ADDRA <= IA(13 downto 2);  -- unteren 12 Bits werden verwendet

    -- Gueltigkeit der Addresse prüfen
    process(IDE, IA)
    begin
        if IDE = '1' then
            if (unsigned(IA) * 4) >= unsigned(INST_LOW_ADDR) and (unsigned(IA) * 4) <= unsigned(INST_HIGH_ADDR) then
                IABORT <= '0';  -- gültige Addresse
            else
                IABORT <= '1';  -- Addresse außerhalb erlaubten Addressbereich
            end if;
        else
            IABORT <= 'Z';  -- IABORT hochohmig für IDE = 0
        end if;
    end process;
    
    
    
    -- Datenausgabe
    process(IDE, DOA)
    begin
        if IDE = '1' then
            ID <= DOA;
        else
            ID <= (others => 'Z');  -- ID hochohmig für IDE = 0
        end if;
    end process;
    

    -- DATENBUS --
    ADDRB <= DA(13 downto 2);  -- unteren 12 Bits werden verwendet    



    -- Write Enable Signale und Fehlersignale
    process(DDE, DnRW, DMAS, DA)
    begin
        if DDE = '1' then -- Datenbus aktiv
            case DMAS is 
                when "00" =>  -- Byte
                    DABORT <= '0';  -- alle Byte-Adressen sind gültig
                    if DnRW = '1' then  -- Schreibmodus
                        case DA(1 downto 0) is
                            when "00" => WEB <= "0001";
                            when "01" => WEB <= "0010";
                            when "10" => WEB <= "0100";
                            when "11" => WEB <= "1000";
                            when others => WEB <= "0000";  -- ungültige Adresse
                        end case;
                    else
                        WEB <= "0000";  -- Lesemodus, kein Schreibvorgang
                    end if;
    
    
                when "01" =>  -- Halbwort
                    if DA(0) = '0' then
                        DABORT <= '0';  -- Halbwort muss 2-Byte-ausgerichtet sein
                        if DnRW = '1' then  -- Schreibmodus
                            case DA(1) is
                                when '0' => WEB <= "0011";
                                when '1' => WEB <= "1100";
                                when others => WEB <= "0000";  -- ungültige Adresse
                            end case;
                        else
                            WEB <= "0000";  -- Lesemodus, kein Schreibvorgang
                        end if;
                    else
                        WEB <= "0000";  -- ungültige Adresse für Halbwortzugriff
                        DABORT <= '1';  -- Fehlersignal
                    end if;
    
    
                when "10" =>  -- Wort
                    if DA(1 downto 0) = "00" then
                        DABORT <= '0';  -- Wort muss 4-Byte-ausgerichtet sein
                        if DnRW = '1' then  -- Schreibmodus
                            WEB <= "1111";
                        else
                            WEB <= "0000";  -- Lesemodus, kein Schreibvorgang
                        end if;
                    else
                         WEB <= "0000";  -- ungültige Adresse für Wortzugriff
                         DABORT <= '1';  -- Fehlersignal
                    end if;
    
    
                when others =>
                    WEB <= "0000";  -- kein Schreibvorgang
                    DABORT <= '1';  -- ungültiger DMAS-Wert
            end case;
        else
            DABORT <= 'Z';  -- Hochohmig wenn Datenbus inaktiv
            WEB <= "0000";  -- kein Schreibvorgang
        end if;
    end process;
   
   
   
    -- Datenausgabe
    process(DDE, DnRW, DOB)
    begin
        if DDE = '1' and DnRW = '0' then
            DDOUT <= DOB;
        else
            DDOUT <= (others => 'Z');  -- Hochohmig, wenn DDE off oder Schreibmodus aktiv
        end if;
    end process;
    
    
end architecture behave;