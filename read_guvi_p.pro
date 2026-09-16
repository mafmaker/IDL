pro read_one_guvi_file,filename,_time,_lat,i1356,i1216,ilbh

format='(5f13)'
dummy=' '

get_lun,unit
openr,unit,filename
counter=0
for i=0,3 do readf,unit,dummy
while not eof(unit) do begin

  readf,unit,format='(a1)',dummy
  COUNTER=COUNTER + 1

endwhile

;---initialize variables
i1356=fltarr(counter)
i1216=fltarr(counter)
ilbh =fltarr(counter)
_lat=fltarr(counter)
_lon=fltarr(counter)
_time=fltarr(counter)
;---

close,unit
openr,unit,filename
newvar=fltarr(5)

for i=0,3 do readf,unit,dummy
counter=0
a=0. & b=a & c=a & d=a & e=a

while not eof(unit) do begin
  
  readf,unit,format=format,a,b,c,d,e
  newvar=[a,b,c,d,e]
  _time(counter) =newvar(0)
  _lat(counter) =newvar(1)
  i1356(counter)=newvar(2)
   ilbh(counter)=newvar(3)
  i1216(counter)=newvar(4)
  counter=counter + 1
endwhile

free_lun,unit



return
end


pro read_guvi_p,year,day,time,lat,lon,i1356,i1216,ilbh

; program to return guvi measurements as formated by Doug Strickland
; for any particular day and year 
; As the current text files do not contain longitudes, it doesn't make
; much sense to read all these files at once.
;

; get a filelist
syear=strcompress(year,/rem)
sdoy=strcompress(day,/rem)

spawn,'/home/immel/sci/guvi/' + syear + '_' + sdoy + '*.txt'

; create variables
lat=0. & lon=lat & i1356=lat & i1216=lat & ilbh=lat

; loop through all files found building variable arrays

for i=0,n_elements(filelist)-1 do begin

  read_one_guvi_file,filelist(i),newlats,newlons,new1356,new1216,newlbh

  lat=[lat,newlats]
  lon=[lon,newlons]
  i1356=[i1356,new1356]
  i1216=[i1216,new1216]
  ilbh=[ilbh,newlbh]

endfor

end
