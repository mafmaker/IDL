pro read_sem,time1,time2,sem_narrow_,sem_wide_,sem_jday_


;  Program to read SOHO SEM (solar extreme-UV monitor) data from 
;  http://www.usc.edu/dept/space_science/sem.htm
;  Using same time field as UDF data
;  [yyyy,doy,hh,mm,ss] for start and end times.
; 
;  Data are read from an IDL file. Read the ASCII using sem2idl.pro
; 
;  Uses jdcvt.pro (PRO JDCNV, YR, MN, DAY, HR, JULIAN). This is in the
;  usual astron library from APL
;  where hour can be a decimal argument 
;  Uses ydn2md.pro (YDN2MD,YR,DY,M,D)
;
;NOTES : This code does not read across month boundaries. Need a
;better version!!!


;From the data file :===
;
;;Data Revision: December 13, 2000  (v3)
;----------------------------------------------
;Column 0-      Julian date (mid point of sample)
;Column 1-      First Order Flux at 1AU (1)
;Column 2-      Central Order Flux at 1AU (2)
;
;-----------------------------------------------
;(0) Blank or Zero values = no data
;(1) Flux at 1AU
;       Range:  26 - 34 nm flux
;       Units:  photons cm^-2 s^-1
;       Value:  15 second average
;       Derivation:  average of CH1 and CH3
;(2) Flux at 1AU
;       Range:  0.1 - 50 nm flux
;       Units:  photons cm^-2 s^-1
;       Value:  15 second average
;       Derivation:  CH2


;restore,'$FUV_HOME/flare/SEM/SEM_2000_07_15sec.idl'  ; not used till later

jd1=0.d
jd2=0.d

hr1=time1(2) + time1(3)/60.
hr2=time2(2) + time2(3)/60.

ydn2md,time1(0),time1(1),mn1,day1
ydn2md,time2(0),time2(1),mn2,day2

smn=strcompress(mn1,/rem) & if mn1 lt 10 then smn='0'+smn
syr=strcompress(time1(0),/rem)

restore,'/home/immel/sci/sem/SEM_'+syr +'_'+smn +'_15sec.idl'

jdcvt,time1(0),mn1,day1,hr1,jd1
jdcvt,time2(0),mn2,day2,hr2,jd2

print,format='(d16.8)',jd1
print,format='(d16.8)',jd2



thing=where(sem_jday lt jd2 and sem_jday gt jd1,counter)

;plot,sem_long(thing)
;oplot,sem_short(thing)*10

sem_wide_=sem_wide(thing)
sem_narrow_=sem_narrow(thing)
sem_jday_=sem_jday(thing)

;use daycvt,sem_jday_,yr,mn,dy,hr (decimal) to get the time stamps back out.
;--- use that with the output, it is easier just to return the Julian day.

return
end
