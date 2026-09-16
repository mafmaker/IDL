;  $Source: /usr/lib/cvsroot/twins-idl/lib/lanl/field_line.pro,v $
;  $Revision: 7092 $
;  $Date: 2010-01-12 12:18:45 -0800 (Tue, 12 Jan 2010) $

function field_line, st, l, flon, num=num

;+
;  Purpose:
;	Compute field line positions for a given L shell and magnetic
;	longitude accounting for occultation by earth limb.
;	
;  Arguments:
;	st	a structure containing the position and attitude 
;		state of the spacecraft: 
;
;	    st.gei - spacecraft position in GEI in units of km.
;	    st.mag_gei - magnetic north in GEI
;	    st.sun_gei - sun direction in GEI
;	    st.axis_gei - sunward spin axis direction in GEI. Z axis of
;			instrument coordinate system.
;	    st.prime_gei - the prime meridian of the instrumental 
;			coordinate system.
;
;	l	L shell in earth radii (must be at least 1.0).
;	flon	SM longitude of field line in degrees.
;	num	number of points along line.
;
;  Preconditions:
;  Postconditions:
;  Invariants:
;	The coordinates of the vectors in the structure st need not be in
;	GEI.  They only need to all be in the same rectangular coordinates
;	system.
;
;  Example:
;  Notes:
;
;  Author:	Pontus Brandt at APL?
;  Modification $Author: jimm $
;  HISTORY:
;
;       Fri Mar 17 11:56:40 2000, Pontus Brandt
;       <brandpc1@lomax.jhuapl.edu>
;
;		Added prime meridian for defining instrument
;		coordinate system more generally. Chris Chase's old
;		version assumed a instrument coordinate system with
;		spin axis as instrument z axis (this is unchanged) and 
;		prime meridian magnetic north pole.

Compile_Opt StrictArr
if not keyword_set(num) then num = 500.

if l lt 1. then return, 0
lat1 = acos(sqrt(1./l))*!radeg
lat = [-lat1,findgen(num)/(num-1)*180.-90., lat1]
r_e = l*cos(lat*!dtor)^2
;;; Earth centered raidus
lon = replicate(flon, n_elements(lat))
d = transpose([[r_e], [lat], [lon]])

ii = [0, where(r_e[1:num] ge 1.), num+1]
d = d[*, ii]

;; From SM to instrument coordinates centered at earth
d = sphere2sphere(d, [[st.mag_gei], [st.sun_gei]],  $
                  [[st.axis_gei], [st.prime_gei]], /degree)
d = sphere_to_xyz(d, /degree)

;; Position from GEI to instrument coordinates
p = xyz_to_sphere(st.gei/6378., /degree)
p = sphere2sphere(p, 0, [[st.axis_gei], [st.prime_gei]], /degree)
p = sphere_to_xyz(p, /degree)

;; To spacecraft centered
for i=0, 2 do d[i, *] = d[i, *]-p[i]

;; Spacecraft centered distance
r_sc = sqrt(total(d*d, 1))

dist = sqrt(total(p*p))
pe = -p/dist
rlimb = sqrt(dist^2-1.)
coslimb = rlimb/dist
;; Cosine of angle between point and earth direction
cosa = (transpose(pe) # d)/r_sc
;; Not hidden
ii = where((cosa le coslimb) or (r_sc le rlimb))
if ii[0] eq -1 then return, 0

;; instrument lat, lon coordinates.
s = xyz_to_sphere(d[*, ii], /degree)
return, s
end
