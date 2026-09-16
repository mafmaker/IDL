;function to determine the appropriate offset for the red value (next value
;under white, which is at the very top) on the current color scale/pallet 
; - this depends on which device is being used and the difference between 
;the scale min and max (diff)
;TJK June 25, 2004
function red_offset, GIF=GIF, diff

color_table_size=256 ;default
;TJK have to open a GIF device, so that I can get the correct !d.table_size
if keyword_set(GIF) then begin
;   tmp=strmid(GIF,0,(strpos(GIF,'/',/reverse_search)))+"/tmp.gif"
;   deviceopen,6,fileOutput=tmp
   ;for the GIF device - was doing the above, but had problems w/ other gifs
   ;being open at the same time...
   color_table_size = 240 ; this needs to match the table size set in deviceopen

endif
roffset = 1  ; default
if (diff gt 0) then roffset = diff/(color_table_size)
;if keyword_set(GIF) then deviceclose
return, roffset
end