library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ArmBarrelShifter4Bit_tb is
end entity ArmBarrelShifter4Bit_tb;

architecture Behavioral of ArmBarrelShifter4Bit_tb is

    signal OPERAND     : std_logic_vector(3 downto 0);
    signal MUX_CTRL    : std_logic_vector(1 downto 0);
    signal AMOUNT      : std_logic_vector(1 downto 0);
    signal ARITH_SHIFT : std_logic;
    signal C_IN        : std_logic;
    signal DATA_OUT    : std_logic_vector(3 downto 0);
    signal C_OUT       : std_logic;

    signal expected_DATA_OUT : std_logic_vector(3 downto 0);
    signal expected_C_OUT    : std_logic;
    

    component ArmBarrelShifter
        generic (OPERAND_WIDTH : integer := 4;
                 SHIFTER_DEPTH : integer := 2);
        port ( OPERAND    : in  std_logic_vector(OPERAND_WIDTH-1 downto 0);
               MUX_CTRL   : in  std_logic_vector(1 downto 0);
               AMOUNT     : in  std_logic_vector(SHIFTER_DEPTH-1 downto 0);
               ARITH_SHIFT: in  std_logic;
               C_IN       : in  std_logic;
               DATA_OUT   : out std_logic_vector(OPERAND_WIDTH-1 downto 0);
               C_OUT      : out std_logic);
    end component;
    

begin

    uut: ArmBarrelShifter
        port map (
            OPERAND    => OPERAND,
            MUX_CTRL   => MUX_CTRL,
            AMOUNT     => AMOUNT,
            ARITH_SHIFT=> ARITH_SHIFT,
            C_IN       => C_IN,
            DATA_OUT   => DATA_OUT,
            C_OUT      => C_OUT
        );

