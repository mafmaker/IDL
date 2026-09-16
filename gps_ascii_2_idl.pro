

infile='gps030529g-ascii.001'

date='529'

outfile1='gps030'+date+'.idl'
;outfile1='gps030530.idl'

array=intarr(360,180,1440/5)
lon=intarr(360*180.*1440/5)
lat=bytarr(360*180.*1440/5)   ;save some memory
time=lon
tec=lon

get_lun,unit
close,unit

openr,unit,infile


bla=[' ',' ',' ']
blabby=[' ',' ',' ',' ',' ']
input=bla

dateread=date

reader=0   ;flag to begin reading
indexer=0l  ;time indexer
count=0l    ;read counter
for i=0,49 do readf,unit,bla 

while dateread eq date and not(eof(unit)) do begin
  nextline:
  readf,unit,format='(3a6,5a6)',INPUT,blabby    ;arg I didn't want to do this

;  print,bla

;--- check to see if you just read a demarcation line, if so, take the
;    info you need and read the next line, prepare it for ingestion
;    into the large 1D arrays (input=...).
;  if n_elements(input) gt 3 then begin

  if (input(1)) eq 1101 and input(2) eq 8000 then if strcompress(blabby(2),/rem) eq date then begin

    reader=1          ;only need to do this once, but OK
    indexer=indexer+1 ; next timestep
    print,blabby
    dateread=strcompress(blabby(2),/rem)
    readf,unit,format='(3a6,5a6)',INPUT,blabby    ; read again

  endif else reader=0 ; there is no ELSE about it, you have to do the following.
  if reader ge 1 then begin
    lat(count)=input(0)/100. + 90
    lon(count)=input(1)/100.      ;have to shiftlong these later
    time(count)=indexer  
    tec(count)=input(2)
    count=count+1
  endif


endwhile
close,unit


lat=lat(0:count-1)
lon=lon(0:count-1)
lon2=lon
shiftlong,lon2
time=time(0:count-1)
tec=tec(0:count-1)

weights=intarr(count) + 1


;--- this is what IDL is good for.
array(lon2,lat,time)=tec
tec=array
array(*)=0
array(lon2,lat,time)=tec
tec=array
array(*)=0
array(lon2,lat,time)=weights  
; ---this weights array may seem dumb right now, since its either one or zero
;f
weights=array

save,filename=outfile1,tec,weights,/compress


end
