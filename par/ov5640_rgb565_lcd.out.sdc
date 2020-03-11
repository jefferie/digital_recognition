## Generated SDC file "ov5640_rgb565_lcd.out.sdc"

## Copyright (C) 1991-2013 Altera Corporation
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, Altera MegaCore Function License 
## Agreement, or other applicable license agreement, including, 
## without limitation, that your use is for the sole purpose of 
## programming logic devices manufactured by Altera and sold by 
## Altera or its authorized distributors.  Please refer to the 
## applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 13.1.0 Build 162 10/23/2013 SJ Full Version"

## DATE    "Thu Nov 08 02:10:26 2018"

##
## DEVICE  "EP4CE10F17C8"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {sys_clk} -period 20.000 -waveform { 0.000 10.000 } [get_ports {sys_clk}]
create_clock -name {cam_pclk} -period 20.000 -waveform { 0.000 10.000 } [get_ports {cam_pclk}]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {u_pll|altpll_component|auto_generated|pll1|clk[0]} -source [get_pins {u_pll|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 2 -master_clock {sys_clk} [get_pins {u_pll|altpll_component|auto_generated|pll1|clk[0]}] 
create_generated_clock -name {u_pll|altpll_component|auto_generated|pll1|clk[1]} -source [get_pins {u_pll|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 2 -phase -75.000 -master_clock {sys_clk} [get_pins {u_pll|altpll_component|auto_generated|pll1|clk[1]}] 
create_generated_clock -name {u_pll|altpll_component|auto_generated|pll1|clk[2]} -source [get_pins {u_pll|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 2 -master_clock {sys_clk} [get_pins {u_pll|altpll_component|auto_generated|pll1|clk[2]}] 
create_generated_clock -name {dri_clk} -source [get_pins {u_pll|altpll_component|auto_generated|pll1|clk[2]}] -divide_by 400 -master_clock {u_pll|altpll_component|auto_generated|pll1|clk[2]} [get_registers {i2c_dri:u_i2c_dri|dri_clk}] 
create_generated_clock -name {clk_10m} -source [get_pins {u_pll|altpll_component|auto_generated|pll1|clk[2]}] -divide_by 10 -master_clock {u_pll|altpll_component|auto_generated|pll1|clk[2]} [get_registers {lcd:u_lcd|clk_div:u_clk_div|clk_10m}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {clk_10m}] -rise_to [get_clocks {clk_10m}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {clk_10m}] -fall_to [get_clocks {clk_10m}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {clk_10m}] -rise_to [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[2]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {clk_10m}] -fall_to [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[2]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {clk_10m}] -rise_to [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {clk_10m}] -fall_to [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clk_10m}] -rise_to [get_clocks {clk_10m}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {clk_10m}] -fall_to [get_clocks {clk_10m}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {clk_10m}] -rise_to [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[2]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clk_10m}] -fall_to [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[2]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clk_10m}] -rise_to [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clk_10m}] -fall_to [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {dri_clk}] -rise_to [get_clocks {dri_clk}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {dri_clk}] -fall_to [get_clocks {dri_clk}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {dri_clk}] -rise_to [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[2]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {dri_clk}] -fall_to [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[2]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {dri_clk}] -rise_to [get_clocks {cam_pclk}] -setup 0.110  
set_clock_uncertainty -rise_from [get_clocks {dri_clk}] -rise_to [get_clocks {cam_pclk}] -hold 0.080  
set_clock_uncertainty -rise_from [get_clocks {dri_clk}] -fall_to [get_clocks {cam_pclk}] -setup 0.110  
set_clock_uncertainty -rise_from [get_clocks {dri_clk}] -fall_to [get_clocks {cam_pclk}] -hold 0.080  
set_clock_uncertainty -fall_from [get_clocks {dri_clk}] -rise_to [get_clocks {dri_clk}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {dri_clk}] -fall_to [get_clocks {dri_clk}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {dri_clk}] -rise_to [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[2]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {dri_clk}] -fall_to [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[2]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {dri_clk}] -rise_to [get_clocks {cam_pclk}] -setup 0.110  
set_clock_uncertainty -fall_from [get_clocks {dri_clk}] -rise_to [get_clocks {cam_pclk}] -hold 0.080  
set_clock_uncertainty -fall_from [get_clocks {dri_clk}] -fall_to [get_clocks {cam_pclk}] -setup 0.110  
set_clock_uncertainty -fall_from [get_clocks {dri_clk}] -fall_to [get_clocks {cam_pclk}] -hold 0.080  
set_clock_uncertainty -rise_from [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[2]}] -rise_to [get_clocks {clk_10m}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[2]}] -fall_to [get_clocks {clk_10m}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[2]}] -rise_to [get_clocks {dri_clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[2]}] -fall_to [get_clocks {dri_clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[2]}] -rise_to [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[2]}] -fall_to [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[2]}] -rise_to [get_clocks {clk_10m}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[2]}] -fall_to [get_clocks {clk_10m}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[2]}] -rise_to [get_clocks {dri_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[2]}] -fall_to [get_clocks {dri_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[2]}] -rise_to [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[2]}] -fall_to [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {clk_10m}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {clk_10m}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {cam_pclk}] -setup 0.110  
set_clock_uncertainty -rise_from [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {cam_pclk}] -hold 0.080  
set_clock_uncertainty -rise_from [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {cam_pclk}] -setup 0.110  
set_clock_uncertainty -rise_from [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {cam_pclk}] -hold 0.080  
set_clock_uncertainty -fall_from [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {clk_10m}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {clk_10m}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {cam_pclk}] -setup 0.110  
set_clock_uncertainty -fall_from [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {cam_pclk}] -hold 0.080  
set_clock_uncertainty -fall_from [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {cam_pclk}] -setup 0.110  
set_clock_uncertainty -fall_from [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {cam_pclk}] -hold 0.080  
set_clock_uncertainty -rise_from [get_clocks {cam_pclk}] -rise_to [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.080  
set_clock_uncertainty -rise_from [get_clocks {cam_pclk}] -rise_to [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.110  
set_clock_uncertainty -rise_from [get_clocks {cam_pclk}] -fall_to [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.080  
set_clock_uncertainty -rise_from [get_clocks {cam_pclk}] -fall_to [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.110  
set_clock_uncertainty -fall_from [get_clocks {cam_pclk}] -rise_to [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.080  
set_clock_uncertainty -fall_from [get_clocks {cam_pclk}] -rise_to [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.110  
set_clock_uncertainty -fall_from [get_clocks {cam_pclk}] -fall_to [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.080  
set_clock_uncertainty -fall_from [get_clocks {cam_pclk}] -fall_to [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.110  


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

set_false_path  -from  [get_clocks {cam_pclk}]  -to  [get_clocks {cam_pclk}]
set_false_path  -from  [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[0]}]  -to  [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[0]}]
set_false_path  -from  [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[2]}]  -to  [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[2]}]
set_false_path  -from  [get_clocks {clk_10m}]  -to  [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[0]}]
set_false_path -from [get_keepers {*rdptr_g*}] -to [get_keepers {*ws_dgrp|dffpipe_re9:dffpipe4|dffe5a*}]
set_false_path -from [get_keepers {*delayed_wrptr_g*}] -to [get_keepers {*rs_dgwp|dffpipe_qe9:dffpipe11|dffe12a*}]
set_false_path -from [get_ports {sys_rst_n}] 


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

