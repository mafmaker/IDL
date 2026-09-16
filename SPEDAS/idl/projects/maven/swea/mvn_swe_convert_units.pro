;+
;PROCEDURE: 
;	mvn_swe_convert_units
;PURPOSE:
;	Convert the units for a SWEA 3d data structure.
;AUTHOR: 
;	David L. Mitchell
;CALLING SEQUENCE: 
;	mvn_swe_convert_units, data, units, SCALE=SCALE
;INPUTS: 
;	Data: A 3D, PAD, or SPEC data structure for SWEA
;	Units: Units to convert the structure to.  Recognized units are:
;            COUNTS : raw counts, uncorrected for deadtime
;            RATE   : raw count rate, uncorrected for deadtime
;            CRATE  : count rate, corrected for deadtime
;            FLUX   : differential number flux (1/cm^2-s-ster-eV)
;            EFLUX  : differential energy flux (eV/cm^2-s-ster-eV)
;            E2FLUX : energy flux per energy bin (eV/cm^2-s-ster-bin)
;            DF     : distribution function (1/(cm^3-(km/s)^3))
;KEYWORDS:
;	SCALE: Returns an array of conversion factors used
;OUTPUTS:
;	Returns the same data structure in the new units
;
; $LastChangedBy: dmitchell $
; $LastChangedDate: 2016-10-18 13:59:04 -0700 (Tue, 18 Oct 2016) $
; $LastChangedRevision: 22128 $
; $URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/spdsoft/trunk/projects/maven/swea/mvn_swe_convert_units.pro $
;
;-

pro mvn_swe_convert_units, data, units, scale=scale

  compile_opt idl2

  if (n_params() eq 0) then return

  if (strupcase(units) eq strupcase(data[0].units_name)) then return

  c = 2.99792458D5                ; velocity of light [km/s]
  mass = (5.10998910D5)/(c*c)     ; electron rest mass [eV/(km/s)^2]
  m_conv = 2D5/(mass*mass)        ; mass conversion factor (flux to distribution function)

; Get information from input 3D structure

  energy  = data.energy           ; [eV]
  denergy = data.denergy          ; [eV]
  gf      = data.gf*data.eff      ; energy/angle dependent GF with MCP efficiency [cm2-ster-eV/eV]
  dt      = data[0].integ_t       ; integration time [sec] per energy/angle bin (unsummed)
  dt_arr  = data.dt_arr           ; #energies * #anodes per bin for rate and dead time corrections
  dtc     = data.dtc              ; dead time correction: 1. - (raw count rate)*dead

; Dead time calculation is done in mvn_swe_package, where the calibrated data structure is first created
; from the raw counts.  This makes it possible to convert back and forth between units with and without 
; the dead time correction applied.

  case strupcase(data[0].units_name) of 
    'COUNTS' : scale = 1D				                          ; Raw counts			
    'RATE'   : scale = 1D*dt*dt_arr				                  ; Raw counts/sec
    'CRATE'  : scale = 1D*dtc*dt*dt_arr				              ; Corrected counts/sec
    'E2FLUX' : scale = 1D*dtc*dt*dt_arr*gf / denergy              ; eV/cm^2-sec-sr
    'EFLUX'  : scale = 1D*dtc*dt*dt_arr*gf 		                  ; eV/cm^2-sec-sr-eV
    'FLUX'   : scale = 1D*dtc*dt*dt_arr*gf * energy		          ; 1/cm^2-sec-sr-eV
    'DF'     : scale = 1D*dtc*dt*dt_arr*gf * energy^2. * m_conv   ; 1/(cm^3-(km/s)^3)
    else     : begin
                 print, 'Unknown starting units: ',data[0].units_name
	             return
               end
  endcase

  case strupcase(units) of
    'COUNTS' : scale = scale * 1D
    'RATE'   : scale = scale * 1D/(dt * dt_arr)
    'CRATE'  : scale = scale * 1D/(dtc * dt * dt_arr)
    'E2FLUX' : scale = scale * 1D/(dtc * dt * dt_arr * gf / denergy)
    'EFLUX'  : scale = scale * 1D/(dtc * dt * dt_arr * gf)
    'FLUX'   : scale = scale * 1D/(dtc * dt * dt_arr * gf * energy)
    'DF'     : scale = scale * 1D/(dtc * dt * dt_arr * gf * energy^2 * m_conv)
    else     : begin
                 print, 'Unknown units: ',units
                 return
               end
  endcase

; Scale to new units

  data.units_name = units
  data.data = data.data * scale
  data.var = data.var * (scale*scale)
  data.bkg = data.bkg * scale

  return

end
