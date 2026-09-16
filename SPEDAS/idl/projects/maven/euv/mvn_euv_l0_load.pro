;+
; NAME:
;       mvn_euv_l0_load
; PURPOSE:
;       Load procedure for EUV L0 data. Use for looking at raw EUV data (slow).
;       Use mvn_euv_load instead to load EUV L2 data (calibrated), which is
;       much faster, but EUV L2 files are currently about a month behind.
; KEYWORDS: 
;   trange: specifies the time range
;   tplot: plots a time-series of the loaded data
; HISTORY:
; VERSION:
;  $LastChangedBy: ali $
;  $LastChangedDate: 2016-09-06 12:39:12 -0700 (Tue, 06 Sep 2016) $
;  $LastChangedRevision: 21800 $
;  $URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/spdsoft/trunk/projects/maven/euv/mvn_euv_l0_load.pro $
;CREATED BY:  ali 20160830
;FILE: mvn_euv_l0_load.pro
;-

pro mvn_euv_l0_load,trange=trange,tplot=tplot,verbose=verbose

  files = mvn_pfp_file_retrieve(/l0,trange=trange,/daily_names,/valid_only,verbose=verbose) ;daily l0 files

  if files[0] eq '' then begin
    dprint,dlevel=2,'No L0 files were found for the selected time range.'
    return
  endif
  
  for i=0,n_elements(files)-1 do begin
    mvn_lpw_load_file,files[i],tplot_var='SCI',filetype=filetype,packet='EUV',board=board,use_compression=use_compression,/nospice ;l0 loader
    options,'mvn_lpw_euv','colors','bgrk'
    get_data,'mvn_lpw_euv',data=mvn_lpw_euv_1day,limits=limits,dlimits=dlimits ;get tplot variables
    append_array,mvn_lpw_euv_x,mvn_lpw_euv_1day.x ;append days
    append_array,mvn_lpw_euv_y,mvn_lpw_euv_1day.y
  endfor
  mvn_lpw_euv_y+=4.6e5; add the offset back to the signals
  limits.xtitle=''
  dlimits.ysubtitle+='+4.6e5'

  store_data,'mvn_euv_l0',mvn_lpw_euv_x,mvn_lpw_euv_y,limits=limits,dlimits=dlimits
  ylim,'mvn_euv_l0',1e4,1e6,1

  if keyword_set(tplot) then tplot,'mvn_euv_l0'

end
