function findGaps, times, gapFactor, avgDeltaT=avgDeltaT
; return array of indices into the array times for beginning of gaps
;   -1 if none; assumes no fill data
; 1995; Rick Burley
; 1996 March 17; Robert.M.Candey.1@gsfc.nasa.gov
; 1996 March 25 BC; added check for too few points to compute on
; 1996 October 22; RTB replaced STDEV w/ IDL MOMENT function
;
if (n_elements(gapFactor) le 0) then gapFactor = 1.5
if (n_elements(times) lt 4) then return, -1L ; or message, 'Too few points'
deltaT = times(1:*) - times
;
;sd = stdev(deltaT, avgDeltaT) ;RTB replaced stdev w/ moment 10/96
 amn=min(deltaT,max=amx) 
;
; If min = max then std. dev. =0. The MOMENT function doesn't have
; error handling in this case for the calculation of Skew. & Kurt.
; 
if(amn eq amx) then begin
  avgDeltaT=amn
  gaps = where(abs(deltaT) gt abs(avgDeltaT * gapFactor))
endif else begin
 tempsd=moment(deltaT,SDEV=sd)
 avgDeltaT=tempsd(0)
; improve calculation of avgDeltaT
 nogaps = where(abs(deltaT) le abs(avgDeltaT * gapFactor), wc)
 if (wc gt 0) then begin  
; sd = stdev(deltaT(nogaps), avgDeltaT) ;RTB replaced stdev w/ moment 10/96
  amn=min(deltaT(nogaps),max=amx)
  if(amn eq amx) then begin
   avgDeltaT=amn
   gaps = where(abs(deltaT) gt abs(avgDeltaT * gapFactor),wc)
   return, gaps
  endif
  tempsd=moment(deltaT(nogaps),SDEV=sd)
  avgDeltaT=tempsd(0)

   if (abs(sd/avgDeltaT) gt 0.5) then avgDeltaT=median(deltaT) 
   if (abs(sd/avgDeltaT) gt 0.5) then message, /info, $
 	'DeltaTime inaccurate; gaps too big; ' + string(avgDeltaT, sd)
    if (abs(sd/avgDeltaT) gt 0.5) then avgDeltaT=median(deltaT) 
  gaps = where(abs(deltaT) gt abs(avgDeltaT * gapFactor),wc)
 endif else begin
  gaps = where(abs(deltaT) gt abs(avgDeltaT * gapFactor))
 endelse
endelse
;#### could repeat until no change in sd or avgDeltatT
return, gaps
end ; findGaps
