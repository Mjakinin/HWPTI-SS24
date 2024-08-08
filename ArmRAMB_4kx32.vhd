--------------------------------------------------------------------------------
-- Wrapper um Basys3-Blockram fuer den RAM des HWPR-Prozessors.
--------------------------------------------------------------------------------
-- Datum: 23.05.2022
-- Version: 1.1
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ArmRAMB_4kx32 is
    generic(
        ------------------------------------------------------------------------
        -- SELECT_LINES ist fuer das HWPR irrelevant, wird aber in einer
        -- komplexeren Variante dieses Speichers zur Groessenauswahl
        -- benoetigt. Im Hardwarepraktikum bitte ignorieren und nicht aendern.
        ------------------------------------------------------------------------
        SELECT_LINES : natural range 0 to 2 := 1
    );
    port(
        RAM_CLK : in std_logic;
        ENA     : in std_logic;
        ADDRA   : in std_logic_vector(11 downto 0);
        DOA     : out std_logic_vector(31 downto 0);
        ENB     : in std_logic;
        ADDRB   : in std_logic_vector(11 downto 0);
        DIB     : in std_logic_vector(31 downto 0);
        DOB     : out std_logic_vector(31 downto 0);
        WEB     : in std_logic_vector(3 downto 0)
    );
end entity ArmRAMB_4kx32;

architecture behavioral of ArmRAMB_4kx32 is
    type ram_array is array(0 to 4095) of std_logic_vector(31 downto 0); --ram definieren
    signal ram : ram_array := (others => (others => 'U')); --ram auf undefinded setzen (erwartet der Test)
begin

    process(RAM_CLK)begin --synchron
        if rising_edge(RAM_CLK) then
            if ENA = '1' then
                DOA <= ram(to_integer(unsigned(ADDRA)));  --synchrones Lesen von Port A
            end if;
            
            if ENB = '1' then
                if WEB /= "0000" then
                    -- Byteweises schreiben in den Ram mit der passenden Adresse von Port B
                    if WEB(0) = '1' then
                        ram(to_integer(unsigned(ADDRB)))(7 downto 0) <= DIB(7 downto 0);
                    end if;
                    if WEB(1) = '1' then
                        ram(to_integer(unsigned(ADDRB)))(15 downto 8) <= DIB(15 downto 8);
                    end if;
                    if WEB(2) = '1' then
                        ram(to_integer(unsigned(ADDRB)))(23 downto 16) <= DIB(23 downto 16);
                    end if;
                    if WEB(3) = '1' then
                        ram(to_integer(unsigned(ADDRB)))(31 downto 24) <= DIB(31 downto 24);
                    end if;
                end if;
                DOB <= ram(to_integer(unsigned(ADDRB)));  -- Read-First mode (Port B)
            end if;
        end if;
    end process;

end architecture behavioral;
