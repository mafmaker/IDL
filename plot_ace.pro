pro plot_ace,year,month,day,x=x,y=y,z=z,p=p,d=d,v=v,t=t,marktime=marktime,big=big

;  plots according to number of keywords provided!!!
;
;  p=pressure
;  d=density
;  v=velocity
;
; new plotting code to plot both swe and mfi data from ace. Will conk
; out if both are not available, for now.
;
; mark time must be given in hh:mm or decimal hours (when I get to coding that)

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
      newmarktime(i)=(hh*3600. + mm*60.) * 1000.
    endif	
  endfor


endif


year_=fix(year)
month_=fix(month)
day_=fix(day)

syear=strcompress(year,/rem)
smonth=strcompress(month,/rem)
sday=strcompress(day,/rem)

read_ace_mfi,year_,month_,day_,0,bx,by,bz,time,-999.9
read_ace_swe,year_,month_,day_,0,press,vx,time2,dst,-999.9


;  dynpress=(vx*1000)^2 * 1.6e-27  *den*1e6

  den=(press/1e9)/ (  (vx*1000.)^2  * 1e6 * 1.6e-27)

increment=(time(5)-time(4))/1000.		;this is increment in seconds
;cdf_epoch,time,year,month,day,hour,minute,/break


dist=150000000.		;km to sun
dist=dist/100.		;km to L1
delay=dist/vx		;m/m/sec

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

no_calc=where(newbx lt -998)
bt=[newbx^2 + newby^2 + newbz^2]^0.5
bt(no_calc)=-999.999

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
    good_dat=where(data(*,i) gt -998)
    xtickname=['0','2','4','6','8','10','12','14','16','18','20','22','24']
;    plot,time(good_dat)-time(0),data(good_dat,i),$
    plot,time-time(0),data(*,i),$
	ytitle=ytitles(i),/xstyle,xticks=12,$
	xtickname=xtickname,title=title,/nodata,min=-990
    oplot,time(good_dat)-time(0),data(good_dat,i)

    if keyword_set(marktime) gt 0 then begin
	for j=0,topcount do begin
	  plots,[newmarktime(j),newmarktime(j)],[!y.crange(0),!y.crange(1)]
	endfor
    endif
    if i le 2 then plots,[!x.crange(0),!x.crange(1)],[0,0],linestyle=1

    first_flag=0

  endif
endfor

;stop

end