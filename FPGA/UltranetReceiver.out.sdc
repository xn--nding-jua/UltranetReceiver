## Generated SDC file "UltranetReceiver.out.sdc"

## Copyright (C) 2022  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and any partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details, at
## https://fpgasoftware.intel.com/eula.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 22.1std.0 Build 915 10/25/2022 SC Lite Edition"

## DATE    "Wed Mar  1 20:27:58 2023"

##
## DEVICE  "10CL016YU256C8G"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {iCLK} -period 20.833 -waveform { 0.000 10.416 } [get_ports {iCLK}]
create_clock -name {RS232_Interface:inst2|rs232_rec_en} -period 250.000 -waveform { 0.000 125.000 } [get_registers {RS232_Interface:inst2|rs232_rec_en}]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {inst1|altpll_component|auto_generated|pll1|clk[0]} -source [get_pins {inst1|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 3 -master_clock {iCLK} [get_pins {inst1|altpll_component|auto_generated|pll1|clk[0]}] 
create_generated_clock -name {inst1|altpll_component|auto_generated|pll1|clk[1]} -source [get_pins {inst1|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 1 -divide_by 12 -master_clock {iCLK} [get_pins {inst1|altpll_component|auto_generated|pll1|clk[1]}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {RS232_Interface:inst2|rs232_rec_en}] -rise_to [get_clocks {RS232_Interface:inst2|rs232_rec_en}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {RS232_Interface:inst2|rs232_rec_en}] -fall_to [get_clocks {RS232_Interface:inst2|rs232_rec_en}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {RS232_Interface:inst2|rs232_rec_en}] -rise_to [get_clocks {inst1|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -rise_from [get_clocks {RS232_Interface:inst2|rs232_rec_en}] -rise_to [get_clocks {inst1|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {RS232_Interface:inst2|rs232_rec_en}] -fall_to [get_clocks {inst1|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -rise_from [get_clocks {RS232_Interface:inst2|rs232_rec_en}] -fall_to [get_clocks {inst1|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {RS232_Interface:inst2|rs232_rec_en}] -rise_to [get_clocks {inst1|altpll_component|auto_generated|pll1|clk[1]}] -setup 0.070  
set_clock_uncertainty -rise_from [get_clocks {RS232_Interface:inst2|rs232_rec_en}] -rise_to [get_clocks {inst1|altpll_component|auto_generated|pll1|clk[1]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {RS232_Interface:inst2|rs232_rec_en}] -fall_to [get_clocks {inst1|altpll_component|auto_generated|pll1|clk[1]}] -setup 0.070  
set_clock_uncertainty -rise_from [get_clocks {RS232_Interface:inst2|rs232_rec_en}] -fall_to [get_clocks {inst1|altpll_component|auto_generated|pll1|clk[1]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {RS232_Interface:inst2|rs232_rec_en}] -rise_to [get_clocks {RS232_Interface:inst2|rs232_rec_en}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {RS232_Interface:inst2|rs232_rec_en}] -fall_to [get_clocks {RS232_Interface:inst2|rs232_rec_en}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {RS232_Interface:inst2|rs232_rec_en}] -rise_to [get_clocks {inst1|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -fall_from [get_clocks {RS232_Interface:inst2|rs232_rec_en}] -rise_to [get_clocks {inst1|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {RS232_Interface:inst2|rs232_rec_en}] -fall_to [get_clocks {inst1|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -fall_from [get_clocks {RS232_Interface:inst2|rs232_rec_en}] -fall_to [get_clocks {inst1|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {RS232_Interface:inst2|rs232_rec_en}] -rise_to [get_clocks {inst1|altpll_component|auto_generated|pll1|clk[1]}] -setup 0.070  
set_clock_uncertainty -fall_from [get_clocks {RS232_Interface:inst2|rs232_rec_en}] -rise_to [get_clocks {inst1|altpll_component|auto_generated|pll1|clk[1]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {RS232_Interface:inst2|rs232_rec_en}] -fall_to [get_clocks {inst1|altpll_component|auto_generated|pll1|clk[1]}] -setup 0.070  
set_clock_uncertainty -fall_from [get_clocks {RS232_Interface:inst2|rs232_rec_en}] -fall_to [get_clocks {inst1|altpll_component|auto_generated|pll1|clk[1]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {inst1|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {inst1|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {inst1|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {inst1|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {inst1|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {inst1|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {inst1|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {inst1|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {inst1|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {RS232_Interface:inst2|rs232_rec_en}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {inst1|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {RS232_Interface:inst2|rs232_rec_en}] -hold 0.070  
set_clock_uncertainty -rise_from [get_clocks {inst1|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {RS232_Interface:inst2|rs232_rec_en}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {inst1|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {RS232_Interface:inst2|rs232_rec_en}] -hold 0.070  
set_clock_uncertainty -rise_from [get_clocks {inst1|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {inst1|altpll_component|auto_generated|pll1|clk[1]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {inst1|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {inst1|altpll_component|auto_generated|pll1|clk[1]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {inst1|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {RS232_Interface:inst2|rs232_rec_en}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {inst1|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {RS232_Interface:inst2|rs232_rec_en}] -hold 0.070  
set_clock_uncertainty -fall_from [get_clocks {inst1|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {RS232_Interface:inst2|rs232_rec_en}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {inst1|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {RS232_Interface:inst2|rs232_rec_en}] -hold 0.070  
set_clock_uncertainty -fall_from [get_clocks {inst1|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {inst1|altpll_component|auto_generated|pll1|clk[1]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {inst1|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {inst1|altpll_component|auto_generated|pll1|clk[1]}]  0.020  


#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

