library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

library work;
use work.ArmTypes.all;
use work.ArmArithInstructionCtrl;
use work.ArmCoarseInstructionDecoder;

entity ArmArithInstructionCtrl_tb is
end entity;

architecture bench of ArmArithInstructionCtrl_tb is
        signal AIC_DECODED_VECTOR                             : std_logic_vector(15 downto 0);
        signal AIC_INSTRUCTION                                : std_logic_vector(31 downto 0);
        signal AIC_IF_IAR_INC         : std_logic;
        signal AIC_ID_R_PORT_A_ADDR   : std_logic_vector(3 downto 0);
        signal AIC_ID_R_PORT_B_ADDR   : std_logic_vector(3 downto 0);
        signal AIC_ID_R_PORT_C_ADDR   : std_logic_vector(3 downto 0);
        signal AIC_ID_REGS_USED       : std_logic_vector(2 downto 0);
        signal AIC_ID_IMMEDIATE       : std_logic_vector(31 downto 0);
        signal AIC_ID_OPB_MUX_CTRL    : std_logic;
        signal AIC_EX_ALU_CTRL        : std_logic_vector(3 downto 0);
        signal AIC_MEM_RES_REG_EN     : std_logic;
        signal AIC_MEM_CC_REG_EN      : std_logic;
        signal AIC_WB_RES_REG_EN      : std_logic;
        signal AIC_WB_CC_REG_EN       : std_logic;
        signal AIC_WB_W_PORT_A_ADDR   : std_logic_vector(3 downto 0);
        signal AIC_WB_W_PORT_A_EN     : std_logic;
        signal AIC_WB_IAR_MUX_CTRL    : std_logic;
        signal AIC_WB_IAR_LOAD        : std_logic;
        signal AIC_WB_PSR_EN          : std_logic;
        signal AIC_WB_PSR_SET_CC      : std_logic;
        signal AIC_WB_PSR_ER          : std_logic;
        signal AIC_DELAY              : std_logic_vector(1 downto 0);
        signal AIC_ARM_NEXT_STATE     : work.ArmTypes.ARM_STATE_TYPE;

        type INSTR_TESTCASES_CODE_TYPE is array (1 to 28) of string(1 to 25);
        constant INSTR_TESTCASES_CODE  : INSTR_TESTCASES_CODE_TYPE := (
            "add    r0, r1, r2, lsl #2",
            "add    r3, r4, r5, lsl r6",
            "add    r7, r8, #16       ",
            "add    r15, r9, r10      ",
            "sub    r0, r1, r2, lsl #2",
            "sub    r3, r4, r5, lsl r6",
            "sub    r7, r8, #16       ",
            "sub    r15, r9, r10      ",
            "mov    r0, r1, lsl #2    ",
            "mvn    r3, r4, lsl r6    ",
            "orr    r7, r8, #16       ",
            "and    r15, r9, r10      ",
            "adds   r0, r1, r2, lsl #2",
            "adds   r3, r4, r5, lsl r6",
            "adds   r7, r8, #16       ",
            "adds   r15, r9, r10      ",
            "subs   r0, r1, r2, lsl #2",
            "subs   r3, r4, r5, lsl r6",
            "subs   r7, r8, #16       ",
            "subs   pc, lr            ",
            "cmp    r0, r1, lsl #2    ",
            "cmn    r3, r4, lsl r6    ",
            "tst    r7, #16           ",
            "teq    r15, r10          ",
            "cmp    r7, #16           ",
            "cmn    r15, r11          ",
            "tst    r0, r1, lsl #2    ",
            "teq    r3, r4, lsl r6    "
        );

        type INSTR_TESTCASES_TYPE is array (1 to 28) of std_logic_vector(31 downto 0);
        constant INSTR_TESTCASES  : INSTR_TESTCASES_TYPE := (
            x"e0810102", x"e0843615", x"e2887010", x"e089f00a",
            x"e0410102", x"e0443615", x"e2487010", x"e049f00a",
            x"e1a00101", x"e1e03614", x"e3887010", x"e009f00a",
            x"e0910102", x"e0943615", x"e2987010", x"e099f00a",
            x"e0510102", x"e0543615", x"e2587010", x"e05ff00e",
            x"e1500101", x"e1730614", x"e3170010", x"e13f000a",
            x"e3570010", x"e17f000b", x"e1100101", x"e1330614"
        );

        constant AIC_IF_IAR_INC_REF : std_logic_vector(1 to 28) := (
            '1', '1', '1', '0',
            '1', '1', '1', '0',
            '1', '1', '1', '0',
            '1', '1', '1', '0',
            '1', '1', '1', '0',
            '1', '1', '1', '1',
            '1', '1', '1', '1'
        );
        type ADDR_REF_TYPE is array(1 to 28) of std_logic_vector(3 downto 0);
        constant AIC_ID_R_PORT_A_ADDR_REF : ADDR_REF_TYPE := (
            "0001", "0100", "1000", "1001",
            "0001", "0100", "1000", "1001",
            "0000", "0000", "1000", "1001",
            "0001", "0100", "1000", "1001",
            "0001", "0100", "1000", "1111",
            "0000", "0011", "0111", "1111",
            "0111", "1111", "0000", "0011"
        );
        constant AIC_ID_R_PORT_B_ADDR_REF : ADDR_REF_TYPE := (
            "0010", "0101", "0000", "1010",
            "0010", "0101", "0000", "1010",
            "0001", "0100", "0000", "1010",
            "0010", "0101", "0000", "1010",
            "0010", "0101", "0000", "1110",
            "0001", "0100", "0000", "1010",
            "0000", "1011", "0001", "0100"
        );
        constant AIC_ID_R_PORT_C_ADDR_REF : ADDR_REF_TYPE := (
            "0001", "0110", "0000", "0000",
            "0001", "0110", "0000", "0000",
            "0001", "0110", "0000", "0000",
            "0001", "0110", "0000", "0000",
            "0001", "0110", "0000", "0000",
            "0001", "0110", "0000", "0000",
            "0000", "0000", "0001", "0110"
        );
        type REGS_USED_REF_TYPE is array(1 to 28) of std_logic_vector(2 downto 0);
        constant AIC_ID_REGS_USED_REF : REGS_USED_REF_TYPE := (
            "011", "111", "001", "011",
            "011", "111", "001", "011",
            "011", "111", "001", "011",
            "011", "111", "001", "011",
            "011", "111", "001", "011",
            "011", "111", "001", "011",
            "001", "011", "011", "111"
        );
        type IMMEDIATE_REF_TYPE is array(1 to 28) of std_logic_vector(31 downto 0);
        constant AIC_ID_IMMEDIATE_REF : IMMEDIATE_REF_TYPE := (
            x"00000002", x"00000015", x"00000010", x"0000000A",
            x"00000002", x"00000015", x"00000010", x"0000000A",
            x"00000001", x"00000014", x"00000010", x"0000000A",
            x"00000002", x"00000015", x"00000010", x"0000000A",
            x"00000002", x"00000015", x"00000010", x"0000000E",
            x"00000001", x"00000014", x"00000010", x"0000000A",
            x"00000010", x"0000000B", x"00000001", x"00000014"
        );
        constant AIC_ID_OPB_MUX_CTRL_REF : std_logic_vector(1 to 28) := (
            '0', '0', '1', '0',
            '0', '0', '1', '0',
            '0', '0', '1', '0',
            '0', '0', '1', '0',
            '0', '0', '1', '0',
            '0', '0', '1', '0',
            '1', '0', '0', '0'
        );
        type ALU_CTRL_REF_TYPE is array(1 to 28) of std_logic_vector(3 downto 0);
        constant AIC_EX_ALU_CTRL_REF : ALU_CTRL_REF_TYPE := (
            "0100", "0100", "0100", "0100",
            "0010", "0010", "0010", "0010",
            "1101", "1111", "1100", "0000",
            "0100", "0100", "0100", "0100",
            "0010", "0010", "0010", "0010",
            "1010", "1011", "1000", "1001",
            "1010", "1011", "1000", "1001"
        );
        constant AIC_MEM_RES_REG_EN_REF : std_logic_vector(1 to 28) := (
            '1', '1', '1', '1',
            '1', '1', '1', '1',
            '1', '1', '1', '1',
            '1', '1', '1', '1',
            '1', '1', '1', '1',
            '0', '0', '0', '0',
            '0', '0', '0', '0'
        );
        constant AIC_MEM_CC_REG_EN_REF : std_logic_vector(1 to 28) := (
            '0', '0', '0', '0',
            '0', '0', '0', '0',
            '0', '0', '0', '0',
            '1', '1', '1', '0',
            '1', '1', '1', '0',
            '1', '1', '1', '1',
            '1', '1', '1', '1'
        );
        constant AIC_WB_RES_REG_EN_REF : std_logic_vector(1 to 28) := (
            '1', '1', '1', '1',
            '1', '1', '1', '1',
            '1', '1', '1', '1',
            '1', '1', '1', '1',
            '1', '1', '1', '1',
            '0', '0', '0', '0',
            '0', '0', '0', '0'
        );
        constant AIC_WB_CC_REG_EN_REF : std_logic_vector(1 to 28) := (
            '0', '0', '0', '0',
            '0', '0', '0', '0',
            '0', '0', '0', '0',
            '1', '1', '1', '0',
            '1', '1', '1', '0',
            '1', '1', '1', '1',
            '1', '1', '1', '1'
        );
        constant AIC_WB_W_PORT_A_ADDR_REF : ADDR_REF_TYPE := (
            "0000", "0011", "0111", "1111",
            "0000", "0011", "0111", "1111",
            "0000", "0011", "0111", "1111",
            "0000", "0011", "0111", "1111",
            "0000", "0011", "0111", "1111",
            "0000", "0000", "0000", "0000",
            "0000", "0000", "0000", "0000"
        );
        constant AIC_WB_W_PORT_A_EN_REF : std_logic_vector(1 to 28) := (
            '1', '1', '1', '1',
            '1', '1', '1', '1',
            '1', '1', '1', '1',
            '1', '1', '1', '1',
            '1', '1', '1', '1',
            '0', '0', '0', '0',
            '0', '0', '0', '0'
        );
        constant AIC_WB_IAR_MUX_CTRL_REF : std_logic_vector(1 to 28) := (
            '0', '0', '0', '0',
            '0', '0', '0', '0',
            '0', '0', '0', '0',
            '0', '0', '0', '0',
            '0', '0', '0', '0',
            '0', '0', '0', '0',
            '0', '0', '0', '0'
        );
        constant AIC_WB_IAR_LOAD_REF : std_logic_vector(1 to 28) := (
            '0', '0', '0', '1',
            '0', '0', '0', '1',
            '0', '0', '0', '1',
            '0', '0', '0', '1',
            '0', '0', '0', '1',
            '0', '0', '0', '0',
            '0', '0', '0', '0'
        );
        constant AIC_WB_PSR_EN_REF : std_logic_vector(1 to 28) := (
            '0', '0', '0', '0',
            '0', '0', '0', '0',
            '0', '0', '0', '0',
            '1', '1', '1', '1',
            '1', '1', '1', '1',
            '1', '1', '1', '1',
            '1', '1', '1', '1'
        );
        constant AIC_WB_PSR_SET_CC_REF : std_logic_vector(1 to 28) := (
            '0', '0', '0', '0',
            '0', '0', '0', '0',
            '0', '0', '0', '0',
            '1', '1', '1', '0',
            '1', '1', '1', '0',
            '1', '1', '1', '1',
            '1', '1', '1', '1'
        );
        constant AIC_WB_PSR_ER_REF : std_logic_vector(1 to 28) := (
            '0', '0', '0', '0',
            '0', '0', '0', '0',
            '0', '0', '0', '0',
            '0', '0', '0', '1',
            '0', '0', '0', '1',
            '0', '0', '0', '0',
            '0', '0', '0', '0'
        );
        type DELAY_REF_TYPE is array(1 to 28) of std_logic_vector(1 downto 0);
        constant AIC_DELAY_REF : DELAY_REF_TYPE := (
            "00", "00", "00", "10",
            "00", "00", "00", "10",
            "00", "00", "00", "10",
            "00", "00", "00", "10",
            "00", "00", "00", "10",
            "00", "00", "00", "00",
            "00", "00", "00", "00"
        );
        type NEXT_STATE_REF_TYPE is array(1 to 28) of work.ArmTypes.ARM_STATE_TYPE;
        constant AIC_ARM_NEXT_STATE_REF : NEXT_STATE_REF_TYPE := (
            STATE_DECODE, STATE_DECODE, STATE_DECODE, STATE_WAIT_TO_FETCH,
            STATE_DECODE, STATE_DECODE, STATE_DECODE, STATE_WAIT_TO_FETCH,
            STATE_DECODE, STATE_DECODE, STATE_DECODE, STATE_WAIT_TO_FETCH,
            STATE_DECODE, STATE_DECODE, STATE_DECODE, STATE_WAIT_TO_FETCH,
            STATE_DECODE, STATE_DECODE, STATE_DECODE, STATE_WAIT_TO_FETCH,
            STATE_DECODE, STATE_DECODE, STATE_DECODE, STATE_DECODE,
            STATE_DECODE, STATE_DECODE, STATE_DECODE, STATE_DECODE
        );
