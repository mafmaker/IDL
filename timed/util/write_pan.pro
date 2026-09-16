;+
; NAME:
;	write_pan.pro
;
; PURPOSE:
;	Write a Product Availability Notice (PAN) file
;
; CATEGORY:
;	All data processing levels.
;
; CALLING SEQUENCE:  
;	write_pan, action, type, version, revision, yyyydoy, url, status
;
; INPUTS:
;	action = "N" for new data, "U" for updated data, "D" for deleted data
;	type = Data product name (i.e.  SEE Level 1 XPS Data)
;	version = version number for data
;	revision = revision number of data
;	yyyydoy = date for data
;	url = complete URL for data file
;
; OUTPUTS:  
;	status = OK_STATUS (0) if wrote PAN file OK,
;			BAD_PARAMS (-1) if invalid parameters,
;			BAD_FILE (-2) if problem writing file
;
; COMMON BLOCKS:
;	None
;
; PROCEDURE:
;	1.  Check input parameters
;	2.  Open PAN file
;	3.  Write / close PAN file
;
; MODIFICATION HISTORY:
;	11/22/99	Tom Woods	Original creation for Version 1.0.0
;
;+

pro write_pan, action, type, version, revision, yyyydoy, url, status

;
;	Define CONSTANTS used in SEE data processing
;
@$see_code_hdr/see_defines.pro

;
;	set default output values
;
status = BAD_PARAMS

;
;	1.  Check input parameters
;
if (n_params(0) lt 6) then return

action = strupcase(strmid(action,0,1))
if (action ne 'N') and (action ne 'U') and (action ne 'D') then return

;
;	2.  Open PAN file
;		Filename uses current time as part of its filename
;
theTime = bin_date( systime() )
theDay = ymd2yyyydoy( theTime[0], theTime[1], theTime[2] )
strtime = string( theDay, format='(I7)' )					; year + day of year
strtime = strtime + string( theTime[3], format='(I2)' )		; hour
strtime = strtime + string( theTime[4], format='(I2)' )		; minute
strtime = strtime + string( theTime[5], format='(I2)' )		; second
sp = strpos( strtime, ' ' )
while (sp ge 0) do begin
	strput, strtime, '0', sp
	sp = strpos( strtime, ' ' )
endwhile
filename = 'SEE__' + strtime + '_' + $
	SEE_PAN_REVISION_STR + '.pan'
if ( !d.name eq 'MAC' ) then begin
	data_dir = SEE_MAC_CODE + 'see_data:'	; for Mac OS
	att_dir = SEE_MAC_CODE + 'see_data:'	; for Mac OS
endif else begin
	data_dir = getenv( 'see_data_pan' ) + '/'	; for SUN OS
	att_dir = getenv( 'see_data_att' ) + '/'	; for SUN OS
endelse			
full_file = data_dir + filename
att_file = att_dir + 'see_pan.att'

on_ioerror, bad_open
openw,pan_lun, full_file, /get_lun

;
;	3.  Write / close PAN file
;
on_ioerror, bad_write

;
;	write TIMED Standard Header
;
see_hdr = get_see_header( att_file, full_file )
num_hdr = n_elements(see_hdr)
for i=0,num_hdr-1 do printf, pan_lun, see_hdr[i]
printf, pan_lun, 'END_OF_HEADER'

TAB_STR = ' '
strput, TAB_STR, 9B, 0
CR_STR = ' '
strput, CR_STR, 13B, 0
printf, pan_lun, action + TAB_STR + $
				strtrim(type,2) + TAB_STR + $
				strtrim(revision,2) + TAB_STR + $
				strtrim(url,2) + TAB_STR + $
				strtrim(yyyydoy,2) + '000000' + TAB_STR + $
				strtrim(yyyydoy,2) + '235959' + TAB_STR + $
				strtrim(version,2) + TAB_STR + ' '
				
goto, end_write

bad_write:
	close, pan_lun
	free_lun, pan_lun
bad_open:
	on_ioerror, NULL
	status = BAD_FILE
	return

end_write:
	close, pan_lun
	free_lun, pan_lun
	on_ioerror, NULL
	status = OK_STATUS

return
end
