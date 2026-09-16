;------------------------------------------------------------------------------
;+
; NAME:			fuv_rotation_matrix
; PURPOSE:		this procedure prepares the rotation matrix which gives
;			the look directions for the IMAGE FUV instruments
; CATEGORY:
; CALLING SEQUENCE:  	transformation_matrix=fuv_rotation_matrix(omega,theta,$
;				phi,scsv_x,scsv_y,scsv_z,sc_x,sc_y,sc_z,psi)
;
; INPUTS:		omega : instrument roll in degrees, fixed in time
;			theta : instrument tilt in degrees, fixed in time
;			phi   : instrument azimuth in degrees
;			    direction cosines of true spin axis in metal system
;			scsv_x = henry's a
;			scsv_y = henry's b
;			scsv_z = henry's c
; 			    direction cosines of true spin axis in inertial 
;			    GCI system
;			sc_x = henry's d
;			sc_y = henry's e
;			sc_z = henry's f
;			psi : phase angle in degrees
;
; OPTIONAL INPUTS:	none
; KEYWORD PARAMETERS:	none
; OUTPUTS:		transformation_matrix
; OPTIONAL OUTPUTS:	none
; COMMON BLOCKS:	none
; SIDE EFFECTS:		none known
; RESTRICTIONS:		we here use the "right mathematical" way of preparing
;			and using a matrix (IDL ##), not the usual IDL way (#)
;			for the moment this looks awful, but provides better
;			comparison with C-code
;			all input vector components have to describe unit 
;			vectors and should be given in double precision
; PROCEDURE:
; EXAMPLE:
; SEE ALSO:
; MODIFICATION HISTORY:
; 	Written by:	hfrey, using the mathematics developed by H. Heetderks
;	        Date:	January 4, 2000
;                       June 4, 2000 transform all angles into radians
;       Written by;     rburley, replaced 'stop' statements with return,-1
;                       so science data processing is not halted by missing
;                       or bad data.
;               Date:   January 9, 2001
;-
;-------------------------------------------------------------------
function fuv_rotation_matrix,omega,theta,phi,scsv_x,scsv_y,scsv_z, $
	sc_x,sc_y,sc_z,psi

; check the input vectors
if (abs(sqrt(scsv_x^2+scsv_y^2+scsv_z^2) - 1.d0) gt 1.d-3) then begin
  print,'!!!Spacecraft spin vector scsv not unit vector!!!'
  return,-1
endif
if (abs(sqrt(sc_x^2+sc_y^2+sc_z^2) - 1.d0) gt 1.d-3) then begin
  print,'!!!Spacecraft spin vector sc not unit vector in GCI!!!'
  return,-1
endif
if (sc_x eq 0. and sc_y eq 0. and abs(sc_z) eq 1.) then begin
  print,'!!!There is no solution for this case!!!'
  return,-1
endif

; transform angles to radians
omegad=omega*!dpi/180d
thetad=theta*!dpi/180d
phid=phi*!dpi/180d
psid = psi*!dpi/180d		; phase angle transform into radians

; T_1 is the transformation from the instrument space with the axis
;	x along x-axis of image
;	y along y-axis of image
;	z pointing into the instrument
; into  the spacecraft system with
;	z' away from the instrument deck along central metal axis
;	x' perpendicular to one side of deck plate
;	y' completing right handed system
t_1_a = [[cos(omegad),-sin(omegad),0.d], $
	 [sin(omegad), cos(omegad),0.d], $
	 [        0.d,         0.d,1.d]]
t_1_b = [[1.d,         0.d,         0.d], $
	 [0.d,-sin(thetad),-cos(thetad)], $
	 [0.d, cos(thetad),-sin(thetad)]]
t_1_c = [[ sin(phid),cos(phid),0.d], $
	 [-cos(phid),sin(phid),0.d], $
	 [       0.d,      0.d,1.d]]
t_1 = t_1_c ## ( t_1_b ## t_1_a)
	
; T_2 is the transformation from the spacecraft system into the thrue
; spinning system with the axes
;	z'' true spin axis
;	x'' defined this way that x' lies in x'' - z'' plane
;	y'' completing system
;
; input here are direction cosines of true spin axis in spacecraft
; system, they should not change with time once the spacecraft is
; fully deployed
;	scsv_x = henry's a
;	scsv_y = henry's b
;	scsv_z = henry's c
sin_alp=scsv_y/sqrt(1.d0-scsv_x^2)
cos_alp=scsv_z/sqrt(1.d0-scsv_x^2)
sin_bet=scsv_x
cos_bet=sqrt(1.d0-scsv_x^2)

t_2_a = [[1.d,    0.d,     0.d], $
         [0.d,cos_alp,-sin_alp], $
         [0.d,sin_alp, cos_alp]]
t_2_b = [[cos_bet,0.d,-sin_bet], $
         [    0.d,1.d,     0.d], $
         [sin_bet,0.d, cos_bet]]

t_2 = t_2_b ## t_2_a

; T_3 is the transformation from the true spinning system into the 
; inertial GCI system
;	sc_x = henry's d
;	sc_y = henry's e
;	sc_z = henry's f
cos_eta = sc_z/sqrt(1.d0-scsv_x^2)
sin_eta = sqrt(1.d0-scsv_x^2-sc_z^2)/sqrt(1.d0-scsv_x^2)
cos_del = (scsv_x*sc_x+sc_y*sqrt(1.d0-scsv_x^2-sc_z^2))/(1.d0-sc_z^2)
sin_del = (scsv_x*sc_y-sc_x*sqrt(1.d0-scsv_x^2-sc_z^2))/(1.d0-sc_z^2)

t_3_a = [[cos(psid),-sin(psid),0.d], $
	 [sin(psid), cos(psid),0.d], $
	 [      0.d,       0.d,1.d]]
t_3_b = [[ cos_bet,0.d,sin_bet], $
	 [     0.d,1.d,    0.d], $
	 [-sin_bet,0.d,cos_bet]]
t_3_c = [[1.d,     0.d,    0.d], $
	 [0.d, cos_eta,sin_eta], $
	 [0.d,-sin_eta,cos_eta]]
t_3_d = [[cos_del,-sin_del,0.d], $
	 [sin_del, cos_del,0.d], $
	 [    0.d,     0.d,1.d]]
t_3 = t_3_d ## ( t_3_c ## (t_3_b ## t_3_a))

transformation_matrix = t_3 ## (t_2 ## t_1)

;result = transformation_matrix ## [[vector[0]],[vector[1]],[vector[2]]]
;print,'test the transformation'
;print,'Input vector: ',vector[0],vector[1],vector[2]
;print,'transformed vector: '
;print,result
;stop

return,transformation_matrix
end

    
