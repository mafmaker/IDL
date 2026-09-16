PRO EULER,AI,BI,AO,BO,SELECT
;+
; NAME:
;	EULER
; PURPOSE:
;	Transform between Galactic, celestial, and ecliptic coordinates.
; EXPLANATION:
;	Use the procedure ASTRO to use this routine interactively
;
; CALLING SEQUENCE:
;	EULER, AI, BI, AO, BO, [ SELECT ] 
;
; INPUTS:
;	AI - Input Longitude in DEGREES, scalar or vector.  If only two 
;		parameters are supplied, then  AI and BI will be modified to 
;		contain the output longitude and latitude.
;	BI - Input Latitude in DEGREES
;
; OPTIONAL INPUT:
;	SELECT - Integer (1-6) specifying type of coordinate transformation.  
;
;	SELECT     From          To       |   SELECT      From            To
;	1     RA-DEC(1950)   GAL.(ii)   |     4       ECLIPTIC       RA-DEC    
;	2     GAL.(ii)       RA-DEC     |     5       ECLIPTIC       GAL.(ii)  
;	3     RA-DEC         ECLIPTIC   |     6       GAL.(ii)       ECLIPTIC  
;
;	If omitted, program will prompt for the value of SELECT
;
; OUTPUTS:
;	AO - Output Longitude in DEGREES
;	BO - Output Latitude in DEGREES
;
; REVISION HISTORY:
;	Written W. Landsman,  February 1987
;	Adapted from Fortran by Daryl Yentis NRL
;	Converted to IDL V5.0   W. Landsman   September 1997
;-
 On_error,2

 npar = N_params()
 if npar LT 4 then begin
    print,'Syntax - EULER, AI, BI, A0, B0, [ SELECT ]
    print,'    AI,BI - Input longitude,latitude in degrees'
    print,'    AO,BO - Output longitude, latitude in degrees'
    print,'    SELECT - Scalar (1-6) specifying transformation type'
    return
 endif

  twopi   =   2.*!DPI
  fourpi  =   4.*!DPI
  deg_to_rad = 360./twopi

  psi   = [ 0.57595865315D, 4.9261918136D,  $
            0.00000000000D, 0.0000000000D,  $  
            0.11129056012D, 4.7005372834D]     
  stheta =[ 0.88781538514D,-0.88781538514D, $
            0.39788119938D,-0.39788119938D, $
            0.86766174755D,-0.86766174755D]    
  ctheta =[ 0.46019978478D, 0.46019978478D, $
            0.91743694670D, 0.91743694670D, $
            0.49715499774D, 0.49715499774D]    
   phi  = [ 4.9261918136D,  0.57595865315D, $
            0.0000000000D, 0.00000000000D, $
	    4.7005372834d, 0.11129056012d]
;
 if npar LT 5 then begin
	print,' '
	print,' 1 RA-DEC(1950) TO GAL.(ii)
	print,' 2 GAL.(ii)     TO RA-DEC
	print,' 3 RA-DEC       TO ECLIPTIC
	print,' 4 ECLIPTIC     TO RA-DEC
	print,' 5 ECLIPTIC     TO GAL.(ii)
	print,' 6 GAL.(ii)     TO ECLIPTIC
;
	read,'Enter selection: ',select
 endif
 I  = select - 1                         ; IDL offset
 a  = ai/deg_to_rad - phi[i]
 b = bi/deg_to_rad
 sb = sin(b) &	cb = cos(b)
 cbsa = cb * sin(a)
 b  = -stheta[i] * cbsa + ctheta[i] * sb
 bo    = asin(b<1.0d)*deg_to_rad
;
 a =  atan( ctheta[i] * cbsa + stheta[i] * sb, cb * cos(a) )
;
; factor of 1./(cos(bo)) removed from both sin(a) and cos(a)
;
 ao = ( (a+psi[i]+fourpi) mod twopi) * deg_to_rad

 if ( npar EQ 2 ) then begin
	ai = ao & bi=bo
 endif

 return
 end
