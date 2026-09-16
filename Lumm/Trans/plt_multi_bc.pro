pro plt_multi_bc, z, ion

; plot total ionization rates from many files

flx=fltarr(249,7)

multi_bc, '/usr2/users/lumm/trans/disort/data/strick_crs', '1', z, ion1
flx(*,0)=ion1
multi_bc, '/usr2/users/lumm/trans/disort/data/strick_crs', '2', z, ion1
flx(*,1)=ion1
multi_bc, '/usr2/users/lumm/trans/disort/data/strick_crs', '3', z, ion1
flx(*,2)=ion1
multi_bc, '/usr2/users/lumm/trans/disort/data/strick_crs', '4', z, ion1
flx(*,3)=ion1
multi_bc, '/usr2/users/lumm/trans/disort/data/strick_crs', '5', z, ion1
flx(*,4)=ion1
multi_bc, '/usr2/users/lumm/trans/disort/data/strick_crs', '6', z, ion1
flx(*,5)=ion1
multi_bc, '/usr2/users/lumm/trans/disort/data/strick_crs', '7', z, ion1
flx(*,6)=ion1

plot_oo, z, flx(*,6), xrange=[1e0,1e5], yrange=[1e1,1e7], $
   xtitle='energy (eV)', ytitle='number flux (eV!e-1!ncm!e-2!ns!e-1!n)', $
   title='Characteristic Energy: (300. 600. 1000. 2000. 4000. 10000.) eV'
for i=0,4 do oplot, z, flx(*,i)

stop
return
end