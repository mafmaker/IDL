pro read_champ_density_p,champ

;
; quick program to read GRACE A,B and CHAMP locations provided by
; Forbes and Sutton.
;

infile='/home/immel/sci/fuv/oct_2003/champ/Thomas_Immel_CHAMP_2003_301_304.asc'

;[column]        [value]                      [unit]          [format]
;1              Year (4-digit)                                   4i
;2                       Day of Year                             3i
;3                       Second of Day                           5i
;4                       Height (above ref. ellipsoid)  km       7.3f
;5                       Geod. Latitude      deg                 7.3f
;6                       Geod. Longitude     deg                 8.3f
;7                       STAR Density        kg/m^3             14.7e




;structures will be defined as soon as we know how large the data set is:
      ;champ.lat, champ.lon, champ.gpst,champ.year,champ.doy
      ;gracea.lat,gracea.lon,gracea.gpst,gracea.year,gracea.doy
      ;graceb.lat,graceb.lon,graceb.gpst,graceb.year,graceb.doy

format='(2i4,f6,1x,f7.3,1x,f7.3,1x,f8.3,1x,f14.7)'

dummy=' '
get_lun,unit
openr,unit,infile
counter=0
while not eof(unit) do begin

  readf,unit,format='(a1)',dummy
  COUNTER=COUNTER + 1

endwhile

champ={lat:fltarr(counter),lon:fltarr(counter),year:intarr(counter),$
       doy:intarr(counter),gpst:fltarr(counter),altitude:fltarr(counter),$
       density:fltarr(counter)}
;gracea={lat:fltarr(counter),lon:fltarr(counter),year:intarr(counter),$
;       doy:intarr(counter),gpst:fltarr(counter)}
;graceb={lat:fltarr(counter),lon:fltarr(counter),year:intarr(counter),$
;       doy:intarr(counter),gpst:fltarr(counter)}


close,unit
openr,unit,infile

a=0 & b=a
c=0. & d=c & e=c & f=c & g=c & h=c & i=c

count=0
while not eof(unit) do begin

  readf,unit,format=format,a,b,c,d,e,f,g
  time=c/3600.  ;decimal hours
  champ.gpst(count)=time 
  champ.year(count)=a 
  champ.doy(count)=b 
  champ.altitude(count)=d
  champ.lat(count)= e & champ.lon(count)=f
  champ.density(count)= g
  count=count + 1

endwhile

free_lun,unit

return



end
