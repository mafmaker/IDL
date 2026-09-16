pro complex_msis_p,year_,day_,ut_,lats_,lons_,alts_,msis_out,$
  f107flux=f107flux, mf107flux=mf107flux , ap=ap, stopper = stopper
;
; procedure simple_msis_p
; to return msis atmosphere for any point or set of points submitted
; to the procedure, given only time, day and location(s).
;
; This routine does two things. 
; 1) Returns MSIS values at the lats,lons,alts you specify
; 2) Returns 3 column densities at the lats and lons you specified
;
;
; year is 4 or more digits
; day is day of year
; ut is in decimal hours
; lats between -90 and 90
; lons from 0-360
;
; * everything but iiyd has to be floating point! * 
;
; returns : msis (densities in #/cc at locations specified)
; 	  : col, if multiple altitudes are asked for, 
;	  :    returns column densities (what units? /cm^2?)
;
; Notes 9-18-03 Beat working resolution down to 1 km before calling
; column density code. It is about TIME.
;
; 
;C     OUTPUT:
;C        D(1) - HE NUMBER DENSITY(CM-3)
;C        D(2) - O NUMBER DENSITY(CM-3)
;C        D(3) - N2 NUMBER DENSITY(CM-3)
;C        D(4) - O2 NUMBER DENSITY(CM-3)
;C        D(5) - AR NUMBER DENSITY(CM-3)                       
;C        D(6) - TOTAL MASS DENSITY(GM/CM3)
;C        D(7) - H NUMBER DENSITY(CM-3)
;C        D(8) - N NUMBER DENSITY(CM-3)
;C        T(1) - EXOSPHERIC TEMPERATURE
;C        T(2) - TEMPERATURE AT ALT
;
;  
;
;

year=float(year_)
day=float(day_)
ut=float(ut_)
lats=float(lats_)
lons=float(lons_)
alts=float(alts_)




;---first, need ap
if keyword_set(ap) le 0 then $
ap_4_msis,year,day,ut,ap ;else print,'real msis : Have AP already' 

;---need f107flux
imagetime=strcompress(string(fix(year)) + string(fix(day)),/rem)
if keyword_set(f107flux) le 0 then $
get_f107_for_time_p,imagetime,f107flux,mf107flux else begin
  f107flux = float(f107flux)
  mf107flux = float(mf107flux)

endelse
;print,'real msis : Have f107 already' 
;
;	f107=f107_ 
; 	f107m=f107_
;--- f107 and f107 are already defined!
;
;endelse

;--- need solar local time
uts=ut * 3600.
slt=float( fix(uts/3600.) + lons/15.) mod 24.	
;uts=long(uts)

;--- need iiyd, where here we use year 99 regardless of the actual year.
iiyd=99000   + float(day)
iiyd=long(iiyd)

;---initialize MSIS
switchy=intarr(25) + 1.		;
switchy(8)=-1.				;array of ap vs single value
;------------call this ONCE
dum=call_external('/home/immel/sci/msis/fuv/msis.so','calltselec_',switchy,1L)

;---determine how many times to call MSIS

maxlats=size(lats)
if maxlats(0) eq 0 or (maxlats(0) eq 1 and maxlats(1) eq 1) then $
  latct=1 else latct=maxlats(1)

maxlons=size(lons)
if maxlons(0) eq 0 or (maxlons(0) eq 1 and maxlons(1) eq 1) then $
  lonct=1 else lonct=maxlons(1)

maxalts=size(alts)
if maxalts(0) eq 0 or (maxalts(0) eq 1 and maxalts(1) eq 1) then $
  altct=1 else altct=maxalts(1)

msis_out=fltarr(lonct,latct,altct,10) ; array to hold all msis fields

;--- reform these arrays later!


temp=fltarr(2)  ;these are just holders
den=fltarr(8)   ;for the MSIS outputs

for hh=0,lonct -1 do begin
  for ii=0,latct - 1 do begin
    for jj=0,altct -1 do begin

;  for j=0,lonct do begin
;    for k=0,altct do begin
      gla=lons(hh)
      glo=lats(ii)
      alt=alts(jj)
      result=call_external('/home/immel/sci/msis/fuv/msis.so','callgtd6_',$
	 iiyd,uts,alt,gla,glo,slt,mf107flux,f107flux, ap, 48L, den, temp)

      msis_out(hh,ii,jj,*)=[den,temp]

    endfor
  endfor
endfor

;--- calculate column density of o, n2 if altitude range is good for that.

msis_out=reform(msis_out)

if keyword_set(stopper) gt 0 then stop

end
