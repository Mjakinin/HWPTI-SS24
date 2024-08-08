--------------------------------------------------------------------------------
--	ALU des ARM-Datenpfades
--------------------------------------------------------------------------------
--	Datum:		??.??.14
--	Version:	?.?
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ArmTypes.all;

entity ArmALU is
    Port (
        ALU_OP1       : in    std_logic_vector(31 downto 0);
        ALU_OP2       : in    std_logic_vector(31 downto 0);           
        ALU_CTRL      : in    std_logic_vector(3 downto 0);
        ALU_CC_IN     : in    std_logic_vector(1 downto 0);
        ALU_RES       : out   std_logic_vector(31 downto 0);
        ALU_CC_OUT    : out   std_logic_vector(3 downto 0)
    );
end entity ArmALU;

architecture behave of ArmALU is

signal result        : std_logic_vector(32 downto 0) := (others => '0');

signal zero_bit      : std_logic := '0';

signal carry_out     : std_logic := '0';

signal overflow_out  : std_logic := '0';

begin

process(ALU_OP1, ALU_OP2, ALU_CTRL, ALU_CC_IN)
    variable op1           : std_logic_vector(32 downto 0) := (others => '0');
    variable op2           : std_logic_vector(32 downto 0) := (others => '0');
    variable add_operation : std_logic := '0';
    variable carry_in      : std_logic_vector(0 downto 0) := (others => '0');
begin
    -- Default values to avoid latches
    
    case ALU_CTRL is
        when OP_AND =>
            result <= '0' & (ALU_OP1 and ALU_OP2);
            add_operation := '0';
            carry_in(0) := '0';
        when OP_EOR =>
            result <= '0' & (ALU_OP1 xor ALU_OP2);
            add_operation := '0';
            carry_in(0) := '0';
        when OP_SUB =>
            op1 := std_logic_vector(unsigned('0' & ALU_OP1));
            op2 := std_logic_vector(unsigned('0' & not(ALU_OP2)) + 1);
            add_operation := '1';
            carry_in(0) := '0';
        when OP_RSB =>
            op1 := std_logic_vector(unsigned('0' & not(ALU_OP1)) + 1);
            op2 := std_logic_vector(unsigned('0' & ALU_OP2));
            add_operation := '1';
            carry_in(0) := '0';
        when OP_ADD =>
            op1 := std_logic_vector(unsigned('0' & ALU_OP1));
            op2 := std_logic_vector(unsigned('0' & ALU_OP2));
            add_operation := '1';
            carry_in(0) := '0';
        when OP_ADC =>
            carry_in(0) := ALU_CC_IN(1);
            op1 := std_logic_vector(unsigned('0' & ALU_OP1));
            op2 := std_logic_vector(unsigned('0' & ALU_OP2));
            add_operation := '1';
        when OP_SBC =>
            carry_in(0) := ALU_CC_IN(1);
            op1 := std_logic_vector(unsigned('0' & ALU_OP1));
            op2 := std_logic_vector(unsigned('0' & not(ALU_OP2)));
            add_operation := '1';
        when OP_RSC =>
            carry_in(0) := ALU_CC_IN(1);
            op1 := std_logic_vector(unsigned('0' & not(ALU_OP1)));
            op2 := std_logic_vector(unsigned('0' & ALU_OP2));
            add_operation := '1';
        when OP_TST =>
            result <= '0' & (ALU_OP1 and ALU_OP2);
            add_operation := '0';
            carry_in(0) := '0';
        when OP_TEQ =>
            result <= '0' & (ALU_OP1 xor ALU_OP2);
            add_operation := '0';
            carry_in(0) := '0';
        when OP_CMP =>
            op1 := std_logic_vector(unsigned('0' & ALU_OP1));
            op2 := std_logic_vector(unsigned('0' & not(ALU_OP2)) + 1);
            add_operation := '1';
            carry_in(0) := '0';
        when OP_CMN =>
            op1 := std_logic_vector(unsigned('0' & ALU_OP1));
            op2 := std_logic_vector(unsigned('0' & ALU_OP2));
            add_operation := '1';
            carry_in(0) := '0';
        when OP_ORR =>
            result <= '0' & (ALU_OP1 or ALU_OP2);
            add_operation := '0';
            carry_in(0) := '0';
        when OP_MOV =>
            result <= '0' & ALU_OP2;
            add_operation := '0';
            carry_in(0) := '0';
        when OP_BIC =>
            result <= '0' & (ALU_OP1 and not(ALU_OP2));
            add_operation := '0';
            carry_in(0) := '0';
        when OP_MVN =>
            result <= '0' & not(ALU_OP2);
            add_operation := '0';
            carry_in(0) := '0';
        when others =>
            result <= (others => '0');
    end case;

    if add_operation = '1' then 
        result <= std_logic_vector(unsigned(op1) + unsigned(op2) + unsigned(carry_in));
    end if;
end process;


-- Overflow bit determination outside the process
overflow_out <= (not ALU_OP1(31) and ALU_OP2(31) and result(31)) or ((ALU_OP1(31)) and not ALU_OP2(31) and not result(31)) when ALU_CTRL = OP_SUB else
                (ALU_OP1(31) and not ALU_OP2(31) and result(31)) or (not(ALU_OP1(31)) and ALU_OP2(31) and not result(31)) when ALU_CTRL = OP_RSB else
                (not(ALU_OP1(31)) and not(ALU_OP2(31)) and result(31)) or (ALU_OP1(31) and ALU_OP2(31) and not result(31)) when ALU_CTRL = OP_ADD or ALU_CTRL = OP_ADC or ALU_CTRL = OP_CMN else
                (ALU_OP1(31) and not(ALU_OP2(31)) and not(result(31))) or (not(ALU_OP1(31)) and ALU_OP2(31) and result(31)) when ALU_CTRL = OP_SBC or ALU_CTRL = OP_RSC or ALU_CTRL = OP_CMP else
                ALU_CC_IN(0);

ALU_RES <= result(31 downto 0);
zero_bit <= '1' when unsigned(result(31 downto 0)) = 0 else '0';
carry_out <= result(32) when ALU_CTRL = OP_SUB or ALU_CTRL = OP_RSB or ALU_CTRL = OP_ADD or ALU_CTRL = OP_ADC or ALU_CTRL = OP_SBC or ALU_CTRL = OP_RSC or ALU_CTRL = OP_CMP or ALU_CTRL = OP_CMN else ALU_CC_IN(1);

ALU_CC_OUT(3) <= result(31); -- N: Negative flag
ALU_CC_OUT(2) <= zero_bit; -- Z: Zero flag
ALU_CC_OUT(1) <= carry_out; -- C: Carry flag
ALU_CC_OUT(0) <= overflow_out; -- V: Overflow flag

end architecture behave;