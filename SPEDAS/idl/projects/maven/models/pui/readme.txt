mvn_pui_model: models oxygen and hydrogen pickup ions measured by MAVEN SEP, SWIA, STATIC
please send bugs/comments to rahmati@ssl.berkeley.edu

160712: modified/added a few routines for better visualization of model results.

160608: speed/memory improvements. fixed a data loading bug. added a couple of routines.

160518: 3D spectra for STATIC are now modeled. Oxygen and hydrogen pickup ions are stored in separare variables for STATIC.

160504: 3D spectra for SWIA are now modeled. SEP's energy and angular response is improved.

160404-Ali: the first working version of the code was checked in. Run mvn_pui_model and it should simulate pickup O+ and H+ fluxes for SEP, SWIA, and STATIC and store them in tplot variables. Note that the results are only valid when MAVEN is outside the bow shock in the upstream undisturbed solar wind.