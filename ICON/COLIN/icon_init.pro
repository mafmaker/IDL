;+
; 
; 
; 
; Copied From goes_init.pro 20 Jan 2016
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
;-

pro icon_init, reset=reset, local_data_dir=local_data_dir, remote_data_dir=remote_data_dir, $
  no_color_setup=no_color_setup,no_download=no_download

cdf_leap_second_init

defsysv,'!icon',exists=exists
if not keyword_set(exists) then begin
  defsysv, '!icon', file_retrieve(/structure_format)
endif

if (keyword_set(reset)) then !icon.init = 0

if (!icon.init) ne 0 then return

!icon = file_retrieve(/structure_format)

icon_config,no_color_setup=no_color_setup,no_download=no_download

;Sets verbose levels that are in !icon write pro like thm_set_verbose

!icon.init = 1

printdat,/values,!icon,varname='!icon' 


!icon.min_age_limit = 900  ;Don't get new data if local file is less than 15 mins old

if file_test(!icon.local_data_dir+'.master') then begin
  !icon.no_server = 1
endif


  
!icon.init = 1

printdat,/values,!icon,varname='!icon'

end