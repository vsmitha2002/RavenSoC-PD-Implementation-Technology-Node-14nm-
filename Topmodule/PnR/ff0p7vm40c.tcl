set_parasitic_parameters -early_spec min_tlu -late_spec min_tlu  -early_temperature -40 -late_temperature -40 -corners {ff0p7vm40c}

set_voltage 0.7 -object_list VDD
set_voltage 0.0 -object_list VSS
set_voltage 0.72 -object_list VDDH

set_operating_conditions -max ss0p6v125c -min ff0p7vm40c


