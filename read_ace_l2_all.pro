pro read_ace_l2_all,year,month,day,ace,x=x,y=y,z=z,p=p,d=d,v=v,t=t,$
	interpolate=interpolate,stopper=stopper,noshift=noshift

;--- read_ace_l2_all.pro - TJI - 2-23-07
;
;
;  read without plotting anything and return ace data in a
;  structure!!!
;  This is based on plot_ace_l2.pro. THat is to take advantage of the
;  time-delay section of this code that works.
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


;NOW THIS CODE returns a structure:
;ace=[[newbx],[newby],[newbz],[bt],[newden],[newvx],[newpress]]

;--- convert marktime to milliseconds

;!p.charsize=1.2
;!x.charsize=1.3
;!y.charsize=1.3

;!x.thick=2.5
;!y.thick=2.5
;!p.thick=3

;if keyword_set(big) eq 1 then begin
;  !p.charsize=1.4
;  !x.charsize=1.5
;  !y.charsize=1.5
;endif

;if keyword_set(bigger) eq 1 then begin
;  !p.charsize=1.5
;  !x.charsize=1.6
;  !y.charsize=1.6
;endif

;if keyword_set(biggest) eq 1 then begin
;  !p.charsize=1.6
;  !x.charsize=1.7
;  !y.charsize=1.7
;endif

;if keyword_set(bigy) eq 1 then !y.charsize=!y.charsize * 1.2

;if keyword_set(thick) eq 1 then !p.charthick=3.


;if keyword_set(marktime) gt 0 then begin
;  msize=size(marktime)
;  newmarktime=marktime
;  newmarktime(*)=0
;  newmarktime=float(newmarktime)
;  if msize(0) eq 0 then topcount=0 else topcount=msize(1)-1
;  for i=0,topcount do begin
;    format=strpos(marktime(i),':')
;    if format gt -1 then begin
;      hh=float(strmid(marktime(i),0,format))
;      mm=float(strmid(marktime(i),format+1,strlen(marktime(i)) ) )
;      cdf_epoch,fracker,year,month,day,hh,mm,/compute
;      newmarktime(i)=fracker



;;;(hh*3600. + mm*60.) * 1000.
;    endif	
;  endfor


;endif


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
print,'Mean delay time is ', strcompress(mean(fix(delay))), ' seconds'
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




no_calc=where(newbx le -998, baddata)
bt=[newbx^2 + newby^2 + newbz^2]^0.5
if baddata gt 0 then bt(no_calc)=-999.999

if keyword_set(interpolate) gt 0 and baddata gt 0 then begin

  gooddata=where(newbx gt -998,goodcount)
  newbx(no_calc)=interpol(newbx(gooddata),gooddata,no_calc)
  newby(no_calc)=interpol(newby(gooddata),gooddata,no_calc)
  newbz(no_calc)=interpol(newbz(gooddata),gooddata,no_calc)

  bt(no_calc)=interpol(bt(gooddata),gooddata,no_calc)

endif

;--- do separately in case separate instruments have separate bad data
;    locations.


no_calc=where(newvx le -998, baddata)

if keyword_set(interpolate) gt 0 and baddata gt 0 then begin

  gooddata=where(newvx gt -998,goodcount)
  newvx(no_calc)=interpol(newvx(gooddata),gooddata,no_calc)
  newden(no_calc)=interpol(newden(gooddata),gooddata,no_calc)
  newpress(no_calc)=interpol(newpress(gooddata),gooddata,no_calc)

endif

if keyword_set(stopper) gt 0 then stop

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

;you know what day you asked for, you know what month, what year. Just
;return the UT in the time element of the structure, converted back
;from damn CDF_EPOCH

real_epoch_get,time,a,b,c,real_hour,real_minute,real_second

newut=real_hour+real_minute/60. + real_second/3600.

ace={ut:newut,bx:newbx,by:newby,bz:newbz,bt:bt,den:newden,vx:newvx,press:newpress}

end
