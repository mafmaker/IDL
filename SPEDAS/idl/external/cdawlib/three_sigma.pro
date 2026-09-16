;+------------------------------------------------------------------------
; NAME: Three_sigma
; PURPOSE: For array y, return min and max values within 3 standard
;          deviations from the mean
; CALLING SEQUENCE:
;       res=three_sigma(y)
; INPUTS:
;       y = array of 4 or more elements
; KEYWORD PARAMETERS:
;       MODIFIED = use modified sigma which uses kurt. & skew. 
;                  results in a more liberal acceptance of data
; OUTPUTS:
;       structure containing:
;       ymin = minimum value within 3 stdev's of mean
;       ymax = maximum value within 3 stdev's of mean
; MODIFICATION HISTORY:
;   05/2006 This is a function version of the procedure semiminmax.pro
;           We've noticed problems when using semiminmax:
;           When calling it a second time from within a routine
;           the values of ymin,ymax from the first call were passed
;           back into semiminmax since now they were existing variables.
;           Calling this program as a function solves this problem.
;-------------------------------------------------------------------------
function three_sigma, y , MODIFIED=MODIFIED

;TJK modified on 12/18/2000 to put in a check so that ymin and ymax will never
;be adjusted any high/lower than what they start out as.  This modification 
;was requested by Bob, because of the new IMAGE data.

;TJK modified again on 1/10/2001 to check if ymin, ymax are actually defined
;since it looks like plottypes, except the image ones, do not have these set
;before entering this routine.

if (n_elements(ymin) eq 0) then minmax_flag = 0 else minmax_flag = 1

if (minmax_flag) then begin
  orig_min = ymin
  orig_max = ymax
endif

if keyword_set(MODIFIED) then mod_flag=1L else mod_flag=0L

if (n_elements(y) lt 3) then begin
  message, 'Not enough points in array', /info
  if (n_elements(y) lt 2) then begin
    Ymin = -1. & Ymax = -1.
  endif else Ymin = min(y, max=Ymax); 2 points only
  return, {ymin:ymin,ymax:ymax}
endif

Ymin = min(y, max=Ymax)

;TJK added check on 12/18/2000

if (minmax_flag) then begin
  if (ymin lt orig_min) then ymin = orig_min
  if (ymax gt orig_max) then ymax = orig_max
endif

if(Ymin eq Ymax) then return, {ymin:ymin,ymax:ymax};Avoid call to MOMENT where Std. Dev.=0

;as = stdev(y, mean) ;RTB replaced w/ moment
res=moment(y,sdev=as)
if(mod_flag) then begin
; Calculate Modified sigma taking into account the skewness and kurtosis 
; of the distribution
 as=res(1)*(1.+res(2)-0.01*(res(3)-3))  
 as=sqrt(abs(as))
endif

mean=res(0)
w = where(abs(y-mean) lt 3.*as, wc) ; use only points within 3 standard
;                                     deviations of the mean
if (wc gt 0) then begin
   ;print, 'time before for loop = ',systime()
   ;  Ymin = y(w(0)) & Ymax = y(w(0)) ;initialize
   ;  for i = 1L, wc-1 do begin
   ;	if (y(w(i)) lt Ymin) then Ymin =  y(w(i))
   ;	if (y(w(i)) gt Ymax) then Ymax =  y(w(i))
   ;  endfor
   ;print, 'time after for loop = ',systime()

  Ymin = min(y(w), max=Ymax)
endif ; else begin

; Ymin = min(y, max=Ymax)
;endelse
;print, Ymin, Ymax

;TJK added check on 12/18/2000
if (minmax_flag) then begin
  if (ymin lt orig_min) then ymin = orig_min
  if (ymax gt orig_max) then ymax = orig_max
endif

return,{ymin:ymin,ymax:ymax}
end ; three_sigma

