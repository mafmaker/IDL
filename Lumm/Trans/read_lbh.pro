pro read_lbh, path

; read the PLOTLBH file from trans

;common grid, energy, altitude, angle, mu_weight
;common uv_emission, wavelength, emission, brightness
@common

on_ioerror, error
msg_out, "Reading file PLOTLBH"
openr, unit, path+"/PLOTLBH", /get_lun

wavelength=fltarr(116)
emission=fltarr(116)
brightness=fltarr(116)

work=fltarr(3)

for l=0,115 do begin
  readf, unit, work		; PLOTLBH is an ASCII file!!!
  wavelength(l)=work(0)
  emission(l)=work(1)
  brightness(l)=work(2)
endfor

free_lun, unit

return

error: prnt_error, !err_string
return

end
