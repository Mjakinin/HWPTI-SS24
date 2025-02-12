--------------------------------------------------------------------------------
-- Decoder zur Ermittlung der Instruktionsgruppe der aktuellen
-- Instruktion im der ID-Stufe im Kontrollpfad des HWPR-Prozessors.
--------------------------------------------------------------------------------
-- Datum: ?? ?? 2014
-- Version: ?.?
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ArmTypes.all;

--------------------------------------------------------------------------------
-- 17 Instruktionsgruppen:
-- CD_UNDEFINED
-- CD_SWI
-- CD_COPROCESSOR
-- CD_BRANCH
-- CD_LOAD_STORE_MULTIPLE
-- CD_LOAD_STORE_UNSIGNED_IMMEDIATE
-- CD_LOAD_STORE_UNSIGNED_REGISTER
-- CD_LOAD_STORE_SIGNED_IMMEDIATE
-- CD_LOAD_STORE_UNSIGNED_REGISTER
-- CD_ARITH_IMMEDIATE
-- CD_ARITH_REGISTER
-- CD_ARITH_REGISTER_REGISTER
-- CD_MSR_IMMEDIATE
-- CD_MSR_REGISTER
-- CD_MRS
-- CD_MULTIPLY
-- CD_SWAP

-- UNDEFINED wird durch den Nullvektor angezeigt, die anderen
-- Befehlsgruppen durch einen 1-aus-16-Code.
--------------------------------------------------------------------------------

entity ArmCoarseInstructionDecoder is
    port(
        CID_INSTRUCTION : in std_logic_vector(31 downto 0);
        CID_DECODED_VECTOR : out std_logic_vector(15 downto 0)
    );
end entity ArmCoarseInstructionDecoder;

architecture behave of ArmCoarseInstructionDecoder is
    signal DECV : COARSE_DECODE_TYPE;
    signal CIB_74 : std_logic_vector(1 downto 0); --7 und 4
    signal CIB_206 : std_logic_vector(1 downto 0); --20 und 6
    signal CIB_232120 : std_logic_vector(2 downto 0); --23, 21 und 20
begin
    CIB_74 <= CID_INSTRUCTION(7) & CID_INSTRUCTION(4);
    CIB_206 <= CID_INSTRUCTION(20) & CID_INSTRUCTION(6);
    CIB_232120  <= CID_INSTRUCTION(23) & CID_INSTRUCTION(21 downto 20);

    CID_DECODED_VECTOR <= DECV;

    process(CID_INSTRUCTION,CIB_74,CIB_206,CIB_232120) begin
        case CID_INSTRUCTION(27 downto 25) is
            when "111" =>
                if CID_INSTRUCTION(24) = '1' then
                    DECV <= CD_SWI;
                elsif CID_INSTRUCTION(24) = '0' then
                    DECV <= CD_COPROCESSOR;
                end if;
            when "110" =>
                DECV <= CD_COPROCESSOR;
            when "101" =>
                DECV <= CD_BRANCH;
            when "100" =>
                DECV <= CD_LOAD_STORE_MULTIPLE;
            when "011" =>
                if CID_INSTRUCTION(4) = '1' then
                    DECV <= CD_UNDEFINED;
                elsif CID_INSTRUCTION(4) = '0' then 
                    DECV <= CD_LOAD_STORE_UNSIGNED_REGISTER;
                end if;
            when "010" =>
                DECV <= CD_LOAD_STORE_UNSIGNED_IMMEDIATE;
            when "001" =>
                case CID_INSTRUCTION(24 downto 23) is
                    when "10" =>
                        case CID_INSTRUCTION(21 downto 20) is
                            when "10" =>
                                DECV <= CD_MSR_IMMEDIATE;
                            when "00" =>
                                DECV <= CD_UNDEFINED;
                            when others =>
                                DECV <= CD_ARITH_IMMEDIATE;
                        end case;
                    when others =>
                        DECV <= CD_ARITH_IMMEDIATE;
                end case;
            when "000" =>
                case CIB_74 is
                    when "11" =>
                        case CID_INSTRUCTION(6 downto 5) is
                            when "00" =>
                                if CID_INSTRUCTION(24) = '0' then
                                    DECV <= CD_MULTIPLY;
                                elsif CID_INSTRUCTION(24)= '1' then
                                    case CIB_232120 is
                                        when "000" =>
                                            DECV <= CD_SWAP;
                                        when others =>
                                            DECV <= CD_UNDEFINED;
                                    end case;
                                end if;
                            when others =>
                                case CIB_206 is
                                    when "01" =>
                                        DECV <= CD_UNDEFINED;
                                    when others =>
                                        if CID_INSTRUCTION(22) = '1' then
                                            DECV <= CD_LOAD_STORE_SIGNED_IMMEDIATE;
                                        elsif CID_INSTRUCTION(22) = '0' then
                                            DECV <= CD_LOAD_STORE_SIGNED_REGISTER;
                                        end if;
                                end case;
                        end case;
                    when "10" =>
                        case CID_INSTRUCTION(24 downto 23) is
                            when "10" =>
                                if CID_INSTRUCTION(20) = '1' then
                                    DECV <= CD_ARITH_REGISTER;
                                elsif CID_INSTRUCTION(20) = '0' then
                                    DECV <= CD_UNDEFINED;
                                end if;
                            when others =>
                                DECV <= CD_ARITH_REGISTER;
                        end case;
                    when "01" =>
                        case CID_INSTRUCTION(24 downto 23) is
                            when "10" =>
                                if CID_INSTRUCTION(20) = '1' then
                                    DECV <= CD_ARITH_REGISTER_REGISTER;
                                elsif CID_INSTRUCTION(20) = '0' then
                                    DECV <= CD_UNDEFINED;
                                end if;
                            when others =>
                                DECV <= CD_ARITH_REGISTER_REGISTER;
                        end case;
                    when "00" =>
                        case CID_INSTRUCTION(24 downto 23) is
                            when "10" =>
                                if CID_INSTRUCTION(20) = '1' then
                                    DECV <= CD_ARITH_REGISTER;
                                elsif CID_INSTRUCTION(20) = '0' then
                                    if CID_INSTRUCTION(21) = '1' then
                                        DECV <= CD_MSR_REGISTER;
                                    elsif CID_INSTRUCTION(21) = '0' then
                                        DECV <= CD_MRS;
                                    end if;
                                end if;
                            when others =>
                                DECV <= CD_ARITH_REGISTER;
                        end case;
                    when others =>
                        DECV <= CD_UNDEFINED;
                end case;
            when others =>
                DECV <= CD_UNDEFINED;
        end case;
    end process;

--------------------------------------------------------------------------------
-- Test fuer die Verhaltenssimulation.
--------------------------------------------------------------------------------
-- synthesis translate_off
    CHECK_NR_OF_SIGNALS : process(CID_INSTRUCTION, DECV) IS
        variable NR : integer range 0 to 16 := 0;
    begin
        NR := 0;
        for i in DECV'range loop
            if DECV(i) = '1' then
                NR := NR + 1;
            end if;
        end loop;
        assert NR <= 1 report "Fehler in ArmCoarseInstructionDecoder: Instruktion nicht eindeutig erkannt." severity error;
    end process CHECK_NR_OF_SIGNALS;
-- synthesis translate_on
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
end architecture behave;
