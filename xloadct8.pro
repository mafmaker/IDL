function tvrd8,true=true,_extra=extra
  ; written by Atle Borsholm
  im3d=tvrd(true=3)
  im3d=long(im3d[*,*,0])+ishft(long(im3d[*,*,1]),8)+ishft(long((temporary(im3d))[*,*,2]),16)
  nx=(size(im3d,/dim))[0]
  ny=(size(im3d,/dim))[1]
  tvlct,red,green,blue,/get
  ct=transpose([[red],[green],[blue],[red*0b]])
  ct=long(temporary(ct),0,!d.table_size)
  byteorder,ct,/lswap,/swap_if_big
  ctsort=sort(ct)
  ct=ct[ctsort]
  index=bytarr(nx*ny)+byte(2^(Floor(Alog(!d.table_size - 1)/Alog(2))))
  for i=7,1,-1 do begin
    over=where(im3d gt ct[index<!d.table_size-1])
    under=where(im3d lt ct[index<!d.table_size-1])
    if (over[0] ne -1) then index[over]=index[over] or ishft(1b,i-1)
    if (under[0] ne -1) then index[under]=index[under] xor (ishft(1b,i) or ishft(1b,i-1))
  endfor
  im2d=reform(byte(ctsort[index]),nx,ny)
  return,im2d<!d.table_size-1
end

pro xloadctcallback,data=data
  old=!d.window
  device, get_decomp=old_dec
  device, decomp=0
  for i=0, n_elements(data.winIDs)-1 do begin
    wset, data.winIDs[i]
    tv, data.(i+1)
  endfor
  device, decomp=old_dec
  wset, old
end

pro xloadct8, winIDs,_extra=extra
  ; On an 8-bit pseudo color display, all graphics windows will
  ; change colortables when the user changes the colortable with XLOADCT
  ;
  ; On a 24-bit true color display the colors of the graphics will not change
  ; because RGB values rather than color indices are stored in the videocard
  ;
  ; This routine simulates the 8-bit pseudo color behaviour of XLOADCT when
  ; you have a 24-bit true color display
  ;
  ;  XLOADCT8 takes one optional argument.
  ;
  ; ARGUMENTS:
  ;
  ; WinIDs  - This argument can be a window ID or an array of window ID's that
  ;           determine which windows will be affected by XLOADCT8
  ;
  ;       If no arguments are present, then only the current graphics window is affected
  ;       (use WSET to change), and it is assumed that the colortable with which the
  ;       graphics was draw is the current colortable.
  ;
  ; KEYWORDS:
  ;
  ;  VERBOSE - If this keyword is set then a warning message is issued if the
  ;             colors in the image does not match the colors in the current colortable.
  ;
  ;     Any additional keywords will be passed along to XLOADCT.
  ;
  device, get_visual_depth=vd
  if (vd eq 8) or (!d.window eq -1) then begin
    xloadct,_extra=extra
    return
  endif
  ;
  old=!d.window
  if (n_elements(winIDs) eq 0) then winIDs=!d.window
  for i=0, n_elements(winIDs)-1 do begin
    wset, winIDs[i]
    image=tvrd8()
    if keyword_set(verbose) then begin
      window, /free, pixmap, xsize=(size(image,/dim))[0], ysize=(size(image,/dim))[1]
      w=!d.window
      device, get_decomp=old_dec
      device, decomp=0
      tv, image
      device, decomp=old_dec
    endif
    res=execute('image'+strtrim(i,2)+'=temporary(image)')
  endfor
  com='data={winIDs:winIDs'
  for i=0, n_elements(winIDs)-1 do com=com+',w'+strtrim(i,2)+':image'+strtrim(i,2)
  com=com+'}'
  res=execute(com)
  wset, old
  xloadct, updatecallback='xloadctcallback',$
    updatecbdata=data,_extra=extra
end
