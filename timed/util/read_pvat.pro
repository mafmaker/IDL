;+
; NAME:
;	read_pvat
;
; PURPOSE:
;	Read a TIMED PVAT file
;
; CATEGORY:
;	SEE Level 0B
;
; CALLING SEQUENCE:  
;	pvat_data = read_pvat( yyyydoy, status, version=ver_num, /predict )
;
; INPUTS:
;	yyyydoy = Date in Year-DOY format
;	/version = optional input for version number of PVAT file
;	/predict = optional flag for selecting Predicted PVAT instead of Actual PVAT
;
; OUTPUTS:  
;	pvat_data is returned as structure data array using read_netCDF.pro
;	status = OK_STATUS (0) if read PVAT file OK,
;		BAD_PARAMS (-1) if invalid parameters,
;		BAD_FILE (-2) if no data file for YYYYDOY,
;		BAD_FILE_DATA (-3) if data in file is corrupted
;
; COMMON BLOCKS:
;	None
;
; PROCEDURE:
;	Check input parameters
;	Look for file
;	Read PVAT file using read_netcdf.pro
;
; MODIFICATION HISTORY:
;	12/4/1999		Tom Woods		Original version
;
;+

function  read_pvat, yyyydoy, status, version=version, predict=predict

;
;	Define CONSTANTS used in SEE data processing
;
@$see_code_hdr/see_defines.pro

;
;	set default output values
;
status = BAD_PARAMS
pvat_data = -1
ver_num = 0				;  version=0 means pick the latest

;
;	 Check input parameters
;
if (n_params(0) lt 1) then begin
	print, "USAGE: pvat_data = read_pvat( yyyydoy, status, version=ver_num )"
	return, pvat_data
endif
if (yyyydoy lt 2000000L) then begin
	print, "ERROR: read_pvat() date must be past DOY 1 of 2000"
	return, pvat_data
endif

if keyword_set(version) then ver_num = version
if ver_num lt 0 then ver_num = 0

p_ext = 'pos'
if keyword_set(predict) then begin
	if predict ne 0 then p_ext = 'npo'
endif

;
;	search for MDC__YYYYDOY_*.pos  PVAT file
;	and then read as netCDF file
;
pvat_base = 'MDC__' + string( yyyydoy, form='(I7)' ) + '_*.' + p_ext
if ( !d.name eq 'MAC' ) then begin
	pvat_dir = SEE_MAC_CODE + 'see_pvat:'	; for Mac OS
endif else begin
	pvat_dir = getenv( 'see_data_pvat' ) + '/'	; for SUN OS
endelse
pvat_full = pvat_dir + pvat_base	
pvat_file = find_file( pvat_full, ver_num, status )
if (status eq OK_STATUS) then begin
	read_netcdf, pvat_file, pvat_data, pvat_att, status
endif

return, pvat_data
end
