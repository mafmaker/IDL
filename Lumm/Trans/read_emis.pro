pro read_emis, path, e_path

; read the PLOTEMI file with band and line brightnesses
; note that this is an ASCII file

@common

on_ioerror, error

if not keyword_set(e_path) then e_path=""
msg_out, "Reading file PLOTEMI"
openr, unit, path+"/PLOTEMI"+e_path, /get_lun

mmax = 0L
readf, unit, mmax

altitude=fltarr(mmax)
readf, unit, altitude
altitude=altitude*1e-5

line = replicate({name:'', wavelength:0., brightness:fltarr(mmax)}, 17)

form = '(a14,f5.1)'
for i=0,16 do begin
   a1 = ''
   a2 = 0.
   a3 = fltarr(mmax)
   readf, unit, a1, a2, form=form
   readf, unit, a3
   line(i).name = a1
   line(i).wavelength = a2
   line(i).brightness = a3
endfor

free_lun, unit

return
error: prnt_error, !err_string
return

end


