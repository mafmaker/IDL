pro  gif_reader,img,r,g,b
;program gif_reader.pro 
;
;Thomas Immel 5-26-95
;
!path = 'Disk$user1:[immel.idl],' + !path

filename=' '

filename = pickfile(/read,filter='*.gif',/fix_filter)
;filename='venus.gif'

read_gif,filename,img,r,g,b
sizer=size(de_img)
window,0,xsize=fix(sizer(1)*1),ysize=fix(sizer(2)*1)

;a plotscl here (not tv) would allow the gif to be placed in a smaller
;window without cutting off the edges!

tv,img


tvlct,r,g,b
;better results with IDL color tables!
xloadct

tvlct,/get,r,g,b
;save,file='venus.idl',img,r,g,b

return
end
