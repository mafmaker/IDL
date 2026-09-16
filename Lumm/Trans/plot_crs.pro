pro plot_crs, file, _extra=_extra

@common_c

print, 'No cross section files here!'

!p.multi = [0,3,1]
if n_elements(file) le 0 then  $
     file = '/usr/users/lumm/New_trans/cros/effective/pho.crs'

read_crs, file
print, 'Reading cross section file:', file

plot, eng, c_n2, yr=[1e-19,1e-14], /xlog, /ylog, _extra=_extra,  $
     title='N!i2!n Cross Sections', ytit='cross section (cm!e2!n)', $
     xtit='energy (eV)'
oplot, eng, elastic_n2, line=2
for i=0,nstat_n2(0)-1 do oplot, eng, exc_n2(*,i)
for i=0,nstat_n2(1)-1 do oplot, eng, ion_n2(*,i), line=1

plot, eng, c_o2, yr=[1e-19,1e-14], /xlog, /ylog, _extra=_extra,  $
     title='O!i2!n Cross Sections', ytit='cross section (cm!e2!n)', $
     xtit='energy (eV)'
oplot, eng, elastic_o2, line=2
for i=0,nstat_o2(0)-1 do oplot, eng, exc_o2(*,i)
for i=0,nstat_o2(1)-1 do oplot, eng, ion_o2(*,i), line=1

plot, eng, c_o, yr=[1e-19,1e-14], /xlog, /ylog, _extra=_extra,  $
     title='O Cross Sections', ytit='cross section (cm!e2!n)', $
     xtit='energy (eV)'
oplot, eng, elastic_o, line=2
for i=0,nstat_o(0)-1 do oplot, eng, exc_o(*,i)
for i=0,nstat_o(1)-1 do oplot, eng, ion_o(*,i), line=1

return
end
