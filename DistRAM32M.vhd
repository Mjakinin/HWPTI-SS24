------------------------------------------------------------------------------
--	Xilinx Artix-7 Distributed RAM Primitive RAM32M
------------------------------------------------------------------------------
--	Datum:		16.05.2022
--	Version:	0.1
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity DistRAM32M is
  port (
	WCLK : in std_logic;
	ADDRA : in std_logic_vector(4 downto 0);
	ADDRB : in std_logic_vector(4 downto 0);
	ADDRC : in std_logic_vector(4 downto 0);
	ADDRD : in std_logic_vector(4 downto 0);
	DID : in std_logic_vector(1 downto 0);
	DOA : out std_logic_vector(1 downto 0);
	DOB : out std_logic_vector(1 downto 0);
	DOC : out std_logic_vector(1 downto 0);
	DOD : out std_logic_vector(1 downto 0);
	WED : in std_logic
  );
end entity;

architecture rtl of DistRAM32M is
type ram_type is array (0 to 31) of std_logic_vector(1 downto 0);
signal ram : ram_type;
begin

process(WCLK) begin
if rising_edge(WCLK) then
    if WED = '1' then
    ram(to_integer(unsigned(ADDRD))) <= DID;
    end if;
end if;
end process;
DOA <= ram(to_integer(unsigned(ADDRA)));
DOB <= ram(to_integer(unsigned(ADDRB)));
DOC <= ram(to_integer(unsigned(ADDRC)));
DOD <= ram(to_integer(unsigned(ADDRD)));
end architecture;
