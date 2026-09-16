



PRO icon_load_data, trange = trange, datatype = datatype, suffix = suffix, $
  downloadonly = downloadonly, no_time_clip = no_time_clip, $
  tplotnames = tplotnames, varformat = varformat, get_support_data = get_support_data, noephem = noephem

compile_opt idl2


icon_init


; ISSUES WITH FINDING TIMES FOR FILES.  FIX LATER.
; 
; 
; 
;if undefined(suffix) then suffix = ''
;
;; handle possible server errors
;catch, errstats
;if errstats ne 0 then begin
;  dprint, dlevel=1, 'Error: ', !ERROR_STATE.MSG
;  catch, /cancel
;  return
;endif
;
;
;; set the default datatype to MIGHTI data
;if not keyword_set(datatype) then datatype = 'mighti'
;if not keyword_set(source) then source = !icon
;if (keyword_set(trange) && n_elements(trange) eq 2) $
;  then tr = timerange(trange) $
;else tr = timerange()
;
;tn_list_before = tnames('*')
;
;dprint,dlevel=2,verbose=source.verbose,'Loading ICON ',strupcase(datatype),' data'
;
;local_dir = !icon.local_data_dir
;
;t_ran = time_string(tr,tformat='YYYY-MM-DD_hh.mm.ss')
;
;t_0 = t_ran[0]
;t_1 = t_ran[1]

 

;stop
if(datatype eq 'fuv' )    then dir = '/Users/Triplett/data/icon/fuv/l1/2009/03/20/'
if(datatype eq 'ivm' )    then dir = '/Users/Triplett/data/icon/ivm/l1/2016/03/26/'
if(datatype eq 'euv' )    then dir = '/Users/Triplett/data/icon/euv/l1/'
if(datatype eq 'mighti_a' )  then dir = '/Users/Triplett/data/icon/mighti_a/L2.1/2013/03/23/'
if(datatype eq 'mighti_b' )  then dir = '/Users/Triplett/data/icon/mighti_b/L2.1/2013/03/23/'
if(datatype eq 'mighti_l22') then dir = '/Users/Triplett/data/icon/mighti_a/L2.2/2013/03/23/'
;if(probes eq 'mighti') then dir ='/Users/triplett/Dropbox/For_Katie/NewWork/MIGHTI_L2/'
;stop

files = file_search(dir,'*.NC',/fold_case)


netcdf2tplot_icon,files

end