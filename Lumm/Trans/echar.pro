pro echar

;plot the characteristic energy as a function of altitude

@common
@common_w

e_dn = fltarr(mmax)
e_up = fltarr(mmax)

for i=0,mmax-2 do e_dn(i) = $
     trap(flux_down(*,i)*energy, energy)/trap(flux_down(*,i), energy)
for i=0,mmax-2 do e_up(i) = $
     trap(flux_up(*,i)*energy, energy)/trap(flux_up(*,i), energy)

;convert to keV
e_dn = e_dn*1e-3
e_up = e_up*1e-3

plot, e_dn, altitude, xtit='Mean Energy (keV)', ytit='Altitude (km)', $
     title='Mean Energy from Up and Downward Fluxes'
oplot, e_up, altitude, line=2

return
end
