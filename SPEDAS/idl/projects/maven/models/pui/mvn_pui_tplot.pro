;20160504 Ali
;create tplot variables from the pickup ion model results
;keywords:
;   store3d: stores 3d pickup ion spectra in tplot variables
;   tplot1d: plots the main results (model-data comparison)
;   swia3d: plots SWIA pickup hydrogen and oxygen 3d spectra
;   static3d_h: plots STATIC 3d spectra, pickup hydrogen (D1 data product, mass channels 0,1,2)
;   static3d_o: plots STATIC 3d spectra  pickup oxygen   (D1 data product, mass channels 3,4,5)

pro mvn_pui_tplot,store1d=store1d,tplot1d=tplot1d,store3d=store3d,swia3d=swia3d,static3d_h=static3d_h,static3d_o=static3d_o

@mvn_pui_commonblock.pro ;common mvn_pui_common
common mvn_swia_data
common mvn_d1,mvn_d1_ind,mvn_d1_dat

tplot_options,'no_interp',1

totet=exp(totdee*dindgen(toteb,start=126.5,increment=-1)); total flux energy bin midpoints (312 keV to 15.6 keV)
swiet=exp(swidee*dindgen(swieb,start=69.5,increment=-1)); SWIA (post Nov 2014) energy bin midpoints (23 keV to 26 eV)
staet=exp(stadee*dindgen(staeb,start=63.4,increment=-1)); STATIC (mode 4) energy bin midpoints (31 keV to 1.0 eV)
sweet=exp(swedee*dindgen(sweeb,start=72.5,increment=-1)); SWEA energy bin midpoints (4627 eV to 3.0 eV)

if keyword_set(store1d) then begin
store_data,'mvn_model_puh_tot',data={x:centertime,y:kefluxh,v:totet}, $
  dlimits={ylog:1,zlog:1,spec:1,yrange:[10.,300e3],ytitle:'Model PUH',zrange:[1e2,1e6],ztitle:'Eflux'}
store_data,'mvn_model_puo_tot',data={x:centertime,y:kefluxo,v:totet}, $
  dlimits={ylog:1,zlog:1,spec:1,yrange:[10.,300e3],ytitle:'Model PUO',zrange:[1e2,1e6],ztitle:'Eflux'}
  
if keyword_set(sep1data) then begin
  store_data,'mvn_model_puo_sep1',centertime,sepeb1att,sep1data.v
  store_data,'mvn_model_puo_sep2',centertime,sepeb2att,sep2data.v
  options,'mvn_model_puo_sep?','spec',1
  ylim,'mvn_model_puo_sep?',10,1e3,1
  zlim,'mvn_model_puo_sep?',.1,1e4,1
endif

store_data,'mvn_model_swia',centertime,kefswih+kefswio,swiet
;store_data,'mvn_model_swia_O',centertime,kefswio,swiaet
;store_data,'mvn_model_swia_H',centertime,kefswih,swiaet
options,'mvn_model_swia','spec',1
ylim,'mvn_model_swia',25,25e3,1
zlim,'mvn_model_swia',1e3,1e8,1

store_data,'mvn_model_H_sta_c0',centertime,kefstao,staet
store_data,'mvn_model_L_sta_c0',centertime,kefstah,staet
options,'*_sta_c0','spec',1
ylim,'*_sta_c0',1,35e3,1
zlim,'*_sta_c0',1e3,1e8,1
endif

if keyword_set(store3d) then begin
  store_data,'mvn_*_3d_A*_D*',/delete
  dprint,dlevel=2,'Creating 3D tplots. This may take a minute or two...'

  for j=0,swina-1 do begin ;loop over azimuth bins
    for k=0,swine-1 do begin ;loop over elevation bins
      jj=15-((j+9) mod 16)
      store_data,'mvn_swia_model_3d_A'+strtrim(jj,2)+'_D'+strtrim(k,2),centertime,kefswih3d[*,*,jj,k]+kefswio3d[*,*,jj,k],swiet
      store_data,'mvn_swia_data_3d_A'+strtrim(jj,2)+'_D'+strtrim(k,2),centertime,swiaef3d[*,*,jj,k],swiet
;      store_data,'mvn_swia_data_3d_A'+strtrim(jj,2)+'_D'+strtrim(k,2),swica.time_unix,transpose(swica[*].data[*,3-k,jj]),swiet
      store_data,'mvn_stat_modelH_3d_A'+strtrim(jj,2)+'_D'+strtrim(k,2),centertime,kefstao3d[*,*,jj,k],staet
      store_data,'mvn_stat_modelL_3d_A'+strtrim(jj,2)+'_D'+strtrim(k,2),centertime,kefstah3d[*,*,jj,k],staet
      if keyword_set(mvn_d1_dat) then begin
        store_data,'mvn_stat_dataH_3d_A'+strtrim(jj,2)+'_D'+strtrim(k,2),centertime,total(statef3d[*,*,k+4*jj,3:5],4),statetd1
        store_data,'mvn_stat_dataL_3d_A'+strtrim(jj,2)+'_D'+strtrim(k,2),centertime,total(statef3d[*,*,k+4*jj,0:2],4),statetd1
