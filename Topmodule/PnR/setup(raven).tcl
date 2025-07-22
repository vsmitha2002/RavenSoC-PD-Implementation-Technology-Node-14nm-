set_host_options -max_cores 8

##############Intialize Variable################
set TECH_FILE "/home1/14_nmts/14_nmts/tech/milkyway/saed14nm_1p9m_mw.tf"   
set REFERENCE_LIBRARY "/home1/14_nmts/14_nmts/stdcell_hvt/ndm/saed14hvt_frame_only.ndm \
		 /home1/14_nmts/14_nmts/stdcell_slvt/ndm/saed14slvt_frame_only.ndm \
		 /home1/14_nmts/14_nmts/stdcell_rvt/ndm/saed14rvt_frame_only.ndm \
		 /home1/14_nmts/14_nmts/stdcell_lvt/ndm/saed14lvt_frame_only.ndm \
                 /home1/BPD23/VSchandrika/RM_Raven/SUBMODULE/PICORV32_PCPI_DIV/ndm/work-dir/picorv32_pcpi_div.ndm\
                 /home1/BPD23/VSchandrika/RM_Raven/SUBMODULE/PICORV32_PCPI_MUL/ndm/work_dir/picorv32_pcpi_mul.ndm\
	         /home1/BPD23/VSchandrika/RM_Raven/SUBMODULE/SIMPLEUART/ndm/work_dir/simpleuart.ndm\
		/home1/BPD23/VSchandrika/RM_Raven/SUBMODULE/SPIMEMIO/ndm/work_dir/spimemio.ndm"
set DESIGN_NAME raven_soc
set target_library "/home1/14_nmts/14_nmts/stdcell_rvt/db_ccs/saed14rvt_ss0p72v125c.db \
		      /home1/14_nmts/14_nmts/stdcell_rvt/db_ccs/saed14rvt_dlvl_ss0p72v125c_i0p6v.db \
		      /home1/14_nmts/14_nmts/stdcell_rvt/db_ccs/saed14rvt_ulvl_ss0p72v125c_i0p6v.db \
		      /home1/14_nmts/14_nmts/stdcell_lvt/db_ccs/saed14lvt_ss0p72v125c.db \
                      /home1/14_nmts/14_nmts/stdcell_rvt/db_ccs/saed14rvt_ss0p6v125c.db \
		      /home1/14_nmts/14_nmts/stdcell_lvt/db_ccs/saed14lvt_ss0p6v125c.db \
                          /home1/14_nmts/14_nmts/stdcell_hvt/db_ccs/saed14hvt_ff0p7vm40c.db"

set link_library "/home1/14_nmts/14_nmts/stdcell_rvt/db_ccs/saed14rvt_ss0p72v125c.db \
		      /home1/14_nmts/14_nmts/stdcell_rvt/db_ccs/saed14rvt_dlvl_ss0p72v125c_i0p6v.db \
		      /home1/14_nmts/14_nmts/stdcell_rvt/db_ccs/saed14rvt_ulvl_ss0p72v125c_i0p6v.db \
		      /home1/14_nmts/14_nmts/stdcell_lvt/db_ccs/saed14lvt_ss0p72v125c.db \
                          /home1/14_nmts/14_nmts/stdcell_rvt/db_ccs/saed14rvt_ss0p6v125c.db \
		      /home1/14_nmts/14_nmts/stdcell_lvt/db_ccs/saed14lvt_ss0p6v125c.db \
                          /home1/14_nmts/14_nmts/stdcell_hvt/db_ccs/saed14hvt_ff0p7vm40c.db"

set ref_libs "/home1/14_nmts/14_nmts/stdcell_rvt/db_ccs/saed14rvt_ss0p72v125c.db \
		      /home1/14_nmts/14_nmts/stdcell_rvt/db_ccs/saed14rvt_dlvl_ss0p72v125c_i0p6v.db \
		      /home1/14_nmts/14_nmts/stdcell_rvt/db_ccs/saed14rvt_ulvl_ss0p72v125c_i0p6v.db \
		      /home1/14_nmts/14_nmts/stdcell_lvt/db_ccs/saed14lvt_ss0p72v125c.db \
                          /home1/14_nmts/14_nmts/stdcell_rvt/db_ccs/saed14rvt_ss0p6v125c.db \
		      /home1/14_nmts/14_nmts/stdcell_lvt/db_ccs/saed14lvt_ss0p6v125c.db \
                          /home1/14_nmts/14_nmts/stdcell_hvt/db_ccs/saed14hvt_ff0p7vm40c.db"

set TLU_PLUS_MAX_FILE "/home1/14_nmts/14_nmts/tech/star_rc/max/saed14nm_1p9m_Cmax.tluplus"
set TLU_PLUS_MIN_FILE "/home1/14_nmts/14_nmts/tech/star_rc/min/saed14nm_1p9m_Cmin.tluplus"
set MAP_FILE "/home1/14_nmts/14_nmts/tech/star_rc/saed14nm_tf_itf_tluplus.map"

