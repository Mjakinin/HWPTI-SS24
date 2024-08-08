--------------------------------------------------------------------------------
--	16-Bit-Register zur Steuerung der Auswahl des naechsten Registers
--	bei der Ausfuehrung von STM/LDM-Instruktionen. Das Register wird
--	mit der Bitmaske der Instruktion geladen. Ein Prioritaetsencoder
--	(Modul ArmPriorityVectorFilter) bestimmt das Bit mit der hochsten 
--	Prioritaet. Zu diesem Bit wird eine 4-Bit-Registeradresse erzeugt und
--	das Bit im Register geloescht. Bis zum Laden eines neuen Datums wird
--	mit jedem Takt ein Bit geloescht bis das Register leer ist.	
--------------------------------------------------------------------------------
--	Datum:		??.??.2013
--	Version:	?.??
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity ArmLdmStmNextAddress is
	port(
		SYS_RST			: in std_logic;
		SYS_CLK			: in std_logic;	
		LNA_LOAD_REGLIST 	: in std_logic;
		LNA_HOLD_VALUE 		: in std_logic;
		LNA_REGLIST 		: in std_logic_vector(15 downto 0);
		LNA_ADDRESS 		: out std_logic_vector(3 downto 0);
		LNA_CURRENT_REGLIST_REG : out std_logic_vector(15 downto 0)
	    );
end entity ArmLdmStmNextAddress;

architecture behave of ArmLdmStmNextAddress is

	component ArmPriorityVectorFilter
		port(
			PVF_VECTOR_UNFILTERED	: in std_logic_vector(15 downto 0);
			PVF_VECTOR_FILTERED	: out std_logic_vector(15 downto 0)
		);
	end component ArmPriorityVectorFilter;
	
	signal current_reg : std_logic_vector(15 downto 0);
    signal filtered_vector : std_logic_vector(15 downto 0);

begin
	CURRENT_REGLIST_FILTER : ArmPriorityVectorFilter
		port map(
			PVF_VECTOR_UNFILTERED	=> current_reg,
			PVF_VECTOR_FILTERED	=> filtered_vector
		);

    process(SYS_CLK, SYS_RST)
        begin  
           if rising_edge(SYS_CLK) then
                if SYS_RST = '1' then -- Reset setzt alles auf 0
                   current_reg <= (others => '0');
                elsif LNA_LOAD_REGLIST = '1' then -- taktsychron überschreiben
                    current_reg <= LNA_REGLIST; 
                else
                    if LNA_HOLD_VALUE = '0' then -- bei 1 Wert halten
                        for i in 0 to 15 loop -- unterste 1 als 0 weitergeben
                            if filtered_vector(i) = '1' then
                                current_reg(i) <= '0';
                                exit; -- fertig
                            end if;
                        end loop;
                    end if;
                end if;
            end if;
    end process;

	LNA_CURRENT_REGLIST_REG <= current_reg; --Output

    process(current_reg)
        begin
            LNA_ADDRESS <= "0000"; --Index des untersten Bits
            for i in 0 to 15 loop -- durchiterieren
                if current_reg(i) = '1' then
                    LNA_ADDRESS <= std_logic_vector(to_unsigned(i, 4)); -- Konvertierung von Index i
                    exit; -- fertig
                end if;
            end loop;
    end process;

end architecture behave;
