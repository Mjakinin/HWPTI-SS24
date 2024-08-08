--------------------------------------------------------------------------------
-- Schaltung fuer das Zaehlen von Einsen in einem 16-Bit-Vektor, realisiert
-- als Baum von Addierern.
--------------------------------------------------------------------------------
-- Datum:     ??.??.2013
-- Version:   ?.??
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ArmRegisterBitAdder is
    Port (
        RBA_REGLIST    : in  std_logic_vector(15 downto 0);
        RBA_NR_OF_REGS : out std_logic_vector(4 downto 0)
    );
end entity ArmRegisterBitAdder;

architecture behavioral of ArmRegisterBitAdder is
    -- Intermediate signals for adder stages
    signal stage1_out1 : std_logic_vector(1 downto 0);
    signal stage1_out2 : std_logic_vector(1 downto 0);
    signal stage1_out3 : std_logic_vector(1 downto 0);
    signal stage1_out4 : std_logic_vector(1 downto 0);
    signal stage1_out5 : std_logic_vector(1 downto 0);
    signal stage1_out6 : std_logic_vector(1 downto 0);
    signal stage1_out7 : std_logic_vector(1 downto 0);
    signal stage1_out8 : std_logic_vector(1 downto 0);

    signal stage2_out1   : integer range 0 to 7;
    signal stage2_out2   : integer range 0 to 7;
    signal stage2_out3   : integer range 0 to 7;
    signal stage2_out4   : integer range 0 to 7;

    signal stage3_out1   : integer range 0 to 15;
    signal stage3_out2   : integer range 0 to 15;

    signal stage4_out1   : integer range 0 to 31;
begin
    -- Erste Stufe: ZÃ¤hlen der Bits in 2-Bit-Gruppen
    first_level_adder1: process(RBA_REGLIST)
    begin
        stage1_out1 <= ("" & (RBA_REGLIST(0) and RBA_REGLIST(1))) & ("" & (RBA_REGLIST(0) xor RBA_REGLIST(1)));
        stage1_out2 <= ("" & (RBA_REGLIST(2) and RBA_REGLIST(3))) & ("" & (RBA_REGLIST(2) xor RBA_REGLIST(3)));
        stage1_out3 <= ("" & (RBA_REGLIST(4) and RBA_REGLIST(5))) & ("" & (RBA_REGLIST(4) xor RBA_REGLIST(5)));
        stage1_out4 <= ("" & (RBA_REGLIST(6) and RBA_REGLIST(7))) & ("" & (RBA_REGLIST(6) xor RBA_REGLIST(7)));
        stage1_out5 <= ("" & (RBA_REGLIST(8) and RBA_REGLIST(9))) & ("" & (RBA_REGLIST(8) xor RBA_REGLIST(9)));
        stage1_out6 <= ("" & (RBA_REGLIST(10) and RBA_REGLIST(11))) & ("" & (RBA_REGLIST(10) xor RBA_REGLIST(11)));
        stage1_out7 <= ("" & (RBA_REGLIST(12) and RBA_REGLIST(13))) & ("" & (RBA_REGLIST(12) xor RBA_REGLIST(13)));
        stage1_out8 <= ("" & (RBA_REGLIST(14) and RBA_REGLIST(15))) & ("" & (RBA_REGLIST(14) xor RBA_REGLIST(15)));
    end process first_level_adder1;

    -- Zweite Stufe: ZÃ¤hlen der Bits in 4-Bit-Gruppen
    second_level_adder1: process(stage1_out1, stage1_out2, stage1_out3, stage1_out4, stage1_out5, stage1_out6, stage1_out7, stage1_out8)
    begin
        stage2_out1 <= to_integer(unsigned(stage1_out1)) + to_integer(unsigned(stage1_out2));
        stage2_out2 <= to_integer(unsigned(stage1_out3)) + to_integer(unsigned(stage1_out4));
        stage2_out3 <= to_integer(unsigned(stage1_out5)) + to_integer(unsigned(stage1_out6));
        stage2_out4 <= to_integer(unsigned(stage1_out7)) + to_integer(unsigned(stage1_out8));
    end process second_level_adder1;

    -- Dritte Stufe: ZÃ¤hlen der Bits in 8-Bit-Gruppen
    third_level_adder1: process(stage2_out1, stage2_out2, stage2_out3, stage2_out4)
    begin
        stage3_out1 <= stage2_out1 + stage2_out2;
        stage3_out2 <= stage2_out3 + stage2_out4;
    end process third_level_adder1;
    -- Vierte Stufe: ZÃ¤hlen der Bits in 16-Bit-Gruppen
    last_level_adder1: process(stage3_out1, stage3_out2)
    begin
        stage4_out1 <= stage3_out1 + stage3_out2;
    end process last_level_adder1;

    -- Ergebnis zuweisen
    RBA_NR_OF_REGS <= std_logic_vector(to_unsigned(stage4_out1, 5));
end architecture behavioral;