pro image_time,time,year,day,month,dom,hh,mm,ss, quiet = quiet
;
;  AUTHOR : Thomas Immel
;  DATE   : 2002
;  License : BSD
;
; This program takes the image_time array (long(2)) from the imageinfo
; structure and returns everything you need to know!
;

year=fix(strmid(strcompress(time(0),/rem),0,4))
day=fix(strmid(strcompress(time(0),/rem),4,3))

if keyword_set(quiet) le 0 then print,year,day

ydn2md,year,day,month,dom

newtime=time(1)/1000.d

hh=fix(newtime/3600.d)
mm=fix((newtime/3600.d - hh) * 60.d)
ss=round(((newtime/3600.d) - hh - mm/60.d) * 3600.d)

if keyword_set(quiet) le 0 then print,hh,mm,ss

return
end
