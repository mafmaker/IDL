pro plt_multi, z, ion

; plot total ionization rates from many files

ion=fltarr(101,7)

multi, '/usr2/users/lumm/trans/disort/data/strick_crs', '1', z, ion1
ion(*,0)=ion1
multi, '/usr2/users/lumm/trans/disort/data/strick_crs', '2', z, ion1
ion(*,1)=ion1
multi, '/usr2/users/lumm/trans/disort/data/strick_crs', '3', z, ion1
ion(*,2)=ion1
multi, '/usr2/users/lumm/trans/disort/data/strick_crs', '4', z, ion1
ion(*,3)=ion1
multi, '/usr2/users/lumm/trans/disort/data/strick_crs', '5', z, ion1
ion(*,4)=ion1
multi, '/usr2/users/lumm/trans/disort/data/strick_crs', '6', z, ion1
ion(*,5)=ion1
multi, '/usr2/users/lumm/trans/disort/data/strick_crs', '7', z, ion1
ion(*,6)=ion1

z=z*1e-5
plot_oi, ion(*,6), z, xrange=[100,10000], yrange=[80,300], $
   xtitle='ionization rate (cm!e-3!ns!e-1!n)', ytitle='altitude (km)', $
   title='Characteristic Energy: (300. 600. 1000. 2000. 4000. 10000.) eV'
for i=0,4 do oplot, ion(*,i), z

return
end