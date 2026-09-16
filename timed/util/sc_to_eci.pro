;+
; NAME:
;	SC_TO_ECI
;
; PURPOSE:
;	Transforms vectors from the TIMED Spacecraft coordinate system
;	to Earth-Centered Inertial (ECI) coordinates
;
; CATEGORY:
;	Utility
;
; CALLING SEQUENCE:  
;	sc_to_eci, scvec, q, ecivec
;
; INPUTS:
;	scvec	vector in spacecraft coordinates, dblarr(3)
;	q	spacecraft attitude quaternion, dblarr(4)
;
; OUTPUTS:  
;	ecivec	vector in ECI coordinates, dblarr(3)
;
; COMMON BLOCKS:
;	None.
;
; PROCEDURE:
;	A vector in S/C coordinates and the spacecraft attitude quaternion
;	are passed to the procedure.  A 3x3 ECI-to-SC rotation matrix is
;	constructed, and its transpose (which equals its inverse for rotation
;	matrices) is multipled by the vector to transform to ECI.
;	Arrays of vectors are not permitted.
;
; REFERENCES
;	GIIS section 6
;	"TIMED Pos. & Att. Geom.", memo by R. DeMajistre, TIMED Data System
;	"Quaternions", memo by S.C. Solomon to TIMED/SEE data proc., 1/21/00
;	Spacecraft Attitude Determ. & Control, J. Wertz, 1990. (ch. 12 & App. D)
;
; MODIFICATION HISTORY:
;	10/99	Obtained from APL in /geom package as sc2eci_mat
;		Presumably written by R. DeMajistre
;	12/99	Revised, edited and documented by Stan Solomon
;	1/00	Error in expression for s2emat corrected, Stan Solomon
;	2/00	Changed matrix to conform to IDL conventions, Stan Solomon
;	2/00	Version 1.0	Stan Solomon
;
;+

pro sc_to_eci, scvec, q, ecivec

e2smat=dblarr(3,3)

e2smat(0,0)=q(0)^2-q(1)^2-q(2)^2+q(3)^2
e2smat(1,0)=(2d)*(q(0)*q(1)+q(2)*q(3))
e2smat(2,0)=(2d)*(q(0)*q(2)-q(1)*q(3))
e2smat(0,1)=(2d)*(q(0)*q(1)-q(2)*q(3))
e2smat(1,1)=-q(0)^2+q(1)^2-q(2)^2+q(3)^2
e2smat(2,1)=(2d)*(q(1)*q(2)+q(0)*q(3))
e2smat(0,2)=(2d)*(q(0)*q(2)+q(1)*q(3))
e2smat(1,2)=(2d)*(q(1)*q(2)-q(0)*q(3))
e2smat(2,2)=-q(0)^2-q(1)^2+q(2)^2+q(3)^2

s2emat=transpose(e2smat)

ecivec = transpose( s2emat ## transpose(scvec) )

return
end