begin

    uut : entity work.ArmArithInstructionCtrl
    port map (
        AIC_DECODED_VECTOR   => AIC_DECODED_VECTOR,
        AIC_INSTRUCTION      => AIC_INSTRUCTION,
        AIC_IF_IAR_INC       => AIC_IF_IAR_INC,
        AIC_ID_R_PORT_A_ADDR => AIC_ID_R_PORT_A_ADDR,
        AIC_ID_R_PORT_B_ADDR => AIC_ID_R_PORT_B_ADDR,
        AIC_ID_R_PORT_C_ADDR => AIC_ID_R_PORT_C_ADDR,
        AIC_ID_REGS_USED     => AIC_ID_REGS_USED,
        AIC_ID_IMMEDIATE     => AIC_ID_IMMEDIATE,
        AIC_ID_OPB_MUX_CTRL  => AIC_ID_OPB_MUX_CTRL,
        AIC_EX_ALU_CTRL      => AIC_EX_ALU_CTRL,
        AIC_MEM_RES_REG_EN   => AIC_MEM_RES_REG_EN,
        AIC_MEM_CC_REG_EN    => AIC_MEM_CC_REG_EN,
        AIC_WB_RES_REG_EN    => AIC_WB_RES_REG_EN,
        AIC_WB_CC_REG_EN     => AIC_WB_CC_REG_EN,
        AIC_WB_W_PORT_A_ADDR => AIC_WB_W_PORT_A_ADDR,
        AIC_WB_W_PORT_A_EN   => AIC_WB_W_PORT_A_EN,
        AIC_WB_IAR_MUX_CTRL  => AIC_WB_IAR_MUX_CTRL,
        AIC_WB_IAR_LOAD      => AIC_WB_IAR_LOAD,
        AIC_WB_PSR_EN        => AIC_WB_PSR_EN,
        AIC_WB_PSR_SET_CC    => AIC_WB_PSR_SET_CC,
        AIC_WB_PSR_ER        => AIC_WB_PSR_ER,
        AIC_DELAY            => AIC_DELAY,
        AIC_ARM_NEXT_STATE   => AIC_ARM_NEXT_STATE
    );

    decoder : entity work.ArmCoarseInstructionDecoder
    port map (
        CID_INSTRUCTION    => AIC_INSTRUCTION,
        CID_DECODED_VECTOR => AIC_DECODED_VECTOR
    );

    tb : process
        variable l : line;
        variable total_errors    : integer := 0;
        variable testcase_errors : integer := 0;
        variable testcase_error  : boolean := false;
    begin
        for i in INSTR_TESTCASES'range loop
            write(l, string'("------------------- Testcase " & integer'image(i) & " / " & integer'image(INSTR_TESTCASES'length) & ": -------------------"));
            writeline(OUTPUT, l);
            write(l, string'("  Instruktion: " & INSTR_TESTCASES_CODE(i)));
            writeline(OUTPUT, l);
            write(l, string'("  binaer:      "));
            write(l, INSTR_TESTCASES(i));
            writeline(OUTPUT, l);
            write(l, string'("  Zeit:        " & time'image(now)));
            writeline(OUTPUT, l);
            writeline(OUTPUT, l);

            testcase_error := false;

            AIC_INSTRUCTION <= INSTR_TESTCASES(i);
            wait for 10 ns;

            if AIC_IF_IAR_INC        /= AIC_IF_IAR_INC_REF(i)       then write(l, string'("  AIC_IF_IAR_INC      fehlerhaft! Wert: ")); write(l, AIC_IF_IAR_INC); write(l, string'(", erwartet: ")); write(l, AIC_IF_IAR_INC_REF(i)); writeline(OUTPUT, l); testcase_error := true; total_errors := total_errors + 1; end if;
            if AIC_ID_R_PORT_A_ADDR  /= AIC_ID_R_PORT_A_ADDR_REF(i) then write(l, string'("  AIC_ID_R_PORT_A_ADD fehlerhaft! Wert: ")); write(l, AIC_ID_R_PORT_A_ADDR); write(l, string'(", erwartet: ")); write(l, AIC_ID_R_PORT_A_ADDR_REF(i)); writeline(OUTPUT, l); testcase_error := true; total_errors := total_errors + 1; end if;
            if AIC_ID_R_PORT_B_ADDR  /= AIC_ID_R_PORT_B_ADDR_REF(i) then write(l, string'("  AIC_ID_R_PORT_B_ADD fehlerhaft! Wert: ")); write(l, AIC_ID_R_PORT_B_ADDR); write(l, string'(", erwartet: ")); write(l, AIC_ID_R_PORT_B_ADDR_REF(i)); writeline(OUTPUT, l); testcase_error := true; total_errors := total_errors + 1; end if;
            if AIC_ID_R_PORT_C_ADDR  /= AIC_ID_R_PORT_C_ADDR_REF(i) then write(l, string'("  AIC_ID_R_PORT_C_ADD fehlerhaft! Wert: ")); write(l, AIC_ID_R_PORT_C_ADDR); write(l, string'(", erwartet: ")); write(l, AIC_ID_R_PORT_C_ADDR_REF(i)); writeline(OUTPUT, l); testcase_error := true; total_errors := total_errors + 1; end if;
            if AIC_ID_REGS_USED      /= AIC_ID_REGS_USED_REF(i)     then write(l, string'("  AIC_ID_REGS_USED    fehlerhaft! Wert: ")); write(l, AIC_ID_REGS_USED); write(l, string'(", erwartet: ")); write(l, AIC_ID_REGS_USED_REF(i)); writeline(OUTPUT, l); testcase_error := true; total_errors := total_errors + 1; end if;
            if AIC_ID_IMMEDIATE      /= AIC_ID_IMMEDIATE_REF(i)     then write(l, string'("  AIC_ID_IMMEDIATE    fehlerhaft! Wert: ")); hwrite(l, AIC_ID_IMMEDIATE); write(l, string'(", erwartet: ")); hwrite(l, AIC_ID_IMMEDIATE_REF(i)); writeline(OUTPUT, l); testcase_error := true; total_errors := total_errors + 1; end if;
            if AIC_ID_OPB_MUX_CTRL   /= AIC_ID_OPB_MUX_CTRL_REF(i)  then write(l, string'("  AIC_ID_OPB_MUX_CTRL fehlerhaft! Wert: ")); write(l, AIC_ID_OPB_MUX_CTRL); write(l, string'(", erwartet: ")); write(l, AIC_ID_OPB_MUX_CTRL_REF(i)); writeline(OUTPUT, l); testcase_error := true; total_errors := total_errors + 1; end if;
            if AIC_EX_ALU_CTRL       /= AIC_EX_ALU_CTRL_REF(i)      then write(l, string'("  AIC_EX_ALU_CTRL     fehlerhaft! Wert: ")); write(l, AIC_EX_ALU_CTRL); write(l, string'(", erwartet: ")); write(l, AIC_EX_ALU_CTRL_REF(i)); writeline(OUTPUT, l); testcase_error := true; total_errors := total_errors + 1; end if;
            if AIC_MEM_RES_REG_EN    /= AIC_MEM_RES_REG_EN_REF(i)   then write(l, string'("  AIC_MEM_RES_REG_EN  fehlerhaft! Wert: ")); write(l, AIC_MEM_RES_REG_EN); write(l, string'(", erwartet: ")); write(l, AIC_MEM_RES_REG_EN_REF(i)); writeline(OUTPUT, l); testcase_error := true; total_errors := total_errors + 1; end if;
            if AIC_MEM_CC_REG_EN     /= AIC_MEM_CC_REG_EN_REF(i)    then write(l, string'("  AIC_MEM_CC_REG_EN   fehlerhaft! Wert: ")); write(l, AIC_MEM_CC_REG_EN); write(l, string'(", erwartet: ")); write(l, AIC_MEM_CC_REG_EN_REF(i)); writeline(OUTPUT, l); testcase_error := true; total_errors := total_errors + 1; end if;
            if AIC_WB_RES_REG_EN     /= AIC_WB_RES_REG_EN_REF(i)    then write(l, string'("  AIC_WB_RES_REG_EN   fehlerhaft! Wert: ")); write(l, AIC_WB_RES_REG_EN); write(l, string'(", erwartet: ")); write(l, AIC_WB_RES_REG_EN_REF(i)); writeline(OUTPUT, l); testcase_error := true; total_errors := total_errors + 1; end if;
            if AIC_WB_CC_REG_EN      /= AIC_WB_CC_REG_EN_REF(i)     then write(l, string'("  AIC_WB_CC_REG_EN    fehlerhaft! Wert: ")); write(l, AIC_WB_CC_REG_EN); write(l, string'(", erwartet: ")); write(l, AIC_WB_CC_REG_EN_REF(i)); writeline(OUTPUT, l); testcase_error := true; total_errors := total_errors + 1; end if;
            if AIC_WB_W_PORT_A_ADDR  /= AIC_WB_W_PORT_A_ADDR_REF(i) then write(l, string'("  AIC_WB_W_PORT_A_ADD fehlerhaft! Wert: ")); write(l, AIC_WB_W_PORT_A_ADDR); write(l, string'(", erwartet: ")); write(l, AIC_WB_W_PORT_A_ADDR_REF(i)); writeline(OUTPUT, l); testcase_error := true; total_errors := total_errors + 1; end if;
            if AIC_WB_W_PORT_A_EN    /= AIC_WB_W_PORT_A_EN_REF(i)   then write(l, string'("  AIC_WB_W_PORT_A_EN  fehlerhaft! Wert: ")); write(l, AIC_WB_W_PORT_A_EN); write(l, string'(", erwartet: ")); write(l, AIC_WB_W_PORT_A_EN_REF(i)); writeline(OUTPUT, l); testcase_error := true; total_errors := total_errors + 1; end if;
            if AIC_WB_IAR_MUX_CTRL   /= AIC_WB_IAR_MUX_CTRL_REF(i)  then write(l, string'("  AIC_WB_IAR_MUX_CTRL fehlerhaft! Wert: ")); write(l, AIC_WB_IAR_MUX_CTRL); write(l, string'(", erwartet: ")); write(l, AIC_WB_IAR_MUX_CTRL_REF(i)); writeline(OUTPUT, l); testcase_error := true; total_errors := total_errors + 1; end if;
            if AIC_WB_IAR_LOAD       /= AIC_WB_IAR_LOAD_REF(i)      then write(l, string'("  AIC_WB_IAR_LOAD     fehlerhaft! Wert: ")); write(l, AIC_WB_IAR_LOAD); write(l, string'(", erwartet: ")); write(l, AIC_WB_IAR_LOAD_REF(i)); writeline(OUTPUT, l); testcase_error := true; total_errors := total_errors + 1; end if;
            if AIC_WB_PSR_EN         /= AIC_WB_PSR_EN_REF(i)        then write(l, string'("  AIC_WB_PSR_EN       fehlerhaft! Wert: ")); write(l, AIC_WB_PSR_EN); write(l, string'(", erwartet: ")); write(l, AIC_WB_PSR_EN_REF(i)); writeline(OUTPUT, l); testcase_error := true; total_errors := total_errors + 1; end if;
            if AIC_WB_PSR_SET_CC     /= AIC_WB_PSR_SET_CC_REF(i)    then write(l, string'("  AIC_WB_PSR_SET_CC   fehlerhaft! Wert: ")); write(l, AIC_WB_PSR_SET_CC); write(l, string'(", erwartet: ")); write(l, AIC_WB_PSR_SET_CC_REF(i)); writeline(OUTPUT, l); testcase_error := true; total_errors := total_errors + 1; end if;
            if AIC_WB_PSR_ER         /= AIC_WB_PSR_ER_REF(i)        then write(l, string'("  AIC_WB_PSR_ER       fehlerhaft! Wert: ")); write(l, AIC_WB_PSR_ER); write(l, string'(", erwartet: ")); write(l, AIC_WB_PSR_ER_REF(i)); writeline(OUTPUT, l); testcase_error := true; total_errors := total_errors + 1; end if;
            if AIC_DELAY             /= AIC_DELAY_REF(i)            then write(l, string'("  AIC_DELAY           fehlerhaft! Wert: ")); write(l, AIC_DELAY); write(l, string'(", erwartet: ")); write(l, AIC_DELAY_REF(i)); writeline(OUTPUT, l); testcase_error := true; total_errors := total_errors + 1; end if;
            if AIC_ARM_NEXT_STATE    /= AIC_ARM_NEXT_STATE_REF(i)   then write(l, string'("  AIC_ARM_NEXT_STATE  fehlerhaft! Wert: ")); write(l, ARM_STATE_TYPE'image(AIC_ARM_NEXT_STATE)); write(l, string'(", erwartet: ")); write(l, ARM_STATE_TYPE'image(AIC_ARM_NEXT_STATE_REF(i))); writeline(OUTPUT, l); testcase_error := true; total_errors := total_errors + 1; end if;

            writeline(OUTPUT, l);

            if testcase_error then
                testcase_errors := testcase_errors + 1;
            end if;
        end loop;

        write(l, string'("------------------------ Ergebnis: ----------------------"));
        writeline(OUTPUT, l);
        write(l, "Erfolgreiche Testcases: " & integer'image(INSTR_TESTCASES'length - testcase_errors) & " / " & integer'image(INSTR_TESTCASES'length));
        writeline(OUTPUT, l);
        write(l, "Fehlerhafte Signale:    " & integer'image(total_errors));
        writeline(OUTPUT,l);
        writeline(OUTPUT,l);
        report " EOT (END OF TEST) - Diese Fehlermeldung stoppt den Simulator unabhaengig von tatsaechlich aufgetretenen Fehlern!" severity failure;
        wait;
    end process;

end architecture;
