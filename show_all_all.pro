;----------------------------------------------------------------------
function  put_doy,year,d_oy

;C****************************************************
;C
;C   author : hfrey, 12-06-99
;C
;C   general description:
;C   This function converts the day of year to month and day.
;C
;C   call_var.  dim. type  I/O  description
;C   MM               I    i    UT Month
;C   DD               I    i    UT Day 
;C
;C   returns                    message
;C   date                       if values ok
;C   
;C**********************************************************************

doy=d_oy
dtab=[31,28,31,30,31,30,31,31,30,31,30,31]

if (year lt 1901 or year gt 2099) then return,-1
if (doy gt 366 or doy lt 1) then return,-1

if((year mod 4) eq 0 and doy gt 59) then doy=doy-1	; leap year

i=-1
repeat begin
	i=i+1
	doy=doy-dtab[i]
	endrep until (doy le 0)

mm=i+1
if (mm lt 10) then month=strcompress('0'+string(fix(mm)),/remove_all) else $
	month=strcompress(string(mm),/remove_all)
dd=doy+dtab[i]
if (dd lt 10) then day=strcompress('0'+string(fix(dd)),/remove_all) else $
	day=strcompress(string(dd),/remove_all)

date=strcompress(month+'-'+day)

return,date

end

;=============================================================================
pro show_all_all, sc, start_time, end_time, scale_top = scale_top, $
                      every = every, label_bottom = label_bottom, nops = nops

;
;  Author : H. Frey
;  Additions by : TJI
;  Keywords : scale_top : set to less than 1 to decrease the top
;  of the color bar
;             every : plot every 'every' image in the ps plot

top_scale = 1.
skipper = 1
annotate_place = 0.0

if keyword_set(scale_top) gt 0 then top_scale = scale_top
if keyword_set(every) gt 0 then skipper = every
if keyword_set(label_bottom) gt 0 then annotate_place = 0.099

if strpos(sc, '2') ge 0 then begin

  name_1 = 'si12_'
  name_2 = 'SI12'
  sc_string = 'IMF12LSI'
  imgnum = 1
  imgsize = 128
endif
if strpos(sc, '3') ge 0 then begin
  name_1 = 'si13_'
  name_2 = 'SI13'
  sc_string = 'IMF13LSI'
  imgnum = 2
  imgsize = 128
endif

if strpos(sc, 'w') ge 0 then begin
  name_1 = 'wic_'
  name_2 = 'WIC'
  sc_string = 'IMFHWIC'
  imgnum = 0
  imgsize = 256
endif

;stop

l=fuv_read_udf(starttime=start_time,stoptime=end_time,vinst=sc_string)

if ((n_elements(l) mod 60) eq 0) then panels=n_elements(l)/skipper/60 else $
	panels=n_elements(l)/skipper/60+1



big=bytarr(imgsize*6,imgsize*10,panels)+255b

ss=size(big)

if imgnum gt 0 then for i=0,n_elements(l)/skipper -1 do $
	big[128*(i mod 6):128*((i mod 6)+1)-1,128*(9-(i mod 60)/6): $
		128*(10-(i mod 60)/6)-1,i/60] = $
		reverse(reverse(bytscl(l[i*skipper].si_pixels,max= $
                                       top_scale*min([8.*mean(l[i*skipper].si_pixels),max(l[i*skipper].si_pixels)])),2), 1 ) else $
for i=0,n_elements(l)/skipper -1 do $
	big[imgsize*(i mod 6):imgsize*((i mod 6)+1)-1,imgsize*(9-(i mod 60)/6): $
		imgsize*(10-(i mod 60)/6)-1,i/60] = $
		(reverse(bytscl(l[i*skipper].wic_pixels,max= $
                top_scale*min([8.*mean(l[i*skipper].wic_pixels),max(l[i*skipper].wic_pixels)])),2))

for i=1,5 do big[imgsize*i,*,*]=255b
for i=1,9 do big[*,i*imgsize,*]=255b

ann_times=strarr(n_elements(l))
ann_times=strcompress(string(fix(l.btime.hour))+':'+string(fix(l.btime.min))+ $
	':'+string(fix(l.btime.sec)))
if skipper gt 1 then ann_times = ann_times(findgen(n_elements(l)/skipper)*skipper)

;stop

if keyword_set(show_color) then begin
  r=byte(sqrt(findgen(256))*sqrt(255))
  g=r
  b=bytarr(256)+50b
  tvlct,r,g,b
  endif else loadct,0

if keyword_set(nops) le 0 then begin

  for i=0,panels-1 do begin
	set_plot,'ps'
	name=strcompress(name_1+string(i)+'.ps',/remove_all)
	if keyword_set(show_color) then $
	device,xsize=ss[1]*24./ss[2],ysize=ss[2]*24./ss[2],xoffset=4.,yoffset=2.,bits=8, $
		scale_factor=1.,filename=name,/color else $
	device,xsize=ss[1]*24./ss[2],ysize=ss[2]*24./ss[2],xoffset=4.,yoffset=2.,bits=8, $
		scale_factor=1.,filename=name	
	tv,big[*,*,i]
	for j=0+i*60,min([59+i*60,n_elements(l)/skipper-1]) do xyouts, $
	   (j mod 6)*1./6.,(10-(j mod 60)/6)*0.1-annotate_place,$
           ann_times[j], /normal, charsize=0.5,color=255
	time=strcompress(name_2+' '+string(l[i*60].btime.(0))+'-'+string(l[i*60].btime.(1))+$
	      '-'+string(fix(l[i*60].btime.(2)))+':'+$
	      string(fix(l[i*60].btime.(3)))+':'+$
	      string(fix(l[i*60].btime.(4))))
	xyouts,!x.margin[0],!d.y_size+!d.y_ch_size,/device,time, $
	      charsize=1.5,color=0,al=0.0,orient=0.0
	label_plot_image
	device,/close
	print,'Output in ',name,' , ',time
  endfor
  set_plot,'x'
