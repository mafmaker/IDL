pro ap_4_msis,year,day,ut,ap_for_msis
;
;  The MSIS AP input, if one wishes to give a time history for accuracy,
;  is not straightforward. From msis90e.txt :
;         AP - MAGNETIC INDEX(DAILY) OR WHEN SW(9)=-1. :
;           - ARRAY CONTAINING:
;             (1) DAILY AP
;             (2) 3 HR AP INDEX FOR CURRENT TIME
;             (3) 3 HR AP INDEX FOR 3 HRS BEFORE CURRENT TIME
;             (4) 3 HR AP INDEX FOR 6 HRS BEFORE CURRENT TIME
;             (5) 3 HR AP INDEX FOR 9 HRS BEFORE CURRENT TIME
;             (6) AVERAGE OF EIGHT 3 HR AP INDICIES FROM 12 TO 33 HRS PRIOR
;                    TO CURRENT TIME
;             (7) AVERAGE OF EIGHT 3 HR AP INDICIES FROM 36 TO 59 HRS PRIOR
;                    TO CURRENT TIME
;-------------------------------------------------------------------------
;
;  Account for day and year rollback (i.e. if runs is for jan 1, 2000)
;  Build array of Ap in three hour increments previous to current time.

year_arr=intarr(24)			;(3*8 HOUR INCREMENTS)
day_arr=intarr(24)
ut_arr=intarr(24)

year_arr(*)=year
day_arr(23)=day
ut_arr(23)=ut


;ut will have to be in minutes at some point, but work with hours here!

for i=22,0,-1 do ut_arr(i)=ut_arr(23)-3*(23-i)

;print,ut_arr

;---find places in ut arrays and adjust accordingly
oneold=where(ut_arr lt 0 and ut_arr ge -24,uno)
twoold=where(ut_arr lt -24 and ut_arr ge -48,dos)
threeold=where(ut_arr lt -48 and ut_arr ge -72,tres)
today=where(ut_arr ge 0,countthis)
if uno gt 0 then ut_arr(oneold)=ut_arr(oneold)+24
if dos gt 0 then ut_arr(twoold)=ut_arr(twoold)+48
if tres gt 0 then ut_arr(threeold)=ut_arr(threeold)+72

;print,ut_arr

;---adjust day array accordingly
day_arr(today)=day

;print,day_arr

if uno gt 0 then day_arr(oneold)=day-1
if dos gt 0 then day_arr(twoold)=day-2
if tres gt 0 then day_arr(threeold)=day-3

;print,day_arr

;---find places in day_arr and adjust
lastyear=where(day_arr le 0,yearold)

if yearold gt 0 then year_arr(lastyear)=year-1

;print,year_arr


AP_FOR_MSIS=FLTARR(7)
ap_arr=fltarr(24)
days=uniq(day_arr) & thing=size(days)

daydex=thing(1)-1	;so I don't have to say thing(1)-1 all the time

for i=0,thing(1)-1 do begin
  kp_p,year_arr(days(i)),day_arr(days(i)),kp,ap

  part_of_day=ut/3
  if i eq thing(1)-1 then daily_ap=total(ap)/8.
;------------may not have any on 3rd day----REALLY!!! must check
  if tres gt 0 then if i eq daydex-3 then ap_arr(threeold)=ap(part_of_day+1:7)
;  print,ap_arr
  if dos gt 0 then if i eq daydex-2 then ap_arr(twoold)=ap
;  print,ap_arr
  if i eq daydex-1 then ap_arr(oneold)=ap
  if i eq daydex then ap_arr(today)=ap(0:part_of_day)  ;but the count up to days
						  ;may take care of the check!
endfor

print,"AP ",string(fix(ap_arr))

ap_for_msis(0)=daily_ap
ap_for_msis(1)=ap_arr(23)
ap_for_msis(2)=ap_arr(22)
ap_for_msis(3)=ap_arr(21)
ap_for_msis(4)=ap_arr(20)
ap_for_msis(5)=total(ap_arr(12:19))/8.
ap_for_msis(6)=total(ap_arr(4:11))/8.

;stop

return


end

