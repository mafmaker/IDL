pro hp_kpbased_p,year, day1, day2, hp,ctpot

;  procedure to create silly hp plot using KP
;

;  day1=33
;  day2=36


tgcm_flag=0

ps_flag=0
;ps_question,ps_flag

;if ps_flag then begin

;  set_plot,'ps'
;  device,/landscape,filename='../hp_kpbased.ps'

;endif

day_arr = indgen(day2-day1)+day1
;day_arr=[32,33,34,35]			;idl indices for KP array
;year='1983'
year = strcompress(year, /rem)

restore,'~immel/sci/kp/KP' + year +  '.idl'
newkp=kp_arr(*,day_arr)
thing=where(newkp ne -4539.)  	;a random number which kp will NOT be.
newkp=newkp(thing)


hp=(3. > (-2.78 + 9.33 * newkp))
hp=congrid(hp,(day2-day1+1)*24.*60.)

ctpot=29. + 11 * newkp
ctpot=congrid(ctpot,(day2-day1+1)*24.*60.)

;help,hp,ctpot


;xsizer=size(ctpot) & xsizer=xsizer(1)
;blank=strarr(10) &  blank(*)=' '
;thing=blank
;thing(indgen(day2-day1+1) + 1)=strcompress(day_arr,/rem)

;!p.multi=[0,2,1,0]



;plot,hp,xticks=8,xtickname=thing,$
;        xtitle='Day of ' + strcompress(year),xminor=1,$
;        title='KP based Hemispheric Power',yrange=[0,300],$
;	xrange=[0,xsizer-1],/xstyle,ytitle='HP (GW)'

;axis,xaxis=0,xticks=4,xticklen=0.081,xminor=1,xtickname=blank
;axis,xaxis=1,xticks=4,xticklen=0.081,xminor=1,xtickname=blank

;plot,ctpot,xticks=8,xtickname=thing,$
;        xtitle='Day of ' + strcompress(year),xminor=1,$
;        title='KP based Cross-Tail Potential',yrange=[0,150],$
;	xrange=[0,xsizer-1],/xstyle,ytitle='Potential (kV?)'

;axis,xaxis=0,xticks=4,xticklen=0.081,xminor=1,xtickname=blank
;axis,xaxis=1,xticks=4,xticklen=0.081,xminor=1,xtickname=blank

	
if ps_flag then ps_close


if tgcm_flag then begin

  close,4
  openw,4,'../output/days33_36ctpot.txt'

  timeincr=15.			;window to find max in.
  timeincr2=timeincr/60./24.			
  totsteps=24. * 60 * (day2-day1 + 1) / timeincr
  tgcm_out=fltarr(totsteps)
  tgcmform1='((i2,",",i2,",",i2,",",f5.1,", ",$))'
  tgcmform2='((i2,",",i2,",",i2,",",f5.1,", "))'
  for i=0,totsteps-1 do begin
    minutes=i*15.
    time=minutes + 7.5
    tgcm_out(i)=max(ctpot(time-7:time+7))
  endfor

  for i=0,totsteps-1 do begin

    thing=i
    minutes=thing*15 mod 60
    hours=((thing*15)/60) mod 24
    days=fix((thing*15/60./24)) + day1 
;    print,i,days,hours,minutes
    if (i+1) mod 4 ne 0 then $
	printf,4,format=tgcmform1,days,hours,minutes,tgcm_out(thing) $
        else printf,4,format=tgcmform2,days,hours,minutes,tgcm_out(thing) 
  endfor


  close,4


endif




return

end
