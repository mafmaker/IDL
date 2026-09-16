;$Author: kenb $
;$Date: 2006-10-11 13:32:51 -0700 (Wed, 11 Oct 2006) $
;$Header: /home/rumba/cdaweb/dev/control/RCS/cnv_sec_mdhms.pro,v 1.2 1996/08/09 17:11:00 kovalick Exp kovalick $
;$Locker: kovalick $
;$Revision: 8 $
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Kile Baker & R.J.Barnes
;
; Copyright ) 2001 The Johns Hopkins University/Applied Physics Laboratory.
; All rights reserved.
; 
; This material may be used, modified, or reproduced by or for the U.S.
; Government pursuant to the license rights granted under the clauses at DFARS
; 252.227-7013/7014.
; 
; For any other permissions, please contact the Space Department
; Program Office at JHU/APL.
; 
; This Distribution and Disclaimer Statement must be included in all copies of
; RST-ROS (hereinafter "the Program").
; 
; The Program was developed at The Johns Hopkins University/Applied Physics
; Laboratory (JHU/APL) which is the author thereof under the "work made for
; hire" provisions of the copyright law.  
; 
; JHU/APL assumes no obligation to provide support of any kind with regard to
; the Program.  This includes no obligation to provide assistance in using the
; Program or to provide updated versions of the Program.
; 
; THE PROGRAM AND ITS DOCUMENTATION ARE PROVIDED AS IS AND WITHOUT ANY EXPRESS
; OR IMPLIED WARRANTIES WHATSOEVER.  ALL WARRANTIES INCLUDING, BUT NOT LIMITED
; TO, PERFORMANCE, MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE ARE
; HEREBY DISCLAIMED.  YOU ASSUME THE ENTIRE RISK AND LIABILITY OF USING THE
; PROGRAM TO INCLUDE USE IN COMPLIANCE WITH ANY THIRD PARTY RIGHTS.  YOU ARE
; ADVISED TO TEST THE PROGRAM THOROUGHLY BEFORE RELYING ON IT.  IN NO EVENT
; SHALL JHU/APL BE LIABLE FOR ANY DAMAGES WHATSOEVER, INCLUDING, WITHOUT
; LIMITATION, ANY LOST PROFITS, LOST SAVINGS OR OTHER INCIDENTAL OR
; CONSEQUENTIAL DAMAGES, ARISING OUT OF THE USE OR INABILITY TO USE THE
; PROGRAM."
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