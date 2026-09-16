;-------------------------------------------------------------
;+
; NAME:
;       YMD2DN
; PURPOSE:
;       Convert from year, month, day to day number of year.
; CATEGORY:
; CALLING SEQUENCE:
;       dy = ymd2dn(yr,m,d)
; INPUTS:
;       yr = year (like 1988).               in
;       m = month number (like 11 = Nov).    in
;       d = day of month (like 5).           in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       dy = day number in year (like 310).  out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       Written by R. Sterner, 20 June, 1985.
;       Johns Hopkins University Applied Physics Laboratory.
;       RES 18 Sep, 1989 --- converted to SUN
;
; Copyright (C) 1985, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	FUNCTION YMD2DN,YR,M,D, help=hlp
 
	IF (N_PARAMS(0) LT 3) or keyword_set(hlp) THEN BEGIN
	  PRINT,' Convert from year, month, day to day number of year.'
	  PRINT,' dy = ymd2dn(yr,m,d)'
	  PRINT,'   yr = year (like 1988).               in'
	  PRINT,'   m = month number (like 11 = Nov).    in'
	  PRINT,'   d = day of month (like 5).           in'
	  PRINT,'   dy = day number in year (like 310).  out'
	  RETURN, -1
	ENDIF
 
	; Days before start of each month.
	IDAYS = [0,31,59,90,120,151,181,212,243,273,304,334,366]
 
	; Correct IDAYS for leap-year.
	IF (((YR MOD 4) EQ 0) AND ((YR MOD 100) NE 0)) $
            OR ((YR MOD 400) EQ 0) THEN IDAYS(2) = IDAYS(2:*) + 1
 
NEXT:	DY = D + IDAYS(M-1)
	RETURN, DY
 
	END
