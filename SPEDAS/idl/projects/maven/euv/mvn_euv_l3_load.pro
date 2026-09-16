;+
; NAME: mvn_euv_l3_load
; SYNTAX: 
;       mvn_euv_l3_load,/daily
;       or
;       mvn_euv_l3_load,/minute
; PURPOSE:
;       Load procedure for the EUV L3 (FISM) daily or minute data
; KEYWORDS: daily, minute 
; HISTORY:      
; VERSION: 
;  $LastChangedBy: ali $
;  $LastChangedDate: 2016-09-06 12:39:12 -0700 (Tue, 06 Sep 2016) $
;  $LastChangedRevision: 21800 $
;  $URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/spdsoft/trunk/projects/maven/euv/mvn_euv_l3_load.pro $
;CREATED BY:  ali 20150401
;FILE: mvn_euv_l3_load.pro
;-

pro mvn_euv_l3_load,trange=trange,daily=daily,minute=minute,tplot=tplot
  
  if keyword_set(daily) then begin
    L3_fileformat='maven/data/sci/euv/l3/YYYY/MM/mvn_euv_l3_daily_YYYYMMDD_v??_r??.cdf'
  endif else L3_fileformat='maven/data/sci/euv/l3/YYYY/MM/mvn_euv_l3_minute_YYYYMMDD_v??_r??.cdf'

  files = mvn_pfp_file_retrieve(L3_fileformat,trange=trange,/daily_names,/valid_only)
  
  if files[0] eq '' then begin
    dprint,dlevel=2,'No EUVM L3 (FISM) files were found for the selected time range.'
    store_data,'mvn_euv_l3',/delete
    return
  endif
  
  cdf2tplot,files,prefix='mvn_euv_l3_'
  
  get_data,'mvn_euv_l3_y',data=fismdata; FISM Irradiances
  store_data,'mvn_euv_l3_y',/delete

  store_data,'mvn_euv_l3',data={x:fismdata.x,y:fismdata.y,v:reform(fismdata.v[0,*])}, $
    dlimits={ylog:0,zlog:1,spec:1,ytitle:'Wavelength (nm)',ztitle:'FISM Irradiance (W/m2/nm)'}
  
  if keyword_set(tplot) then tplot,'mvn_euv_l3'

end
