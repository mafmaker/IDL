;+
; NAME:
;	ECI_TO_SC
;
; PURPOSE:
;	Transforms vectors from the Earth-Centered Inertial (ECI)
;	coordinate system to the TIMED Spacecraft coordinate system
;
; CATEGORY:
;	Utility
;
; CALLING SEQUENCE:  
;	eci_to_sc, ecivec, q, scvec
;
; INPUTS:
;	ecivec	vector in spacecraft coordinates, dblarr(3)
;	q	spacecraft attitude quaternion, dblarr(4)
;
; OUTPUTS:  
;	scivec	vector in ECI coordinates, dblarr(3)
;
; COMMON BLOCKS:
;	None.
;
; PROCEDURE:
;	A vector in ECI coordinates and the spacecraft attitude quaternion
;	are passed to the procedure.  A 3x3 ECI-to-SC rotation matrix is
;	constructed, and multiplied by the vector to transform it to S/C
;	coordinates.
;	Arrays of vectors are not permitted.
;
; REFERENCES
;	GIIS section 6
;	"TIMED Pos. & Att. Geom.", memo by R. DeMajistre, TIMED Data System
;	"Quaternions", memo by S.C. Solomon to TIMED/SEE data proc., 1/21/00
;	Spacecraft Attitude Determ. & Control, J. Wertz, 1990. (ch. 12 & App. D)
;
; MODIFICATION HISTORY:
;	2/00	Version 1.0  Adapted from SC_TO_ECI procedure by Stan Solomon
;		
;
;+

pro eci_to_sc, ecivec, q, scvec

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

scvec = transpose( e2smat ## transpose(ecivec) )

return
end
