
create_clock -period 10.0 -name pll [get_ports pll_clk]

create_clock -period 5.4 -name ext [get_ports ext_clk]

set_input_delay 0.4 -clock pll [remove_from_collection [all_inputs] [get_ports pll_clk]]

set_input_delay 0.4 -clock ext [remove_from_collection [all_inputs] [get_ports ext_clk]]

set_output_delay 0.4 [all_outputs]

set_load -pin_load 0.2 [all_outputs]

set_max_fanout 200 [current_design]

set_max_transition 0.5 [current_design]

set_max_capacitance 50 [current_design]

