#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3

#**************************************************************
# Create Clocks
#**************************************************************

create_clock -name {iCLK} -period 20.833 -waveform { 0.000 10.416 } [get_ports {iCLK}]
create_clock -name {RS232_Interface:inst2|rs232_rec_en} -period 250.000 -waveform { 0.000 125.000 } [get_registers {RS232_Interface:inst2|rs232_rec_en}]

create_generated_clock -name {inst1|altpll_component|auto_generated|pll1|clk[0]} -source [get_pins {inst1|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -phase 0.00 -multiply_by 25 -divide_by 24 -master_clock {iCLK} [get_pins {inst1|altpll_component|auto_generated|pll1|clk[0]}] 
create_generated_clock -name {inst1|altpll_component|auto_generated|pll1|clk[1]} -source [get_pins {inst1|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -phase 90.00 -multiply_by 25 -divide_by 24 -master_clock {iCLK} [get_pins {inst1|altpll_component|auto_generated|pll1|clk[1]}] 
create_generated_clock -name {inst1|altpll_component|auto_generated|pll1|clk[2]} -source [get_pins {inst1|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -phase 180.00 -multiply_by 25 -divide_by 24 -master_clock {iCLK} [get_pins {inst1|altpll_component|auto_generated|pll1|clk[2]}] 
create_generated_clock -name {inst1|altpll_component|auto_generated|pll1|clk[3]} -source [get_pins {inst1|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -phase 270.00 -multiply_by 25 -divide_by 24 -master_clock {iCLK} [get_pins {inst1|altpll_component|auto_generated|pll1|clk[3]}] 
create_generated_clock -name {inst1|altpll_component|auto_generated|pll1|clk[4]} -source [get_pins {inst1|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -phase 0.00 -multiply_by 1 -divide_by 12 -master_clock {iCLK} [get_pins {inst1|altpll_component|auto_generated|pll1|clk[4]}] 

#Do not analyze paths launched from clk1 and captured by blocks
#set_false_path -from [get_clocks {inst1|altpll_component|auto_generated|pll1|clk[4]}] -to [get_pins {RS232_Interface:inst2|rs232_rec_en}]

#derive_pll_clocks
derive_clock_uncertainty
