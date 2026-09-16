pro real_msis_P2,year_,day_,ut_,lats_,lons_,alts_,o_arr,n2_arr,o2_arr,col,$
                temp_arr,$
  f107flux=f107flux, mf107flux=mf107flux , ap=ap, stopper = stopper
;
; procedure real_msis_P
; to return msis atmosphere for any point or set of points submitted
; to the procedure, given only time, day and location(s).
;
; It can handle, glat or alt being a 1-D array. Not glon yet, because of
; solar local time. This is an easy fix tho... (it must be in now)
;
; Notice that this routine is setup to loop for a grid, NOT a
; satellite orbit. It is really customized to make a grid of column densities.
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
; returns : o_arr, n2_arr, o2_arr (densities in #/cc at locations specified)
; 	  : col, if multiple altitudes are asked for, 
;	  :    returns column densities (what units? /cm^2?)
;
; Notes 9-18-03 Beat working resolution down to 1 km before calling
; column density code. It is about TIME.
;
;       Version 2.0 (p2) : returns a temperature array now (finally).
;                          why does 'switch=' result in an error now?!?!
;                          WTF!!!!????? Oh well, make it 'switchy='
;       (answer: because switch is now an IDL function. Cripes!)
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
  latct=0 else latct=maxlats(1)-1

maxlons=size(lons)
if maxlons(0) eq 0 or (maxlons(0) eq 1 and maxlons(1) eq 1) then $
  lonct=0 else lonct=maxlons(1)-1

maxalts=size(alts)
if maxalts(0) eq 0 or (maxalts(0) eq 1 and maxalts(1) eq 1) then $
  altct=0 else altct=maxalts(1)-1

;--- reform these arrays later!
n2_arr=fltarr(max([latct+1,lonct+1,altct+1]))
o2_arr=fltarr(max([latct+1,lonct+1,altct+1]))
o_arr=fltarr(max([latct+1,lonct+1,altct+1]))
temp_arr=o_arr
temp=fltarr(2)
den=fltarr(8)


for i=0,latct do begin
  for j=0,lonct do begin
    for k=0,altct do begin
      gla=lats(i)
      glo=lons(j)
      alt=alts(k)
       result=call_external('/home/immel/sci/msis/fuv/msis.so','callgtd6_',$
	iiyd,uts,alt,gla,glo,slt,mf107flux,f107flux, ap, 48L, den, temp)
        O_arr(i>j>k)=den(1) & N2_arr(i>j>k)=den(2) & O2_arr(i>j>k)=den(3)
	temp_arr(i>j>k)=temp(1)

    endfor
  endfor
endfor

;--- calculate column density of o, n2 if altitude range is good for that.

col=fltarr(3)-1.
 if altct gt 0 then begin

  p_target=1e-5	;pressure level in torr
  base_alt=pressure_alt_f(iiyd,uts,gla,glo,mf107flux,f107flux,ap,p_target)

  
;--- with 5 km resolution, the difference between 129.9 and 130.1 is 5
;    km of atmosphere. Which SUCKS!@

;---New section,  9-18-03 INTERPOLATE to 1 KM HERE BEFORE CALLING col..f3

  if base_alt gt alts(0) then begin
    hires_alts = findgen(1000)  ;1000 km
    hires_o = fltarr(1000) &  hires_o(fix(alts)) = o_arr 
    hires_o2 = fltarr(1000) &  hires_o2(fix(alts)) = o2_arr 
    hires_n2 = fltarr(1000) &  hires_n2(fix(alts)) = n2_arr 
;--- this is the entire old section
;    thing=where(alts gt base_alt)
;    new_o=o_arr(thing)
;    new_n2=n2_arr(thing)
;    new_o2=o2_arr(thing)
;    new_alts=alts(thing)
;    column_o=column_den_f3(new_o,new_alts)
;    column_n2=column_den_f3(new_n2,new_alts)
;    column_o2=column_den_f3(new_o2,new_alts)
;    col=[column_o,column_n2,column_o2]
;--- going to mainly duplicate it...

    thing=where(hires_alts gt round(base_alt))
    new_o=hires_o(thing)
    new_n2=hires_n2(thing)
    new_o2=hires_o2(thing)
    new_alts=hires_alts(thing)

;--- NOW interpolate densities

    zipper = where(new_o eq 0)
    goody = where(new_o gt 0)
    new2_o = interpol(new_o(goody), goody, zipper)
    new2_o2 = interpol(new_o2(goody), goody, zipper)
    new2_n2 = interpol(new_n2(goody), goody, zipper)

    new_o(zipper) = new2_o
    new_o2(zipper) = new2_o2
    new_n2(zipper) = new2_n2

    column_o=column_den_f3(new_o,new_alts)
    column_n2=column_den_f3(new_n2,new_alts)
    column_o2=column_den_f3(new_o2,new_alts)
    col=[column_o,column_n2,column_o2]

;--- done 9-18-03


  endif
endif



if keyword_set(stopper) gt 0 then stop

end
