;20160404 Ali
;loads PFP data for MAVEN pickup ion model
;to be called by mvn_pui_model

pro mvn_pui_data_load,do3d=do3d,nosep=nosep,nostatic=nostatic

;mvn_spice_load ;load spice kernels
kernels = mvn_spice_kernels(/all,/clear,/load,trange=trange,verbose=2)
maven_orbit_tplot ;loads the color-coded orbit info
mvn_swia_load_l2_data,/loadmom,/loadspec,loadcoarse=do3d,/eflux,/tplot,qlevel=0.1 ;load SWIA data
mvn_mag_load,'L2_1sec' ;load MAG data
;cdf2tplot,mvn_pfp_file_retrieve('maven/data/sci/sep/anc/cdf/YYYY/MM/mvn_sep_l2_anc_YYYYMMDD_v??_r??.cdf',/daily),prefix='SepAnc_'
mvn_swe_load_l2,/spec,/sumplot ;load SWEA data
mvn_euv_l3_load ;load FISM data
mvn_euv_load ;load EUVM data
if ~keyword_set(nosep) then begin
  mvn_sep_var_restore ;load SEP data
  mvn_sep_create_subarrays,'mvn_sep1_svy',zval='Rate'
  mvn_sep_create_subarrays,'mvn_sep2_svy',zval='Rate'
endif
if ~keyword_set(nostatic) then begin
mvn_sta_l2_load,sta_apid='c0' ;load STATIC data
mvn_sta_l2_tplot ;store STATIC data in tplot variables
if keyword_set(do3d) then mvn_sta_l2_load,sta_apid='d1' ;load STATIC 3d data
endif

;set tplot limits
zlim,'swe_a4',1e4,1e9
ylim,'mvn_swim_swi_mode',0,1
ylim,'mvn_swim_density',.01,100,1
ylim,'mvn_swim_velocity_mso',100,-800
ylim,'mvn_swis_en_eflux',25,25e3
zlim,'mvn_swis_en_eflux',1e3,1e8
ylim,'mvn_B_1sec',-10,10
ylim,'mvn_euv_data',.0001,.01,1
ylim,'mvn_sep*_*-O_Rate_Energy',10,1e3
zlim,'mvn_sep*_*-O_Rate_Energy',.1,1e4
options,'mvn_sep*_*-O_Rate_Energy','panel_size',1
ylim,'mvn_sta_c0_?_E',1,32e3,1
zlim,'mvn_sta_c0_?_E',1e3,1e8,1

end