function xyz_to_sphere, rect, degrees=degrees
; $Id: xyz_to_sphere.pro 7092 2010-01-12 20:18:45Z jimm $

;; Convert from xyz to lat/lon coordinates which are raidus,
;; lattitude, longitude.
;; Unfortunately, the function is misnamed since it does not compute
;; spherical coordinates (i.e., radius, longitude, co-lattitude).

; rect = 3xN array of (x,y,z)
; output = 3xN array of (r,lat,phi)
; R is radius.
; lat is the lattitude: the angle from the x,y plane (equator) toward +z
; Phi is the longitude angle: measured from +x towards the +y in the equator.
; angles are in radians.

x = rect(0, *)
y = rect(1, *)
z = rect(2, *)

phi = atan(y, x)
lat = atan(z, sqrt(x^2+y^2))
r = sqrt(x^2+y^2+z^2)
if keyword_set(degrees) then begin
    return, [r, lat*!radeg, phi*!radeg]
endif
return, [r, lat, phi]
end
