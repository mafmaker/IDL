pro pix_2_area,lat,latsize,lonsize,area,km=km,meters=meters

;
;  author : Thomas Immel - UCB
;  date   : 
;  license : Berkeley License
;
;  Program to convert lat and lon and latsize and lonsize of a 
;  gridded geographic coordinate system to area in square centimeters!
;
;  inputs - lat (in degrees -90,90)
;	    latsize (in decimal degrees e.g. 0.5)
;	    lonsize (in decimal degrees)
;  outputs - area ( in cm^2)
;
;  keywords : km - report area in km^2


;lat=45
;latsize=1.
;lonsize=1.

r=6340.d
rm=r*1000.d
rcm=rm * 100.d
circ=2.* !dpi  * rcm

latdist=(latsize / 360.) * circ
lonradius=rcm * cos(lat/!radeg)
loncirc=2. * !pi * lonradius
londist=loncirc * (lonsize / 360.)

area_=latdist*londist

if keyword_set(km) eq 1 then area_=area_/1e10
if keyword_set(meters) eq 1 then area_=area_/1e4
area=area_

return
end