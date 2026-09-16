pro astro, selection, EQUINOX = equinox        ;Interactive astronomical utility
;+
; NAME:
;	ASTRO
; PURPOSE:
;	Interactive utility to compute precession or coordinate conversions.
;
; CALLING SEQUENCE:
;	ASTRO, [ selection, EQUINOX = ]
;
; OPTIONAL INPUT:
;	SELECTION - Scalar Integer (0-6) giving the the particular astronomical
;		utility to be used.  (0) Precession, (1) RA, Dec to Galactic 
;		coordinates, (2) Galactic to RA,Dec (3) RA,Dec to Ecliptic,
;		(4) Ecliptic to RA, Dec, (5) Ecliptic to Galactic, (6) Galactic
;		to Ecliptic.   Program will prompt for SELECTION if this 
;		parameter is omitted.
;
; OPTIONAL KEYWORD INPUT:
;	EQUINOX - numeric scalar specifying the equinox to use when converting 
;		between celestial and other coordinates.    If not supplied, 
;		then the RA and Dec will be assumed to be in EQUINOX 1950.   
;		This keyword is ignored by the precession utility.   For 
;		example, to convert from RA and DEC (2000) to galactic 
;		coordinates:
;
;		IDL> astro, 1, E=2000
;
; METHOD:
;	ASTRO uses PRECESS to compute precession, and EULER to compute
;	coordinate conversions.   The procedure GET_COORDS is used to
;	read the coordinates, and ADSTRING to format the RA,Dec output.
;
; NOTES:
;	ASTRO temporarily sets !QUIET to suppress compilation messages and
;	keep a pretty screen display.   
;         
; PROCEDURES USED:
;	Procedures: GET_COORDS, EULER       Function: ADSTRING
; REVISION HISTORY
;	Written, W. Landsman November 1987
;	Code cleaned up       W. Landsman   October 1991
;	Added Equinox keyword, call to GET_COORDS, W. Landsman   April, 1992
;	Allow floating point equinox input J. Parker/W. Landsman  July 1996
;	Converted to IDL V5.0   W. Landsman   September 1997
;-
 On_error,2                    ;Return to caller

 input_type =   [0,0,1,0,2,2,1]     ;0= RA,Dec  1= Galactic   2 = Ecliptic
 output_type =  [0,1,0,2,0,1,2]        

 sv_quiet = !quiet & !quiet = 1	;Don't display compiled procedures

 yeari = 1950.0  & yearf = 1950.0  ;Default equinox values except for Precession

 select = ['(0) Precession: (RA, Dec)',                  $
   	   '(1) Conversion: (RA, Dec) --> Galactic', $
	   '(2) Conversion: Galactic --> (RA, Dec 1950)', $
	   '(3) Conversion: (RA, Dec 1950) --> Ecliptic', $
	   '(4) Conversion: Ecliptic --> (RA, Dec 1950)', $
	   '(5) Conversion: Ecliptic --> Galactic',       $
	   '(6) Conversion: Galactic --> Ecliptic']

 npar = N_params()       

 SELECTOR: if (npar EQ 0 ) then begin

	print,'Select astronomical utility'
	for i = 0,6 do print, select[i]
        selection = 0
       	print,' '
	read,'Enter Utility Number: ',selection 
        print,' '

     endif

 if ( selection LT 0 ) or ( selection GT 6 ) then begin

       print,selection,' is not an available option'
       npar = 0
       goto, SELECTOR

 endif

 print, select[selection]

 if keyword_set(EQUINOX) and (input_type[selection] EQ 0) then yeari =equinox
 if keyword_set(EQUINOX) and (output_type[selection] EQ 0) then yearf = equinox

 if ( selection EQ 0 ) then read, $
     'Enter initial and final equinox (e.g. 1950,2000): ',yeari,yearf

 case output_type[ selection ] of

   0:  OutName = " RA Dec (" + string( yearf, f= "(F6.1)" ) + "):  "
   1:  OutName = " Galactic longitude and latitude: "
   2:  OutName = " Ecliptic longitude and latitude: "

 endcase 

 case input_type[ selection ] of 

  0:  InName = "RA Dec (" + string(yeari ,f ='(F6.1)' ) + ')'
  1:  InName = "galactic longitude and latitude: "
  2:  InName = "ecliptic longitude and latitude: "

 endcase
 
 HELP_INP: if ( input_type[selection] EQ 0 ) then begin

  print,format='(/A)',' Enter RA, DEC with either 2 or 6 parameters '
  print,format='(A/)',' Either RA, DEC (degrees) or HR, MIN, SEC, DEG, MIN SEC'

 endif

 READ_INP: 

     get_coords,coords,'Enter '+ InName, Numcoords 

 if ( coords[0] EQ -999 ) then begin        ;Normal Return
        print,' '
        if Numcoords GT 0 then goto, READ_INP
	!quiet = sv_quiet
	return
 endif

 ra = coords[0] & dec = coords[1]
 if Numcoords EQ 6 then ra = ra*15.

 if ( selection EQ 0 ) then begin 

         precess, ra , dec , yeari, yearf    ;Actual Calculations
         newra = ra & newdec = dec

 endif else begin 

         if yeari NE 1950 then precess, ra, dec, yeari, 1950
         euler, ra, dec, newra, newdec, selection
         if yearf NE 1950 then precess, newra,newdec, 1950, yearf

 endelse

 if newra LT 0 then newra = newra + 360.

 if output_type[selection] EQ 0 then $
     print, outname + adstring( [newra,newdec], 1) $

 else  print, FORM = '(A,2F7.2,A,F7.2 )', $
      outname, newra, newdec

 print,' '
 goto, READ_INP      

 end            
