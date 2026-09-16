pro read_noaa,powerfile,year,day,hr,min_,hemi,power,sat,factor
;
;   program to read noaa satelite hemi. power indicies
;   will make arrays of everything read in and return to main program
;   author : TJI
;   date   : 
;# A7    NOAA POES Satellite number
;# A3    (S) or (N) - hemisphere
;# I3    Day of year
;# I4    UT hour and minute
;# F8.1  Estimated Hemispheric Power in gigawatts
;# I3    Hemispheric Power Index (activity level)
;# F8.3  Normalizing factor

;tgcm_flag=1	;make a tgcm infile



;powerfile='../data/power_1983.txt'

close,5
openr,5,powerfile

inform='(a7,a3,i3,i2,i2,f8.1,i3,f8.3)'


blank='    '
counter=0
startflag=0

readf,5,blank
while startflag eq 0 do begin
  counter = counter + 1
  lastblank=blank
  readf,5,blank
;  print,blank
  if strmid(blank,0,4) eq 'NOAA' then startflag=1
endwhile
dummyread=counter-1

year=fix(lastblank)

counter=0
while not(eof(5)) do begin
  readf,5,blank
  counter=counter + 1
endwhile

close,5
openr,5,powerfile

day=intarr(counter) & hr=day & min_=hr & hemi=bytarr(counter)
power=fltarr(counter) & sat=strarr(counter) & factor=power

for i=0,dummyread do readf,5,blank
for i=0,counter-1 do begin

  a=' ' & b=' ' & c=0 & d=0 & e=0
  readf,5,format=inform,a,b,c,d,e,f,g,h
;  print,a,b,c,d,e,f,g,h
  sat(i)=a
  if strcompress(b) eq '(N)' then hemi(i)=1 else hemi(i)=0
  day(i)=c
  hr(i)=d
  min_(i)=e
  power(i)=f
  factor(i)=h
endfor




return
end




