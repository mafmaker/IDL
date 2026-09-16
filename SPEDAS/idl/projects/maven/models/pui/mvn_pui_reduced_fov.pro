;20160708 Ali
;routine to plot dependence of SWIA and STATIC elevation coverage on energy
;to show reduced FOV at high energies
;
pro mvn_pui_reduced_fov

ke=100*dindgen(1001) ;energy (eV) from 100 eV to 100 keV 
ke5=ke/1e3 ;energy (keV)
ke25=ke5
ke5[where(ke5 lt 5.,/null)]=5.
ke25[where(ke25 gt 25.,/null)]=25.
rfov=1.+(ke5-5.)/5.; correction factor for SWIA and STATIC reduced FOV at E>5keV
fov=45/rfov
p=plot(ke,fov,/xlog,/ylog,xtitle='SWIA and STATIC Energy (eV)',ytitle='Elevation Coverage (Degree)')

q=1.602e-19; %electron charge (C)
mp=1.67e-27; %proton mass (kg)
mamu=16; %mass of [H=1 C=12 N=14 O=16] (amu)
m=mamu*mp; %pickup ion mass (kg)

;uncomment the following two lines to get constant energy contours
;ke25=30 ;energy in keV
;fov=dindgen(91)

vx=sqrt(2*ke25*1e3*q/m)*cos(!dtor*fov) ;m/s
vy=sqrt(2*ke25*1e3*q/m)*sin(!dtor*fov) ;m/s

p=plot([-vx,reverse(-vx)]/1e3,[vy,reverse(-vy)]/1e3,/aspect_ratio,xtitle='Vx (km/s)',ytitle='Vy (km/s)')


end