;        store_data,'mvn_stat_dataH_3d_A'+strtrim(jj,2)+'_D'+strtrim(k,2),mvn_d1_dat.time,total(mvn_d1_dat.eflux[*,*,k+4*jj,3:5],4),mvn_d1_dat.energy[mvn_d1_dat.swp_ind,*,0,0]
;        store_data,'mvn_stat_dataL_3d_A'+strtrim(jj,2)+'_D'+strtrim(k,2),mvn_d1_dat.time,total(mvn_d1_dat.eflux[*,*,k+4*jj,0:2],4),mvn_d1_dat.energy[mvn_d1_dat.swp_ind,*,0,0]
      endif
      ;      store_data,'mvn_stat_model_3d_A'+strtrim(jj,2)+'_D'+strtrim(k,2),centertime,kefstah3d[*,*,jj,k]+kefstao3d[*,*,jj,k],staet
      ;      store_data,'mvn_stat_data_3d_A'+strtrim(jj,2)+'_D'+strtrim(k,2),mvn_ca_dat.time,mvn_ca_dat.eflux[*,*,k+4*jj],mvn_ca_dat.energy[mvn_ca_dat.swp_ind,*,0]
   endfor
  endfor
  options,'mvn_swia*','spec',1
  ylim,'mvn_swia*',25,25e3,1
  zlim,'mvn_swia*',1e4,1e8,1

  options,'mvn_stat*','spec',1
  ylim,'mvn_stat*',1,35e3,1
  zlim,'mvn_stat*',1e4,1e8,1
endif

if keyword_set(swia3d) then begin
  swiastat='swia'
  statmass=''
endif

if keyword_set(static3d_h) then begin
  swiastat='stat'
  statmass='L'
endif

if keyword_set(static3d_o) then begin
  swiastat='stat'
  statmass='H'
endif

if keyword_set(swia3d) || keyword_set(static3d_h) || keyword_set(static3d_o) then begin
  !p.background=2
  !p.color=-1
  wi,1,wsize=[480,1000],wposition=[0*480,0]
  wi,5,wsize=[480,1000],wposition=[0*480,0]
  wi,2,wsize=[480,1000],wposition=[1*480,0]
  wi,6,wsize=[480,1000],wposition=[1*480,0]
  wi,3,wsize=[480,1000],wposition=[2*480,0]
  wi,7,wsize=[480,1000],wposition=[2*480,0]
  wi,4,wsize=[480,1000],wposition=[3*480,0]
  wi,8,wsize=[480,1000],wposition=[3*480,0]
  tplot,'mvn_'+swiastat+'_data'+statmass+'_3d_A*_D0',window=1
  tplot,'mvn_'+swiastat+'_data'+statmass+'_3d_A*_D1',window=2
  tplot,'mvn_'+swiastat+'_data'+statmass+'_3d_A*_D2',window=3
  tplot,'mvn_'+swiastat+'_data'+statmass+'_3d_A*_D3',window=4
  tplot,'mvn_'+swiastat+'_model'+statmass+'_3d_A*_D0',window=5
  tplot,'mvn_'+swiastat+'_model'+statmass+'_3d_A*_D1',window=6
  tplot,'mvn_'+swiastat+'_model'+statmass+'_3d_A*_D2',window=7
  tplot,'mvn_'+swiastat+'_model'+statmass+'_3d_A*_D3',window=8
  !p.background=-1
  !p.color=0
endif

if keyword_set(tplot1d) then begin
wi,0 ;tplot main results (model-data comparison)
tplot,'alt2 n_sw_(cm-3) Vsw_MSO_(km/s) redures_swia mvn_model_swia MAG_MSO_(nT) O+_Max_Energy_(keV) mvn_sep?_B-O_Rate_Energy mvn_model_puo_sep? *_sta_c0',window=0
wi,10 ;tplot most of the variables. for diagnostic purposes, best shown on a vertical screen
tplot,'MAVEN_pos_(km) swe_a4 redures_swea mvn_swim_density mvn_swim_velocity_mso mvn_swim_atten_state mvn_swim_swi_mode swica_dt swics_dt mvn_swis_en_eflux mvn_B_1sec MAG_MSO_(nT) sep1_dt sep2_dt mvn_sep?_redures mvn_SEPS_svy_ATT mvn_euv_l3 mvn_euv_data Ionization_Frequencies_(s-1) mvn_sta_c0_att mvn_sta_c0_mode',window=10
endif

;tplot_names
;printdat
end