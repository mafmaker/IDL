pro map_s13_to_wic2,  year, day, s13in, s13out


time_diff=0.

;--- the software returns pixel locations for the s13 pixels. Have to
;    fool it so that I do not have to do any interpolation or dilation.

x_in2 = findgen(256)#replicate(1., 256)
y_in2 = replicate(1., 256)#findgen(256)
new_s13 = fltarr(256, 256)   ;do not interpolate (add info)

convert_wic_si13_new, x_in2, y_in2, x_out, y_out, x_out2, y_out2, x_out3, y_out3, x_out4, y_out4, x_out5, y_out5, x_out6, y_out6, x_out7, y_out7, x_out8, y_out8, x_out9, y_out9, x_out10, y_out10, time_diff


x_out_f = x_out8
y_out_f = y_out8

if year eq 2000 and day lt 297 then x_out_f = x_out6
if year eq 2000 and day lt 297 then y_out_f = y_out6
if year eq 2000 and day lt 262 then x_out_f = x_out2
if year eq 2000 and day lt 262 then y_out_f = y_out2

if year eq 2000 and day lt 171 then begin
  ;begin spaghetti code
  print, 'No mapping is available for the given date'
  s13out = -1
  goto, GETOUT
endif

new_s13(x_in2, y_in2)= s13in(round(x_out_f), round(y_out_f))
;fltarr(256, 256)   ; wic.image &  mapped_s13_2(*) = 0
;mapped_s13_2(x_out_f, y_out_f) = hacked_s13(x_in2*2, y_in2*2)

;s13out = mapped_s13_2

GETOUT:

s13out = new_s13

return
end
