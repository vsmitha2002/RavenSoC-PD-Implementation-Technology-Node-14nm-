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

####### clock routing ##########
create_routing_rule cts \
	-default_reference_rule -widths { M1 0.1 M2 0.11 M3 0.11 M4 0.11 M5 0.11} \
          -spacings {M2 0.16 M3 0.45 M4 0.45 M5 1.1} \
          -spacing_length_thresholds {M2 3.0 M3 3.0 M4 4.0 M5 4.0} \
          -taper_distance 0.4 -driver_taper_distance 0.4 \
          -cuts { {VIA1 {VIA1LG 1}} {VIA2 {VIA2LG 1}} {VIA3 {VIA3LG 1}} {VIA4 {VIA4LG 1}} {VIA5 {VIA5LG 1}}}
	-spacing_weight_levels {{M1 {high medium}
                              M2 {high medium}
                              M3 {high medium}
                              M4 {high medium}
                              M5 {high medium}}
set_clock_routing_rules -rules cts -min_routing_layer $clock_min_layer -max_routing_layer $clock_max_layer

####### routing rules #########
create_routing_rule routing \
	-default_reference_rule \
          -spacings {M1 0.10 M2 0.16 M3 0.45 M4 0.45 M5 1.1} 
	-spacing_weight_levels {{M1 {high medium}
                              M2 {high medium}
                              M3 {high medium}
                              M4 {high medium}
                              M5 {high medium}}
set_routing_rule {HFSNET_1 N14 N16 N18 N20 N22 N24 N26 N27 N28 N30 N32 N34 N36 N38 N40 N42 N43 N44 N46 N48 N50 N52 N54 N56 N58 N59 N60 N62 N64 N66 N68 N70 N72 N74 N75 N76 N78 N79 N80 N81 N82 N83 N84 N85 N86 N87 N88 N89 N90 N91 N92 N93 N94 N95 N96 N97 N98 N99 N100 N101 N102 N103 N104 N105 N106 N107 N108 N109 N129 N163 N264 N266 N268 N269 N270 N271 N272 N273 N274 N275 N276 N277 N278 N279 N280 N281 N282 N283 N284 N285 N286 N287 N288 N289 N290 N291 N292 N293 N294 N295 N296 N297 N298 N299 N300 N301 N302 N317 N318 N320 N333 N340 N341 N342 N343 N344 N345 N346 N347 N348 N349 N350 N351 N352 N353 N354 N355 N356 N357 N358 N359 N360 N361 N362 N363 N364 N365 N366 N367 N368 N369 N370 N371 N374 N386 N388 N390 N392 N394 N396 N398 N400 N402 N403 N405 N407 N409 N411 N412 N413 N414 N415 N416 N417 N418 N419 N420 N421 N422 N423 N424 N425 N426 N427 N428 N429 N430 N431 N432 N433 N434 N435 N436 N437 N438 N439 N440 N441 N442 N443 VDD VDDo VSS ZCTSNET_1 add_x_4/n99 add_x_4/n100 add_x_4/n101 add_x_4/n102 add_x_4/n103 add_x_4/n104 add_x_4/n105 add_x_4/n106 add_x_4/n107 add_x_4/n108 add_x_4/n109 add_x_4/n110 add_x_4/n111 add_x_4/n112 add_x_4/n113 add_x_4/n114 add_x_4/n115 add_x_4/n116 add_x_4/n117 add_x_4/n118 add_x_4/n119 add_x_4/n120 add_x_4/n121 add_x_4/n122 add_x_4/n123 add_x_4/n124 add_x_4/n125 add_x_4/n126 add_x_4/n127 add_x_4/n128 add_x_26/n99 add_x_26/n100 add_x_26/n101 add_x_26/n102 add_x_26/n103 add_x_26/n104 add_x_26/n105 add_x_26/n106 add_x_26/n107 add_x_26/n108 add_x_26/n109 add_x_26/n110 add_x_26/n111 add_x_26/n112 add_x_26/n113 add_x_26/n114 add_x_26/n115 add_x_26/n116 add_x_26/n117 add_x_26/n118 add_x_26/n119 add_x_26/n120 add_x_26/n121 add_x_26/n122 add_x_26/n123 add_x_26/n124 add_x_26/n125 add_x_26/n126 add_x_26/n127 add_x_26/n128 clk gre_net_28 gre_net_29 gre_net_30 gre_net_31 gre_net_32 gt_x_5/n223 gt_x_5/n224 gt_x_5/n225 gt_x_5/n226 gt_x_5/n227 gt_x_5/n228 gt_x_5/n229 gt_x_5/n230 gt_x_5/n231 gt_x_5/n232 gt_x_5/n233 gt_x_5/n234 gt_x_5/n235 gt_x_5/n236 gt_x_5/n237 gt_x_5/n238 gt_x_5/n239 gt_x_5/n240 gt_x_5/n241 gt_x_5/n242 gt_x_5/n243 gt_x_5/n244 gt_x_5/n245 gt_x_5/n246 gt_x_5/n247 gt_x_5/n248 gt_x_5/n249 gt_x_5/n250 gt_x_5/n251 gt_x_5/n252 gt_x_5/n253 gt_x_5/n254 gt_x_5/n255 gt_x_5/n256 gt_x_5/n257 gt_x_5/n258 gt_x_5/n259 gt_x_5/n260 gt_x_5/n261 gt_x_5/n262 gt_x_5/n263 gt_x_5/n264 gt_x_5/n265 gt_x_5/n266 gt_x_5/n267 gt_x_5/n268 gt_x_5/n269 gt_x_5/n270 gt_x_5/n271 gt_x_5/n272 gt_x_5/n273 gt_x_5/n274 gt_x_5/n275 gt_x_5/n276 gt_x_5/n277 gt_x_5/n278 gt_x_5/n279 gt_x_5/n280 gt_x_5/n281 gt_x_5/n282 gt_x_5/n283 gt_x_5/n284 gt_x_5/n285 gt_x_5/n286 gt_x_5/n287 gt_x_5/n288 gt_x_5/n289 gt_x_5/n290 gt_x_5/n291 gt_x_5/n292 gt_x_5/n293 gt_x_5/n294 gt_x_5/n295 gt_x_5/n296 gt_x_5/n297 gt_x_5/n298 gt_x_5/n299 gt_x_5/n300 gt_x_5/n301 gt_x_5/n302 gt_x_5/n303 gt_x_5/n304 gt_x_5/n305 gt_x_5/n306 gt_x_5/n307 gt_x_5/n308 gt_x_5/n309 gt_x_5/n310 gt_x_5/n311 gt_x_5/n312 gt_x_5/n313 gt_x_5/n314 gt_x_5/n315 gt_x_5/n316 gt_x_5/n317 gt_x_5/n318 gt_x_5/n319 gt_x_5/n320 gt_x_5/n321 gt_x_5/n322 gt_x_5/n323 gt_x_5/n324 gt_x_5/n325 gt_x_5/n326 gt_x_5/n327 gt_x_5/n328 gt_x_5/n329 gt_x_5/n330 gt_x_5/n331 gt_x_5/n332 gt_x_5/n333 gt_x_5/n334 gt_x_5/n335 gt_x_5/n336 gt_x_5/n337 gt_x_5/n338 gt_x_5/n339 gt_x_5/n340 gt_x_5/n341 gt_x_5/n342 gt_x_5/n343 gt_x_5/n344 gt_x_5/n345 gt_x_5/n346 gt_x_5/n347 gt_x_5/n348 gt_x_5/n349 gt_x_5/n350 gt_x_5/n351 gt_x_5/n352 gt_x_5/n353 gt_x_5/n354 gt_x_5/n355 gt_x_5/n356 gt_x_5/n357 gt_x_5/n358 gt_x_5/n359 gt_x_5/n360 gt_x_5/n361 gt_x_5/n362 gt_x_5/n363 gt_x_5/n364 gt_x_5/n365 gt_x_5/n366 gt_x_5/n367 gt_x_5/n368 gt_x_5/n369 gt_x_5/n370 gt_x_27/n227 gt_x_27/n228 gt_x_27/n229 gt_x_27/n230 gt_x_27/n231 gt_x_27/n232 gt_x_27/n233 gt_x_27/n234 gt_x_27/n235 gt_x_27/n236 gt_x_27/n237 gt_x_27/n238 gt_x_27/n239 gt_x_27/n240 gt_x_27/n241 gt_x_27/n242 gt_x_27/n243 gt_x_27/n244 gt_x_27/n245 gt_x_27/n246 gt_x_27/n247 gt_x_27/n248 gt_x_27/n249 gt_x_27/n250 gt_x_27/n251 gt_x_27/n252 gt_x_27/n253 gt_x_27/n254 gt_x_27/n255 gt_x_27/n256 gt_x_27/n257 gt_x_27/n258 gt_x_27/n259 gt_x_27/n260 gt_x_27/n261 gt_x_27/n262 gt_x_27/n263 gt_x_27/n264 gt_x_27/n265 gt_x_27/n266 gt_x_27/n267 gt_x_27/n268 gt_x_27/n269 gt_x_27/n270 gt_x_27/n271 gt_x_27/n272 gt_x_27/n273 gt_x_27/n274 gt_x_27/n275 gt_x_27/n276 gt_x_27/n277 gt_x_27/n278 gt_x_27/n279 gt_x_27/n280 gt_x_27/n281 gt_x_27/n282 gt_x_27/n283 gt_x_27/n284 gt_x_27/n285 gt_x_27/n286 gt_x_27/n287 gt_x_27/n288 gt_x_27/n289 gt_x_27/n290 gt_x_27/n291 gt_x_27/n292 gt_x_27/n293 gt_x_27/n294 gt_x_27/n295 gt_x_27/n296 gt_x_27/n297 gt_x_27/n298 gt_x_27/n299 gt_x_27/n300 gt_x_27/n301 gt_x_27/n302 gt_x_27/n303 gt_x_27/n304 gt_x_27/n305 gt_x_27/n306 gt_x_27/n307 gt_x_27/n308 gt_x_27/n309 gt_x_27/n310 gt_x_27/n311 gt_x_27/n312 gt_x_27/n313 gt_x_27/n314 gt_x_27/n315 gt_x_27/n316 gt_x_27/n317 gt_x_27/n318 gt_x_27/n319 gt_x_27/n320 gt_x_27/n321 gt_x_27/n322 gt_x_27/n323 gt_x_27/n324 gt_x_27/n325 gt_x_27/n326 gt_x_27/n327 gt_x_27/n328 gt_x_27/n329 gt_x_27/n330 gt_x_27/n331 gt_x_27/n332 gt_x_27/n333 gt_x_27/n334 gt_x_27/n335 gt_x_27/n336 gt_x_27/n337 gt_x_27/n338 gt_x_27/n339 gt_x_27/n340 gt_x_27/n341 gt_x_27/n342 gt_x_27/n343 gt_x_27/n344 gt_x_27/n345 gt_x_27/n346 gt_x_27/n347 gt_x_27/n348 gt_x_27/n349 gt_x_27/n350 gt_x_27/n351 gt_x_27/n352 gt_x_27/n353 gt_x_27/n354 gt_x_27/n355 gt_x_27/n356 gt_x_27/n357 gt_x_27/n358 gt_x_27/n359 gt_x_27/n360 gt_x_27/n361 gt_x_27/n362 gt_x_27/n363 gt_x_27/n364 gt_x_27/n365 gt_x_27/n366 gt_x_27/n367 gt_x_27/n368 gt_x_27/n369 gt_x_27/n370 gt_x_27/n371 gt_x_27/n372 gt_x_27/n373 gt_x_27/n374 gt_x_27/n375 gt_x_27/n376 gt_x_27/n377 gt_x_35/n227 gt_x_35/n228 gt_x_35/n229 gt_x_35/n230 gt_x_35/n231 gt_x_35/n232 gt_x_35/n233 gt_x_35/n234 gt_x_35/n235 gt_x_35/n236 gt_x_35/n237 gt_x_35/n238 gt_x_35/n239 gt_x_35/n240 gt_x_35/n241 gt_x_35/n242 gt_x_35/n243 gt_x_35/n244 gt_x_35/n245 gt_x_35/n246 gt_x_35/n247 gt_x_35/n248 gt_x_35/n249 gt_x_35/n250 gt_x_35/n251 gt_x_35/n252 gt_x_35/n253 gt_x_35/n254 gt_x_35/n255 gt_x_35/n256 gt_x_35/n257 gt_x_35/n258 gt_x_35/n259 gt_x_35/n260 gt_x_35/n261 gt_x_35/n262 gt_x_35/n263 gt_x_35/n264 gt_x_35/n265 gt_x_35/n266 gt_x_35/n267 gt_x_35/n268 gt_x_35/n269 gt_x_35/n270 gt_x_35/n271 gt_x_35/n272 gt_x_35/n273 gt_x_35/n274 gt_x_35/n275 gt_x_35/n276 gt_x_35/n277 gt_x_35/n278 gt_x_35/n279 gt_x_35/n280 gt_x_35/n281 gt_x_35/n282 gt_x_35/n283 gt_x_35/n284 gt_x_35/n285 gt_x_35/n286 gt_x_35/n287 gt_x_35/n288 gt_x_35/n289 gt_x_35/n290 gt_x_35/n291 gt_x_35/n292 gt_x_35/n293 gt_x_35/n294 gt_x_35/n295 gt_x_35/n296 gt_x_35/n297 gt_x_35/n298 gt_x_35/n299 gt_x_35/n300 gt_x_35/n301 gt_x_35/n302 gt_x_35/n303 gt_x_35/n304 gt_x_35/n305 gt_x_35/n306 gt_x_35/n307 gt_x_35/n308 gt_x_35/n309 gt_x_35/n310 gt_x_35/n311 gt_x_35/n312 gt_x_35/n313 gt_x_35/n314 gt_x_35/n315 gt_x_35/n316 gt_x_35/n317 gt_x_35/n318 gt_x_35/n319 gt_x_35/n320 gt_x_35/n321 gt_x_35/n322 gt_x_35/n323 gt_x_35/n324 gt_x_35/n325 gt_x_35/n326 gt_x_35/n327 gt_x_35/n328 gt_x_35/n329 gt_x_35/n330 gt_x_35/n331 gt_x_35/n332 gt_x_35/n333 gt_x_35/n334 gt_x_35/n335 gt_x_35/n336 gt_x_35/n337 gt_x_35/n338 gt_x_35/n339 gt_x_35/n340 gt_x_35/n341 gt_x_35/n342 gt_x_35/n343 gt_x_35/n344 gt_x_35/n345 gt_x_35/n346 gt_x_35/n347 gt_x_35/n348 gt_x_35/n349 gt_x_35/n350 gt_x_35/n351 gt_x_35/n352 gt_x_35/n353 gt_x_35/n354 gt_x_35/n355 gt_x_35/n356 gt_x_35/n357 gt_x_35/n358 gt_x_35/n359 gt_x_35/n360 gt_x_35/n361 gt_x_35/n362 gt_x_35/n363 gt_x_35/n364 gt_x_35/n365 gt_x_35/n366 gt_x_35/n367 gt_x_35/n368 gt_x_35/n369 gt_x_35/n370 gt_x_35/n371 gt_x_35/n372 gt_x_35/n373 gt_x_35/n374 gt_x_35/n375 gt_x_35/n376 gt_x_35/n377 n[437] n[438] n[439] n[440] net553 net559 net564 net569 net574 net579 net584 net589 n187 n188 n189 n190 n191 n192 n193 n199 n203 n204 n205 n206 n207 n208 n209 n210 n211 n212 n213 n214 n215 n216 n217 n218 n219 n220 n221 n222 n223 n224 n225 n226 n227 n228 n229 n230 n231 n232 n233 n234 n235 n236 n237 n238 n240 n316 n373 n374 n375 n376 n377 n378 n379 n380 n434 n435 n436 n441 n442 n443 n444 n445 n446 n447 n448 n449 n450 n451 n452 n453 n454 n455 n456 n457 n458 n459 n460 n461 n462 n463 n464 n465 n466 n467 n468 n469 n470 n471 n472 n473 n474 n475 n476 n477 n478 n479 n480 n481 n482 n483 n484 n485 n486 n488 optlc_net_3 optlc_net_10 optlc_net_12 optlc_net_13 optlc_net_15 optlc_net_16 optlc_net_17 optlc_net_18 optlc_net_19 optlc_net_20 optlc_net_21 optlc_net_22 optlc_net_23 optlc_net_24 optlc_net_25 recv_buf_data[0] recv_buf_data[1] recv_buf_data[2] recv_buf_data[3] recv_buf_data[4] recv_buf_data[5] recv_buf_data[6] recv_buf_data[7] recv_buf_valid recv_divcnt[0] recv_divcnt[1] recv_divcnt[2] recv_divcnt[3] recv_divcnt[4] recv_divcnt[5] recv_divcnt[6] recv_divcnt[7] recv_divcnt[8] recv_divcnt[9] recv_divcnt[10] recv_divcnt[11] recv_divcnt[12] recv_divcnt[13] recv_divcnt[14] recv_divcnt[15] recv_divcnt[16] recv_divcnt[17] recv_divcnt[18] recv_divcnt[19] recv_divcnt[20] recv_divcnt[21] recv_divcnt[22] recv_divcnt[23] recv_divcnt[24] recv_divcnt[25] recv_divcnt[26] recv_divcnt[27] recv_divcnt[28] recv_divcnt[29] recv_divcnt[30] recv_divcnt[31] recv_pattern[0] recv_pattern[1] recv_pattern[2] recv_pattern[3] recv_pattern[4] recv_pattern[5] recv_pattern[6] recv_pattern[7] recv_state[0] recv_state[1] recv_state[2] recv_state[3] reg_dat_di[0] reg_dat_di[1] reg_dat_di[2] reg_dat_di[3] reg_dat_di[4] reg_dat_di[5] reg_dat_di[6] reg_dat_di[7] reg_dat_di[8] reg_dat_di[9] reg_dat_di[10] reg_dat_di[11] reg_dat_di[12] reg_dat_di[13] reg_dat_di[14] reg_dat_di[15] reg_dat_di[16] reg_dat_di[17] reg_dat_di[18] reg_dat_di[19] reg_dat_di[20] reg_dat_di[21] reg_dat_di[22] reg_dat_di[23] reg_dat_di[24] reg_dat_di[25] reg_dat_di[26] reg_dat_di[27] reg_dat_di[28] reg_dat_di[29] reg_dat_di[30] reg_dat_di[31] reg_dat_do[0] reg_dat_do[1] reg_dat_do[2] reg_dat_do[3] reg_dat_do[4] reg_dat_do[5] reg_dat_do[6] reg_dat_do[7] reg_dat_do[8] reg_dat_re reg_dat_wait reg_dat_we reg_div_di[0] reg_div_di[1] reg_div_di[2] reg_div_di[3] reg_div_di[4] reg_div_di[5] reg_div_di[6] reg_div_di[7] reg_div_di[8] reg_div_di[9] reg_div_di[10] reg_div_di[11] reg_div_di[12] reg_div_di[13] reg_div_di[14] reg_div_di[15] reg_div_di[16] reg_div_di[17] reg_div_di[18] reg_div_di[19] reg_div_di[20] reg_div_di[21] reg_div_di[22] reg_div_di[23] reg_div_di[24] reg_div_di[25] reg_div_di[26] reg_div_di[27] reg_div_di[28] reg_div_di[29] reg_div_di[30] reg_div_di[31] reg_div_do[0] reg_div_do[1] reg_div_do[2] reg_div_do[3] reg_div_do[4] reg_div_do[5] reg_div_do[6] reg_div_do[7] reg_div_do[8] reg_div_do[9] reg_div_do[10] reg_div_do[11] reg_div_do[12] reg_div_do[13] reg_div_do[14] reg_div_do[15] reg_div_do[16] reg_div_do[17] reg_div_do[18] reg_div_do[19] reg_div_do[20] reg_div_do[21] reg_div_do[22] reg_div_do[23] reg_div_do[24] reg_div_do[25] reg_div_do[26] reg_div_do[27] reg_div_do[28] reg_div_do[29] reg_div_do[30] reg_div_do[31] reg_div_we[0] reg_div_we[1] reg_div_we[2] reg_div_we[3] resetn send_bitcnt[0] send_bitcnt[1] send_bitcnt[2] send_bitcnt[3] send_divcnt[0] send_divcnt[1] send_divcnt[2] send_divcnt[3] send_divcnt[4] send_divcnt[5] send_divcnt[6] send_divcnt[7] send_divcnt[8] send_divcnt[9] send_divcnt[10] send_divcnt[11]} -rule routing -min_routing_layer M1 -max_routing_layer M2

################ CTS Stage ################
remove_tracks -layer M1
report_tracks 
create_track -layer {M1} -coord 1.111 -space 0.037
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