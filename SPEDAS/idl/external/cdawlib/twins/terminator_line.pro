function terminator_line, st, num=num
;; compute the the sunlit terminator line on the earth surface.
;; Returns an array of [radius, lat, lon] (degrees) of points in
;; instrument coordinates along the terminator.  Instrument
;; coordinates use the st.axis for the north pole and st.phase to
;; determine 0 phase (i.e. 0 longitude or +x).

;; st is a structure containing the position and attitude state of the
;; spacecraft.  Fields:

;; p - earth centered spacecraft position in km
;; c - coordinate structure containing fields:
;;
;;   axis  - direction of the spin axis ("north end")
;;   phase - direction lying in the meridian of 0 phase clock angle
;;           about spin axis (i.e. this determines the azimuth 0
;;           reference for instrument coordinates).  phase must be
;;           linearly independent of axis.
;;   sun   - direction to sun

;;
;; All fields are 3 element vectors in the same rectangular coordinate
;; system.  The units of the direction vectors are unimportant and
;; need not be normalized.

;; num - number of points along line.  Num-1 is the number of points the
;;       half circle of the terminator.  A total of 2*Num-2 points will
;;       be used for the full terminator circle.
if not keyword_set(num) then num = 500.

sun = unitv(st.c.sun)
axis = unitv(st.c.axis)
phase = unitv(st.c.phase)

;; Pick a +z direction that is perpendicular to st.sun.

if sun(0) eq 0 then z = [1., 0, 0] else z = [0., 1., 0]
z = unitv(z-dot(z, sun)*sun)

;; Terminator in lat,lon coordinates for this +z with 0 longitude at +x
nt = num
t_lat = findgen(nt)/(nt-1)*180.-90.
t_sph = [[t_lat, reverse(t_lat(1:nt-2))], [replicate(90., nt), replicate(270., nt-2)]]
d = transpose([[replicate(1., 2*nt-2)], [t_sph]])

num = nt*2-2

;; To instrument coordinates centered at earth
d = sphere2sphere(d, [[z], [sun]],  $
                  [[axis], [phase]], /degree)
d = sphere_to_xyz(d, /degree)

;; Position to instrument coordinates (converted to Re from km)
p = sphere2sphere(st.p/6378., 0, [[axis], [phase]], /xyz)

;; To spacecraft centered
for i=0, 2 do d(i, *) = d(i, *)-p(i)

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
if ii(0) eq -1 then return, 0

;; instrument lat, lon coordinates.
s = xyz_to_sphere(d(*, ii), /degree)
return, s
end