process
    begin
        --Kein Shift
        OPERAND <= "1001"; MUX_CTRL <= "00"; AMOUNT <= "00"; ARITH_SHIFT <= '0'; C_IN <= '0';
        expected_DATA_OUT <= "1001"; expected_C_OUT <= '0';
        wait for 10 ns;
        if (DATA_OUT /= expected_DATA_OUT) then
            report "Kein Shift: DATA_OUT ist falsch" severity error;
        end if;
        if (C_OUT /= expected_C_OUT) then
            report "Kein Shift: C_OUT ist falsch" severity error;
        end if;
        assert (DATA_OUT = expected_DATA_OUT and C_OUT = expected_C_OUT)
        report "Kein Shift fehlgeschlagen" severity error;


        --Linksshift
        OPERAND <= "1001"; MUX_CTRL <= "01"; AMOUNT <= "01"; ARITH_SHIFT <= '0'; C_IN <= '0';
        expected_DATA_OUT <= "0010"; expected_C_OUT <= '1';
        wait for 10 ns;
        if (DATA_OUT /= expected_DATA_OUT) then
            report "Linksshift: DATA_OUT ist falsch" severity error;
        end if;
        if (C_OUT /= expected_C_OUT) then
            report "Linksshift: C_OUT ist falsch" severity error;
        end if;
        assert (DATA_OUT = expected_DATA_OUT and C_OUT = expected_C_OUT)
        report "Linksshift fehlgeschlagen" severity error;


        --Rechtsshift (logical)
        OPERAND <= "1001"; MUX_CTRL <= "10"; AMOUNT <= "01"; ARITH_SHIFT <= '0'; C_IN <= '0';
        expected_DATA_OUT <= "0100"; expected_C_OUT <= '1';
        wait for 10 ns;
        if (DATA_OUT /= expected_DATA_OUT) then
            report "Rechtsshift (logical): DATA_OUT ist falsch" severity error;
        end if;
        if (C_OUT /= expected_C_OUT) then
            report "Rechtsshift (logical): C_OUT ist falsch" severity error;
        end if;
        assert (DATA_OUT = expected_DATA_OUT and C_OUT = expected_C_OUT)
        report "Rechtsshift (logical) fehlgeschlagen" severity error;


        --Rechtsshift (arithmetic)
        OPERAND <= "1001"; MUX_CTRL <= "10"; AMOUNT <= "01"; ARITH_SHIFT <= '1'; C_IN <= '0';
        expected_DATA_OUT <= "1100"; expected_C_OUT <= '1';
        wait for 10 ns;
        if (DATA_OUT /= expected_DATA_OUT) then
            report "Rechtsshift (arithmetic): DATA_OUT ist falsch" severity error;
        end if;
        if (C_OUT /= expected_C_OUT) then
            report "Rechtsshift (arithmetic): C_OUT ist falsch" severity error;
        end if;
        assert (DATA_OUT = expected_DATA_OUT and C_OUT = expected_C_OUT)
        report "Rechtsshift (arithmetic) fehlgeschlagen" severity error;


        --Rechtsrotation
        OPERAND <= "1001"; MUX_CTRL <= "11"; AMOUNT <= "01"; ARITH_SHIFT <= '0'; C_IN <= '0';
        expected_DATA_OUT <= "1100"; expected_C_OUT <= '1';
        wait for 10 ns;
        if(DATA_OUT /= expected_DATA_OUT) then
            report "Rechtsrotation: DATA_OUT ist falsch" severity error;
        end if;
        if (C_OUT /= expected_C_OUT) then
            report "Rechtsrotation: C_OUT ist falsch" severity error;
        end if;
        assert (DATA_OUT = expected_DATA_OUT and C_OUT = expected_C_OUT)
        report "Rechtsrotation fehlgeschlagen" severity error;
        
        
        --2x Linksshift
        OPERAND <= "1001"; MUX_CTRL <= "01"; AMOUNT <= "10"; ARITH_SHIFT <= '0'; C_IN <= '0';
        expected_DATA_OUT <= "0100"; expected_C_OUT <= '0';
        wait for 10 ns;
        if (DATA_OUT /= expected_DATA_OUT) then
            report "2x Linksshift: DATA_OUT ist falsch" severity error;
        end if;
        if (C_OUT /= expected_C_OUT) then
            report "2x Linksshift: C_OUT ist falsch" severity error;
        end if;
        assert (DATA_OUT = expected_DATA_OUT and C_OUT = expected_C_OUT)
        report "2x Linksshift fehlgeschlagen" severity error;


        --2x Rechtsshift (logical)
        OPERAND <= "1001"; MUX_CTRL <= "10"; AMOUNT <= "10"; ARITH_SHIFT <= '0'; C_IN <= '1';
        expected_DATA_OUT <= "0010"; expected_C_OUT <= '0';
        wait for 10 ns;
        if (DATA_OUT /= expected_DATA_OUT) then
            report "2x Rechtsshift (logical): DATA_OUT ist falsch" severity error;
        end if;
        if (C_OUT /= expected_C_OUT) then
            report "2x Rechtsshift (logical): C_OUT ist falsch" severity error;
        end if;
        assert (DATA_OUT = expected_DATA_OUT and C_OUT = expected_C_OUT)
        report "2x Rechtsshift (logical) fehlgeschlagen" severity error;


        --2x Rechtsshift (arithmetic)
        OPERAND <= "1001"; MUX_CTRL <= "10"; AMOUNT <= "10"; ARITH_SHIFT <= '1'; C_IN <= '0';
        expected_DATA_OUT <= "1110"; expected_C_OUT <= '0';
        wait for 10 ns;
        if (DATA_OUT /= expected_DATA_OUT) then
            report "2x Rechtsshift (arithmetic): DATA_OUT ist falsch" severity error;
        end if;
        if (C_OUT /= expected_C_OUT) then
            report "2x Rechtsshift (arithmetic): C_OUT ist falsch" severity error;
        end if;
        assert (DATA_OUT = expected_DATA_OUT and C_OUT = expected_C_OUT)
        report "2x Rechtsshift (arithmetic) fehlgeschlagen" severity error;


        --2x Rechtsrotation
        OPERAND <= "1001"; MUX_CTRL <= "11"; AMOUNT <= "10"; ARITH_SHIFT <= '0'; C_IN <= '0';
        expected_DATA_OUT <= "0110"; expected_C_OUT <= '0';
        wait for 10 ns;
        if (DATA_OUT /= expected_DATA_OUT) then
            report "2x Rechtsrotation: DATA_OUT ist falsch" severity error;
        end if;
        if (C_OUT /= expected_C_OUT) then
            report "2x Rechtsrotation: C_OUT ist falsch" severity error;
        end if;
        assert (DATA_OUT = expected_DATA_OUT and C_OUT = expected_C_OUT)
        report "2x Rechtsrotation fehlgeschlagen" severity error;


        --3x Linksshift
        OPERAND <= "1001"; MUX_CTRL <= "01"; AMOUNT <= "11"; ARITH_SHIFT <= '0'; C_IN <= '0';
        expected_DATA_OUT <= "1000"; expected_C_OUT <= '0';
        wait for 10 ns;
        if (DATA_OUT /= expected_DATA_OUT) then
            report "3x Linksshift: DATA_OUT ist falsch" severity error;
        end if;
        if (C_OUT /= expected_C_OUT) then
            report "3x Linksshift: C_OUT ist falsch" severity error;
        end if;
        assert (DATA_OUT = expected_DATA_OUT and C_OUT = expected_C_OUT)
        report "3x Linksshift fehlgeschlagen" severity error;


        --3x Rechtsshift (logical)
        OPERAND <= "1001"; MUX_CTRL <= "10"; AMOUNT <= "11"; ARITH_SHIFT <= '0'; C_IN <= '0';
        expected_DATA_OUT <= "0001"; expected_C_OUT <= '0';
        wait for 10 ns;
        if (DATA_OUT /= expected_DATA_OUT) then
            report "3x Rechtsshift (logical): DATA_OUT ist falsch" severity error;
        end if;
        if (C_OUT /= expected_C_OUT) then
            report "3x Rechtsshift (logical): C_OUT ist falsch" severity error;
        end if;
        assert (DATA_OUT = expected_DATA_OUT and C_OUT = expected_C_OUT)
        report "3x Rechtsshift (logical) fehlgeschlagen" severity error;


        --3x Rechtsshift (arithmetic)
        OPERAND <= "1001"; MUX_CTRL <= "10"; AMOUNT <= "11"; ARITH_SHIFT <= '1'; C_IN <= '0';
        expected_DATA_OUT <= "1111"; expected_C_OUT <= '0';
        wait for 10 ns;
        if (DATA_OUT /= expected_DATA_OUT) then
            report "3x Rechtsshift (arithmetic): DATA_OUT ist falsch" severity error;
        end if;
        if (C_OUT /= expected_C_OUT) then
            report "3x Rechtsshift (arithmetic): C_OUT ist falsch" severity error;
        end if;
        assert (DATA_OUT = expected_DATA_OUT and C_OUT = expected_C_OUT)
        report "3x Rechtsshift (arithmetic) fehlgeschlagen" severity error;


        --3x Rechtsrotation
        OPERAND <= "1001"; MUX_CTRL <= "11"; AMOUNT <= "11"; ARITH_SHIFT <= '0'; C_IN <= '0';
        expected_DATA_OUT <= "0011"; expected_C_OUT <= '0';
        wait for 10 ns;
        if(DATA_OUT /= expected_DATA_OUT) then
            report "3x Rechtsrotation: DATA_OUT ist falsch" severity error;
        end if;
        if (C_OUT /= expected_C_OUT) then
            report "3x Rechtsrotation: C_OUT ist falsch" severity error;
        end if;
        assert (DATA_OUT = expected_DATA_OUT and C_OUT = expected_C_OUT)
        report "3x Rechtsrotation fehlgeschlagen" severity error;
        
        
        
        report "Alle Tests durchgeführt" severity note;
        wait;
    end process;
end Behavioral;
