--------------------------------------------------------------------------------
-- 	Teilsteuerung Arithmetisch-logischer Instruktionen im Kontrollpfad
--	des HWPR-Prozessors.
--------------------------------------------------------------------------------
--	Datum:		??.??.2014
--	Version:	?.?
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ArmTypes.all;

entity ArmArithInstructionCtrl is
	port(
		AIC_DECODED_VECTOR	: in std_logic_vector(15 downto 0);
		AIC_INSTRUCTION		: in std_logic_vector(31 downto 0);
		AIC_IF_IAR_INC		: out std_logic;
		AIC_ID_R_PORT_A_ADDR	: out std_logic_vector(3 downto 0);
		AIC_ID_R_PORT_B_ADDR	: out std_logic_vector(3 downto 0);
		AIC_ID_R_PORT_C_ADDR	: out std_logic_vector(3 downto 0);
		AIC_ID_REGS_USED	: out std_logic_vector(2 downto 0);
		AIC_ID_IMMEDIATE	: out std_logic_vector(31 downto 0);	
		AIC_ID_OPB_MUX_CTRL	: out std_logic;
		AIC_EX_ALU_CTRL		: out std_logic_vector(3 downto 0);
		AIC_MEM_RES_REG_EN	: out std_logic;
		AIC_MEM_CC_REG_EN	: out std_logic;
		AIC_WB_RES_REG_EN	: out std_logic;
		AIC_WB_CC_REG_EN	: out std_logic;	
		AIC_WB_W_PORT_A_ADDR	: out std_logic_vector(3 downto 0);
		AIC_WB_W_PORT_A_EN	: out std_logic;	
		AIC_WB_IAR_MUX_CTRL	: out std_logic;
		AIC_WB_IAR_LOAD		: out std_logic;
		AIC_WB_PSR_EN		: out std_logic;
		AIC_WB_PSR_SET_CC	: out std_logic;
		AIC_WB_PSR_ER		: out std_logic;
		AIC_DELAY		: out std_logic_vector(1 downto 0);
--------------------------------------------------------------------------------
--	Verwendung eines Typs aus ArmTypes weil die Codierung der Zustaende 
--	nicht vorgegeben ist.
--------------------------------------------------------------------------------
		AIC_ARM_NEXT_STATE	: out ARM_STATE_TYPE
	    );
end entity ArmArithInstructionCtrl;

architecture behave of ArmArithInstructionCtrl is

begin

process(AIC_DECODED_VECTOR, AIC_INSTRUCTION)
    variable next_state : ARM_STATE_TYPE;
