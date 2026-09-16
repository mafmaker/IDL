;+
; NAME:
;	ECI_TO_LLA
;
; PURPOSE:
;	Converts position vectors in ECI coordinates into Lat/Lon/Alt.
;
; CATEGORY:
;	Utility
;
; CALLING SEQUENCE:
;	ECI_TO_LLA, year, doy, utc, eci, lla
; 
; INPUTS:
;	year	Year, yyyy, longword integer
;	doy	Day of Year, ddd, longword integer
;	utc	Coordinated Universal Time of day in seconds, floating point
;       eci	ECI position vector, x, y, x, in km.
;
; OUTPUTS:
;	lla	latitude, longitude, altitude (degrees, degrees, km)
;
; KEYWORDS:
;	None
;
; COMMON BLOCKS:
;	None.
;
; PROCEDURE:
;	Transform Earth-Centered-Inertial position vector into
;	Geodetic latitude, longitude, and altitude above the surface.
;	Uses SUNCOR to find Greenwich sidereal time (GST), the angle between
;	the Greenwich meridian and the vernal equinox.  
;	Uses oblate spheroid approximation to shape of the Earth for altitude
;	and geodetic latitude calculation (ref.: W.J. Larson & J.R. Wertz,
;	Space Mission Analysis and Design, p. 809)
;	Arrays of vectors are OK!
;	
; ROUTINES USED:
;	SUNCOR - calculates coordinates of sun and Greenwich sidereal time
;
; MODIFICATION HISTORY:
;       Stan Solomon, 3/00
;
;-

pro eci_to_lla, year, doy, utc, eci, lla

; f = Earth oblateness flattening factor, re = equatorial radius:
f = 1./298.257D
re = 6378.14D

; Get Greenwich sidereal time:
yd=year*1000L+doy
suncor, yd, utc, sdec, srasn, gst

; Calculate length of position vector:
rs=sqrt(eci[0,*]^2+eci[1,*]^2+eci[2,*]^2)

; Calculate normalized position vector:
rnx=eci[0,*]/rs
rny=eci[1,*]/rs
rnz=eci[2,*]/rs

; Calculate declination, geodetic latitude and altitude above oblate spheroid:
dec = asin(rnz)
lat = atan(tan(dec)/(1.-f)^2)
alt = re * (rs/re-(1-f)/(sqrt(1-f*(2-f)*(cos(dec))^2)))

; Calculate  right ascension and geocentric longitude of satellite:
ra = atan(rny,rnx)
lon=atan(sin(ra-gst),cos(ra-gst))

; Convert radians into degrees:
lla=eci
lla[0,*] = lat * 180./!pi
lla[1,*] = lon * 180./!pi
lla[2,*] = alt

return
end
