Pro arcbar, hdr, arcmins, LABEL = label, SIZE = size, THICK = thick,  $
            COLOR = color, POSITION = position, NORMAL = normal
;+
; NAME:
;	ARCBAR
; PURPOSE:
;	Create and display a bar of a specified input size in arcminutes
;
; CALLING SEQUENCE:
;	ARCBAR, hdr, arcmins,[  LABEL= , SIZE =, THICK =, POSITION =, /NORMAL ]
;
; INPUTS:
;	hdr - image FITS header with astrometry, string array
;	arcmins - length in arcminutes of bar, scalar 
;
; OPTIONAL KEYWORD INPUTS:
;	LABEL - string giving user defined label for bar.  Default label is size
;		of bar in arcminutes
;	SIZE  - size of label, default = 1.0
;	THICK -  Character thickness of the annotation, default = !P.THICK
;	POS - 2 element vector giving the (X,Y) position in device units (or 
;		normalized units if /NORMAL is set) at which to begin the 
;		scale bar.   If not supplied, then the user will be prompted 
;		to place the cursor at the desired position
;	NORMAL - if this keyword is set and non-zero, then POS is given in
;		normalized units
;
; EXAMPLE:
;	Place a 3' arc minute scale bar, at position 300,200 of the current
;	image window, (which is associated with a FITS header, HDR)
;
;	IDL> arcbar, HDR, 3, pos = [300,200]
;
; RESTRICTIONS:
;	When using using a device with scalable pixels (e.g. postscript)
;	the data coordinate system must be established before calling ARCBAR.
;	If data coordinates are not set, then ARCBAR assumes that the displayed
;	image size is given by the NAXIS1 keyword in the FITS header.
; PROCEDURE CALLS:
;	AD2XY, EXTAST, GSSSADXY
; REVISON HISTORY:
;	written by L. Taylor (STX) from ARCBOX (Boothman)
;	modified for Version 2 IDL,                     B. Pfarr, STX, 4/91
;	New ASTROMETRY structures               W.Landsman,  HSTX, Jan 94
;	Recognize a GSSS header                 W. Landsman June 94
;	Added /NORMAL keyword                   W. Landsman Feb. 96
;	Use NAXIS1 for postscript if data coords not set,  W. Landsman Aug 96
;	Fixed typo for postscript W. Landsman   Oct. 96
;	Account for zeropoint offset in postscript  W. Landsman   Apr 97
;	Converted to IDL V5.0   W. Landsman   September 1997
;-
;
 On_error,2                                  ;Return to caller

 if N_params() LT 1 then begin
      print, $
 "Syntax - ARCBAR, hdr,[ arcmins, LABEL=, SIZE=, THICK =, POS =, /NORM ]
      return
 endif

 extast, hdr, bastr, noparams   ;extract astrom params in deg.

 if N_params() LT 2 then arcmins=1      ;default size = 1 arcmin

 if not keyword_set( SIZE ) then size = 1.0
 if not keyword_set( THICK ) then thick = !P.THICK
 if not keyword_set( COLOR ) then color = !P.COLOR

 a = bastr.crval[0]
 d = bastr.crval[1]
 d1 = d + (1/60.)             ;compute x,y of crval + 1 arcmin

 proj = strmid(bastr.ctype[0],5,3)
  
 case proj of 
	'GSS': gsssadxy, bastr, [a,a], [d,d1], x, y
	else:  ad2xy, [a,a], [d,d1], bastr, x, y 
 endcase

 dmin = sqrt( (x[1]-x[0])^2 + (y[1]-y[0])^2 ) ;det. size in pixels of 1 arcmin

 if (!D.FLAGS AND 1) EQ 1 then begin          ;Device have scalable pixels?
	if !X.s[1] NE 0 then begin
		dmin = convert_coord( dmin, 0, /DATA, /TO_DEVICE) - $ 
                       convert_coord(    0, 0, /DATA, /TO_DEVICE)  ;Fixed Apr 97
		dmin = dmin[0]
	endif else dmin = dmin/sxpar(hdr, 'NAXIS1' )     ;Fixed Oct. 96
 endif 

 dmini2 = round(dmin * arcmins)

 if not keyword_set( POSITION) then begin
	  tvcursor,1
	  print,'Position the cursor where you want the bar to begin'
	  print,'Hit right mouse button when ready'
	  cursor,xi,yi,1,/device
 endif else begin 
	if keyword_set(NORMAL) then begin
		posn = convert_coord(position,/NORMAL, /TO_DEVICE) 
		xi = posn[0] & yi = posn[1]
	endif else begin
		xi = position[0]   & yi = position[1]
	endelse		
 endelse

 xf = xi + dmini2
 dmini3 = dmini2/10             ;Height of vertical end bars = total length/10.

 plots,[xi,xf],[yi,yi], COLOR=color, /DEV, THICK=thick
 plots,[xf,xf],[ yi+dmini3, yi-dmini3 ], COLOR=color, /DEV, THICK=thick
 plots,[xi,xi],[ yi+dmini3, yi-dmini3 ], COLOR=color, /DEV, THICK=thick

 if (!D.NAME EQ 'PS') and (!P.FONT EQ 0) then $        ;Postscript Font?
	minsym='!9'+string(162B)+'!X' else minsym = "'" 
 if not keyword_set( LABEL) then begin
     if (arcmins LT 1) then arcstr = string(arcmins,format='(f4.2)') $
        else arcstr = string(arcmins)
     label = strtrim(arcstr,2) + minsym 
 endif

 xyouts,(xi+xf)/2, yi+2, label, SIZE = size,COLOR=color,/DEV, alignment=.5, $
        CHARTHICK=thick

 return
 end
