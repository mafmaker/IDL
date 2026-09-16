;20160706 Ali
;routine to model pickup ion fluxes using given constant upstream drivers

pro mvn_pui_flux_drivers

@mvn_pui_commonblock.pro ;common mvn_pui_common

np=1000
mamu=1; %mass of [H=1 C=12 N=14 O=16] (amu)
ntg=0.999 ;for SEP one full gyro-period is necessary

mag=transpose([0,0,3.5e-9]) ;magnetic field (T)
vsw=transpose([-570e3,0,0]) ;solar wind velocity (m/s)
scp=transpose([7000e3,0,0]) ;s/c position (m)

usw=norm(vsw) ;solar wind speed (m/s)
inn=1 ;number of time steps
ifreq_o=3e-7 ;ionization frequency (s-1)
ifreq_h=3e-7 ;ionization frequency (s-1)

mvn_pui_solver,mamu=mamu,np=np,ntg=ntg ;solve pickup ion trajectories

qqo=5e22; %for Mars oxygen exosphere (m-0.9) fit to Rahmati et al., 2014
qqh=4e27; %for Mars hydrogen exosphere (m-0.3) fit to Feldman et al., 2011
phi=1e-4*(ifreq_o#replicate(1.,np))*drxyz*qqo/((rxyz-2400e3)^2.1); %total pickup O+ flux (cm-2 s-1)
phi=1e-4*(ifreq_h#replicate(1.,np))*drxyz*qqh/((rxyz-2700e3)^2.7); %total pickup H+ flux (cm-2 s-1)
dphide=phi/de ;differential flux (cm-2 s-1 eV-1)
dephde=phi*ke/de ;differential energy flux (cm-2 s-1 eV-1)

toteb=100 ;total flux # of energy bins
totdee=.1 ;total flux binning dE/E

keflux=replicate(1e-10,toteb) ;total flux binning
lnkestep=126-floor(alog(ke)/totdee); %log energy step ln(eV) for all flux (edges: 328 keV to 14.9 eV with 10% resolution)
lnkestep[where((lnkestep lt 0) or (lnkestep gt toteb-1),/null)]=toteb-1 ;if bins are outside the range, put them at the last bin (lowest energy bin)
totet=exp(totdee*dindgen(toteb,start=126.5,increment=-1)); total flux energy bin midpoints (312 keV to 15.6 keV)

for it=1,np-1 do begin ;loop over particles
  keflux[lnkestep[it]]+=phi[*,it]/totdee; %total energy flux
endfor

p=plot([0],/xlog,/ylog,xrange=[100,100e3],yrange=[1000,1000e3],xtitle='Pickup Ion Energy (eV)',ytitle='Differential Energy Flux (eV/[cm2 s eV])')
p=plot(ke,dephde,/overplot)
p=plot(totet,keflux,/overplot)

p=plot(v3x/1e3,v3y/1e3,/aspect_ratio,xtitle='Vx (km/s)',ytitle='Vy (km/s)')
p=plot(r3x/1e3,r3y/1e3,/aspect_ratio,xtitle='X (km)',ytitle='Y (km)')
rmars=3400. ;radius of mars (km)
theta=!dtor*(90.-dindgen(180))
x=rmars*cos(theta)
y=rmars*sin(theta)
p=plot(x,y,/o)
end