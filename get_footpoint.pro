;
;  Edit the following lines by hand!!!
;

read_gif,'POLAR_foot_print_2000265_north.gif',a
savefile='polar_foot_2000_265.idl'
begin_time=8

print,'Start clicking at hour ' + strcompress(begin_time)

thing=size(a)
 window,0,xsize=thing(1),ysize=thing(2)
 window,1,xsize=thing(1),ysize=thing(2)
!p.position=[0.01,0.01,.99,.99] 


map_set,90,0,/ortho,limit=[50,-180,90,180]
map_horizon
map_continents
map_grid,latdel=10,londel=30

;stop
tvscl,a

;--- going to make dummy lat and lon arrays, map_image those guys
;--- and reference them with mouse clicks on the original gif!!!

;--- lats and lons array will be 10 elements for each mapped degree

precision=1

lon_one=fltarr(361 * precision)
lon_one(*)=1.
lat_one=fltarr(41 * precision)
lat_one(*)=1.
lats=findgen(41 * precision)/precision + 50
lats=lon_one # lats
lons=findgen(361 * precision)/precision -180
lons=lons # lat_one

;maplats=map_image(lats,latmax=90,latmin=50,compress=1)
;maplons=map_image(lats,latmax=90,latmin=50,compress=1)
;maplats=congrid(maplats,thing(1),thing(2))
;maplons=congrid(maplons,thing(1),thing(2))


foot_lat=fltarr(12) 
foot_lon=fltarr(12)
foot_times=indgen(12) + begin_time

thing=size(foot_times)

for i=0,thing(1)-1 do begin

  cursor,x,y,/down

;---x is longitude, y is latitude
  print,x,y,foot_times(i)
  foot_lat(i)=y
  foot_lon(i)=x

endfor


save,filename=savefile,foot_lat,foot_lon,foot_times


end






