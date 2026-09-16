;;;;@fits_lib_p
;@fits_lib_p

pro read_fits_img, filelist, a, b, stopper = stopper

;  astrolib

;spawn,'ls *.fit',filelist

for i = 0, n_elements(filelist)-1 do begin

bla=filelist(i)
;image=mrdfits(filelist(i))
one=mrdfits(filelist(i),0,header)
;two=mrdfits(filelist(i),1)
;print,'thats it?'

a = one
b = header

print, header(12)


if keyword_set(stopper) gt 0 then stop

endfor

return
end
