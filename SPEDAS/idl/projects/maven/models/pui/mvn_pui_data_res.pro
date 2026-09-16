;20160404 Ali
;change the data resolution and load instrument pointings
;to be called by mvn_pui_model

pro mvn_pui_data_res,trange=trange,binsize=binsize

@mvn_pui_commonblock.pro ;common mvn_pui_common
common mvn_swia_data
common mvn_d1,mvn_d1_ind,mvn_d1_dat

;get data from tplot variables
get_data,'mvn_swim_density',data=swian; %solar wind density (cm-3)
get_data,'mvn_swim_velocity_mso',data=swiav; %solar wind velocity MSO (km/s)
get_data,'mvn_swis_en_eflux',data=swiaefdata; %swia energy spectrum
get_data,'swe_a4',data=sweaefdata; %swea energy spectrum
;get_data,'mvn_B_1sec_MAVEN_MSO',data=mag; magnetic field vector, MSO (nT)
get_data,'mvn_B_1sec',data=magdata; magnetic field vector, payload coordinates (nT)
;get_data,'SepAnc_mvn_pos_mso',data=pos; maven position (km)
;get_data,'SepAnc_sep_1f_fov_mso',data=dld1; %sep1f fov
;get_data,'SepAnc_sep_2f_fov_mso',data=dld2; %sep2f fov
get_data,'mvn_sep1_B-O_Rate_Energy',data=sep1data ; SEP1 count rates
get_data,'mvn_sep2_B-O_Rate_Energy',data=sep2data ; SEP2 count rates
get_data,'mvn_sep1_svy_ATT',data=sep1at ; SEP1 attenuator state
get_data,'mvn_sep2_svy_ATT',data=sep2at ; SEP2 attenuator state
;get_data,'mvn_euv_data',data=euvdata
get_data,'mvn_sta_c0_H_E',data=sta_c0_H_E_data ; STATIC m>12 energy spectra
get_data,'mvn_sta_c0_L_E',data=sta_c0_L_E_data ; STATIC m<12 energy spectra
get_data,'mvn_euv_l3',data=fismdata
get_data,'wind',data=wind

;average/interpolate the data over given resolution
if ~keyword_set(magdata) then begin
  dprint,'No MAG data available, returning...'
  stop
endif
magpayload=1e-9*average_hist2(magdata.y,magdata.x,binsize=binsize,trange=trange,centertime=centertime); magnetic field vector payload (T)
swalt=average_hist2(wind.y,wind.x,binsize=binsize,trange=trange,centertime=centertime); solar wind altitude (km)
nsw=average_hist2(swian.y,swian.x,binsize=binsize,trange=trange,centertime=centertime); solar wind density (cm-3)
vsw=1e3*average_hist2(swiav.y,swiav.x,binsize=binsize,trange=trange,centertime=centertime); solar wind velocity (m/s)
usw=sqrt(vsw[*,0]^2+vsw[*,1]^2+vsw[*,2]^2); solar wind speed (m/s)
swiaef=average_hist2(swiaefdata.y,swiaefdata.x,binsize=binsize,trange=trange,centertime=centertime); swia energy flux
swiaet=average_hist2(swiaefdata.v,swiaefdata.x,binsize=binsize,trange=trange,centertime=centertime); swia energy table

if n_elements(swica) ge 2 then begin
  swica3d=average_hist2(transpose(swica.data),swica.time_unix,binsize=binsize,trange=trange,centertime=centertime); swia energy flux
  swicadt=swica[1:*].time_unix-swica[0:-1].time_unix
  store_data,'swica_dt',swica[1:*].time_unix,swicadt
endif

if n_elements(swics) ge 2 then begin
  swics3d=average_hist2(transpose(swics.data),swics.time_unix,binsize=binsize,trange=trange,centertime=centertime); swia energy flux
  swicsdt=swics[1:*].time_unix-swics[0:-1].time_unix
  store_data,'swics_dt',swics[1:*].time_unix,swicsdt
endif

if keyword_set(swica) then swief3d=(n_elements(swica) ge n_elements(swics)) ? swica3d:swics3d

sweaef=average_hist2(sweaefdata.y,sweaefdata.x,binsize=binsize,trange=trange,centertime=centertime); swea energy flux
sweaet=sweaefdata.v

if keyword_set(sta_c0_L_E_data) then begin
  sta_c0H=average_hist2(sta_c0_H_E_data.y,sta_c0_H_E_data.x,binsize=binsize,trange=trange,centertime=centertime); static c0
  sta_c0L=average_hist2(sta_c0_L_E_data.y,sta_c0_L_E_data.x,binsize=binsize,trange=trange,centertime=centertime); static c0
  staetc0=average_hist2(sta_c0_L_E_data.v,sta_c0_L_E_data.x,binsize=binsize,trange=trange,centertime=centertime); static energy table
  store_data,'redures_H_sta_c0',centertime,sta_c0H,staetc0
  store_data,'redures_L_sta_c0',centertime,sta_c0L,staetc0
end

