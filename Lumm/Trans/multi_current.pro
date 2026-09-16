!p.multi=[0,3,2]
j_up1=fltarr(mmax)
j_dn1=fltarr(mmax)
limit=[.05,max(energy)]
yr = [100,500]
for i=0,mmax-2 do j_up1(i) = trap(flux_up(*,i), energy, limit=limit)*1.6022e-9
for i=0,mmax-2 do j_dn1(i) = trap(flux_down(*,i), energy,limit=limit)*1.6022e-9
plot, j_dn1, altitude, xtit='Current Density (!4l!3Am!u-2!n)',  $
     ytit='Altitude (km)', ysty=16, yr=yr, $
     title='Current Density from Up and Downward Fluxes'
oplot, j_up1, altitude, line=2

j_up2=fltarr(mmax)
j_dn2=fltarr(mmax)
limit=[5.,max(energy)]
for i=0,mmax-2 do j_up2(i) = trap(flux_up(*,i), energy, limit=limit)*1.6022e-9
for i=0,mmax-2 do j_dn2(i) = trap(flux_down(*,i), energy,limit=limit)*1.6022e-9
plot, j_dn2, altitude, xtit='Current Density (!4l!3Am!u-2!n)',  $
     ytit='Altitude (km)', ysty=16, yr=yr, $
     title='Current Density from Up and Downward Fluxes'
oplot, j_up2, altitude, line=2

j_up3=fltarr(mmax)
j_dn3=fltarr(mmax)
limit=[10.,max(energy)]
for i=0,mmax-2 do j_up3(i) = trap(flux_up(*,i), energy, limit=limit)*1.6022e-9
for i=0,mmax-2 do j_dn3(i) = trap(flux_down(*,i), energy,limit=limit)*1.6022e-9
plot, j_dn3, altitude, xtit='Current Density (!4l!3Am!u-2!n)',  $
     ytit='Altitude (km)', ysty=16, yr=yr, $
     title='Current Density from Up and Downward Fluxes'
oplot, j_up3, altitude, line=2

j_up4=fltarr(mmax)
j_dn4=fltarr(mmax)
limit=[30.,max(energy)]
for i=0,mmax-2 do j_up4(i) = trap(flux_up(*,i), energy, limit=limit)*1.6022e-9
for i=0,mmax-2 do j_dn4(i) = trap(flux_down(*,i), energy,limit=limit)*1.6022e-9
plot, j_dn4, altitude, xtit='Current Density (!4l!3Am!u-2!n)',  $
     ytit='Altitude (km)', ysty=16, yr=yr, $
     title='Current Density from Up and Downward Fluxes'
oplot, j_up4, altitude, line=2

j_up5=fltarr(mmax)
j_dn5=fltarr(mmax)
limit=[100.,max(energy)]
for i=0,mmax-2 do j_up5(i) = trap(flux_up(*,i), energy, limit=limit)*1.6022e-9
for i=0,mmax-2 do j_dn5(i) = trap(flux_down(*,i), energy,limit=limit)*1.6022e-9
plot, j_dn5, altitude, xtit='Current Density (!4l!3Am!u-2!n)',  $
     ytit='Altitude (km)', ysty=16, yr=yr, $
     title='Current Density from Up and Downward Fluxes'
oplot, j_up5, altitude, line=2

plot, j_dn1-j_up1, altitude, xtit='Current Density (!4l!3Am!u-2!n)',  $
     ytit='Altitude (km)', ysty=16,  yr=yr, $
     xr=[min([j_dn1-j_up1, j_dn2-j_up2, j_dn3-j_up3, j_dn4-j_up4]), $
         max([j_dn1-j_up1, j_dn2-j_up2, j_dn3-j_up3, j_dn4-j_up4])], $
     title='Net Current Density'
oplot, j_dn2-j_up2, altitude, line=2
oplot, j_dn3-j_up3, altitude, line=3
oplot, j_dn4-j_up4, altitude, line=4
oplot, j_dn5-j_up5, altitude, line=5
oplot, [0,0], [0, max(altitude)], line=1

