################ Loading setup file ##############
source -echo ../scripts/setup.tcl 

#############Creating Library################
create_lib -technology $TECH_FILE -ref_libs $REFERENCE_LIBRARY $DESIGN_NAME

############Reading TLU plus files#############
read_parasitic_tech -name max_tlu -tlup $TLU_PLUS_MAX_FILE -layermap $MAP_FILE
read_parasitic_tech -name min_tlu -tlup $TLU_PLUS_MIN_FILE -layermap $MAP_FILE
source -echo ../scripts/TCL_PARASITIC_SETUP_FILE.tcl

############Reading Netlist##################
read_verilog ../OUTPUT_DIR/${DESIGN_NAME}.mapped.v
current_design $DESIGN_NAME
link_design

############Reading SDC#################
read_sdc ../OUTPUT_DIR/${DESIGN_NAME}.sdc

############Loading upf###############
load_upf ../outputs/${DESIGN_NAME}.mapped.upf
set_attribute [get_lib_cells *LS*] dont_touch false
set_attribute [get_lib_cells *ISO*] dont_touch false

set_voltage 0.72 -object_list {VDDH}
set_voltage 0.6 -object_list {VDD}
set_voltage 0.0 -object_list {VSS}
commit_upf

################Setting Floorplan##############
initialize_floorplan -control_type die -core_utilization 0.5 -side_ratio {140 140} -core_offset {5}

###############Setting pins constraints#############
set_block_pin_constraints -self -allowed_layers {M2 M3} -sides {1 3}
place_pins -ports [get_ports -filter direction==in]

set_block_pin_constraints -self -allowed_layers {M2 M3} -sides {2 4}
place_pins -ports [get_ports -filter direction==out]

#set_attribute [get_ports *] physical_status fixed

############Setting Routing Layers##############
get_site_defs
set_attribute [get_site_defs unit] symmetry Y
set_attribute [get_site_defs unit] is_default true

set_attribute [get_layers {M1 M3 M5 M7 M9}] routing_direction vertical
set_attribute [get_layers {M2 M4 M6 M8}] routing_direction  horizontal

report_ignored_layers
#set_ignored_layers -max_routing_layer M9

##############Creating keepout margin################
create_keepout_margin -type hard -outer {1.5 1.5 1.5 1.5} [get_flat_cells -of_objects *mul]

create_keepout_margin -type hard -outer {1.5 1.5 1.6 1.5} [get_flat_cells -of_objects *div]

create_keepout_margin -type hard -outer {1.5 1.5 1.5 1.5} [get_flat_cells -of_objects */spimemio]

create_keepout_margin -type hard -outer {1.5 1.5 1.5 1.5} [get_flat_cells -of_objects */simpleuart]

set_attribute [get_flat_cells -filter "is_hard_macro"] physical_status fix

#################Boundary cells#####################
set_attribute [get_lib_cells *LVT14_DCAP_V4*] dont_use false
create_boundary_cells -left_boundary_cell saed14lvt_ss0p72v125c/SAEDLVT14_DCAP_V4_5 \
	            -right_boundary_cell saed14lvt_ss0p72v125c/SAEDLVT14_DCAP_V4_5

###########setting don't touch attribute#############
set_attribute [get_lib_cells *TIE*] dont_touch false
set_lib_cell_purpose -include optimization [get_lib_cells *TIE*]

#derive_design_level_via_regions
################## MCMM ######################
#current_corner default
#current_mode default
#set_parasitic_parameters -late_spec {max_tlu} -early_spec {min_tlu}
#set_process_number 1 -corners default
#set_temperature 125 -corners default
#set_voltage 0.6 -corners default
#set_scenario_status default -active true -setup true -hold true -max_transition true -max_capacitance true -min_capacitance true -leakage_power true -dynamic_power true

source -echo ../scripts/TCL_MCMM_SETUP_FILE.explicit.tcl 

#################Power plan#####################
source -echo ../pns.tcl 

################# Placement ###################
set_app_options -list {place.coarse.max_density {0.5}}
set_app_options -list {place_opt.place.congestion_effort {high}}
create_placement -incremental -congestion 
legalize_placement 
magnet_placement [get_ports clk]
place_opt

####placement checks#######
check_legality
report_timing
report_utilization
check_pg_drc
check_pg_missing_vias
check_pg_connectivity


#############Routing Rules#################
set clock_min_layer "M4"
set clock_max_layer "M5"

set route_min_layer "M1"
set route_max_layer "M5"

################ CTS Stage ################
remove_tracks -layer M1
report_tracks 
#create_track -layer {M1} -coord 1.111 -space 0.037
set_app_options -list {clock_opt.place.congestion_effort {high}}

clock_opt
report_timing
report_clock_settings
report_qor -summary

################ Routing stage ################
set_app_options -list {route.common.via_on_grid_by_layer_name {{M1 true}}}
route_auto -max_detail_route_iterations 30
route_opt
route_eco

#routing checks
report_timing

##############Filler cells placement ##############
set_attribute [ get_lib_cells *FILL*] dont_use false
create_stdcell_fillers -lib_cells [get_lib_cells *FILL*] -rules {post_route_auto_delete}
connect_pg_net
remove_stdcell_fillers_with_violation
check_legality

################## Reports ########################
report_constraints -all_violators > ../reports/violators.rpt
check_legality > ../reports/legality.rpt
check_lvs > ../reports/lvs.rpt
report_timing > ../reports/timing_report.rpt
report_global_timing > ../reports/global_timing_report.rpt
report_congestion > ../reports/congestion.rpt
write_parasitics -output ../reports/spef_generation_1

################## Extracted files ###############
write_parasitics -output ../results/${DESIGN_NAME}.spef
write_verilog ../results/$DESIGN_NAME.mapped.v
write_sdf ../results/$DESIGN_NAME.sdf
write_sdc -output ../results/$DESIGN_NAME.sdc
create_abstract 
create_frame -block_all true
write_gds -compress -hierarchy all -long_names -keep_data_type ../results/$DESIGN_NAME.gds
