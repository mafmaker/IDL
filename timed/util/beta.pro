;+
; NAME:
;	BETA
;
; PURPOSE:
;	Calculates beta (angle between orbit plane and sun vector) from PVAT
;
; CATEGORY:
;	Utility
;
; CALLING SEQUENCE:  
;	beta = beta(file)
;
; INPUTS:
;	file	Name of PVAT file, string
;
; OUTPUTS:  
;	beta	Solar beta angle, degrees, floating point scalar
;
; COMMON BLOCKS:
;	None.
;
; PROCEDURE:
;	Operates on the first point in a TIMED PVAT file
;	Find orbit normal ECI vector using position and velocity vector
;	Translate S/C solar vector into ECI coordinates using quaternion
;	Find angle between orbit normal and ECI sun vector, subtract from 90
;
; ROUTINES CALLED:
;	read_netcdf, sc_to_eci
;
; MODIFICATION HISTORY:
;	1/02	Stan Solomon
;		Not tested, no error checking, caveat emptor
;+

function beta, file

 read_netcdf,file,pvat

 p=pvat.position_eci_cis[*,0]
 r=sqrt(total(p^2))
 v=pvat.velocity_eci_cis[*,0]
 s=sqrt(total(v^2))
 n=crossp(p/r,v/s)

 scsun=pvat.solar_vector[*,0]
 q=pvat.quaternion[*,0]
 sc_to_eci,scsun,q,ecisun

 beta=90.-acos(total(n*ecisun))*180/!pi
 return, beta

end
