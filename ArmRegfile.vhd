------------------------------------------------------------------------------
--	Registerspeichers des ARM-SoC
------------------------------------------------------------------------------
--	Datum:		16.05.2022
--	Version:	0.2
------------------------------------------------------------------------------

library work;
use work.ArmTypes.all;
use work.ArmRegAddressTranslation.all;
use work.ArmConfiguration.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity ArmRegfile is
	Port ( REF_CLK 		: in std_logic;
	       REF_RST 		: in  std_logic;

	       REF_W_PORT_A_ENABLE	: in std_logic;
	       REF_W_PORT_B_ENABLE	: in std_logic;
	       REF_W_PORT_PC_ENABLE	: in std_logic;

	       REF_W_PORT_A_ADDR 	: in std_logic_vector(4 downto 0);
	       REF_W_PORT_B_ADDR 	: in std_logic_vector(4 downto 0);

	       REF_R_PORT_A_ADDR 	: in std_logic_vector(4 downto 0);
	       REF_R_PORT_B_ADDR 	: in std_logic_vector(4 downto 0);
	       REF_R_PORT_C_ADDR 	: in std_logic_vector(4 downto 0);

	       REF_W_PORT_A_DATA 	: in std_logic_vector(31 downto 0);
	       REF_W_PORT_B_DATA 	: in std_logic_vector(31 downto 0);
	       REF_W_PORT_PC_DATA 	: in std_logic_vector(31 downto 0);

	       REF_R_PORT_A_DATA 	: out std_logic_vector(31 downto 0);
	       REF_R_PORT_B_DATA 	: out std_logic_vector(31 downto 0);
	       REF_R_PORT_C_DATA 	: out std_logic_vector(31 downto 0)
       );
end entity ArmRegfile;

architecture behavioral of ArmRegfile is
    signal ram_data_blocka_a: std_logic_vector(31 downto 0);
    signal ram_data_blocka_b: std_logic_vector(31 downto 0);
    signal ram_data_blocka_c: std_logic_vector(31 downto 0);
    signal ram_data_blockb_a: std_logic_vector(31 downto 0);
    signal ram_data_blockb_b: std_logic_vector(31 downto 0);
    signal ram_data_blockb_c: std_logic_vector(31 downto 0);
    signal pc_addr: std_logic_vector(31 downto 0);
    
    type valid_array is array (31 downto 0) of std_logic_vector(1 downto 0);
    signal valid : valid_array;

begin
------------------------------------------------------------------------------
-- Auswahl und Einstellung der Registerspeicher-Implementierung
-- Version 2 des Registerspeichers nutzt Distributed RAM
-- Im HWPTI wird Version 2 implementiert, die ARM_SIM_LIB stellt
-- zu Debugging-Zwecken auch Version 1 zur Verfügung
--------------------------------------------------------------------------------
    REGFILE_VERSION : if USE_REGFILE_V2 generate
        -- Registerspeicher auf Basis von Distributed RAM
        -- Initialisierung der ganzen Ram Blöcke (insgesamt 32, 16 und nochmal 16)
    gen_ram_blocks: for i in 15 downto 0 generate
        u_dist_ram_a: entity work.DistRAM32M
            port map(
                WCLK => REF_CLK,
                ADDRA => REF_R_PORT_A_ADDR,
                ADDRB => REF_R_PORT_B_ADDR,
                ADDRC => REF_R_PORT_C_ADDR,
                ADDRD => REF_W_PORT_A_ADDR,
                DOA => ram_data_blocka_a(2*i+1 downto 2*i),
                DOB => ram_data_blocka_b(2*i+1 downto 2*i),
                DOC => ram_data_blocka_c(2*i+1 downto 2*i),
                DID => REF_W_PORT_A_DATA(2*i+1 downto 2*i),
                WED => REF_W_PORT_A_ENABLE
            );
        u_dist_ram_b: entity work.DistRAM32M
            port map(
                WCLK => REF_CLK,
                ADDRA => REF_R_PORT_A_ADDR,
                ADDRB => REF_R_PORT_B_ADDR,
                ADDRC => REF_R_PORT_C_ADDR,
                ADDRD => REF_W_PORT_B_ADDR,
                DOA => ram_data_blockb_a(2*i+1 downto 2*i),
                DOB => ram_data_blockb_b(2*i+1 downto 2*i),
                DOC => ram_data_blockb_c(2*i+1 downto 2*i),
                DID => REF_W_PORT_B_DATA(2*i+1 downto 2*i),
                WED => REF_W_PORT_B_ENABLE
            );
    end generate gen_ram_blocks;
end generate;
-- Prioritätenauswahl 
-- Lesedaten zuordnen basierend auf dem Validarray
-- Prioritätenauswahl 
REF_R_PORT_A_DATA <= ram_data_blockb_a when valid(to_integer(unsigned(REF_R_PORT_A_ADDR))) = "01" else
                    pc_addr when valid(to_integer(unsigned(REF_R_PORT_A_ADDR))) = "00" else
                    ram_data_blocka_a;

REF_R_PORT_B_DATA <= ram_data_blockb_b when valid(to_integer(unsigned(REF_R_PORT_B_ADDR))) = "01" else
                    pc_addr when valid(to_integer(unsigned(REF_R_PORT_B_ADDR))) = "00" else
                    ram_data_blocka_b;

REF_R_PORT_C_DATA <= ram_data_blockb_c when valid(to_integer(unsigned(REF_R_PORT_C_ADDR))) = "01" else
                    pc_addr when valid(to_integer(unsigned(REF_R_PORT_C_ADDR))) = "00" else
                    ram_data_blocka_c;

process(REF_CLK) -- synchron
begin
    if rising_edge(REF_CLK) then
        if REF_W_PORT_PC_ENABLE = '1' then
            valid(to_integer(unsigned(get_internal_address(R15, SYSTEM, '0')))) <= "00";
            pc_addr <= REF_W_PORT_PC_DATA;
        end if;
        if REF_W_PORT_B_ENABLE = '1' then
            valid(to_integer(unsigned(REF_W_PORT_B_ADDR))) <= "01";
        end if;
        if REF_W_PORT_A_ENABLE = '1' then
            valid(to_integer(unsigned(REF_W_PORT_A_ADDR))) <= "10";
        end if;
    end if;
end process;

end behavioral;