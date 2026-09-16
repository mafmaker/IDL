;  $Source: /usr/lib/cvsroot/twins-idl/lib/lanl/earth_boundary.pro,v $
;  $Revision: 7092 $
;  $Date: 2010-01-12 12:18:45 -0800 (Tue, 12 Jan 2010) $

FUNCTION earth_boundary, v, north, npoints=p_len,  degrees=degrees, $
                         prime_meridian=prime_meridian, help=help,  $
                         earth=earth, radius=radius
;+
; $Id: earth_boundary.pro 7092 2010-01-12 20:18:45Z jimm $
; 
; NAME:
;
;   EARTH_BOUNDARY
;
; PURPOSE:
;
;   Calculate spherical coordinates of a parameterized the earth
;   boundary curve projected onto a viewing sphere centered at
;   position V and with North the north pole (+z) of the sphere.  The
;   input coordinate system is assumed to be an orthogonal earth
;   centered system.
;
; CATEGORY:
;
;   Magenetosphere imaging
;
; CALLING SEQUENCE:
;
;   Result = EARTH_BOUNDARY,V
;   Result = EARTH_BOUNDARY,V,North
; 
; INPUTS:
;
;   V - Center of viewing sphere.  A 3 element vector in an
;       earth-centered coordinate frame and in units of earth radii.
;
; OPTIONAL INPUTS:
;
;   North - +z direction of the spherical coordinates, i.e.  the north
;           pole of the viewing sphere.  See the comments in
;           view_coord.pro for a description of this system.  In
;           standard coordinates.  Defaults to [0., 0., 1.].
;
; KEYWORD PARAMETERS:
;
;   NPOINTS - Number of points in parameterization. Defaults to 100.
;
;   PRIME_MERIDIAN - A 3 element vector that lies in the plane of the
;                    sphere pole and the zero reference angle of the
;                    sphere equator (the +x axis).  This has nothing
;                    to do with the prime meridian of the earth; it is
;                    just the most convenient description.
;                    
;   DEGREES - If set then return angle values are in DEGREES.
;
;   EARTH - The spherical coordinates of the center of the earth.
;
;   HELP - Provide help (this information). No other action is
;          performed.  To invoke, dummy=earth_boundary(/help).
;
; OUTPUTS:
;
;   Result - The spherical coordinates for the parameterized earth
;            boundary in the reference system given by North.  Result
;            is a 3xN array.  The columns are radius, angle from pole,
;            and equatorial angle (rho, theta, phi).  The theta, phi
;            coordinates can be equated to lattitude, longitude
;            coordinates for use with IDL mapping procedures.  All
;            angles are in radians unless the DEGREES keyword is set.
;
; PROCEDURE:
;
; Calculate spherical coordinates of a the earth boundary projected
; onto a viewing sphere centered at position v.  The spherical
; coordinate system is specified in view_coord.pro which is based on
; an input North vector that is used for the +z azis of the sphere.
;
; The earth boundary is a parameterized curve on the projection
; sphere for a canonical spherical coordinate system that has NORTH
; pointing at the center of the earth.  This parameterization is
; transformed to the new coordinates specified by the input NORTH.
;
; EXAMPLE:
;
;  ;; Suppose we are using GSE coordinates.
;  
;  ;; View position 3 Re north GSE, View NORTH direction toward sun
;  ;; Prime meridian (phase 0) is GSE north.
;  en=earth_boundary([0.,0,3.],[1.,0.,0],prime=[0,0,1.],/deg,n=1000)
;
;  ;; View position at 3Re, 60 deg lattitude, dawn.
;  ee=earth_boundary([0.,-1.5,2.6],/deg)
;  
;  ;; View position at 3Re, 60 deg lattitude, dawn, North toward sun
;  es=earth_boundary([0.,-1.5,2.6],[1.,0.,0],/deg)
;  
;  ;; Azimuthal projection centered at north pole with lattitude
;  ;; Full sphere
;  map_set,90.,/az,/grid,/lab,lonlab=0,latlab=45
;
;  ;; plotting the earth boundary
;  plots,en(2,*),en(1,*)     
;  plots,ee(2,*),ee(1,*)     
;  plots,es(2,*),es(1,*)     
;  
;  ;; display only a hemisphere.
;  map_set,90.,/az,/grid,/lab,limit=[0.,0,180.,360.],lonlab=180./6,latlab=45
;  
;  ;; plotting the earth boundary
;  plots,en(2,*),en(1,*)     
;  plots,ee(2,*),ee(1,*)     
;  plots,es(2,*),es(1,*)     
;
;  Author:	Chris Chase (chase@jackson), Feb, 1994
;  Modification $Author: jimm $
;  MODIFICATION HISTORY:
;
;       Thu Mar 16 15:16:45 1995, Chris Chase S1A
;       <chase@retro.jhuapl.edu>
;
;               Added PRIME_MERIDIAN, HELP, DEGREES keywords and
;               examples. 
;
;       Mon Feb 28 13:34:53 1994, Chris Chase S1A <chase@jackson>
;
;               Created.
;
;-
;on_error, 2

 Compile_Opt StrictArr
if keyword_set(help) then begin
   doc_library, 'earth_boundary'
   return,''
endif

if n_elements(north) eq 0 then north = [0., 0., 1.]
if not keyword_set(p_len) then p_len = 100

;; For the parameterization in the canonical spherical coordinates
;; (with NORTH pointed at the earth) the boundary is a circle in phi
;; and theta, i.e., theta is a constant and phi varies uniformly over
;; [0,2!pi].
;;
;; The angle from x to y - uniform over [0,2!pi]

phi = 2*!pi*findgen(p_len)/(p_len-1)

;; Angle from the +z (NORTH) pole to the earth limb using a spherical
;; earth.  This angle is a constant for all points in the
;; parameterization in the canonical spherical coordinates.
if not keyword_set(radius) then radius = 1.0
theta = asin(radius/norm(v))

;; Convert to angle from the x-y plane to the point
theta = !Pi/2. - theta
theta = replicate(theta, p_len)
;; Let projection sphere have radius 1.
rho = replicate(1., p_len)
sph = transpose([[rho], [theta], [phi]])

;; Compute the retangular coordinate vectors of the canonical and NORTH
;; spherical coordinate systems.
x1 = sphere_basis(-v)
x2 = sphere_basis(north, prime_meridian=prime_meridian)

;; Parameteriztion of earth boundary in new coordinates.
ce = sphere2sphere(sph, x1, x2)
earth = sphere2sphere([1., !pi/2., 0], x1, x2)
if keyword_set(degrees) then begin
    ce[1:2, *] = ce[1:2, *]*!radeg
    earth[1:2] = earth[1:2]*!radeg
endif
return, ce
end
