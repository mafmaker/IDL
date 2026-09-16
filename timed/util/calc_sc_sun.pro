;+
; NAME:
;	CALC_SC_SUN
;
; PURPOSE:
;	Calculates solar vector in TIMED spacecraft coordiates
;
; CATEGORY:
;	Utility
;
; CALLING SEQUENCE:
;	calc_sc_sun,date,time,sc_att,sc_sun,err
; 
; INPUT PARAMETERS:
;	date	date in yyyyddd format; longword integer scalar
;	time	universal time in seconds; floating point scalar
;	sc_att	spacecraft attitude quaternion; fltarr(4)
;
; OUTPUT PARAMETERS:
;	sc_sun	calculated solar vector in spacecraft coordinates
;	err	error code:	0=OK	3=invalid attitude quaternion
;
; COMMON BLOCKS:
;	none
;
; ROUTINES USED:
;	SUNCOR - calculates coordinates of sun and Greenwich sidereal time
;	ECI_TO_SC - transform ECI S/C coordinates using S/C quaternion
;
; PROCEDURE:
;	Calculate solar vector in ECI coordinates using SUNCOR, and
;	transform to S/C coordinates using quaternion from PVAT and ECI_TO-SC.
;
; REFERENCES:
;	W.J. Larson & J.R. Wertz, Space Mission Analysis and Design
;	C.T. Russell, Geophysical Coordinate Transforms.
;
; MODIFICATION HISTORY:
;	1/00 	Version 1.0	 Stan Solomon
;-

pro calc_sc_sun, date, time, sc_att, sc_sun, err

; Check validity of S/C attitude quaternion:
err=0
if abs(sqrt(total(sc_att^2))-1.) gt 0.1 then begin
  err=3
  return
endif

; Find solar declination and right ascension:
suncor, date, time, sdec, sra, gst

; Calculate solar vector in ECI coordinates:
sunvec=dblarr(3)
sunvec(0)=cos(sra)*cos(sdec)
sunvec(1)=sin(sra)*cos(sdec)
sunvec(2)=sin(sdec)
sunvec=sunvec/sqrt(total(sunvec^2))

; Transform solar vector into S/C coordinates:
eci_to_sc, sunvec, sc_att, sc_sun
sc_sun=sc_sun/sqrt(total(sc_sun^2))

return
end
