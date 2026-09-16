pro plot_ace_l2,year,month,day,x=x,y=y,z=z,p=p,d=d,v=v,t=t,$
	marktime=marktime,big=big,half=half,fourth=fourth,$
	bigger=bigger,biggest=biggest,stopper=stopper,noshift=noshift,$
        bigy=bigy                

;  plots according to number of keywords provided!!!
;
;  p=pressure
;  d=density
;  v=velocity
;
; new plotting code to plot both swe and mfi data from ace. Will conk
; out if both are not available, for now.
;
; mark time must be given in hh:mm or decimal hours
;	(when I get to coding that)
;
; 2-1-02 : Added noshift keyword
; 10-22-02 : Why is first_time commented out everywhere it is defined,
; when it is used practically universally in this code?!?!!

;--- convert marktime to milliseconds

!p.charsize=1.2
!x.charsize=1.3
!y.charsize=1.3

!x.thick=2.5
!y.thick=2.5
!p.thick=3

if keyword_set(big) eq 1 then begin
  !p.charsize=1.4
  !x.charsize=1.5
  !y.charsize=1.5
endif

if keyword_set(bigger) eq 1 then begin
  !p.charsize=1.5
  !x.charsize=1.6
  !y.charsize=1.6
endif

if keyword_set(biggest) eq 1 then begin
  !p.charsize=1.6
  !x.charsize=1.7
  !y.charsize=1.7
endif

if keyword_set(bigy) eq 1 then !y.charsize=!y.charsize * 1.2

;if keyword_set(thick) eq 1 then !p.charthick=3.


if keyword_set(marktime) gt 0 then begin
  msize=size(marktime)
  newmarktime=marktime
  newmarktime(*)=0
  newmarktime=float(newmarktime)
  if msize(0) eq 0 then topcount=0 else topcount=msize(1)-1
  for i=0,topcount do begin
    format=strpos(marktime(i),':')
    if format gt -1 then begin
      hh=float(strmid(marktime(i),0,format))
      mm=float(strmid(marktime(i),format+1,strlen(marktime(i)) ) )
      cdf_epoch,fracker,year,month,day,hh,mm,/compute
      newmarktime(i)=fracker



;;;(hh*3600. + mm*60.) * 1000.
    endif	
  endfor


endif


year_=fix(year)
month_=fix(month)
day_=fix(day)

syear=strcompress(year,/rem)
smonth=strcompress(month,/rem)
sday=strcompress(day,/rem)

badflag=-999.9

print,day_
read_ace_mfi_l2,year_,month_,day_,0,bx,by,bz,time,xgse,badflag
print,day_
read_ace_swe_l2,year_,month_,day_,0,press,vx,time2,dst,xgse2
print,day_

;--- l2 data may be of different timescales, congrid one or the other
;--- up the the greatest size.

mfi_size=size(time) & mfi_size=mfi_size(1)
swe_size=size(time2) & swe_size=swe_size(1)

if swe_size gt mfi_size then begin
  bx=congrid(bx,swe_size,/interp)
  by=congrid(by,swe_size,/interp)
  bz=congrid(bz,swe_size,/interp)
  xgse=xgse2
  time=congrid(time,swe_size,/interp)
endif else begin
  press=congrid(press,mfi_size,/interp)
  vx=congrid(vx,mfi_size,/interp)
  time2=congrid(time2,mfi_size,/interp)
  ;xgse=xgse
endelse



;---

;  dynpress=(vx*1000)^2 * 1.6e-27  *den*1e6

  den=(press/1e9)/ (  (vx*1000.)^2  * 1e6 * 1.6e-27)

;--- even though time stamps are interpolated, use one that is not for
;--- determining the increment. WHY>??!?!?

if swe_size gt mfi_size then increment=(time2(5)-time2(4))/1000. else $
increment=(time(5)-time(4))/1000.	;this is increment in seconds
increments=24*60.*60./round(increment)
;cdf_epoch,time,year,month,day,hour,minute,/break


;dist=150000000.		;km to sun
;dist=dist/100.		;km to L1
;delay=dist/vx		;m/m/sec

;--- xgse is in km

re=6340.
bow_shock_dist= 14 * re

