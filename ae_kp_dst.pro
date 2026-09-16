;
;   ae_kp_dst.pro 
;
;
;   TJI SWRI GPL
;
;
;   Plot for Figure 1 of expected Joule heating paper.
;
;


ps_flag=0
ps_question,ps_flag

day1=0
day2=0
year=0
print,format='("Enter start day for plot (doy)",$)'
read,day1
print,format='("Enter end day for plot (doy)",$)'
read,day2
print,format='("Enter year for plot (full 4 digits)",$)'
read,year


if ps_flag eq 1 then begin
  set_plot,'ps'

  day_yr_string=strcompress(day1,/rem) + '_' + strcompress(year,/rem)
  device,filename='ae_kp_dst'+  day_yr_string +  '.ps',xsize=7,ysize=9,$
	/portrait,/inches,xoffset=0.75,yoffset=1,/helvetica
 

endif

!p.thick=2
!x.thick=2
!y.thick=2
!p.charthick=1.3

pos_arr=fltarr(4,3)
pos_arr(*,0)=[.1,.7,.9,.95]
pos_arr(*,1)=[.1,.45,.9,.7]
pos_arr(*,2)=[.1,.2,.9,.45]

;day1=33
;day2=37
;year=1983

;day1=121
;day2=124
;year=1998

ae_res=1440
kp_res=8
dst_res=24

;ae_arr=fltarr((day2-day1)*1440)
;kp_arr=fltarr((day2-day1)*8)
;dst_arr=fltarr((day2-day1)*24)

;for i=0,day2-day1 do begin

;  ae_p,year,day1+i,ae_temp
;  kp_p,year,day1+i,kp_temp
;  dst_p,year,day1+i,dst_temp
;  ae_arr(0+ae_res*i:1+ae_res+i-1)=ae_temp
;  kp_arr(0+kp_res*i:1+kp_res+i-1)=kp_temp
;  dst_arr(0+dst_res*i:1+dst_res+i-1)=dst_temp

;endfor

!p.position=pos_arr(*,0)

spawn,'ls ~immel/sci/ae/*.idl',textlist

print,textlist

helper=size(textlist) & helper=helper(1)
bla=' '
if helper gt 1 then for i=0,helper-1 do bla=bla + textlist(i)


if strpos(bla,strcompress(year,/rem)) ge 0 then $	;AE File may not exist
if ps_flag eq 1 then multiple_ae_p,year,day1,day2,0,/noxlab,/big else $
	         multiple_ae_p,year,day1,day2,0,/noxlab,inverse=inverse,/big

!p.position=pos_arr(*,1)

if ps_flag eq 1 then multiple_kp_p,year,day1,day2,0,/noxlab,/rhs else $
multiple_kp_p,year,day1,day2,0,/noxlab,inverse=inverse,/rhs

!p.position=pos_arr(*,2)

if ps_flag eq 1 then multiple_dst_p,year,day1,day2,0 else $
          multiple_dst_p,year,day1,day2,0,inverse=inverse 

xyouts,.41,.14,'Day of ' + strcompress(year,/rem),/norm,charsize=1.3

if ps_flag eq 1 then ps_close
print,'Your output file : ae_kp_dst'+  day_yr_string +  '.ps'

end


