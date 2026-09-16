


pro misc2
  hkp= spp_apdat('36E'x)
  s=hkp.data.array
  
  naan = !values.f_nan
 ; sgn= fix(s.mram_wr_addr_hi eq 1) - fix(s.mram_wr_addr_hi eq 2)
sgns = [!values.f_nan,1.,-1., !values.f_nan]
  sgn = sgns[0 > s.mram_wr_addr_hi < 3]
  def = s.mram_wr_addr * sgn
;  def = s.mram_wr_addr *  sign(s.adc_vmon_def1 - s.adc_vmon_def2)
  store_data,'DEF1-DEF2',s.time,float(def)

end



pro spane_center_energy,tranges=tt,emid=emid,ntot=ntot

  channels = [3,2,1,0,8,9,10,11,12,13,14,15,7,6,5,4]
  rotation = [-108.,-84,-60,-36,-21,-15,-9,-3,3.,9,15,21,36,60,84,108]
  emid = replicate(0.,16)
  ntot = replicate(0.,16)
  xlim,lim,4500,5500
  
  for i=0,15 do begin
    trange=tt[*,i]
    scat_plot,'spp_spane_hkp_ACC_DAC','spp_spane_spec_CNTS2',trange=trange,lim=lim,xvalue=x,yvalue=y,ydimen= channels[i]
    ntot[i] = total(y)
    emid[i] = total(x*y)/total(y)
  endfor

