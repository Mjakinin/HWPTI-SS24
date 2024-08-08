library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ArmMultiplier_tb is
end ArmMultiplier_tb;

architecture Behavioral of ArmMultiplier_tb is
    -- Component declaration for the Unit Under Test (UUT)
    component ArmMultiplier
        Port (
            MUL_OP1 : in  STD_LOGIC_VECTOR (31 downto 0);  -- Rm
            MUL_OP2 : in  STD_LOGIC_VECTOR (31 downto 0);  -- Rs
            MUL_RES : out STD_LOGIC_VECTOR (31 downto 0)   -- Rd bzw. RdLo
        );
    end component;

    -- Signals for connecting to the UUT
    signal tb_MUL_OP1 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal tb_MUL_OP2 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal tb_MUL_RES : STD_LOGIC_VECTOR(31 downto 0);

    -- Clock für Testbench
    signal clk : STD_LOGIC := '0';
    
    -- Test vectors and expected result
    type test_vector_array is array (natural range <>) of std_logic_vector(31 downto 0);

constant test_vectors : test_vector_array := (
    -- Normale positive Zahlen
    x"00000003", x"00000002", x"00000006",   -- 3 * 2 = 6
    x"0000000A", x"0000000F", x"00000096",   -- 10 * 15 = 150
    x"0000FFFF", x"00000002", x"0001FFFE",  -- 65535 * 2 = 131070

    -- Negative Zahlen
    x"FFFFFFF5", x"00000003", x"FFFFFFDF",   -- -11 * 3 = -33
    x"FFFFFFF0", x"FFFFFFF1", x"000000F0",   -- -16 * -15 = 240
    x"80000000", x"00000002", x"00000000",   -- -2147483648 * 2 = 0 (overflow in 32-bit signed integer)
    
    -- Null
    x"00000000", x"0000000A", x"00000000",   -- 0 * 10 = 0
    x"0000000A", x"00000000", x"00000000"    -- 10 * 0 = 0
);
    constant num_tests : natural := test_vectors'length/3;  -- Number of test cases

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: ArmMultiplier
        Port map (
            MUL_OP1 => tb_MUL_OP1,
            MUL_OP2 => tb_MUL_OP2,
            MUL_RES => tb_MUL_RES
        );

    -- Clock generation process
    clk_process : process
    begin
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
    end process;

    -- Test process
    stim_proc: process
        begin
        for i in 0 to num_tests - 1 loop
            tb_MUL_OP1 <= test_vectors(i * 3);
            tb_MUL_OP2 <= test_vectors(i * 3 + 1);
            wait for 10 ns; -- Wait for one clock cycle
    
            if tb_MUL_RES /= test_vectors(i * 3 + 2) then
                report "Test failed for input" severity error;
            else
                report "Tests passed!" severity note;
            end if;
        end loop;
    
        -- End simulation after all tests are completed
        report "Simulation finished" severity note;
        wait;
     end process stim_proc;
end Behavioral;
