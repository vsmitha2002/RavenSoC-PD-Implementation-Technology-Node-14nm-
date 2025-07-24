###################################################################################
###################################   INITLIB   ###################################
###################################################################################

set_host_options -max_cores 2

set TECH_FILE "/home1/14_nmts/14_nmts/tech/milkyway/saed14nm_1p9m_mw.tf" 

set target_library "/home1/14_nmts/14_nmts/stdcell_rvt/db_ccs/saed14rvt_ss0p6v125c.db \
                   /home1/14_nmts/14_nmts/stdcell_lvt/db_ccs/saed14lvt_ss0p6v125c.db "


set link_library "/home1/14_nmts/14_nmts/stdcell_rvt/db_ccs/saed14rvt_ss0p6v125c.db  \
                  /home1/14_nmts/14_nmts/stdcell_lvt/db_ccs/saed14lvt_ss0p6v125c.db "
 
set REFERENCE_FILES              "/home1/14_nmts/14_nmts/stdcell_hvt/ndm/saed14hvt_frame_only.ndm \
				   /home1/14_nmts/14_nmts/stdcell_slvt/ndm/saed14slvt_frame_only.ndm \
				   /home1/14_nmts/14_nmts/stdcell_rvt/ndm/saed14rvt_frame_only.ndm \
				   /home1/14_nmts/14_nmts/stdcell_lvt/ndm/saed14lvt_frame_only.ndm" 

set TLUPLUS_MAX                    "/home1/14_nmts/14_nmts/tech/star_rc/max/saed14nm_1p9m_Cmax.tluplus"
set TLUPLUS_MIN                     "/home1/14_nmts/14_nmts/tech/star_rc/min/saed14nm_1p9m_Cmin.tluplus"
set MAP_FILES                       "/home1/14_nmts/14_nmts/tech/star_rc/saed14nm_tf_itf_tluplus.map"                                       

create_lib -technology $TECH_FILE -ref_libs $REFERENCE_FILES spimemio
read_parasitic_tech -name {maxtlu} -tlup $TLUPLUS_MAX -layermap $MAP_FILES 
read_parasitic_tech -name {mintlu} -tlup $TLUPLUS_MIN -layermap $MAP_FILES  
                                   
current_corner default
set_parasitic_parameters -early_spec {maxtlu} -late_spec {mintlu} 
set_process_number 1 -corners default
set_temperature 125 -corners default
set_voltage 0.60 -corners default
current_mode default
set_scenario_status default -active true -setup true -hold true -max_transition true -max_capacitance true -min_capacitance true -leakage_power true  \
-dynamic_power true

###################################  netlist   ##################################
 
read_verilog /home1/BPD23/VSchandrika/RM_Raven/SUBMODULE/SPIMEMIO/OUTPUT_DIR/spimemio.mapped.v
####################################     sdc        #######################################
read_sdc /home1/BPD23/VSchandrika/RM_Raven/SUBMODULE/SPIMEMIO/OUTPUT_DIR/spimemio.sdc
################################       UPF         ##############################################
load_upf ../../SPIMEMIO/OUTPUT_DIR/spimemio.upf 
commit_upf
set_voltage 0.6 -object_list {VDD}
set_voltage 0.0 -object_list {VSS}

save_block -as loadedupfmcmm
get_attribute [get_layers M?] routing_direction

set_attribute [get_layers M1] routing_direction vertical
set_attribute [get_layers M2] routing_direction horizontal
set_attribute [get_layers M3] routing_direction vertical
set_attribute [get_layers M4] routing_direction horizontal
set_attribute [get_layers M5] routing_direction vertical
set_attribute [get_layers M6] routing_direction horizontal
set_attribute [get_layers M7] routing_direction vertical
set_attribute [get_layers M8] routing_direction horizontal
set_attribute [get_layers M9] routing_direction vertical
set_attribute [get_layers MRDL] routing_direction horizontal

initialize_floorplan \
  -flip_first_row true \
  -boundary {{0 0} {26 26}} \
  -core_offset {3 3}

save_block -as fllorplan

########################################pinplacing
place_pins -port [get_ports *]
set_block_pin_constraints -self -allowed_layers {M2 M3} -pin_spacing 3 -sides {1 3}  
place_pins -ports [get_ports -filter {direction == in }] 
#place_pins -ports [all_inputs] 
set_block_pin_constraints -self -allowed_layers {M2 M3} -pin_spacing 3 -sides {2 4} 
place_pins -ports [get_ports -filter {direction == out}] 
#place_pins -ports [all_outputs] 
place_pins -legalize -ports [all_inputs] 
place_pins -legalize -ports [all_outputs] 
check_pin_placement 

save_block -as pinplacing

#########################################Placement################################################################


create_placement -floorplan 
legalize_placement
place_opt
place_opt -from initial_place -to initial_place
report_utilization
place_opt -from initial_drc -to initial_drc
report_utilization
place_opt -from initial_opto -to initial_opto
report_utilization
place_opt -from final_place -to final_place
report_utilization
place_opt -from final_opto -to final_opto
report_utilization
check_legality -verbos
report_congestion
report_utilization
set_attribute [get_cells *] physical_status fixed

##########################################################################################################################
report_area
report_timing
report_power 

write_script -force -format icc2 -output ../results/spimemio.spef
write_parasitics -output ../results/spef_generation_01
write_sdf ../results/spimemio.sdf
write_verilog ../results/spimemio.v
write_gds ../results/spimemio.gds
write_sdc -output ../results/spimemio.sdc

i
