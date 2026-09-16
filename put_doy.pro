function  put_doy,year,d_oy

;C****************************************************
;C
;C   author : hfrey, 12-06-99
;C
;C   general description:
;C   This function converts the day of year to month and day.
;C
;C   call_var.  dim. type  I/O  description
;C   MM               I    i    UT Month
;C   DD               I    i    UT Day
;C
;C   returns                    message
;C   date                       if values ok
;C
;C**********************************************************************

doy=d_oy
dtab=[31,28,31,30,31,30,31,31,30,31,30,31]

if (year lt 1901 or year gt 2099) then return,-1
if (doy gt 366 or doy lt 1) then return,-1

if((year mod 4) eq 0 and doy gt 59) then doy=doy-1	; leap year

i=-1
repeat begin
	i=i+1
	doy=doy-dtab[i]
	endrep until (doy le 0)

mm=i+1
if (mm lt 10) then month=strcompress('0'+string(fix(mm)),/remove_all) else $
	month=strcompress(string(mm),/remove_all)
dd=doy+dtab[i]
if (dd lt 10) then day=strcompress('0'+string(fix(dd)),/remove_all) else $
	day=strcompress(string(dd),/remove_all)

date=strcompress(month+'-'+day)

return,date

end

