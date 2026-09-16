pro multi_sza_a1p

path = '../output/'
file = 'pho_sza00f150'
get_a1p, path+file, alt, a1p_00
file = 'pho_sza60f150'
get_a1p, path+file, alt, a1p_60
file = 'pho_sza80f150'
get_a1p, path+file, alt, a1p_80
file = 'pho_sza90f150'
get_a1p, path+file, alt, a1p_90

; make ascii file for Glynn
;openw, unit, /get, 'a1p_dat.asc'
;printf, unit, 'altitude', 'sza=0', 'sza=60', 'sza=80',  $
;     'sza=90', form='(5a10)'
;for i=0,n_elements(alt)-1 do printf, unit, alt(i), a1p_00(i),  $
;     a1p_60(i), a1p_80(i), a1p_90(i), form='(5e10.3)'
;free_lun, unit

plot, a1p_00, alt, /xlog, yr=[100,300], xr=[1,1000],  $
     title='N!i2!n(a!e1!n!4p!3) Excitation Rate (F!i10.7!n=150, 75)',  $
     ytit='Altitude (km)', $
     xtit='Excitation rate (cm!e-3!ns!e-1!n)'
reverse_ct
zmax = max(a1p_00, nmax)
x_off = 0.6
xyouts, a1p_00(nmax)*x_off, alt(nmax), 'sza=0'
oplot, a1p_60, alt
zmax = max(a1p_60, nmax)
xyouts, a1p_60(nmax)*x_off, alt(nmax), 'sza=60'
oplot, a1p_80, alt
zmax = max(a1p_80, nmax)
xyouts, a1p_80(nmax)*x_off, alt(nmax), 'sza=80'
oplot, a1p_90, alt
zmax = max(a1p_90, nmax)
xyouts, a1p_90(nmax)*x_off, alt(nmax), 'sza=90'

file = 'pho_sza00f75'
get_a1p, path+file, alt, a1p_00
file = 'pho_sza60f75'
get_a1p, path+file, alt, a1p_60
file = 'pho_sza80f75'
get_a1p, path+file, alt, a1p_80
file = 'pho_sza90f75'
get_a1p, path+file, alt, a1p_90
oplot, a1p_00, alt, line=2
oplot, a1p_60, alt, line=2
oplot, a1p_80, alt, line=2
oplot, a1p_90, alt, line=2

ss_a1p = [690., 220., 57., 9.2]
ss_alt = [140., 157., 186., 219.]
oplot, ss_a1p, ss_alt, psym=2

return
stop
end
