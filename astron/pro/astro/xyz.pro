pro xyz,date,x,y,z
;+
; NAME:
;	XYZ
; PURPOSE:
;	Calculate heliocentric X,Y, and Z coordinates for 1950.0
; EXPLANATION:
;	The positive X axis is directed towards the equinox, the Y-axis
;	towards the point on the equator at right ascension 6h, and the Z
;	axis toward the north pole of the equator.
;
; CALLING SEQUENCE:
;	xyz, date, x, y, z
;
; INPUT:
;	date - reduced julian date (=JD - 2400000), scalar or vector
;
; OUTPUT:
;	X,Y,Z - scalars or vectors giving heliocentric rectangular coordinates
;		(in A.U) for each date supplied.
;
; EXAMPLE:
;	What were the rectangular coordinates of the sun on Jan 1, 1982 at 0h UT
;	(= julian day 2444969.5)
;
;	IDL> xyz,44969.5,x,y,z ==> x = 0.1502, y = -0.8915, z = -0.3867
;
;	within 0.001 A.U of the Astronomical Almanac position
; REVISION HISTORY
;	Original algorithm from Almanac for Computers, Doggett et al. USNO 1978
;	Adapted from the book Astronomical Photometry by A. Henden
;	Written  W. Landsman   STX       June 1989
;	Correct error in X coefficient   W. Landsman HSTX  January 1995
;	Converted to IDL V5.0   W. Landsman   September 1997
;-
 On_error,2

 if N_elements(date) lt 1 then begin
    print,'Syntax - XYZ, date, x, y, z
    print,'     date - Input reduced Julian date (JD - 2400000.0)
    print,'     x,y,z - Output heliocentric rectangular coordinates (B1950.0)
    return
 endif

 picon = !DPI/180.0d
 t = (date - 15020.0d0)/36525.0d0         ;Relative Julian century

; Compute mean solar longitude, precessed back to 1950
 el = 279.696678D + 36000.76892D*t + 0.000303*t*t - $
     (1.396041 + 0.000308*(t + 0.5))*(t-0.499998)

; Compute mean solar anomaly
 g = 358.475833 + 35999.04975*t - 0.00015*t*t

; Compute the mean jupiter anomaly
 aj = 225.444651 + 2880.0*t + 154.906654*t*t

; Convert degrees to radians for trig functions
 el = el*picon
 g = g*picon
 aj = aj*picon

; Calculate X,Y,Z using trigonometric series
 X = 0.99986*cos(el) - 0.025127*cos(g-el) + 0.008374*cos(g+el) + $
    0.000105*cos(g+g+el) + 0.000063*t*cos(g-el) +    $
    0.000035*cos(g+g-el) - 0.000026*sin(g-el-aj) -   $
    0.000021*t*cos(g+el)

 Y = 0.917308*sin(el) + 0.023053*sin(g-el) + 0.007683*sin(g+el) + $
    0.000097*sin(g+g+el) - 0.000057*t*sin(g-el) -    $
    0.000032*sin(g+g-el) - 0.000024*cos(g-el-aj) -   $
    0.000019*t*sin(g+el)

 Z = 0.397825*sin(el) + 0.009998*sin(g-el) + 0.003332*sin(g+el) + $
    0.000042*sin(g+g+el) - 0.000025*t*sin(g-el) - $
    0.000014*sin(g+g-el) - 0.000010*cos(g-el-aj)

 return
 end
