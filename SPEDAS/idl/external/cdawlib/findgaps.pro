function findgaps, times, gapFactor, avgDeltaT=avgDeltaT, checkLog=checkLog
; return array of indices into the array times for beginning of gaps
;   -1 if none; assumes no fill data nor log spacing
; set checkLog to allow checking for log spaced values
; 1995; Rick Burley
; 1996 March 17; Robert.M.Candey.1@gsfc.nasa.gov
; 1996 March 25 BC; added check for too few points to compute on
; 1996 October 22; RTB replaced STDEV w/ IDL MOMENT function
; 2001 March 21 BC, added check for NANs and log spacing
; 2001 August 10 BC, cleared illegal operand errors on where stmts due to NANs

; NOTE: 'Times' is a general variable name. When this program as first written,
; it was aimed at the 'time' variable plotted on the x-axis but after BC's changes
; this became a more general routine, so now 'times' could be a y-axis variable, for
; example. RCJ 09/01

if (n_elements(gapFactor) le 0) then gapFactor = 1.5
if (n_elements(times) lt 4) then return, -1L ; or message, 'Too few points'
;
gaps = [-1.] & avgDeltaT = 0.
;w0nan = where(times eq times, w0nanc) ; find all real values
w0nan = where(finite(times), w0nanc) ; find all real values
if w0nanc gt 0 then begin
   times1 = times[w0nan] ; all real values
   deltaT = times * 0 ; !values.d_nan
   ;  deltaT(w0nan) = times1(1:*) - times1
   deltaT[w0nan[1:*]] = times1[1:*] - times1
   ; ####assumes first 3 points define whether log spaced and times gt 0
   logT = 0 ; default assume no log spacing
   if keyword_set(checkLog) then $
      if (abs(deltaT[w0nan[2]]-deltaT[w0nan[1]]) lt 1.e-6 * $
         min([deltaT[w0nan[2]], deltaT[w0nan[1]]])) then logT=1
   ;  if logT then deltaT(w0nan) = alog10(times1(1:*)) - alog10(times1)
   if logT then deltaT(w0nan[1:*]) = alog10(times1[1:*]) - alog10(times1)
   deltaT=deltaT[1:*]
   
   ;sd = stdev(deltaT, avgDeltaT) ;RTB replaced stdev w/ moment 10/96
   amn=min(deltaT,max=amx,/nan) 
   ;
   ; If min = max then std. dev. =0. The MOMENT function doesn't have
   ; error handling in this case for the calculation of Skew. & Kurt.
   ; 
   if (amn eq amx) then begin
      avgDeltaT=amn
      gaps = where(abs(deltaT) gt abs(avgDeltaT * gapFactor))
   endif else begin
      tempsd=moment(deltaT,SDEV=sd,/nan)
      avgDeltaT=tempsd(0)
      ; improve calculation of avgDeltaT
      nogaps = where(abs(deltaT) le abs(avgDeltaT * gapFactor), wc)
      if (wc gt 0) then begin  
         ; sd = stdev(deltaT(nogaps), avgDeltaT) ;RTB replaced stdev w/ moment 10/96
         amn=min(deltaT(nogaps),max=amx,/nan)
         if (amn eq amx) then begin
            avgDeltaT=amn
            gaps = where(abs(deltaT) gt abs(avgDeltaT * gapFactor),wc)
            if logT then avgDeltaT = 10^avgDeltaT ; back to linear space
            ; 'mask' is valid for idl5.3 but we are still running 5.2 on the web. RCJ
            ;c=check_math(mask=128) ; clear illegal floating point operand errors from where statements
            c=check_math() ; clear illegal floating point operand errors from where statements
            return, gaps
         endif
         tempsd=moment(deltaT(nogaps),SDEV=sd,/nan)
         avgDeltaT=tempsd(0)
         ; #### why not "avgDeltaT=mean(deltaT,/nan)" ? expect most to be same
         if (abs(sd/avgDeltaT) gt 0.5) then avgDeltaT=median(deltaT) 
         if (abs(sd/avgDeltaT) gt 0.5) then message, /info, $
 	    'DeltaTime inaccurate; gaps too big; ' + string(avgDeltaT, sd)
         gaps = where(abs(deltaT) gt abs(avgDeltaT * gapFactor),wc)
      endif else begin
         gaps = where(abs(deltaT) gt abs(avgDeltaT * gapFactor))
      endelse
   endelse
   ;#### could repeat until no change in sd or avgDeltatT
   if logT then avgDeltaT = 10^avgDeltaT ; back to linear space
endif ; (w0nanc gt 0) else all NANs
;
; 'mask' is valid for idl5.3 but we are still running 5.2 on the web. RCJ
;c=check_math(mask=128) ; clear illegal floating point operand errors from where statements
c=check_math() ; clear illegal floating point operand errors from where statements
;
return, gaps
end ; findGaps
