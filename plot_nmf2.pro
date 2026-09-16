;necessary procedure BOX****
pro box,x0,y0,x1,y1
  plots,[x0,x0],[y0,y1]
  plots,[x1,x1],[y0,y1]
  plots,[x0,x1],[y1,y1]
return
end
;****


PRO PLOT_KP2,YEAR,MONTH,DAY,MONTHDAY,KP,flag,noxtitle=nox,notitle=no,inbox=in,$
  scale=yup,noerase=nope,noxlabel=noxl

print,flag,'***********FLAG!!!**************'
;PROGRAM TO PLOT KP EXTRACTED FROM NGDC KP .DAT FILES
;flag is to supress y-axes


MONTHS=['Jan', 'Feb','Mar', 'Apr', 'May', 'June' ,'July', 'Aug',$
         'Sept' , 'Oct', 'Nov', 'Dec']
;xlabels=['000', '300' ,'600' ,'900' ,'1200' ,'1500' ,'1800' ,'2100', '2400']
xlabels=['00','03','06','09','12','15','18','21','24']
if flag eq 0 then xlabels(8)=' '
if flag eq 2 then xlabels(0)=' '                ;not really ready for this!
ylabels=['0','1','2','3','4','5','6','7','8','9']
if flag eq 1 then ylabels(*)=' '
xtitle='Universal Time'

if keyword_set(nox) then begin
  print,'No X-Title requested!'
  xtitle=' '
endif
if keyword_set(noxl) then begin
  print,'No X-Labels requested'
  xlabels=[' ',' ',' ',' ',' ',' ',' ',' ',' ']
  xtitle=' '
endif

if keyword_set(yup) then ymax=yup else ymax=9


newkp=findgen(10)
newkp(1:8)=kp
newkp(0)=newkp(1)
newkp(9)=newkp(8)
xaxis=indgen(8)
blanka=fltarr(8)
smonthday=strcompress(string(monthday),/remove_all)
sday=strcompress(string(day),/remove_all)
syear=strcompress(string(year),/remove_all)
title='K!dP!n for ' + months(month-1) + ' ' + smonthday + ', 19' + syear +$
     ' (Day ' + sday + ')'
title_forxy=' '
if keyword_set(no) then begin
   print,'No title on graph requested!'
   title=' '
endif
if keyword_set(in) then begin
   print,'Title inside plot requested!'
   title_forxy=title
   title=' '
endif
ytitler=' '
styler=1 & axflag =0 & ytitler= 'K!dP!n'
if (flag ge 0) and (flag le 2) then styler=4 
if flag eq 1 then ytitler=' ' 

if keyword_set(nope) then begin


PLOT,xaXIS,blanka,xtickname=xlabels,xrange=[0,8],xticks=8,yrange=[0,ymax],$
  ytickname=ylabels,yticks=ymax,title=title,xtitle=xtitle,$
  ytitle=ytitler,xminor=1,charsize=1.2,/noerase,ystyle=styler
  xyouts,0.5,8.2,title_forxy,charsize=1.2

case (flag) of
  (3) :    print,' '
  (2) :    print,' '
  (1) :   axis,yaxis=flag,yrange=[0,ymax]$
                               ,ytickname=ylabels,ytitle=ytitler,$
                               /ystyle,yticks=ymax,charsize=1.2
  (0) :    axis,yaxis=flag,yrange=[0,ymax]$
                               ,ytickname=ylabels,ytitle=ytitler,$
                               /ystyle,yticks=ymax,charsize=1.2
endcase

endif else begin
PLOT,xaXIS,blanka,xtickname=xlabels,xrange=[0,8],xticks=8,yrange=[0,ymax],$
  ytickname=ylabels,yticks=ymax,title=title,xtitle=xtitle,$
  ytitle=ytitler,xminor=1,charsize=1.2,ystyle=styler
xyouts,0.5,8.2,title_forxy,charsize=1.2
  ;    a) do something     b) which may be nothing!

print,ymax
if axflag eq 1 and flag ne 2 then axis,yaxis=flag,yrange=[0,ymax]$
                               ,ytickname=ylabels,ytitle=ytitler,$
				/ystyle,yticks=ymax,charsize=1.2

endelse

for i=0,7 do begin
  x0=i
  x1=i+1
  y0=0
  y1=kp(i)
  box,x0,y0,x1,y1
endfor

return
end


pro box,x0,y0,x1,y1
  plots,[x0,x0],[y0,y1]
  plots,[x1,x1],[y0,y1]
  plots,[x0,x1],[y1,y1]
return
end
          
