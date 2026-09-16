function sphere2sphere, pts, x1, x2, degrees=degrees, xyz=xyz,  $
                        left_transform=left_transform
; $Id: sphere2sphere.pro 7092 2010-01-12 20:18:45Z jimm $

;; Given two rectangular coordinate systems x1, x2 expressed in the
;; standard coordinates.
;;
;; The rows of x1 and x2 contain the normalized coordinate
;; vectors. (In normal linear algebra they would be in the columns,
;; but IDL's matrix multiplication operator is screwed up).  These are
;; rectangular coordinates, thus transpose(x1) # x1 = identity
;; (i.e. x1 and x2 are orthogonal matrices).
;; 
;; sp is a 3xN array of spherical coordinates in x1 each row of the
;; form (radius, lattitude, longitude).
;; Return 3xN array spherical coordinates in x2.
;;
;; Alternatively, x1 or x2 can be 3x2 specifying the north pole and
;; prime_meridian of the sphere.  See sphere_basis.pro for a
;; description. 

if n_params() ne 3 then begin
    message, "Must supply 3 arguments."
    return, 0
endif
sz = size(x1)
case 1 of 
    sz(sz(0)+2) eq 1: bx1 = [[1., 0., 0.], [0, 1, 0], [0, 0, 1]]
    min(sz(0:2) eq [2, 3, 3]): bx1 = x1
    min(sz(0:2) eq [2, 3, 2]): bx1 = sphere_basis(x1)
    else: begin
        message, "Second argument invalid."
        return, 0
    end
endcase
sz = size(x2)
case 1 of 
    sz(sz(0)+2) eq 1: bx2 = [[1., 0., 0.], [0, 1, 0], [0, 0, 1]]
    min(sz(0:2) eq [2, 3, 3]): bx2 = x2
    min(sz(0:2) eq [2, 3, 2]): bx2 = sphere_basis(x2)
    else: begin
        message, "Third argument invalid."
        return, 0
    end
endcase

if keyword_set(xyz) then begin
    cx1 = pts
endif else begin
    cx1 = sphere_to_xyz(pts, degrees=degrees)
endelse
;; bx1 - X1 to standard coordinates.
;; bx2 - X2 to standard coordinates.
left_transform = transpose(bx2) # bx1
cx2 = left_transform # cx1
;; To spherical.
if keyword_set(xyz) then return, cx2 $
else return, xyz_to_sphere(cx2, degrees=degrees)
end
