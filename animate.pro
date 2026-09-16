pro animate,array

;  animates an array of data of nframes,xsize,ysize
;
;

sizer=size(array)
imgs=sizer(1)
xsize=sizer(2)
ysize=sizer(3)

xinteranimate,set=[xsize,ysize,imgs]

for i=0,imgs-1 do xinteranimate,frame=i,image=reform(array(i,*,*))

xinteranimate

end