pro hardy_interpolate,array,kp

sizer=size(array)

midy=round(sizer(2)/2)

spacer=18 ; pixel space from the hardy poles to not consider
if kp ge 5 then spacer = 25

for i=0,sizer(1)-1 do begin

;--- this section draws a slope down from the peak to zero at the equator

  peak1=where(array(i,spacer:midy) eq max(array(i,spacer:midy)),count1)
  peak2=where(array(i,midy:sizer(2)-spacer) eq $
              max(array(i,midy:sizer(2)-spacer)),count2)
  fill_1=(findgen(midy-peak1(count1-1)-spacer)/(midy-peak1(count1-1)-spacer))^2 * $
                          max(array(i,spacer:midy))
  array(i,peak1(count1-1)+1+spacer:midy)=reverse(fill_1)

  fill_2=(findgen(peak2(0))/(peak2(0)))^2 * $
                          max(array(i,midy:sizer(2)-spacer))
  array(i,midy+1:peak2(0)+midy)=fill_2

;---this section draws a slope down from 0.7* the peak down to 0 at the equator




;  peak1=where(array(i,10:midy) gt max(array(i,10:midy))/sqrt(2.),count1)
;  peak2=where(array(midy:sizer(2)-10) gt max(array(midy:sizer(2)-10))/sqrt(2.),count2)
;  fill_1=(findgen(midy-peak1(count1-1)-10)/(midy-peak1(count1-1)-10))^2. * $
;                          max(array(i,10:midy)/sqrt(2.))
;  array(i,peak1(count1-1)+11:midy)=reverse(fill_1)

;  stop

endfor

end