dist=xgse
delay=(xgse-bow_shock_dist)/vx + (bow_shock_dist * 2/vx)
print,'Delay time is ', strcompress(mean(fix(delay))), ' seconds'
if keyword_set(noshift) eq 1 then delay(*)=0.

shifter=round(delay/increment)
sizer=size(shifter)
newpos=shifter + indgen(sizer(1))

newbx=bx & newbx(*)=-999.999
newby=newbx
newbz=newbx
newpress=newbx
newvx=newbx
newden=newbx


for i=0,sizer(1)-1 do begin
  if newpos(i) lt sizer(1) then begin
    newbx(newpos(i))=bx(i)
    newby(newpos(i))=by(i)
    newbz(newpos(i))=bz(i)
    newpress(newpos(i))=press(i)
    newvx(newpos(i))=vx(i)
    newden(newpos(i))=den(i)
  endif
endfor

starter=min(newpos)

goto, SKIP_THIS

filler=newbx(starter:*)
sw_interp,filler,(time(starter:*)-time(starter))/1000.,0
newbx(starter:*)=filler

filler=newby(starter:*)
sw_interp,filler,(time(starter:*)-time(starter))/1000.,0
newby(starter:*)=filler

filler=newbz(starter:*)
sw_interp,filler,(time(starter:*)-time(starter))/1000.,0
newbz(starter:*)=filler

filler=newpress(starter:*)
sw_interp,filler,(time(starter:*)-time(starter))/1000.,0
newpress(starter:*)=filler

filler=newvx(starter:*)
sw_interp,filler,(time(starter:*)-time(starter))/1000.,0
newvx(starter:*)=filler

filler=newden(starter:*)
sw_interp,filler,(time(starter:*)-time(starter))/1000.,0
newden(starter:*)=filler

SKIP_THIS:


;--- now do the plots
plot_num=0

if keyword_set(x) gt 0 then plot_num=plot_num+1
if keyword_set(y) gt 0 then plot_num=plot_num+1
if keyword_set(z) gt 0 then plot_num=plot_num+1
if keyword_set(t) gt 0 then plot_num=plot_num+1
if keyword_set(d) gt 0 then plot_num=plot_num+1
if keyword_set(v) gt 0 then plot_num=plot_num+1
if keyword_set(p) gt 0 then plot_num=plot_num+1


!p.multi=[0,1,plot_num,0]

; cycle through keywords so we can plot in a loop
keys=intarr(7);		['x','y','z','p','d','v']
if keyword_set(x) gt 0 then keys(0)=1
if keyword_set(y) gt 0 then keys(1)=1
if keyword_set(z) gt 0 then keys(2)=1
if keyword_set(t) gt 0 then keys(3)=1
if keyword_set(d) gt 0 then keys(4)=1
if keyword_set(v) gt 0 then keys(5)=1
if keyword_set(p) gt 0 then keys(6)=1


if keyword_set(stopper) gt 0 then stop

no_calc=where(newbx lt -998, baddata)
bt=[newbx^2 + newby^2 + newbz^2]^0.5
if baddata gt 0 then bt(no_calc)=-999.999

toplot=where(newbx ne badflag,countplot)	;all the data, for sure

;--- implement half and quarter day plots, need to do new xticknames
;--- specific to each of these!

xtickname=['0','2','4','6','8','10','12','14','16','18','20','22','24']
xticks=12

;--- the problem with this half business is that it does not
;--- take into account bad data, and if the set starts bad (July 16)
;--- it does not appear shifted wrt the time indication on xaxis.

;--- you cannot fix plot limits with these bad data! So define the 
;--- quarter and half sizes very strictly with cdf_epoch. Should be better!

;--- added these 10-02, how did I get by without these before?!?
first_time=time(0)
last_time=time(n_elements(time)-1)


if keyword_set(half) gt 0 then begin
  newsize=countplot/2

;--- UNCommenting 10-02
  first_time=time(newsize*((half)-1))
  last_time =time(newsize*(half)-1)

  cdf_epoch,first_time,year,month,day,(half-1)*12,0,/compute

  top_hr=half*12
  top_min=0
  top_sec=0
  if half*12 eq 24 then begin
    top_hr=23
    top_min=59
    top_sec=59
  endif

  cdf_epoch,last_time,year,month,day,top_hr,top_min,/compute
  toplot=where(time ge first_time and time $
		le last_time)




