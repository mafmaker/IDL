function median_arr,arr,range,flag, fill = fill
;
;  Author : Thomas Immel
;  Date : 1996
;  Use  : To calculate medians while excluding flagged values which
;  would bias the results

; Function to return medianized values of an array
; arr : array in question
; range: center to edge size, 1:no median, 2:3x3,3:5x5, etc
; flag : values not to replace or include in calculations
; keywords : fill - will calculate median for pixels which have values=flag
;                   if any neighboring pixels are != flag.
; 11-12-03  - made loop variable type long integer

fill_flag = 0
if keyword_set(fill) gt 0 then fill_flag =  1

thingy = size(arr)                                     ;get size of array 
xsize = thingy(1) 
if thingy(0) gt 1 then ysize = thingy(2) else ysize = 1   ;7-17-96 
s_arr=float(arr) & s_arr(*,*)=flag                     ;the smoothed array
;                                                       values set to flag
for i=0l,xsize-1 do begin
  for j=0l,ysize-1 do begin
    if arr(i,j) ne flag or fill_flag eq 1 then begin
        sub_arr = arr( 0 > (i-range) : (xsize - 1) < (i + range),$
                       0 > (j-range) : (ysize - 1) < (j + range))  ; careful!!!
        bonk = where(sub_arr ne flag,bonker)               ; exclude flagged

        if bonker ge 1 then s_arr(i,j)=median(sub_arr(bonk))
    endif
  endfor
endfor




return,s_arr
end
