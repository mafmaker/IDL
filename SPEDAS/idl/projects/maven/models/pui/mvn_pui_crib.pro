;20160518 Ali
;crib sheet for MAVEN Pickup Ion Modeler

@idl_startup ;IDL startup by Davin
loadct2,33 ;color table Blue-Red

mvn_pui_model ;models pickup oxygen and hydrogen for SEP and 1D SWIA/STATIC spectra
mvn_pui_model,/do3d ;models 3D spectra for SWIA and STATIC (10x slower)
mvn_pui_model,binsize=32 ;sets the model time bin size to 32 seconds and runs the modeler (default is 30 sec)

common mvn_pui_common ;model results are stored in this common block

mvn_pui_tplot,/store1d,/tplot1d ;stores and plots SEP and 1D SWIA/STATIC spectra
mvn_pui_tplot,/store3d ;stores 3D SWIA/STATIC spectra in tplot variables (a bit slow)
mvn_pui_tplot,/swia3d ;plots SWIA 3D spectra: 16 azimuth x 4 elevation bins
mvn_pui_tplot,/static3d_o ;plots STATIC 3D spectra: 16 azimuth x 4 elevation bins for pickup oxygen
mvn_pui_tplot,/static3d_h ;plots STATIC 3D spectra: 16 azimuth x 4 elevation bins for pickup hydrogen

mvn_pui_results ;manipulating pickup ion model results