endif

if keyword_set(mach_gifs) then begin
  for i=1,71 do begin			;n_elements(l)-1 do begin
;   for i=0,179 do print,i,l[i].btime.doy,l[i].btime.hour,l[i].btime.min,$
;    l[i].btime.min,l[i].btime.sec,long64(l[i].start_met),min(l[i].si_pixels),$
;    mean(l[i].si_pixels),max(l[i].si_pixels)
  name=strcompress('si13_'+string(long64(l[i].start_met))+'.gif',/remove_all)
  write_gif,name,reverse(reverse(bytscl(l[i].si_pixels,max=50,min=0),2),1)
  tv,reverse(reverse(bytscl(l[i].si_pixels,max=50,min=0),2),1)
  endfor
endif	


gif_input=bytarr(64*6,64*10+10*10+12,panels)+255b

if imgnum gt 0 then for i=0,n_elements(l)/skipper-1 do begin
	gif_input[64*(i mod 6):64*((i mod 6)+1)-1,$
		64*(9-(i mod 60)/6)+(10-(i mod 60)/6)*10-10: $
		64*(10-(i mod 60)/6)-1+(10-(i mod 60)/6)*10-10,i/60] = $
		reverse(reverse(bytscl(rebin(l[i*skipper].si_pixels,64,64),max= $
		min([5.*mean(l[i*skipper].si_pixels),max(l[i*skipper].si_pixels)])),2), 1)
	time_stamp=bytarr(64,10)
	set_plot,'z'
	device,set_resolution=[64,9]
	erase
	xyouts,1,0,ann_times[i],charsize=0.8,/device
	time_stamp[*,0:8]=tvrd()
		gif_input[64*(i mod 6):64*((i mod 6)+1)-1,$
		64*(10-(i mod 60)/6)+(10-(i mod 60)/6)*10-10: $
		64*(10-(i mod 60)/6)-1+(10-(i mod 60)/6)*10,i/60] = time_stamp
endfor	else for i=0,n_elements(l)/skipper-1 do begin
	gif_input[64*(i mod 6):64*((i mod 6)+1)-1,$
		64*(9-(i mod 60)/6)+(10-(i mod 60)/6)*10-10: $
		64*(10-(i mod 60)/6)-1+(10-(i mod 60)/6)*10-10,i/60] = $
		reverse(reverse(bytscl(rebin(l[i*skipper].wic_pixels,64,64),max= $
		min([5.*mean(l[i*skipper].wic_pixels),max(l[i*skipper].wic_pixels)])),2), 1)
	time_stamp=bytarr(64,10)
	set_plot,'z'
	device,set_resolution=[64,9]
	erase
	xyouts,1,0,ann_times[i],charsize=0.8,/device
	time_stamp[*,0:8]=tvrd()
		gif_input[64*(i mod 6):64*((i mod 6)+1)-1,$
		64*(10-(i mod 60)/6)+(10-(i mod 60)/6)*10-10: $
		64*(10-(i mod 60)/6)-1+(10-(i mod 60)/6)*10,i/60] = time_stamp
endfor



for j=0,panels-1 do begin
	time_stamp=bytarr(6*64,12)
	set_plot,'z'
	device,set_resolution=[64*6,11]
	erase

                                ;--- use 10 here to avoid screwing up
                                ;    the day when the udf file
                                ;    stretches into the previous day.
        day_index = 10 <  n_elements(l)
	fn_name=strcompress(name_1+$
	   string(fix(l[day_index].btime.year))+'_'+string(fix(l[day_index].btime.doy))+$
	   '_?.gif',/remove_all)

	xyouts,10,0,fn_name, charsize = 1, /device
;	   'This are raw data. For scientific use contact FUV-PI.',$
;	   charsize=1.,/device
	time_stamp[*,1:*]=tvrd()
	gif_input[*,64*10+10*10:64*10+10*10+11,j]=time_stamp
	endfor

set_plot,'x'

for i=1,5 do gif_input[i*64,0:64*10+10*10,*]=255b
for i=1,10 do gif_input[*,i*(64+10),*]=255b
loadct,0
tvlct,r,g,b,/get
for j=0,panels-1 do begin
	if (j lt 10) then numb=strcompress('0'+string(j),/remove_all) else $
		numb=string(j)
	name=strcompress(name_1+$
	   string(fix(l[j*60].btime.year))+'_'+string(fix(l[j*60].btime.doy))+$
	   '_'+numb+'.gif',/remove_all)
	write_gif,name,gif_input[*,*,j],r,g,b
	print,'Output in ',name
endfor




;stop
END

