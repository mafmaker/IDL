function sphere_basis, north, prime_meridian=prime_meridian
; $Id: sphere_basis.pro 7092 2010-01-12 20:18:45Z jimm $
;;
;; Returns the rectangular coordinate vectors x,y,z, in the standard
;; basis from a spherical coordinate system with north as +z.  The
;; return value is a 3x3 array with x,y,z coordinate vectors in the
;; rows of the array.
;;
;; The standard basis is the one used for the north and prime_meridian
;; vectors.
;; 
;; x,y,z form a right-handed coordinate system.
;; 
;; The spherical coordinate system equatorial phase 0 reference (+x)
;; is determined by prime_meridian.  Think of +x as 0 longitude or 0
;; azimuth.
;; 
;; +x is taken in the plane of north and prime_meridian with
;; dot(+x,prime_meridian) > 0.
;; 
;; When prime_meridian is not given or is parallel to north, the
;; default for the equatorial phase is chosen such that +y is in the
;; "northerly" [1,0,0] direction.  Specifically:
;;
;; +z = north, +y is in the (north, [1,0,0]) plane with dot(+y,[1,0,0]) > 0.
;;
;; If north is parallel to [1,0,0] and prime_meridian is not given or
;; is parallel to north then the standard coordinate system is used.
;;
;; Alternatively, prime_meridian can be a second row of north,
;; i.e. north can be size 3x2.

;; Standard basis +z
z_d = [0., 0., 1.]
if (n_elements(north(*, 0)) ne 3) then begin
    message, "North must be a 3 element vector"
    return, 0
endif
if n_elements(north(0, *)) eq 2 and n_elements(prime_meridian) eq 0 then begin
    prime_meridian = north(*, 1)
endif

;; x1, y1, z1 are the rectangular coordinates in the standard basis of
;; spherical system.
;;
;; Make into a row vector.
z1 = reform(north(*, 0), 3)
z1 = z1/norm(z1)

if n_elements(prime_meridian) ne 0 then begin
    if n_elements(prime_meridian) ne 3 then begin
        message, "Prime_meridian should be size 3"
        return, 0
    endif
    x1 = prime_meridian - dot(prime_meridian, z1)*z1
    vx = norm(x1)
    if vx eq 0 then begin
        message, "Prime_meridian is along same direction as north."
        return, 0
    endif
    x1 = x1/vx
    y1 = crossp(z1, x1)
endif else begin
    ;; y1 is in the northerly direction
    y1 = z_d - dot(z_d, z1)*z1
    vy = norm(y1)
    if vy eq 0 then begin
        ;; Canonical coordinates
        x1 = [1., 0., 0.]
        y1 = crossp(z1, x1)
    endif else begin
        y1 = y1/vy
        ;; choose x1 to form a right-hand coordinate system for the pinhole
        x1 = crossp(y1, z1)
    endelse
endelse
;; The coordinate vectors form the _rows_ of the transformation matrix.
coord = float([[x1],[y1],[z1]])
return, coord
end
