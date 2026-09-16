function flux2mag, flux, zero_pt
;+
; NAME:
;	FLUX2MAG
; PURPOSE:
;	Convert from flux (ergs/s/cm^2/A) to magnitudes.
; EXPLANATION:
;	Use MAG2FLUX() for the opposite direction.
;
; CALLING SEQUENCE:
;	mag = flux2mag( flux, [ zero_pt ] )
;
; INPUTS:
;	flux - scalar or vector flux vector
;
; OPTIONAL INPUT:
;	zero_pt - scalar giving the zero point level of the magnitude.
;		If not supplied then zero_pt = 21.1 (Code et al 1976)
;
; OUTPUT:
;	mag - magnitude vector  (mag = -2.5*alog10(flux) - zero_pt)
;
; REVISION HISTORY:
;	Written    J. Hill        STX Co.       1988
;	Converted to IDL V5.0   W. Landsman   September 1997
;-   

 if ( N_params() LT 2 ) then zero_pt = 21.10        ;Default zero pt

 return, -2.5*alog10( flux ) - zero_pt

 end