if keyword_set(mvn_d1_dat) then begin
  statef3d=average_hist2(mvn_d1_dat.eflux,mvn_d1_dat.time,binsize=binsize,trange=trange,centertime=centertime); static energy flux
  statetd1=average_hist2(mvn_d1_dat.energy[mvn_d1_dat.swp_ind,*,0,0],mvn_d1_dat.time,binsize=binsize,trange=trange,centertime=centertime); static energy table
endif

if keyword_set(sep1data) then begin
  sep1att=interp(sep1at.y,sep1at.x,centertime)
  sep2att=interp(sep2at.y,sep2at.x,centertime)
  sep1cps=average_hist2(sep1data.y,sep1data.x,binsize=binsize,trange=trange,centertime=centertime); sep1 counts/sec
  sep2cps=average_hist2(sep2data.y,sep2data.x,binsize=binsize,trange=trange,centertime=centertime); sep1 counts/sec
  store_data,'mvn_sep1_redures',centertime,sep1cps,sep1data.v
  store_data,'mvn_sep2_redures',centertime,sep2cps,sep2data.v
  options,'mvn_sep?_redures','spec',1
  ylim,'mvn_sep?_redures',10,1e3,1
  zlim,'mvn_sep?_redures',.1,1e4,1
  sep1dt=sep1data.x[1:*]-sep1data.x[0:-1]
  sep2dt=sep2data.x[1:*]-sep2data.x[0:-1]
  store_data,'sep1_dt',sep1data.x[1:*],sep1dt
  store_data,'sep2_dt',sep2data.x[1:*],sep2dt
endif

if size(fismdata,/type) eq 2 then fismir=0 else fismir=interp(fismdata.y,fismdata.x,centertime)

;rotate MAG data into MSO coordinates (Tesla)
mag=transpose(spice_vector_rotate(transpose(magpayload),centertime,'MAVEN_SPACECRAFT','MAVEN_MSO',check_objects='MAVEN_SPACECRAFT'))
magtot=sqrt(mag[*,0]^2+mag[*,1]^2+mag[*,2]^2); magnetic field magnitude (T)

scp=1e3*transpose(spice_body_pos('MAVEN','MARS',frame='MSO',utc=centertime)) ;MAVEN position MSO (m)
inn=n_elements(centertime) ;number of time steps
xdir=[1.,0,0]#replicate(1.,inn) ;SEP front FOV
ydir=[0,1.,0]#replicate(1.,inn) ;Y-direction
zdir=[0,0,1.]#replicate(1.,inn) ;Z-direction (symmetry axis of SWIA and STATIC)
sep1ld=transpose(spice_vector_rotate(xdir,centertime,'MAVEN_SEP1','MSO',check_objects='MAVEN_SPACECRAFT')); sep1 look direction MSO
sep2ld=transpose(spice_vector_rotate(xdir,centertime,'MAVEN_SEP2','MSO',check_objects='MAVEN_SPACECRAFT')); sep2 look direction MSO
;swizld=transpose(spice_vector_rotate(zdir,centertime,'MAVEN_SWIA','MSO',check_objects='MAVEN_SPACECRAFT')); SWIA-Z look direction
staxld=transpose(spice_vector_rotate(xdir,centertime,'MAVEN_STATIC','MSO',check_objects=['MAVEN_APP_OG','MAVEN_SPACECRAFT'])); STATIC-X look direction
stazld=transpose(spice_vector_rotate(zdir,centertime,'MAVEN_STATIC','MSO',check_objects=['MAVEN_APP_OG','MAVEN_SPACECRAFT'])); STATIC-Z look direction

if keyword_set(swief3d) then begin

swiaef3d=replicate(0.,inn,swieb,swina,swine) ;swap swia dimentions to match the model (time-energy-az-el)
for j=0,swina-1 do begin ;loop over azimuth bins
  for k=0,swine-1 do begin ;loop over elevation bins
    for i=0,swieb-1 do begin ;loop over energy bins
      swiaef3d[*,i,j,k]=swief3d[*,j,3-k,i]
    endfor
  endfor
endfor

endif

;create tplot variables from calculated new cadenses
;SWIA moments
store_data,'n_sw_(cm-3)',centertime,nsw
ylim,'n_sw_(cm-3)',.01,100,1
store_data,'Vsw_MSO_(km/s)',centertime,[[vsw],[-usw]]/1e3
options,'Vsw_MSO_(km/s)','colors','bgrk'
;MAG
store_data,'MAG_MSO_(nT)',centertime,1e9*[[mag],[magtot]]
options,'MAG_MSO_(nT)','colors','bgrk'
ylim,'MAG_MSO_(nT)',-10,10
;POS
store_data,'MAVEN_pos_(km)',centertime,scp/1e3
options,'MAVEN_pos_(km)','colors','bgrk'
;SEP FOV
store_data,'sep1_FOV',centertime,sep1ld
store_data,'sep2_FOV',centertime,sep2ld
;SWEA
store_data,'redures_swea',centertime,sweaef,sweaet
options,'redures_swea','spec',1
ylim,'redures_swea',3,5e3,1
zlim,'redures_swea',1e4,1e9,1
;SWIA
store_data,'redures_swia',centertime,swiaef,swiaet
options,'redures_swia','spec',1
ylim,'redures_swia',25,25e3,1
zlim,'redures_swia',1e3,1e8,1

tplot_options,'no_interp',1


end