####################################################################################
###################################  POWER PLAN  ###################################
####################################################################################
remove_pg_strategies -all
remove_pg_patterns -all
remove_pg_regions -all
remove_pg_via_master_rules -all
remove_pg_strategy_via_rules -all
remove_routes -net_types {power ground} -ring -stripe -macro_pin_connect -lib_cell_pin_connect > /dev/null
connect_pg_net -automatic 
#Setting up the attribute for TIE cells
set_attribute [get_lib_cells */*TIE*] dont_touch false
set_lib_cell_purpose -include optimization [get_lib_cells */*TIE*]

############################
########  PG RINGS  ########
############################

########PG ring creation####

create_pg_ring_pattern ring_pattern -horizontal_layer M8 \
    -horizontal_width {0.5} -horizontal_spacing {1} \
    -vertical_layer M7 -vertical_width {0.5} \
    -vertical_spacing {1} -corner_bridge false
set_pg_strategy core_ring -core -pattern {{pattern:ring_pattern}{nets: {VDD VSS}} {offset : 0.5 0.5}} -extension {{{side:1} {direction: B} {nets: {VDD VSS}} {stop:design_boundary_and_generate_pin}}}
compile_pg -strategies core_ring
###Mesh
create_pg_mesh_pattern pg_mesh_pattern -layers {{{horizontal_layer: M6} {width: 0.5} {spacing: Interleaving}{pitch:6}}{{vertical_layer: M7} {width: 0.5} {spacing: Interleaving}{pitch:6}}}
set_pg_strategy s_mesh1 -core -pattern {{pattern:pg_mesh_pattern}{nets:{VDD VSS}}} -extension {{stop:outermost_ring}}
compile_pg -strategies s_mesh1

#create_pg_mesh_pattern pg_mesh_pattern_lower -layers {{vertical_layer: M3} {width:0.5} {spacing: Interleaving}{pitch:10}}
#set_pg_strategy s_mesh1_lower -core -pattern {{pattern:pg_mesh_pattern_lower} {nets:{VDD VSS}}} -extension {{stop:outermost_ring}}
#compile_pg -strategies s_mesh1_lower
##STD_Rails###
create_pg_std_cell_conn_pattern \
    std_cell_rail  \
    -layers {M1} \
    -rail_width 0.065
set_pg_strategy rail_start -core \
    -pattern {{name: std_cell_rail} {nets: VDD VSS} }
compile_pg -strategies rail_start


