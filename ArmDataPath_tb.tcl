set curr_wave [current_wave_config]
if { [string length $curr_wave] == 0 } {
  if { [llength [get_objects]] > 0} {
    add_wave /
    set_property needs_save false [current_wave_config]
  } else {
     send_msg_id Add_Wave-1 WARNING "No top level signals found. Simulator will start without a wave window. If you want to open a wave window go to 'File->New Waveform Configuration' or type 'create_wave_config' in the TCL console."
  }
}

# force signals
add_force {/ArmDataPath_tb/uut/EX_OPA_REG} -radix hex {aaaaaaaa 1025ns}
add_force {/ArmDataPath_tb/uut/EX_OPC_REG} -radix hex {cccccccc 1025ns}
add_force {/ArmDataPath_tb/uut/EX_SHIFT_REG} -radix hex {dd 1025ns}
add_force {/ArmDataPath_tb/uut/MEM_RES_REG} -radix hex {11111111 1025ns}
add_force {/ArmDataPath_tb/uut/WB_RES_REG} -radix hex {22222222 1025ns} \
    {7fff7000 5375ns} \
    {0000aaac 5875ns} \
    {0000bbbc 6075ns} \
    {0000cccc 6175ns} \
    {0000dddc 6275ns} \
    {0000eeec 6375ns} \
    {0000fffc 6475ns}
add_force {/ArmDataPath_tb/uut/MEM_CC_REG} -radix hex {4 1025ns}
add_force {/ArmDataPath_tb/uut/WB_CC_REG} -radix hex {5 1025ns}
add_force {/ArmDataPath_tb/uut/EX_CPSR} -radix hex {60000000 1025ns}

run -all
