pro display, path

; Driver to read all plotfiles from the transport code
; This code puts all data in common blocks and makes them
; so available to the subsequent plotting programs.

;common grid, energy, altitude, angle, mu_weight
;common flux, flux_up, flux_down, flux_extra
;common intensity, int_dn, int_up
;common excitation, exr_n2, exr_o2, exr_o, ion_n2, ion_o2, ion_o
;common engdep, exdep_n2, exdep_o2, exdep_o, iondep_n2, iondep_o2, iondep_o
;common density, n2, o2, o, n_e, te
;common header, messag, crs_file, nmax, mmax, kmax, jmax, ex_states, ion_states
;common uv_emission, wavelength, emission, brightness
@common

read_int, path
read_flx, path
read_exr, path
read_dep, path
read_atm, path
read_lbh, path

loadct, 5

; phot
; tflx_cont	; make a plot just for kicks

stop
end
