;+
; NAME:
;	CALC_SZA
;
; PURPOSE:
;	Calculates solar zenith angle and tangent ray height
;
; CATEGORY:
;	For TIMED/SEE L1 and L2 processing
;
; CALLING SEQUENCE:
;	calc_sza,date,time,sc_alt,sc_pos,sc_sun,sc_att,sza,trh,dif,err,status
; 
; INPUT PARAMETERS:
;	date	date in yyyyddd format; longword integer scalar
;	time	universal time in seconds; floating point scalar
;	sc_alt  spacecraft altitude in km; floating point scalar
;	sc_pos	spacecraft position vector in km, ECI coords; fltarr(3)
;	sc_sun	guidance & control solar vector in spacecraft coords; fltarr(3)
;	sc_att	spacecraft attitude quaternion; fltarr(4)
;
; OUTPUT PARAMETERS:
;	sza	solar zenith angle, degrees; floating point scalar
;	trh	tangent ray height of sun, km; floating point scalar
;			( = sc_alt if sza < 90)
;	dif	difference between SZA using S/C sun vector and calculated SZA
;			degrees, floating point scalar
;	err	error code:	0=OK
;				1=sc_sun & solar ephemeris differ by > 1 deg
;				2=invalid sc_sun (sza calculated anyway)
;				3=invalid sc_att (sza calculated anyway)
;				4=invalid sc_pos (sza not calculated)
;	status	status flag     spare
;
; COMMON BLOCKS:
;	none
;
; ROUTINES USED:
;	SUNCOR - calculates coordinates of sun and Greenwich sidereal time
;	SC_TO_ECI - transform S/C to ECI coordinates using S/C quaternion
;
; PROCEDURE:
;	Calculates solar zenith angle and tangent ray height
;	Calculation is based on angle between S/C position vector and the
;	solar vector, obtained from a solar ephemeris routine.  Also rotates
;	the solar vector obtained from the S/C from spacecraft body fixed (SBF)
;	to Earth centered inertial (ECI) coordinates, and compares it to the
;	solar ephemeris.  Calculates tangent altitude of a ray between the
;	S/C and the sun if the solar zenith angle is greater than 90 degrees.
;
; REFERENCES:
;	W.J. Larson & J.R. Wertz, Space Mission Analysis and Design
;	C.T. Russell, Geophysical Coordinate Transforms.
;
; MODIFICATION HISTORY:
;	12/99	Version 1.0	Stan Solomon
;	2/00	Version 1.1	Included dif in output, SCS
;-



pro calc_sza, date,time,sc_alt,sc_pos,sc_sun,sc_att,sza,trh,dif,err,status

err=0
status=0

; Find solar declination and right ascension, and Greenwich sidereal time:
suncor, date, time, sdec, sra, gst

; Calculate length of satellite position vector and check validity:
rs=sqrt(total(sc_pos^2))
re=6371.
if (rs lt re) then begin
  err=4
  return
endif

; Normalize position vector, find geocentric lat and right ascen of satellite:
rn=sc_pos/rs
lat = asin(rn(2))
ra = atan(rn(1),rn(0))

; Calculate solar zenith angle:
sza = acos(sin(sdec)*sin(lat)+cos(sdec)*cos(lat)*cos(ra-sra))

; Calculate tangent altitude of sun:
if sza gt !pi/2. then trh=sin(sza)*(re+sc_alt)-re else trh=sc_alt
; Convert radians into degrees:
lat = lat * 180./!pi
sza = sza * 180./!pi

; Check validity of S/C solar vector and attitude quaternion:
if abs(sqrt(total(sc_sun^2))-1.) gt 0.1 then begin 
  err=2 
  return
endif
if abs(sqrt(total(sc_att^2))-1.) gt 0.1 then begin
  err=3
  return
endif


; Transform S/C solar vector into ECI:
sc_to_eci, sc_sun, sc_att, sc_sun_eci
sc_sun_eci=sc_sun_eci/sqrt(total(sc_sun_eci^2))
scsdec=asin(sc_sun_eci(2))
scsra=atan(sc_sun_eci(1),sc_sun_eci(0))

; Compare S/C solar vector with solar ephemeris:
dif = acos(sin(sdec)*sin(scsdec)+cos(sdec)*cos(scsdec)*cos(scsra-sra))
dif = dif * 180./!pi
if (dif gt 1.) then err = 1

return
end
