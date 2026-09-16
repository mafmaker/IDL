pro GSSS_StdAst,h
;+
; NAME:
;	GSSS_STDAST
; DESCRIPTION:
;	This procedure takes a header with GSSS (ST Guide Star Survey) 
;	astrometry and writes a roughly equivalent tangent projection 
;	astrometry into the header. 
;
; CALLING SEQUENCE:
;	GSSS_STDAST, H
;
; INPUT - OUTPUT:
;	H -  FITS header (string array) containing GSSS astrometry.  
;	GSSS_STDAST will write the roughly equivalent tangent projection 
;		astrometry solution into H.
;
; METHOD:
; 	The procedures GSSSXYAD is used to exactly determine the RA and Dec
;	at 3 reference points.    STARAST is then used to find the tangent
;	projection astrometry that best matches these reference points.
;
; NOTES:
;	Some early GSSS images (before the 1994 CD-Rom) used keywords CRPIXx
;	rather than CNPIXx.    The GSSS astrometry in these images could be
;	corrupted by this procedure as the CRPIXx values will be altered.
;
;	The tangent is only a approximation of the nonlinear GSSS astrometry,
;	but is generally accurate to about 0.1 pixels on a 1024 x 1024 image.
;
; PROCEDURES USED:
;	GSSSEXTAST, GSSSXYAD, STARAST, PUTAST, SXADDHIST, SXDELPAR
;
; HISTORY:
;	13-AUG-91 Version 2 written from MAKEASTGSSS  Eric Deutsch (STScI)
;	Delete CDELT* keywords from header   W. Landsman      May 1994
;	Remove call to BUILDAST  W. Landsman                  Jan, 1995
;	Converted to IDL V5.0   W. Landsman   September 1997
;-
  On_error,2

  arg = N_params()

  if (arg lt 1) then begin
    print,'Syntax - GSSS_StdAst, header'
    print,'Purpose - Write tangent projection astrometry into a GSSS header'
    return
    endif

  NAXIS1 = sxpar(h,'NAXIS1') & NAXIS2 = sxpar(h,'NAXIS2')
  X = [.2,.8,.5]*NAXIS1 & Y=[.2,.4,.8]*NAXIS2

  GSSSExtAst,h,gsa
  GSSSXYAD,gsa,X,Y,ra,dec

  starast, RA, DEC, X, Y, cd
  crval=[RA[0],DEC[0]] & crpix=[X[0],Y[0]]+1

  sxaddpar, h, 'CTYPE1','RA---TAN'
  sxaddpar, h, 'CTYPE2','DEC--TAN'
  sxaddpar, h, 'CD1_1', cd[0,0]
  sxaddpar, h, 'CD1_2', cd[0,1]
  sxaddpar, h, 'CD2_1', cd[1,0]
  sxaddpar, h, 'CD2_2', cd[1,1]
  sxaddpar, h, 'CRPIX1', crpix[0]
  sxaddpar, h, 'CRPIX2', crpix[1]
  sxaddpar, h, 'CRVAL1', crval[0]
  sxaddpar, h, 'CRVAL2', crval[1]

  hist = ['GSSS_STDAST: Astrometry calculated from GSSS format and written', $
          'GSSS_STDAST: in tangent projection format: ' + systime() ]
  sxaddhist,hist,h

  sxdelpar, h, 'CDELT1'
  sxdelpar, h, 'CDELT2'

  return
  end
