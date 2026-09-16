pro trapzd, func, a, b, s, step
;+
; NAME
;	TRAPZD
; PURPOSE:
;	Compute the nth stage of refinement of an extended trapezoidal rule.
;	This procedure is called by QSIMP and QTRAP.   Algorithm from Numerical
;	Recipes, Section 4.2.   TRAPZD is meant to be called iteratively from
;	a higher level procedure.
;
; CALLING SEQUENCE:
;	TRAPZD, func, A, B, S, step
;
; INPUTS:
;	func - scalar string giving name of function to be integrated.   This
;		must be a function of one variable.
;	A,B -  scalars giving the limits of the integration
;
; INPUT-OUTPUT:
;	S -    scalar giving the total sum from the previous interations on 
;		input and the refined sum after the current iteration on output.
;
;	step - LONG scalar giving the number of points at which to compute the
;		function for the current iteration.   If step is not defined on
;		input, then S is intialized using the average of the endpoints
;		of limits of integration.
;
; NOTES:
;	(1) TRAPZD will check for math errors when computing the function at the
;	endpoints, but not on subsequent iterations.
;
;	(2) TRAPZD always uses double precision to sum the function values
;	but the call to the user-supplied is double precision only if one of
;	the limits A or B is double precision.
; REVISION HISTORY:
;	Written         W. Landsman                 August, 1991
;	Always use double precision for TOTAL       March, 1996
;	Converted to IDL V5.0   W. Landsman   September 1997
;-
 On_error,2

 if N_elements(step) EQ 0 then begin          ;Initialize?

     junk = check_math(1)                    ;If a math error occurs, it is
     s1 = CALL_FUNCTION(func,A)              ;likely to occur at the endpoints
     if check_math() NE 0 then $
        message,'ERROR - Illegal lower bound of '+strtrim(A,2)+ $
                ' to function ' + strupcase(func)
     s2 = CALL_FUNCTION(func,B)
     if check_math() NE 0 then $
        message,'ERROR - Illegal upper bound of '+strtrim(B,2) + $
                ' to function ' + strupcase(func)
     s = 0.5d * ( double(B)-A ) * ( s1+s2 )    ;First approx is average of endpoints
     step = 1l

 endif else begin

     tnm = float( step )               
     del = ( B - A ) / tnm                    ;Spacing of the points to add
     x = A + 0.5*del + findgen( step ) * del  ;Grid of points @ compute function
     sum = CALL_FUNCTION( func, x )
     S = 0.5d * ( S + (double(B)-A) * total( sum, /DOUBLE )/tnm )     
     step = 2*step

 endelse

 return
 end 
