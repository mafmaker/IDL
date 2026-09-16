pro read_champ_times_p,champ,gracea,graceb

;
; quick program to read GRACE A,B and CHAMP locations provided by
; Forbes and Sutton.
;

infile='/home/immel/sci/fuv/oct_2003/champ/CHAMP_GRACE_2003_301_304.asc'

;[Column]		[Description]		[units]
; 1				 4-digit year		 (years)
; 2				 Day of the Year	 (days)
; 3				 GPS Second of Day	 (sec)
; 4				 CHAMP Llatitude	 (deg)
; 5				 CHAMP Longitude	 (deg)
; 6				 GraceA Latitude	 (deg)
; 7				 GraceA Longitude	 (deg)
; 8				 GraceB Latitude	 (deg)
; 9				 GraceB Longitude	 (deg)

;structures will be defined as soon as we know how large the data set is:
      ;champ.lat, champ.lon, champ.gpst,champ.year,champ.doy
      ;gracea.lat,gracea.lon,gracea.gpst,gracea.year,gracea.doy
      ;graceb.lat,graceb.lon,graceb.gpst,graceb.year,graceb.doy

format='(2i4,f6,1x,f7,1x,f8,1x,f7,1x,f8,1x,f7,1x,f8)'

dummy=' '
get_lun,unit
openr,unit,infile
counter=0
while not eof(unit) do begin

  readf,unit,format='(a1)',dummy
  COUNTER=COUNTER + 1

endwhile

champ={lat:fltarr(counter),lon:fltarr(counter),year:intarr(counter),$
       doy:intarr(counter),gpst:fltarr(counter)}
gracea={lat:fltarr(counter),lon:fltarr(counter),year:intarr(counter),$
       doy:intarr(counter),gpst:fltarr(counter)}
graceb={lat:fltarr(counter),lon:fltarr(counter),year:intarr(counter),$
       doy:intarr(counter),gpst:fltarr(counter)}


close,unit
openr,unit,infile

a=0 & b=a
c=0. & d=c & e=c & f=c & g=c & h=c & i=c

count=0
while not eof(unit) do begin

  readf,unit,format=format,a,b,c,d,e,f,g,h,i
  time=c/3600.  ;decimal hours
  champ.gpst(count)=time & gracea.gpst(count)=time & graceb.gpst(count)=time
  champ.year(count)=a & gracea.year(count)=a & graceb.year(count)=a
  champ.doy(count)=b & gracea.doy(count)=b & graceb.doy(count)=b
  champ.lat(count)= d & champ.lon(count)=e
  gracea.lat(count)= f & gracea.lon(count)=g
  graceb.lat(count)= h & graceb.lon(count)=i

  count=count + 1
endwhile

free_lun,unit



return



end
