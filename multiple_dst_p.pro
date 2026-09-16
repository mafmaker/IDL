PRO multiple_dst_p,YEAR,beginning,ending,listing,inverse=inverse,hours=hours,$
	noxlab=noxlab,month=month,stopper=stopper,min_dst=min_dst
;
;  11-10-98  : added inverse keyword
;  Year is real year digits
;  beginning is beginning day of year
;  ending    is  ending   day of year
;  listing is an array of times in yydddhhmmss format
;; hours is supposed to label the times in hours. Good luck there.
;
;  supposed to draw vertical lines at time listed in listing. Good luck.
;
;  CMON IMMEL, now it's y2k compliant
;  Now, I am trying to get the min_dst to work, and it almost does.
;  want integers on y-axis always.


if keyword_set(inverse) then invert_color_flag=1 else $
                        invert_color_flag=0

;PROGRAM TO PLOT KP EXTRACTED FROM NGDC DST .DAT FILES
;flag is to supress y-axes
;listing can be any filename array listing DE-1 filenames/.

;---for positioning

numplots=ending-beginning + 1

old_pos=!p.position	;save to set things as they were before plot
xlim=!p.position(0)
ylim1=!p.position(1)
ylim2=!p.position(3)
xstep=(!p.position(2)-!P.position(0))/float(numplots)

;---for plot annotation
MONTHS=['Jan', 'Feb','Mar', 'Apr', 'May', 'June' ,'July', 'Aug',$
         'Sept' , 'Oct', 'Nov', 'Dec']

blanks=[' ',' ',' ',' ',' ',' ',' ',' ']
ylab1=[' ','-200',' ','-100',' ','0',' ']
xaxis=indgen(24)
ylen=0.03

;=== new 6-21-04
yticks=6
if keyword_set(min_dst) gt 0 then yticks= (50 - min_dst)/50

;---for image time indication
daylist=fix(strmid(listing,2,3))
hourlist=fix(strmid(listing,5,2))
minlist=fix(strmid(listing,7,2))

;---plot 1
xlabs=[' ',strcompress(beginning,/rem),' ']
  if keyword_set(noxlab) then xlabs=[' ',' ',' ']
xticklen=0.0000001
!p.position=[xlim,ylim1,xlim+xstep,ylim2]
dst_p,year,beginning,dst
help,dst

color=0
if invert_color_flag then color=255

dst_minimum=-250

if keyword_set(min_dst) gt 0 then dst_minimum=min_dst
if keyword_set(min_dst) gt 0 then print,'MIN DST IS SET'

plot,xaxis,dst,xticks=2,xtickname=xlabs,xminor=0,xticklen=xticklen,$
        ystyle=5,xrange=[0,24],xstyle=1,yrange=[dst_minimum,50],$
        ytitle='DST (nT)',/NOERASE,color=color

  if keyword_set(hours) gt 0 then axis,xaxis=0,xticks=4,xtickname=blanks,$
    xticklen=0.08,xminor=1,color=color


plots,[!x.crange(0),!x.crange(1)],[0,0],linestyle=2



axis,yaxis=0,ytickinterval=100,yrange=[dst_minimum,50],$
        yminor=1,yticklen=ylen,ytitle='DST (nT)',color=color,ystyle=1

thing=where(daylist eq beginning,maybenot)
if maybenot gt 0 then begin
  minutetimes= hourlist(thing)*60. + minlist(thing)
  print,minutetimes
  for j=0,maybenot-1 do $
   plots,[minutetimes(j)/60.,minutetimes(j)/60.],[!y.crange(0),!y.crange(1)],$
	linestyle=1,color=color,thick=2.2

endif


;---end plot 1
;---begin loop for plots 1 to n-1

