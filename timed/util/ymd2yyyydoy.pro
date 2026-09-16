;+
; NAME:
;	ymd2yyyydoy.pro
;
; PURPOSE:
;	Convert year-month-day to yyyydoy
;
; CATEGORY:
;	Library function
;
; CALLING SEQUENCE:  
;	yyyydoy = ymd2yyyydoy( year, month, day )
;
; INPUTS:
;	year = 4 digit year
;	month = 1-12 for Jan-Dec
;	day = 1-31 for day of month
;	IF array input, then all three need to be same dimension
;
; OUTPUTS:  
;	yyyydoy = year + day of year
;
; COMMON BLOCKS:
;	None
;
; PROCEDURE:
;	1.  Check input parameters
;	2.  Convert to yyyydoy
;		Correct for leap year if necessary
;
; MODIFICATION HISTORY:
;	11/22/99	Tom Woods	Original creation for Version 1.0.0
;
;+

function ymd2yyyydoy, theYear, theMonth, theDay

;
;	set default output values
;
yyyydoy = 1900001L

;
;	define day arrays for quick calculation
;
day_max    = [ 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 ]
doy_offset = [  0, 31, 59, 90,120,151,181,212,243,273,304,334 ]

;
;	1.  Check input parameters
;
if (n_params(0) lt 1) then begin
	print, 'USAGE:  yyyydoy = ymd2yyyydoy( year, month, day )'
	return, yyyydoy
endif

;
;	2.  Convert to yyyydoy
;		Correct for leap year if necessary
;
if (n_params(0) ge 1) then begin
	year = long(theYear)
	wbad = where(year lt 200)
	if (wbad[0] ne -1) then year[wbad] = year[wbad] + 1900.
	yyyydoy = year * 1000L
endif
if (n_params(0) ge 2) then begin
	if (n_elements(theMonth) ne n_elements(theYear)) then return, yyyydoy
	month = long(theMonth) - 1
	wbad = where( month lt 0 )
	if (wbad[0] ne -1) then month[wbad] = 0
	wbad = where( month ge 12 )
	if (wbad[0] ne -1) then month[wbad] = 11
	yyyydoy = yyyydoy + doy_offset[month]
endif
if (n_params(0) ge 3) then begin
	if (n_elements(theDay) ne n_elements(theYear)) then return, yyyydoy
	day = long(theDay)
	wbad = where( day lt 1 )
	if (wbad[0] ne -1) then day[wbad] = 1
	wbad = where( day gt day_max[month] )
	if (wbad[0] ne -1) then day[wbad] = day_max[month]
	wleap = where( (month ge 2) and ((year mod 4) eq 0) and $
				( ((year mod 100) ne 0) or ((year mod 400) eq 0) ) )
	if (wleap[0] ne -1) then day[wleap] = day[wleap] + 1L
	yyyydoy = yyyydoy + day
endif

return, yyyydoy
end
