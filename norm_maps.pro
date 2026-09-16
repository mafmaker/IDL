pro norm_maps,map1,map2,map3,sh=sh

 
;
; The order doesn't really matter, but this is here to put 3 maps
; on the same grid, cropping the equatorward latitudes. EXAMPLE:
; IDL> help,s12map
; S12MAP          FLOAT     = Array[721, 165]
; IDL> help,s13map
; S13MAP          FLOAT     = Array[721, 155]
; IDL> help,wicmap
; WICMAP          FLOAT     = Array[721, 165]
; That is a problem! Fix it!
;

  thing1=size(map1)
  thing2=size(map2)
  thing3=size(map3)

  limit=min([thing1(2),thing2(2),thing3(2)])

if keyword_set(sh) ne 1 then begin

  map1=reverse(map1,2)
  map2=reverse(map2,2)
  map3=reverse(map3,2)

endif

  map1=map1(*,0:limit-1)
  map2=map2(*,0:limit-1)
  map3=map3(*,0:limit-1)

if keyword_set(sh) ne 1 then begin

  map1=reverse(map1,2)
  map2=reverse(map2,2)
  map3=reverse(map3,2)

endif

end
