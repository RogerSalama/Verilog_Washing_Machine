# Set up the work library
vlib work

# Compile the Verilog files, enabling code coverage
vlog Desgin_code.v Testbench_code.v +cover -covercells

# Elaborate the testbench with access to all signals and enable coverage
vsim -voptargs=+acc work.WashingMachine_tb -cover

# Add all signals to the waveform viewer
add wave *
add wave -position end  /WashingMachine_tb/dut/assert__POWER_NOT_IDLE
add wave -position end  /WashingMachine_tb/dut/assert__Configurations_Timeout_Handling
add wave -position end  /WashingMachine_tb/dut/assert__Manual_Timer_Validation
add wave -position end  /WashingMachine_tb/dut/assert__Washing_Without_Water_Error
add wave -position end  /WashingMachine_tb/dut/assert__Sequential_State_Progression
add wave -position end  /WashingMachine_tb/dut/assert__Idle_to_options
add wave -position end  /WashingMachine_tb/dut/assert__Options_to_Configurations
add wave -position end  /WashingMachine_tb/dut/assert__Idle_to_Idle
add wave -position end  /WashingMachine_tb/dut/assert__Options_to_Ready
add wave -position end  /WashingMachine_tb/dut/assert__Synthetics_time
add wave -position end  /WashingMachine_tb/dut/assert__Configurations_to_Configurations
add wave -position end  /WashingMachine_tb/dut/assert__Config_Valid_Timer
add wave -position end  /WashingMachine_tb/dut/assert__Ready_to_CheckForError
add wave -position end  /WashingMachine_tb/dut/assert__Ready_Stay_Without_Run
add wave -position end  /WashingMachine_tb/dut/assert__Power_Off_Reset
add wave -position end  /WashingMachine_tb/dut/assert__Idle_Timer_Reset
add wave -position end  /WashingMachine_tb/dut/assert__Wash_to_Drain
add wave -position end  /WashingMachine_tb/dut/assert__Drain_to_Dry
add wave -position end  /WashingMachine_tb/dut/assert__Completion_CycleComplete
add wave -position end  /WashingMachine_tb/dut/assert__CheckForError_Handle_Door_Error
add wave -position end  /WashingMachine_tb/dut/assert__CheckForError_Handle_Water_Error



# Save coverage data on exit
coverage save Testbench_code.ucdb -onexit

# Run the simulation to completion
run -all

#decipher the ucdb and save it in a txt file
vcover report Testbench_code.ucdb -details -annotate -all > Coverage.txt 