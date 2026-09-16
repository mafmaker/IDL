pro map_msis_p,mapim,col_arr,minlat,maxlat,lat_res,lon_res,maptime,f107flux=f107flux,mf107flux=mf107flux, stopper = stopper, res_step = res_step

; Thomas Immel 
; program to calculate msis column densities for a select number of points
; in a mapped image, and interpolate to get the rest. Faster than doing 
; every pixel, though this will NOT work for magnetically mapped images
;
; maptime is the same time format as that in imageinfo.time
; opening the f107 database is always time consuming. That is now 
; something you can provide in a keyword.
;
; Notes : Minlat has to be defined between 0 and 180. Negative numbers
; will blow up your results.
;
; inputs : 
; outputs: 
; keywords: stopper : stops code before exiting procedure (debugging
; purposes)
;          res_step : integer multiplier of resolution.
;
;


higher_res = 1
if keyword_set(res_step) gt 0 then begin
  if res_step gt 1 and res_step lt 10 then higher_res = fix(res_step) $
  else if res_step ge 10 then print, 'Resolution doesnt go that high, sorry!' 
endif

sizer=size(mapim)
help,mapim
xones=fltarr(sizer(1)) + 1
yones=fltarr(sizer(2)) + 1

lats=findgen(sizer(2))* lat_res + round(minlat) - 91.	;91 is a HACK!
							;this will come
							;back to haunt me!
lons=findgen(sizer(1)) * lon_res
lats2=xones#lats
lons2=lons#yones

ysize=10 * higher_res
xsize=20 * higher_res
lats3=congrid(lats2,xsize,ysize)
lons3=congrid(lons2,xsize,ysize)
col_arr=lats3 & col_arr(*)=0

alt_arr=findgen(100)*5 + 100.

image_time,maptime,year,day,month,dom,hh,mm,ss
ut=hh + mm/60.
;--- call these so they are not called for every pixel!!!
;--- option to provide f107 is now included above
if keyword_set(f107flux) le 0 then get_f107_for_time_p,maptime,f107flux,mf107flux
ap_4_msis,year,day,ut,ap

;--- 
print,'Ap for MSIS :' ,strcompress(ap)

;stopper = -1


for i=0,xsize-1 do begin
  for j=0,ysize-1 do begin
;    if j eq 15 and (i eq 14 or i eq 15) then stopper2 = 1 else stopper2 = -1
    real_msis_p,year,day,ut,lats3(0,j),lons3(i,0),alt_arr,o,n2,o2,col,$	
	f107flux=f107flux,mf107flux=mf107flux,ap=ap;, stopper = stopper2
    col_arr(i,j)=col(0)/col(1)
  endfor
endfor

old_col = col_arr
col_arr=congrid(col_arr,sizer(1),sizer(2),/interp)

help,col_arr
 if keyword_set(stopper) gt 0 then stop
end
