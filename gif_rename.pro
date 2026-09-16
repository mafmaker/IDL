
;
; program to rename gifs
;
;

spawn,'ls -1 *2000-06-08*.gif',filelist

for i=0,n_elements(filelist) -1 do begin
  thing=strmid(filelist(i),0,15) + strcompress(i,/rem) + '.gif'
  print,i
  print,'mv -f ' + filelist(i) + ' ' + thing
  spawn,'mv -f ' + filelist(i) + ' ' + thing
endfor 


end
