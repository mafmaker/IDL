;+
; NAME:
;	yyyydoy2ymd.pro
;
; PURPOSE:
;	Convert yyyydoy to year-month-day
;
; CATEGORY:
;	Library function
;
; CALLING SEQUENCE:  
;	yyyydoy2ymd, yyyydoy, year, month, day
;
; INPUTS:
;	yyyydoy = year + day of year
;
; OUTPUTS:  
;	year = 4 digit year
;	month = 1-12 for Jan-Dec
;	day = 1-31 for day of month
;
; COMMON BLOCKS:
;	None
;
; PROCEDURE:
;	1.  Check input parameters
;	2.  Convert yyyydoy to year-month-day
;		Correct for leap year if necessary
;
; MODIFICATION HISTORY:
;	2/11/00		Tom Woods	Original creation for Version 1.0.0
;
;+

pro yyyydoy2ymd, yyyydoy, theYear, theMonth, theDay

;
;	set default output values
;
theYear = 1900L
theMonth = 1L
theDay = 1L

;
;	define day arrays for quick calculation
;
day_max    = [ 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 ]
doy_offset = [  0L, 31, 59, 90,120,151,181,212,243,273,304,334,365 ]
doy_ly_offset = [ 0L, 31, 60, 91,121,152,182,213,244,274,305,335,366 ]

;
;	1.  Check input parameters
;
if (n_params(0) lt 2) then begin
	print, 'USAGE:  yyyydoy2ymd, yyyydoy, year, month, day'
	return
endif

;
;	2.  Convert yyyydoy to year-month-day
;		Correct for leap year if necessary
;
theYear = long( yyyydoy/1000L )
DOY = long( yyyydoy mod 1000L )
n_days = n_elements(DOY)

leapYear = theYear - theYear
if (n_days gt 1) then begin
	wleap = where( (theYear mod 4) eq 0) and $
				( ((theYear mod 100) ne 0) or ((theYear mod 400) eq 0) )
	if (wleap[0] ne -1) then leapYear[wleap] = 1
endif else begin
	leapYear = ( (theYear mod 4) eq 0) and $
				( ((theYear mod 100) ne 0) or ((theYear mod 400) eq 0) )
endelse

;
;	process for each day
;
theMonth = DOY
theDay = DOY
for k=0,n_days-1 do begin
	if (leapYear[k] ne 0) then doff = doy_ly_offset else doff = doy_offset
	theMonth[k] = (where( (doff - DOY[k]) ge 0 ))[0]
	if (theMonth[k] lt 1) then theMonth[k] = 1
	if (theMonth[k] gt 12) then theMonth[k] = 12
	theDay[k] = DOY[k] - doff[theMonth[k]-1]
endfor

return
end
