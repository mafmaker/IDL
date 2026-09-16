;+
; NAME:
;	CHAP
;
; PURPOSE:
;	Chapman grazing incidence integral function
;
; CATEGORY:
;	TIMED/SEE Level 2
;
; CALLING SEQUENCE:  
;	ch=chap(chi,rs,h)
;
; INPUTS:
;	chi	zenith angle in degrees, floating point scalar
;	rs	distance from center of Earth in cm, floating point scalar
;	h	scale heights in cm, floating point array (or scalar)
;
; OUTPUTS:  
;	ch	path length enhancement factor, floating point array (or scalar)
;
; COMMON BLOCKS:
;	none
;
; PROCEDURE:
;	Calculates Chapman grazing incidence integral using fit function.
;	Result is a path length factor to be multiplied by the
;	vertical column density.  For low zenith angles, this factor is
;	approximately equal to 1/cos(chi).  An array of scale heights
;	(e.g., one for each atmospheric species) may be used.  
;	Designed for use with solar zenith angles on the Earth,
;	but is sufficiently general that it may be used for any body
;	on any planet.  (Dimensions are also arbitrary as long as they
;	are self-consistent, i.e., rs and h must be in the same units.)
;	Note - at large h and small chi, fit function can go slightly less
;	than 1, which is non-physical.  Therefore, fit is constrained to be
;	greater than or equal to 1.
; REFERENCE:
;	Smith & Smith, JGR, 77, 3592, 1972
;
; MODIFICATION HISTORY:
;	1/00	Adapted from FORTRAN function by Stan Solomon
;
;+

function CHAP, chi, rs, h
hg=rs/h 
x=sqrt(0.5*hg*(cos(chi*!pi/180.)^2))
sp = 0.56498823/(0.06651874+x) 
w=where(x le 8.)
if w(0) ne -1 then $
  sp(w)=(1.0606963+0.55643831*x(w))/(1.0619896+1.7245609*x(w)+x(w)^2)
chap=sqrt(0.5*!pi*hg)*sp > 1.
return, chap
end
