pro plot_box,kp,color
  for i=0,7 do begin
    x0=i
    x1=i+1
    y0=0
    y1=kp(i)
    box,x0,y0,x1,y1,color
  endfor
return
end


pro box,x0,y0,x1,y1,color
  plots,[x0,x0],[y0,y1],color=color
  plots,[x1,x1],[y0,y1],color=color
  plots,[x0,x1],[y1,y1],color=color
return
end
;-----------------------begin main procedure----------------------

PRO multiple_kp_p,YEAR,beginning,ending,listing,inverse=inverse,hours=hours,$
	noxlab=noxlab,month=month,rhs=rhs
;
;  11-10-98  : added inverse keyword
;  Year is 0-99
;  beginning is beginning day of year
;  ending    is  ending   day of year
;  listing is an array of times in yydddhhmmss format
;; hours is supposed to label the times in hours. Good luck there.
;
;  supposed to draw vertical lines at time listed in listing. Good luck.

if keyword_set(inverse) then invert_color_flag=1 else $
                        invert_color_flag=0
if keyword_set(rhs) then rhs_flag=1 else $
                        rhs_flag=0


;PROGRAM TO PLOT KP EXTRACTED FROM NGDC KP .DAT FILES
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
ylab1=['0','3','6','9']
xaxis=indgen(1440)
ylen=0.03

;---for image time indication
daylist=fix(strmid(listing,2,3))
hourlist=fix(strmid(listing,5,2))
minlist=fix(strmid(listing,7,2))

;---plot 1
xlabs=[' ',strcompress(beginning,/rem),' ']
  if keyword_set(noxlab) then xlabs=[' ',' ',' ']
xticklen=0.0000001
!p.position=[xlim,ylim1,xlim+xstep,ylim2]
kp_p,year,beginning,kp
help,kp

color=0
if invert_color_flag then color=255

plot,xaxis,kp,xticks=2,xtickname=xlabs,xminor=0,xticklen=xticklen,$
        ystyle=5,xrange=[0,8],xstyle=1,yrange=[0,9],$
        ytitle=' ',/NOERASE,color=color,/nodata,ytickname=blanks

plot_box,kp,color

if rhs_flag eq 1 then ytitle=' ' else ytitle='Kp'
if rhs_flag eq 1 then yaxistickname=blanks else yaxistickname=ylab1
axis,yaxis=0,yticks=3,yrange=[0,9],$
  	ytickname=yaxistickname,$
        yminor=1,yticklen=ylen,ytitle=ytitle,color=color

;if rhs_flag eq 0 then axis,yaxis=0,yticks=3,yrange=[0,9],ytickname=ylab1,$
;        yminor=1,yticklen=ylen,ytitle='Kp',color=color

thing=where(daylist eq beginning,maybenot)
if maybenot gt 0 then begin
  minutetimes= hourlist(thing)*60. + minlist(thing)
  print,minutetimes
  for j=0,maybenot-1 do $
   plots,[minutetimes(j),minutetimes(j)],[!y.crange(0),!y.crange(1)],$
	linestyle=1,color=color,thick=2.2

endif


;---end plot 1
;---begin loop for plots 1 to n-1

for i=1,numplots-2 do begin

  kp_p,year,beginning+i,kp
  xlabs=[' ',strcompress(beginning+i,/rem),' ']
  if keyword_set(noxlab) then xlabs=[' ',' ',' ']
  !p.position=[xlim+(xstep*i),ylim1,xlim+(xstep*(i+1)),ylim2]
  plot,xaxis,kp,xticks=2,xtickname=xlabs,xminor=0,xticklen=xticklen,$
        ystyle=5,/noerase,xrange=[0,8],xstyle=1,yrange=[0,9],$
	color=color,/nodata

  plot_box,kp,color				;PLOT KP!!!!!

  axis,yaxis=0,yticks=3,yrange=[0,9],$
        ytickname=blanks,yminor=1,yticklen=ylen,color=color
  axis,yaxis=0,yticks=3,yrange=[0,9],$
        ytickname=blanks,yminor=1,yticklen=-1*ylen,color=color
thing=where(daylist eq (beginning + i),maybenot)
if maybenot gt 0 then begin
  minutetimes= hourlist(thing)*60. + minlist(thing)
  print,minutetimes
  for j=0,maybenot-1 do $
   plots,[minutetimes(j),minutetimes(j)],[!y.crange(0),!y.crange(1)],$
	linestyle=1,color=color
endif

endfor

;---end loop for plots 1 to n-1
;---last plot

kp_p,year,ending,kp
xlabs=[' ',strcompress(ending,/rem),' ']
if keyword_set(noxlab) then xlabs=[' ',' ',' ']
!p.position=[xlim+(xstep*(numplots-1)),ylim1,xlim+(xstep*numplots),ylim2]
plot,xaxis,kp,xticks=2,xtickname=xlabs,xminor=0,xticklen=xticklen,$
    ystyle=5,/noerase,xrange=[0,8],xstyle=1,yrange=[0,9],color=color,/nodata

plot_box,kp,color

if rhs_flag eq 0 then ytitle=' ' else ytitle='Kp'
if rhs_flag eq 0 then yaxistickname=blanks else yaxistickname=ylab1
axis,yaxis=1,yticks=3,yrange=[0,9],$
  	ytickname=yaxistickname,$
        yminor=1,yticklen=ylen,ytitle=ytitle,color=color

axis,yaxis=0,yticks=3,yrange=[0,9],ytickname=blanks,$
        yminor=1,yticklen=ylen,color=color
axis,yaxis=0,yticks=3,yrange=[0,9],ytickname=blanks,$
        yminor=1,yticklen=-1*ylen,color=color
axis,yaxis=1,yticks=3,yrange=[0,9],ytickname=blanks,yminor=1,$
        yticklen=ylen,color=color
thing=where(daylist eq ending,maybenot)
if maybenot gt 0 then begin
  minutetimes= hourlist(thing)*60. + minlist(thing)
  for j=0,maybenot-1 do $
   plots,[minutetimes(j),minutetimes(j)],[!y.crange(0),!y.crange(1)],$
	linestyle=1,color=color
endif

;ytitler=' '


!p.position=old_pos

return
end




