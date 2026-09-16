pro combine_image,filelist,img,bck=bck,dosmooth=dosmooth,back_factor=back_factor
;
;  program simply averages images in time, all the images in filelist.
;  Will look for offset files in the same locations as filelist
;  bck flag will reduce the brightness of the airglow by 90%
;  dosmooth will smooth the images 
;
;  NOTES:
;  This program depends on off2 and off being defined in the offset file
;  You always have to at least calculate off2, for the jitter in the earth
;  in the image. If the coordinates are calculated correctly, you can
;  define the variable 'offset' as 0
;
;--- tone down the dayglow subtraction ---;
if keyword_set(back_factor) eq 0 then bck_factor=0.9


imgs=n_elements(filelist)
thing=strpos(filelist(0),'.')
offsetfiles=strmid(filelist,0,thing) + '.off'

restore,filelist(0)
img=imageinfo.image
img(*)=0
stamp=img		;this will show where image pixels have been added
size_=size(img)
size_=size_(1)

for i=0,imgs-1 do begin
  restore,filelist(i)
  spawn,'ls ' offsetfiles(i)
  if shift_exist(0) ne '' then restore,offsetfiles(i) else begin
	offset = 0
	off2 = 0
  endelse
  print,offset,off2
  if keyword_set(dosmooth) then imageinfo.image=smooth(imageinfo.image,3)
  lat=shift(imageinfo.glat,off2-offset)


  if offset gt 0 then begin
       lat(0:offset,*)=-999
  endif else lat(size_-1+offset:size_-1,*)=-999


  stamp(where(lat gt -90))=  stamp(where(lat gt -90)) + 1

  if i gt 0 then oneimg=shift(imageinfo.image,off2) else $
	oneimg=imageinfo.image
  if keyword_set(bck) eq 1 then begin
    image_bckgnd_p,imageinfo,bck,0
    bck=shift(bck,off2-offset)
    oneimg=oneimg-bck*back_factor
  endif else begin
    flat_arr=get_flatfield(2000,198,2)
    oneimg=oneimg*flat_arr
  endelse
  img=img+oneimg
;  tvscl,img
endfor

img=img/imgs


img(where(stamp ne imgs))=0


;stop

return
end