begin
    -- Initialize all outputs to their default values
    AIC_IF_IAR_INC <= '1';
    AIC_ID_R_PORT_A_ADDR <= AIC_INSTRUCTION(19 downto 16);
    AIC_ID_R_PORT_B_ADDR <= AIC_INSTRUCTION(3 downto 0);
    AIC_ID_R_PORT_C_ADDR <= AIC_INSTRUCTION(11 downto 8);
    AIC_WB_W_PORT_A_ADDR <= AIC_INSTRUCTION(15 downto 12);
    AIC_ID_REGS_USED <= (others => '0');
    AIC_ID_IMMEDIATE <= (others => '0');
    AIC_ID_OPB_MUX_CTRL <= '0';
    AIC_EX_ALU_CTRL <= (others => '0');
    AIC_MEM_RES_REG_EN <= '0';
    AIC_MEM_CC_REG_EN <= '0';
    AIC_WB_RES_REG_EN <= '0';
    AIC_WB_CC_REG_EN <= '0';
    AIC_WB_W_PORT_A_EN <= '0';
    AIC_WB_IAR_MUX_CTRL <= '0';
    AIC_WB_IAR_LOAD <= '0';
    AIC_WB_PSR_EN <= '0';
    AIC_WB_PSR_SET_CC <= '0';
    AIC_WB_PSR_ER <= '0';
    AIC_DELAY <= "00";
    AIC_EX_ALU_CTRL <= AIC_INSTRUCTION(24 downto 21);
    next_state := STATE_DECODE;
    


    case AIC_DECODED_VECTOR is
        when CD_ARITH_IMMEDIATE =>
            if(AIC_INSTRUCTION(15 downto 12) = R15) then
                AIC_IF_IAR_INC <= '0';
            end if;
            AIC_ID_REGS_USED(0) <= '1';--Rn is used
            
            AIC_ID_IMMEDIATE(31 downto 8) <= (others => '0');
            AIC_ID_IMMEDIATE(7 downto 0) <= AIC_INSTRUCTION(7 downto 0);
            
            AIC_ID_OPB_MUX_CTRL <= '1';
            AIC_WB_W_PORT_A_EN <= '1';
            AIC_MEM_RES_REG_EN <= '1';
            AIC_WB_RES_REG_EN <= '1';

        when CD_ARITH_REGISTER =>  
            if(AIC_INSTRUCTION(15 downto 12) = R15) then
                AIC_IF_IAR_INC <= '0';
            end if;          
            AIC_ID_REGS_USED(0) <= '1';--Rn is used
            AIC_ID_REGS_USED(1) <= '1';--Rm is used
            
            AIC_ID_IMMEDIATE(7 downto 0) <= AIC_INSTRUCTION(7 downto 0);
            AIC_WB_W_PORT_A_EN <= '1';
            AIC_MEM_RES_REG_EN <= '1';
            AIC_WB_RES_REG_EN <= '1';

        when CD_ARITH_REGISTER_REGISTER =>  
            if(AIC_INSTRUCTION(15 downto 12) = R15) then
                AIC_IF_IAR_INC <= '0';
            end if;       
            AIC_ID_REGS_USED(0) <= '1';--Rn is used
            AIC_ID_REGS_USED(1) <= '1';--Rm is used
            AIC_ID_REGS_USED(2) <= '1';--Rs is used
            
            AIC_ID_IMMEDIATE(7 downto 0) <= AIC_INSTRUCTION(7 downto 0);
            AIC_WB_W_PORT_A_EN <= '1';
            AIC_MEM_RES_REG_EN <= '1';
            AIC_WB_RES_REG_EN <= '1';

        when others =>
            if(AIC_DECODED_VECTOR = CD_BRANCH or AIC_INSTRUCTION(15 downto 12) = R15) then
                AIC_IF_IAR_INC <= '0';
            end if;
    end case;

    --PSR control Signale fÃ¼r TST, TEQ, CMP, CMN
    if AIC_INSTRUCTION(24 downto 21) = "1000" or
        AIC_INSTRUCTION(24 downto 21) = "1001" or
        AIC_INSTRUCTION(24 downto 21) = "1010" or
        AIC_INSTRUCTION(24 downto 21) = "1011" then
        AIC_WB_PSR_EN <= '1';
        AIC_WB_PSR_SET_CC <= '1';
        AIC_MEM_CC_REG_EN <= '1';
        AIC_WB_CC_REG_EN <= '1';
        AIC_MEM_RES_REG_EN <= '0';
        AIC_WB_RES_REG_EN <= '0';
        AIC_WB_W_PORT_A_EN <= '0';
    else
        next_state := STATE_DECODE;

        --Handle S-bit
        if AIC_INSTRUCTION(20) = '1' and AIC_INSTRUCTION(15 downto 12) /= "1111" then
            AIC_WB_PSR_EN <= '1';
            AIC_WB_PSR_SET_CC <= '1';
            AIC_MEM_CC_REG_EN <= '1';
            AIC_WB_CC_REG_EN <= '1';
        end if;
        if AIC_INSTRUCTION(20) = '1' and AIC_INSTRUCTION(15 downto 12) = "1111" then
            AIC_WB_PSR_EN <= '1';
            AIC_WB_PSR_ER <= '1';
            AIC_WB_PSR_SET_CC <= '0';
        end if;

        --Handle Rd
        if AIC_INSTRUCTION(15 downto 12) = "1111" then
            AIC_WB_IAR_LOAD <= '1';
            AIC_WB_IAR_MUX_CTRL <= '0';
            next_state := STATE_WAIT_TO_FETCH;
            AIC_DELAY <= "10";
        end if;
    end if;

    --Handle next_state
    AIC_ARM_NEXT_STATE <= next_state;
end process;
    
end architecture behave;