function map_vmax,filelist

;
;  function to return a suitable top countrate for a colortable to 
; 

for i = 0,n_elements(filelist)-1 do begin

  restore,filelist(i)

  sizer=size(mapim)
  
  if sizer(1) gt 15 and sizer(2) gt 15 then  begin
      map=smooth(mapim,15)

      if i eq 0 then $
        v_max_arr=max(map) else $
        v_max_arr=[v_max_arr,max(map)]

  endif  ; else don't smooth the map and don't try to include those counts in the average array

endfor

v_max=mean(v_max_arr)

return,v_max

end
