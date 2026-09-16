;$Author: kovalick $
;$Date: 1996/08/09 13:57:59 $
;$Header: /home/rumba/cdaweb/dev/control/RCS/cnv_sec_mdhms.pro,v 1.1 1996/08/09 13:57:59 kovalick Exp kovalick $
;$Locker: kovalick $
;$Revision: 1.1 $
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;+
; NAME:
;	CNV_SEC_MDHMS
;
; PURPOSE:
;	Convert the time in seconds of the year to the form month, day
;	hour, minutes, and seconds
;
; CALLING SEQUENCE:
;	status = cnv_sec_mdhms(yr, mo, day, hour, minute, sec, yr_secs)
;
;	All the arguments must be given. yr must be assigned a value (this
;	determines whether you are in  aleap year or not).  Mo, day, hour,
;	minute and sec must be declared to be normal integers and yr_secs
;	must be given a value and must be a long integer.
;
;	The status will be 0 for success and -1 for failure
;-----------------------------------------------------------------
;
function cnv_sec_mdhms,yr,mo,dy,hr,mn,sec,seconds

modys=[31,28,31,30,31,30,31,31,30,31,30,31]

if (n_elements(yr) eq 1) then $
  if (yr mod 4 eq 0) then modys(1)=29 else modys(1)=28 $
else if (yr(0) mod 4 eq 0) then modys(1)=29 else modys(1)=28

sec = fix(seconds mod 60)
tmin = (seconds - sec)/60
mn = fix(tmin mod 60)
thr = (tmin - mn)/60
hr = fix(thr mod 24)
tdays = fix((thr - hr)/24)
if n_elements(tdays) eq 1 then begin
  m = 0
  while tdays GT 0 AND m LT 12 do begin
    tdays = tdays - modys(m)
    m = m + 1
    endwhile
  if (m GT 0) then begin
    if (tdays EQ 0) then begin
      mo = m + 1
      dy = 1
    endif else begin
      mo = m
      dy = tdays + modys(m-1) + 1
    endelse
  endif else begin
    mo = 1
    dy = tdays + 1
  endelse
  return,0
endif else begin
  for i = 0,n_elements(tdays)-1 do begin
    m=0
    while tdays(i) GT 0 AND m LT 12 do begin
	tdays(i) = tdays(i) - modys(m)
	m = m + 1
	endwhile
    if (m GT 0) then begin
      if (tdays(i) EQ 0) then begin
        mo(i) = m + 1
        dy(i) = 1
      endif else begin
        mo(i) = m
        dy(i) = tdays(i) + modys(m-1) + 1
      endelse
    endif else begin
      mo(i) = 1
      dy(i) = tdays(i) +1
    endelse
  endfor
endelse
return,0
end