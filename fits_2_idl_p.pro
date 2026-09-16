pro fits_2_idl_p, filelist

;
; Program to dump images from fits files to idl files
; Made for euv fits files created in euv_imtool-1.05
;


;@fits_lib_p
;@fits_lib_p

print, 'If this crashes, type .run fits_lib at the IDL prompt';

;pro blabla

astrolib

;spawn,'ls -1 *2001101*.fits',filelist
sizer=size(filelist)
savefilelist=filelist
for i=0,sizer(1)-1 do savefilelist(i)=strmid(savefilelist(i),0,$
	strpos(savefilelist(i),'.'))
savefilelist=savefilelist + '.idl'

for i=0,sizer(1)-1 do begin
  print,i
  fits_read,filelist(i),tab,htab

  img=tab
  info=htab
  fitsfile=filelist(i)
  img=img(*,10:289)
  img=rotate(img,3)
  img=10^img
  save,filename=savefilelist(i),img,info,fitsfile

endfor

return
end
