pro image_time_reverse,time,year,day,ut
;
;  AUTHOR : Thomas Immel
;  DATE   : 2002
;  License : BSD
;
; This program produces and image_time array (long(2)) in the same
; format as the imageinfo
; structure used in IMAGE savefiles, simply from the year, day of year
; and ut floating points. 
;

time=lonarr(2)

;syear=strcompress(year,/rem)
;sday=strcompress(day,/rem);

;if day lt 100 then sday = '0' + sday
;if day lt 10 then  sday = '0' + sday

time(0)=long(1000.* year + day)

time(1)=ut * long(3600.*1000.)   ; convert UT hours to milliseconds.

return
end