for i=1,numplots-2 do begin
  old_dst=dst
  dst_p,year,beginning+i,dst
  xlabs=[' ',strcompress(beginning+i,/rem),' ']
  if keyword_set(noxlab) then xlabs=[' ',' ',' ']
  !p.position=[xlim+(xstep*i),ylim1,xlim+(xstep*(i+1)),ylim2]
  plot,xaxis,dst,xticks=2,xtickname=xlabs,xminor=0,xticklen=xticklen,$
        ystyle=5,/noerase,xrange=[0,24],xstyle=1,yrange=[dst_minimum,50],color=color

  if keyword_set(hours) gt 0 then axis,xaxis=0,xticks=4,xtickname=blanks,$
    xticklen=0.08,xminor=1,color=color

  if i gt 1 then plots,[0,-1],[dst(0),old_dst(23)],color=colorl;,ystyle=1
  axis,yaxis=0,ytickinterval=100,yrange=[dst_minimum,50],$
        ytickname=blanks,yminor=1,yticklen=ylen,color=color,ystyle=1
  axis,yaxis=0,ytickinterval=100,yrange=[dst_minimum,50],$
        ytickname=blanks,yminor=1,yticklen=-1*ylen,color=color,ystyle=1



  thing=where(daylist eq (beginning + i),maybenot)
  plots,[!x.crange(0),!x.crange(1)],[0,0],linestyle=2
  if maybenot gt 0 then begin
    minutetimes= hourlist(thing)*60. + minlist(thing)
    print,minutetimes
    for j=0,maybenot-1 do $
     plots,[minutetimes(j)/60.,minutetimes(j)/60.],[!y.crange(0),!y.crange(1)],$
	linestyle=1,color=color
  endif



endfor

;---end loop for plots 1 to n-1
;---last plot
old_dst=dst  ; redundant but necessary if exiting
dst_p,year,ending,dst
xlabs=[' ',strcompress(ending,/rem),' ']
if keyword_set(noxlab) then xlabs=[' ',' ',' ']
!p.position=[xlim+(xstep*(numplots-1)),ylim1,xlim+(xstep*numplots),ylim2]
plot,xaxis,dst,xticks=2,xtickname=xlabs,xminor=0,xticklen=xticklen,$
    ystyle=5,/noerase,xrange=[0,24],xstyle=1,yrange=[dst_minimum,50],color=color

  if keyword_set(hours) gt 0 then axis,xaxis=0,xticks=2,xtickname=blanks,$
    xticklen=0.1,xminor=2,color=color

axis,yaxis=0,ytickinterval=100,yrange=[dst_minimum,50],ytickname=blanks,$
        yminor=1,yticklen=ylen,color=color,ystyle=1
axis,yaxis=0,ytickinterval=100,yrange=[dst_minimum,50],ytickname=blanks,$
        yminor=1,yticklen=-1*ylen,color=color,ystyle=1
axis,yaxis=1,ytickinterval=100,yrange=[dst_minimum,50],ytickname=blanks,yminor=1,$
        yticklen=ylen,color=color,ystyle=1

  if i gt 1 then plots,[0,-1],[dst(0),old_dst(23)],color=color

thing=where(daylist eq ending,maybenot)
plots,[!x.crange(0),!x.crange(1)],[0,0],linestyle=2

if maybenot gt 0 then begin
  minutetimes= hourlist(thing)*60. + minlist(thing)
  for j=0,maybenot-1 do $
   plots,[minutetimes(j)/60.,minutetimes(j)/60.],[!y.crange(0),!y.crange(1)],$
	linestyle=1,color=color
endif

;ytitler=' '
;begin
;  x0=i
;  x1=i+1
;  y0=0
;  y1=kp(i)
;  box,x0,y0,x1,y1
;endfor

!p.position=old_pos


if keyword_set(stopper) gt 0 then stop

return
end


;pro box,x0,y0,x1,y1
;  plots,[x0,x0],[y0,y1],color=color
;  plots,[x1,x1],[y0,y1],color=color
;  plots,[x0,x1],[y1,y1],color=color
;return
;end


