function mag2flux, mag, zero_pt
;+
; NAME:
;	MAG2FLUX
; PURPOSE:
;	Convert from magnitudes to flux (ergs/s/cm^2/A). 
; EXPLANATION:
;	Use FLUX2MAG() for the opposite direction.
;
; CALLING SEQUENCE:
;	flux = mag2flux( mag, [ zero_pt ] )
;
; INPUTS:
;	mag - scalar or vector of magnitudes
;
; OPTIONAL INPUT:
;	zero_pt - scalar giving the zero point level of the magnitude.
;		If not supplied then zero_pt = 21.1 (Code et al 1976)
;
; OUTPUT:
;	flux - scalar or vector flux vector (flux = 10^(-0.4*(mag + zero_pt))
;
; REVISION HISTORY:
;	Written    J. Hill        STX Co.       1988
;	Converted to IDL V5.0   W. Landsman   September 1997
;-   
 if ( N_params() lt 2 ) then zero_pt = 21.10

 logf = -0.4*( mag + zero_pt)

 return, 10^logf

 end
