pro hardy_2_geo,pe,ut

;
;  Author : Thomas Immel
;  Date   : 11-14-01
;
;  Program to try to convert hardy magnetic lt model to geographic
;  If mag_2_geo takes arrays, may speed this up immensely by making
;  mlats and mlts arrays 2-D, and removing for loops. We shall see!
;  --- note, the above is implemented and works!
;
;  I should also consider using the poly_warp trick I used in trimag.
;  how _else_ will I get the right numbers at high latitudes?
;  The poly warp trick would probably get me past this terrible aliasing
;  that this routine results in!

sizer=size(pe)

latres=0.5
lonres=0.5

latsizer=180 * 1/latres
lonsizer=360 * 1/lonres

mlats=findgen(latsizer + 1) * latres    -90.
mlts=findgen(lonsizer + 1)* lonres

onelons=fltarr(lonsizer+1) + 1	;arrays of ones to build mlat and mlon arrays
onelats=fltarr(latsizer+1) + 1

mlons=mlts + 70. - ut * 15.
fix1=where(mlons gt 360.,ctfix1)
fix2=where(mlons lt 0.,ctfix2)

if ctfix1 gt 0 then mlons(fix1)=mlons(fix1)-360.
if ctfix2 gt 0 then mlons(fix2)=mlons(fix2)+360.

mlons_arr=mlons#onelats
mlats_arr=onelons#mlats

;lats=fltarr(lonsizer+1,latsizer + 1)
;lons=lats

noval=-1
pe_geo=pe & pe_geo(*)=noval

;for i=0,sizer(1) - 1 do begin
;print,i
;  for j=0,sizer(2) -1  do begin
;    mag_2_geo,mlats(j),mlons(i),lat,lon
;    print,mlats(j),mlons(i),lat,lon
;    lat=lat + 90.
;    if lon lt 0 then lon=lon + 360.
;    if lon gt 360. then lon=lon-360.
;    lat_dex = round(lat * 1/latres)
;    lon_dex = round(lon * 1/lonres)
;    pe_geo(lon_dex,lat_dex)=pe(i,j)
;  endfor
;endfor

mag_2_geo,mlats_arr,mlons_arr,lat_arr,lon_arr

  lat_arr=lat_arr + 90
  hilon=where(lon_arr gt 360. , cthilon)
  lolon=where(lon_arr lt 0. , ctlolon)

  if ctlolon gt 0. then lon_arr(lolon)=lon_arr(lolon) + 360.
  if cthilon gt 0. then lon_arr(hilon)=lon_arr(hilon)-360.

  lat_dex = round(lat_arr * 1/latres)
  lon_dex = round(lon_arr * 1/lonres)

;  lon_dex2=where(lon_dex ne -9999)
;pe_geo(lon_dex(lon_dex2),lat_dex(lon_dex2))=pe

pe_geo(lon_dex,lat_dex)=pe

;for i=0,sizer(1)-1 do begin
;  for j=0,sizer(2)-1 do begin
;    pe_geo(lon_dex(i),lon_dex(j))=
;  endfor
;endfor

print,'starting interpolation'
for j=0,sizer(2) - 1 do begin
  cut=pe_geo(*,j)
  bad=where(cut eq noval)
  good=where(cut gt noval,goodct)
  if goodct gt 2 then begin
    new=interpol(cut(good),good,bad)
    cut(bad)=new
    pe_geo(*,j)=cut
  endif

endfor

print,'ending interpolation'
pe=pe_geo
;stop

end
