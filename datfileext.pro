
;Program DATFILEEXT.pro Reads the data file given by user. It then deletes
;every extension and adds the user supplied extension!
;
;   version 1.1 searches string for extention beginning, only
;               worked with DE filenames before!  TJI 12-4-96


close,2
close,3
file=' '
ext=' '
print,format='($,"Enter filename to change extensions:")
read,file
print,format='($,"Enter extension to change to:")
read,ext

num=0 
spare='                                       '
openr,2,file
readf,2,num
readf,2,spare
thinger=' '
counter=0
while thinger ne '.' do begin
  thinger=strmid(spare,counter,1)
  counter=counter + 1
endwhile
close,2

dum=' '
openr,2,file
readf,2,num
filarr=strarr(num)
for I=0,num-1 do begin
  readf,2,dum
  filarr(i)=dum
endfor
filarr=strmid(filarr,0,counter-1) + '.' + ext

openw,3,file
printf,3,strcompress(string(fix(num)),/remove_all)
for j=0,num-1  do begin
  printf,3,filarr(j)
endfor
close,2
close,3


end
