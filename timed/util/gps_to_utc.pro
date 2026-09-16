;+
; NAME:
;	GPS_TO_UTC
;
; PURPOSE:
;	Convert GPS (spacecraft) time to Date and Universal Time
;
; CATEGORY:
;	Utility
;
; CALLING SEQUENCE:  
;	gps_to_utc,gps,nleap,year,doy,utc,month,day,hour,min,sec,vern=vern
;
; INPUTS:
;	gps	GPS time in seconds (e.g., spacecraft_time from PVAT)
;	nleap	Number of leap seconds since 1980 (e.g., leap_seconds from PVAT)
;
; OUTPUTS:  
;	year	Year, yyyy, longword integer
;	doy	Day of Year, ddd, longword integer
;	utc	Coordinated Universal Time of day in seconds, floating point
;	month	Month of year, integer
;	day	Day of month, integer
;	hour	Hour of day, integer
;	min	Minute of hour, integer
;	sec	Second of minute, integer
;
; KEYWORDS:
;	vern	Time vernier, optional, in microseconds, longword integer 
;
; COMMON BLOCKS:
;	None.
;
; PROCEDURE:
;	Converts from the GPS time used by the TIMED spacecraft to
;	year, day-of-year, and second-of-day in coordinated UT.  An
;	optional time vernier, in microseconds, e.g., position_time_vernier
;	or attitude_time_vernier from the PVAT files, may be included.
;	Month, day, hour, minute, and second are optional output parameters.
;	Uses the IDL routine JULDAY and the modified IDL routine CALDATES
;       (an array-friendly version of CALDAT) to perform conversions.
;	An array of times may be converted in one call.
;	However, all times in the array must be in the same year.
;
; MODIFICATION HISTORY:
;	10/99	Obtained from APL in /geom package as gps2utc
;		Presumably written by R. DeMajistre
;	1/00	Revised, vectorized, and documented by Stan Solomon
;	1/00	Corrected vernier (/1.e6), Stan Solomon
;	2/00	Corrected calls to JULDAY to specify midnight, Stan Solomon
;       12/01   Changed to CALDATES to perform array date conversions, SCS
;
;+

pro gps_to_utc,gps,nleap,year,doy,utc,month,day,hour,min,sec,vern=vern

secday=86400l
secmin=60l
minhour=60l
sechour= secmin*minhour
ver=0.
if keyword_set(vern) then ver=vern

utcbin=gps-nleap
gps0_jday=julday(1,6,1980,0,0,0)
days1=long(utcbin/secday)
jday_utc=gps0_jday+days1
caldates,jday_utc,um,ud,uy
jul0=julday(1,1,uy(0),0,0,0)
doy=long(jday_utc-jul0+1)
us=double(utcbin mod secday)+ver/1.e6
ss =us mod secmin
mm0=long(us/secmin)
mm=mm0 mod minhour
hh=long(us/sechour)
year=long(uy)
utc=us
month=um
day=ud
hour=hh
min=mm
sec=ss
return
end
