;$Author: kovalick $
;$Date: 1996/08/09 13:57:37 $
;$Header: /home/rumba/cdaweb/dev/control/RCS/cnv_mdhms_sec.pro,v 1.1 1996/08/09 13:57:37 kovalick Exp kovalick $
;$Locker: kovalick $
;$Revision: 1.1 $
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;+
; NAME:
;       CNV_MDHMS_SEC
;
; PURPOSE:
;       convert time from the form year, month, day, hour, minute, sec
;       to seconds of the year
;
; Calling sequence:
;	t = cnv_mdhms_sec(yr, month, day, hour, minute, sec)
;	   if the arguments are arrays, they must be the same size
;
;	   OR
;
;	t = cnv_mdhms_sec(time_array)
;	   where time_array is a 2-d intarr (6,n)
;	   the first dimension gives the year, month, day, hour, minute, sec
;
;---------------------------------------------------------------------
;
function cnv_mdhms_sec,yr,mo,day,hr,mn,sc

jday=[0,31,59,90,120,151,181,212,243,273,304,334]
mday=[31,28,31,30,31,30,31,31,30,31,30,31]

if n_params() eq 1 then begin
	sz = size(yr)
	if (sz(0) eq 1) then begin
		y = yr(0)
		m = yr(1)
		d = yr(2)
		h = yr(3)
		n = yr(4)
		s = yr(5)
	endif else begin
		if (sz(1) eq 6) then begin
			y=intarr(sz(2))
			m=y & d=y & h=y & n=y & s=y
			y = yr(0,*)
			m = yr(1,*)
			d = yr(2,*)
			h = yr(3,*)
			n = yr(4,*)
			s = yr(5,*)
		endif else begin 
		  if sz(2) eq 6 then begin
			y=intarr(sz(1))
			m=y & d=y & h=y & n=y & s=y
			y= yr(*,0)
			m= yr(*,1)
			d= yr(*,2)
			h= yr(*,3)
			n= yr(*,4)
			s= yr(*,5)
		  endif else begin
			print,"input array must be 6 x n  or n x 6"
			help,yr
			return,-1
		  endelse
		endelse
	endelse
endif else begin
	y = yr
	m = mo
	d = day
	h = hr
	n = mn
	s = sc
endelse
;
t = long(jday(m-1)+d - 1)
if (n_elements(m) gt 1) then begin
	leap = where (m gt 2 AND ((y mod 4) EQ 0))
	ls = size(leap)
	if ls(0) ne 0 then t(leap)=t(leap)+1
endif $
else if (m gt 2) AND ((y mod 4) EQ 0) then t= t+1
;
t = ((t*24 + h)*60 + n)*60 + s
return,t
end