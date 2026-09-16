pro vicinity,var,range,flag

;**********************************
;  Author: Thomas Immel
;    Date: 8-23-95
;Location: disk$jdc:[nicholas.idl]
;
; Use : Sets all pixels in moving boxcar to flag if any pixels in 
;     : the range are equal to flag
;     : 
;**********************************
;
;  fixes : Will handle 1-D arrays 7-17-96 TJI
;
;
;
; Variable list
;  var : the 2D array that will be smoothed
;  range : the size of the 'boxcar' smoothing
;  flag : the values of pixels that will not be included in the smoothing
;
;***********begin program************
thingy = size(var)                                     ;get size of array 
xsize = thingy(1) 
if thingy(0) gt 1 then ysize = thingy(2) else ysize = 1   ;7-17-96 
s_var=float(var) & s_var(*,*)=var                       ;the smoothed array
; 							values set to flag
for i=0,xsize-1 do begin
  for j=0,ysize-1 do begin
    if var(i,j) ne flag then begin
	sub_var = var( 0 > (i-range) : (xsize - 1) < (i + range),$
                       0 > (j-range) : (ysize - 1) < (j + range))   ; careful!!!
	bonk = where(sub_var eq flag,count)                   ; exclude flagged
;	sum = total(sub_var(bonk))                            ; total 
;	num = size(bonk)                                      ; to divide by
	if count gt 0 then $
	s_var( 0 > (i-range) : (xsize - 1) < (i + range),$
                       0 > (j-range) : (ysize - 1) < (j + range)) = flag

;	avg = sum/num(1)
;        s_var(i,j)=avg
    endif
  endfor
endfor
;
var=s_var                                                     ;replace var with
                                                              ;s_var
return

end
