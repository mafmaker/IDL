pro multi_bc, path, e_path, t_energy, t_flx

; Driver to read all plotfiles from the transport code
; This code puts all data in common blocks and makes them
; so available to the subsequent plotting programs.

common grid, energy, altitude, angle, mu_weight
common flux, flux_up, flux_down, flux_extra
common intensity, int
common excitation, exr_n2, exr_o2, exr_o
common engdep, dep_n2, dep_o2, dep_o
common density, n2, o2, o, n_e, te
common header, messag, crs_file, nmax, mmax, kmax, jmax, states
common uv_emission, wavelength, emission, brightness

;read_int, path
read_flx, path, e_path
;read_exr, path, e_path
;read_dep, path
;read_atm, path
;read_lbh, path

; we need to due this twice to get it right, due to 
; a bug in X or openwindows or whatever
; loadct, 1	
; window, /free
loadct, 5

; phot
; tflx_cont	; make a plot just for kicks

t_energy=energy
t_flx=fltarr(nmax)
t_flx=flux_down(*,0)

return
stop
end
