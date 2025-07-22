set_parasitic_parameters -early_spec max_tlu -late_spec max_tlu -early_temperature 125 -late_temperature 125 -corners {ss0p6v125c}

set_voltage 0.6 -object_list VDD
set_voltage 0.0 -object_list VSS
set_voltage 0.72 -object_list VDDH

set_operating_conditions -max ss0p6v125c -min ff0p7vm40c

