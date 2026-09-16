;20160705 Ali
;routine to plot exospheric density profiles used in mvn_pui_model
;
pro mvn_pui_plot_exoden,overplot=overplot

rmars=3400 ;mars radius (km)

alt=1e3*dindgen(300)/3 ;altitude (km)
rxyz=1e3*(alt+rmars) ;radial distance (m)

qqo=5e22; %for Mars oxygen exosphere (m-0.9) fit to Rahmati et al., 2014
nno=1e-6*qqo/((rxyz-2400e3)^2.1); %density (cm-3)

qqh=4e27; %for Mars hydrogen exosphere (m-0.3) fit to Feldman et al., 2011
nnh=1e-6*qqh/((rxyz-2700e3)^2.7); %density (cm-3)
p=plot(nno,alt,/xlog,/ylog,title='',color='red',xtitle='Mars Exospheric Neutral Density (cm-3)',ytitle='Altitude (km)',overplot=overplot)
p=plot(nnh,alt,color='blue',xrange=[1,1e5],yrange=[1e3,1e5],overplot=overplot)

end