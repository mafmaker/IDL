pro gif_dump,img_arr,base,nograb=nograb

;  hand this program a 3d array with images stacked in (xsize,ysize,nimg)
;  order and it will dump numbered gif files with 'base' as their base
;  filename. It uses the colors assigned to the current device. This
;  may be a bad thing (TM) and you have the option to avoid this.


  sizer=size(img_arr)
  if keyword_set(nograb) eq 0 then tvlct,r,g,b,/get
  handy=bytarr(sizer(1),sizer(2))
  
  for i=0,sizer(3)-1 do begin
    giffilename=base + '_' + strcompress(i,/rem) + '.gif'
    handy=img_arr(*,*,i)
    if keyword_set(nograb) eq 0 then write_gif,giffilename,handy,r,g,b $
	else write_gif,giffilename,handy

  endfor




return
end