;  Emid = [5070, 5107, 5112,

end


pro spane_deflector_scan,tranges = trange
    scat_plot,/swap_interp,'DEF1-DEF2','spp_spane_spec_CNTS2',trange=trange,lim=lim,xvalue=x,yvalue=y,ydimen= 4
end


pro spane_threshold_scan,tranges=trange,lim=lim   ;now obsolete
  swap_interp=0
  xlim,lim,0,512
  ylim,lim,10,10000,1
  options,lim,psym=4  
  scat_plot,swap_interp=swap_interp,'spp_spane_hkp_ACC_DAC','spp_spane_spec_CNTS2',trange=trange[*,1],lim=lim,xvalue=x,yvalue=y,ydimen= 4;,color=4
  scat_plot,swap_interp=swap_interp,'spp_spane_hkp_ACC_DAC','spp_spane_spec_CNTS2',trange=trange[*,0],lim=lim,xvalue=x,yvalue=y,ydimen= 4,color=6,/overplot
  scat_plot,swap_interp=swap_interp,'spp_spane_hkp_ACC_DAC','spp_spane_spec_CNTS2',trange=trange[*,2],lim=lim,xvalue=x,yvalue=y,ydimen= 4,color=2,/overplot
end


pro spane_threshold_scan_phd,tranges=trange,lim=lim
  
  if ~keyword_set(trange) then ctime,trange,npo=2
  swap_interp=0
  xlim,lim,0,550
  ylim,lim,10,5000,1
  options,lim,psym=4
  scat_plot,swap_interp=swap_interp,'spp_spane_hkp_ACC_DAC','spp_spane_p1_CNTS',trange=trange,lim=lim,xvalue=dac,yvalue=cnts,ydimen= 4;,color=4
  range = [80,500]
  xp = dgen(8,range=range)
  yp = xp*0+500
  xv = dgen()
  !p.multi = [0,1,2]
  yv = spline_fit3(xv,xp,yp,param=p,/ylog)
  fit,dac,cnts,param=p
  pf,p,/over
 ; wi,2
  plot,dac,cnts,psym=4,xtitle='Threshold DAC level',ytitle='Counts'
  ;pf,p,/over
  plt1 = get_plot_state()
  xv = dgen(range=range)
;  wi,3
  plot,xv,-deriv(xv,func(xv,param=p)),xtitle='Threshold DAC level',ytitle='PHD'
  plt2= get_plot_state()
  
end




f= spp_file_retrieve( 'spp/data/sci/sweap/prelaunch/gsedata/EM/z320/20160331_125002_/PTP_data.dat' )
f= spp_file_retrieve( 'spp/data/sci/sweap/prelaunch/gsedata/EM/mgsehires1/20160801_092658_flightToFlight_contd/PTP_data.dat' )


;files = spp_swp_spane_functiontest1_files()

files = f

spp_swp_startup



spp_ptp_file_read, spp_file_retrieve( 'spp/data/sci/sweap/prelaunch/gsedata/EM/mgsehires1/20160729_150358_FLTAE_digital/PTP_data.dat' )

spp_ptp_file_read, spp_file_retrieve( 'spp/data/sci/sweap/prelaunch/gsedata/EM/mgsehires1/20160801_092658_flightToFlight_contd/PTP_data.dat' )
spp_msg_file_read, spp_file_retrieve( 'spp/data/sci/sweap/prelaunch/gsedata/EM/mgsehires1/20160801_092658_flightToFlight_contd/GSE_all_msg.dat' )
spp_ptp_file_read, spp_file_retrieve( 'spp/data/sci/sweap/prelaunch/gsedata/EM/mgsehires1/20160802_081922_flightToFlight_contd2/PTP_data.dat' )
spp_msg_file_read, spp_file_retrieve( 'spp/data/sci/sweap/prelaunch/gsedata/EM/mgsehires1/20160802_081922_flightToFlight_contd2/GSE_all_msg.dat' )


spp_ptp_file_read, spp_file_retrieve( 'spp/data/sci/sweap/prelaunch/gsedata/EM/SWEAP-2/20160727_115654_large_packet_test/PTP_data.dat')
spp_msg_file_read, spp_file_retrieve( 'spp/data/sci/sweap/prelaunch/gsedata/EM/SWEAP-2/20160727_115654_large_packet_test/GSE_all_msg.dat')

spp_msg_file_read, spp_file_retrieve( 'spp/data/sci/sweap/prelaunch/gsedata/EM/SWEAP-2/20160805_125639_ramp_up/GSE_all_msg.dat')  ; Ion ramp in which SWEMULATOR reset?


spp_ptp_file_read, spp_file_retrieve('spp/data/sci/sweap/prelaunch/gsedata/EM/SWEAP-3/20160920_084426_BfltBigCalChamberEAscan/PTP_data.dat.gz')

spp_ptp_file_read, spp_file_retrieve('spp/data/sci/sweap/prelaunch/gsedata/EM/SWEAP-3/20160923_165136_BfltContinuedPHDscan/PTP_data.dat')
;spp_ptp_file_read, spp_file_retrieve('spp/data/sci/sweap/prelaunch/gsedata/EM/mgsehires1/20161229_001105_/PTP_data.dat')
spp_ptp_file_read, spp_file_retrieve('spp/data/sci/sweap/prelaunch/gsedata/EM/mgsehires1/20161223_163710_test/PTP_data.dat') ;second cycling attempt cover open




;   spane B flight CO pre conformal coat
files = spp_file_retrieve(/elec,/cal,trange=['2016 9 28 12','2016 9 29 8']) 




 trange =  '2016 10 '+ ['18/04','19/22']   ; SPANE - A flght in Cal chamber:  MCP test
 trange =  '2016 11 '+ ['18/21','18/23']  ; SPAN-Ae FM postcoat w/ attenuator: Full rotation (angles incorrect, ROT not zeroed)

 trange =  '2016 11 '+ ['19/00','19/02'] ; SPAN-Ae FM quick EA scan
 trange =  '2016 11 '+ ['19/02','19/04'] ; SPAN-Ae FM rotation @ 2degrees Yaw, which has been shown to be the beam emit angle
 trange =  '2016 11 '+ ['20/00','20/07'] ; SPAN-Ae FM thresh & MCP scan @ 2degrees Yaw
 trange =  '2016 11 '+ ['21/01','21/23'] ; SPAN-Ae FM deflector test
 trange =  '2016 11 '+ ['21/23','22/02'] ; SPAN-Ae FM spoiler test

  

 ;;SPANB PRE VIBE CAL
 ; Note that these should be loaded as spanea
 trange = '2016 12 '+ ['06/02','06/05']
 trange = '2016 12 '+ ['05/12','06/00']
 trange = '2016 12 '+ ['05/19','06/00'] ; SPAN-B FM pre-Vibe sweep yaw test w/ correction of yawlin (other version is yaw only)
 trange = '2016 12 '+ ['05/23','06/02'] ; SPAN-B FM pre-Vibe low energy electrons grab

 trange = '2016 12 '+ ['02/23','03/01'] ; SPAN-B FM pre-Vibe spoiler test @ 2degrees Yaw & full rotation @ 2degrees yaw
 trange = '2016 12 '+ ['02/18','02/22'] ; SPAN-B FM pre-Vibe deflector test on anodes 14 & 15
 trange = '2016 11 '+ ['30/01','30/03'] ; SPAN-B FM deflector test on anode 0
 trange = '2016 11 '+ ['30/02','30/04'] ; SPAN-B FM deflector test on anode 1
 ;anode 2 partial coverage
 ;anode 3 partial coverage
 ;anode 4 partial coverage
 trange = '2016 11 '+ ['30/08','30/10'] ; SPAN-B FM deflector test on anode 5
 ;anode 6 partial coverage
 trange = '2016 11 '+ ['30/11','30/13'] ; SPAN-B FM deflector test on anode 7
 trange = '2016 11 '+ ['30/12','30/14'] ; SPAN-B FM deflector test on anode 8
 trange = '2016 11 '+ ['30/13','30/15'] ; SPAN-B FM deflector test on anode 9
 ;anode 10 no coverage
 ;anode 11 partial coverage
 trange = '2016 11 '+ ['30/17','30/19'] ; SPAN-B FM deflector test on anode 12
 trange = '2016 11 '+ ['30/18','30/22'] ; SPAN-B FM deflector test on anode 13
 trange = '2016 11 '+ ['29/04','29/08'] ; SPAN-B FM ea quick scan - missing data for some anodes
 
 ;; SPANB TBAL & cover opening Malfunction
 trange = '2016 12 '+ ['22/06','22/11'] ; SPAN-B FM TBAL cover opening - failure. SPANB is XX
 trange = '2016 12 '+ ['22/18','22/20'] ; SPAN-B FM TBAL cover opening - indicating open. SPANB is XX
 trange = '2016 12 '+ ['23/16','24/03'] ; SPAN-B FM TBAL temeprature data - op heater. SPANB is Cold.
 
 
 files = spp_file_retrieve(/elec,/cal,trange=trange)
 trange = '2016 12 '+ ['02/00','03/12'] ; SPAN-B FM pre-Vibe last load
 trange = '2016 12 '+ ['01/00','02/00'] ; SPAN-B FM pre-Vibe contains nothing

;  Get recent data files:
files = spp_file_retrieve(/spanea,/cal,recent=1/24.)   ; get last 1 hour of data from server
files = spp_file_retrieve(/spanea,/cal,recent=4/24.)   ; get last 4 hours of data from server

; Read  (Load) files
spp_ptp_file_read,files


; Real time data collection:
spp_init_realtime,/spanea,/cal,/exec


tplot, 'manip*',/add
spp_swp_tplot,/setlim
spp_swp_tplot,'SE'
spp_swp_tplot,'SE_hv'
spp_swp_tplot,'SE_lv'
spp_swp_tplot,'SE'


; print information on collected data
spp_apdat_info,/print



; get SPANE-A HKP data:
hkp = spp_apdat('36e'x)

hkp.help

hkp.print

printdat, hkp.strct

printdat, hkp.data      ; return the 

printdat, hkp.data.array   ; return a copy of the data array

printdat, hkp.data.size    ; return the number of elements in the data array

printdat, hkp.data.typename   ; return the typename of the data array 

printdat,  hkp.data.array[-1]  ; return the current last element of the data array








; Get info on 




tplot,'*CNTS *DCMD_REC *VMON_MCP *VMON_RAW *ACC*'


if 0 then begin
  tplot,'spp_spane_?_ar_????_p1*',/names
  
  
  
  
endif





if 1 then begin
  options,'spp_spane_spec_CNTS',spec=0,yrange=[.5,5000],ystyle=1,ylog=1,colors='mbcgdr'
  options,'spp_spane_spec_CNTS1',spec=0,yrange=[.5,5000],ystyle=1,ylog=1,colors='mbcgdr'
  options,'spp_spane_spec_CNTS2',spec=0,yrange=[.5,5000],ystyle=1,ylog=1,colors='mbcgdr'
endif else begin
  options,'spp_spane_spec_CNTS',spec=1,yrange=[-1,16],ylog=0,zrange=[1,500.],zlog=1,/no_interp
  options,'spp_spane_spec_CNTS1',spec=1,yrange=[-1,32],ylog=0,zrange=[1,500.],zlog=1,/no_interp
  options,'spp_spane_spec_CNTS2',spec=1,yrange=[-1,16],ylog=0,zrange=[1,500.],zlog=1,/no_interp
endelse


if 0 then begin
  tplot,'spp_spani_hkp_HEMI_CDI spp_manip_MROTPOS spp_spani_tof_TOF APID spp_spani_rates_VALID_CNTS
  tplot,'spp_spani_ar_full_p0_m?_*_SPEC2'
  tplot,'spp_spani_ar_full_p1_m?_*_SPEC2'
  
  
  store_data,'ALL_C',data='spp_*_C'
  store_data,'ALL_V',data='spp_*_V'
  store_data,'ALL_ERR_CNT',data='spp_*_ERR_CNT'
  store_data,'ALL_ERR',data='spp_*_ERR'
  store_data,'ALL_CMD_CNT',data='spp_*_CMDS_*'
  !y.style=3
  tplot_options,'ynozero',1
  
  tplot,'APID'
  tplot,'spp_*_TEMPS ALL_? *NYS*',/add
  tplot,'ALL_ERR_CNT',/add
  tplot,'ALL_ERR',/add
  tplot,'ALL_CMD_CNT',/add
  tplot,/add,'spp*hkp*ERR_CNT'
  tplot,/add,'spp_*_C'
;  tplot/
  
endif




end