;  first_time= increment     (increments*1000.)/2

  case half of
    1: xtickname=['0','2','4','6','8','10','12']
    2: xtickname=['12','14','16','18','20','22','24']
    else: print,'You have to set half to 1 or 2 only!!!' 
  endcase
  xticks=6 
endif
;--- third makes my keyword /t screw up, and I LIKE /t!!!

if keyword_set(fourth) gt 0 then begin
  newsize=countplot/4

;--- again UNcommenting 10-02

  first_time=time(newsize*((fourth)-1))
  last_time =time(newsize*(fourth)-1)
  cdf_epoch,first_time,year,month,day,(fourth-1)*6,0,/compute
  top_hr=fourth*6
  top_min=0
  top_sec=0
  if fourth*6 eq 24 then begin
    top_hr=23
    top_min=59
    top_sec=59
  endif

  cdf_epoch,last_time,year,month,day,top_hr,top_min,/compute

  toplot=where(time ge first_time and time $
		le last_time)

;  newsize=countplot/4
;  newtime=time(newsize*keyword_set(fourth)-1:newsize*keyword_set(fourth))
  case fourth of
    1: xtickname=['0','1:00','2:00','3:00','4:00','5:00','6:00']
    2: xtickname=[6,7,8,9,10,11,12]
    3: xtickname=[12,13,14,15,16,17,18]
    4: xtickname=[18,19,20,21,22,23,24]
    else: print,'You have to set fourth to 1,2,3 or 4 only!!!' 
  endcase 
  xticks=6
  xminor=4
  xtickname=strcompress(xtickname,/rem)
endif


data=[[newbx],[newby],[newbz],[bt],[newden],[newvx],[newpress]]

ytitles=['IMF Bx (GSM nT)','IMF By (GSM nT)',$
	'IMF Bz (GSM nT)','IMF Btot (nT)',$
	'Density (cm!u-3!n)','Rad. Velocity (km/sec)',$
	'Pressure (nPa)']

first_title='ACE Solar Wind Parameters, ' + smonth +'/'+ sday +'/'+ syear
first_title=first_title + ' (corrected to 1 AU)'
first_flag = 1
last_flag=0

for i=0,6 do begin

  title=' '
  if first_flag eq 1 then title=first_title

  if keys(i) gt 0 then begin
    good_dat=where(data(toplot,i) gt badflag,goodcount)
    bad_dat=where(data(toplot,i) eq badflag,badcount)
;    xtickname=['0','2','4','6','8','10','12','14','16','18','20','22','24']
;    plot,time(good_dat)-time(0),data(good_dat,i),$
;    plot,time-time(0),data(*,i),$
;    plot,time(toplot(good_dat))-time(0),data(toplot(good_dat),i),$
    if goodcount gt 2 then $
    plot,time(toplot(good_dat))-first_time,data(toplot(good_dat),i),$
	ytitle=ytitles(i),/xstyle,xticks=xticks,$
	xtickname=xtickname,title=title,/nodata,min=-990,$
	xrange=[0,last_time-first_time],xticklen=0.06,xminor=xminor $
    else begin
	blankdat=time & blankdat(*)=-1
        plot,time-first_time,blankdat,ytitle=ytitles(i),/xstyle,xticks=xticks,$
	xtickname=xtickname,title=title,/nodata,min=-990,$
	xrange=[0,last_time-first_time],xticklen=0.06,xminor=xminor 
    endelse

;    oplot,time(good_dat)-time(0),data(good_dat,i)
;     oplot,time(toplot(good_dat))-time(0),data(toplot(good_dat),i)

    if goodcount gt 2 then $
     oplot,time(toplot(good_dat))-first_time,data(toplot(good_dat),i)

    if keyword_set(marktime) gt 0 then begin
	for j=0,topcount do begin
	  plots,[newmarktime(j),newmarktime(j)]- first_time, $
	[!y.crange(0),!y.crange(1)]
	endfor
    endif
    if i le 2 then plots,[!x.crange(0),!x.crange(1)],[0,0],linestyle=1

    first_flag=0

  endif
endfor

if keyword_set(stopper) gt 0 then stop

end
