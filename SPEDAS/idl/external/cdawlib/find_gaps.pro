;$Author: jimm $
;$Date: 2010-01-12 12:18:45 -0800 (Tue, 12 Jan 2010) $
;$Header: /home/cdaweb/dev/control/RCS/find_gaps.pro,v 1.3 2001/03/30 20:47:03 johnson Exp kovalick $
;$Locker: kovalick $
;$Revision: 7092 $
;+------------------------------------------------------------------------
; NAME: FIND_GAPS
; PURPOSE: To locate data gaps in an array of Epoch times by searching
;          for delta-T's of a given size greater than the average data
;          resolution.
; CALLING SEQUENCE:
;       gaps = find_gaps(times)
; INPUTS:
;       times = array of time tags
; KEYWORD PARAMETERS:
;       RATIO    = default gap detection is 2.5 times the average data
;                  resolution.  Use this keyword to change the 2.5
; OUTPUTS:
;       gaps = array of indices where a gap has been detected.
; AUTHOR:
;       Richard Burley, NASA/GSFC/Code 632.0, Feb 22, 1996
;       burley@nssdca.gsfc.nasa.gov    (301)286-2864
; MODIFICATION HISTORY:
;	RCJ 03/30/01 Changed 'lt 3' to 'le 3' because this was preventing
;		     the plot of one single data point in some cases
;-------------------------------------------------------------------------
FUNCTION find_gaps, times, RATIO=RATIO
if NOT keyword_set(RATIO) then ratio = 2.5
nt = n_elements(times)
;if nt lt 3 then gaps = -1 $
if nt le 3 then gaps = -1 $
else begin
  deltas = abs(times - shift(times,-1)) & deltas(nt-1) = 0
  avggap = abs(total(deltas(1:n_elements(deltas)-2)) / nt) ; exclude first/last
  gaps = where(deltas gt (avggap * ratio))
endelse
return, gaps
end
