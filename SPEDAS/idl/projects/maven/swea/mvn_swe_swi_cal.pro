;+
;PROCEDURE:   mvn_swe_swi_cal
;PURPOSE:
;  Compares ion density from SWIA and electron density from SWEA for the purpose 
;  of cross calibration.  Beware of situations where SWEA and/or SWIA are not
;  measuring important parts of the distribution.  Furthermore, SWEA data must be
;  corrected for spacecraft potential (see mvn_swe_sc_pot), and photoelectron 
;  contamination must be removed for any hope of a decent cross calibration.
;
;USAGE:
;  mvn_swe_swi_cal
;
;INPUTS:
;   None.  Uses the current value of TRANGE_FULL to define the time range
;   for analysis.  Calls timespan, if necessary, to set this value.
;
;KEYWORDS:
;   FINE:      Select SWIA 'fine' data for comparison with SWEA.  Default
;              is to use 'coarse' data.
;
;   DDD:       Use SWEA 3D data for computing density.  Allows for bin
;              masking.
;
;   ABINS:     When using 3D spectra, specify which anode bins to 
;              include in the analysis: 0 = no, 1 = yes.
;              Default = replicate(1,16)
;
;   DBINS:     When using 3D spectra, specify which deflection bins to
;              include in the analysis: 0 = no, 1 = yes.
;              Default = replicate(1,6)
;
;   OBINS:     When using 3D spectra, specify which solid angle bins to
;              include in the analysis: 0 = no, 1 = yes.
;              Default = reform(ABINS#DBINS,96).  Takes precedence over
;              ABINS and OBINS.
;
;   MASK_SC:   Mask the spacecraft blockage.  This is in addition to any
;              masking specified by the above three keywords.
;              Default = 1 (yes).
;
;   FUDGE:     Fudge factor for determining spacecraft potential.
;
; $LastChangedBy: dmitchell $
; $LastChangedDate: 2016-09-19 17:02:20 -0700 (Mon, 19 Sep 2016) $
; $LastChangedRevision: 21868 $
; $URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/spdsoft/trunk/projects/maven/swea/mvn_swe_swi_cal.pro $
;
;CREATED BY:    David L. Mitchell
;-
pro mvn_swe_swi_cal, fine=fine, ddd=ddd, pans=pans

  @mvn_swe_com

  tplot_options, get=opt
  if (max(opt.trange_full) eq 0D) then timespan

  if keyword_set(ddd) then dflg = 1 else dflg = 0

; Get electron density from SWEA - create a variable for overplotting
; with SWIA densities.

  if (dflg) then dname = 'mvn_swe_3d_dens' else dname = 'mvn_swe_spec_dens'
  get_data,dname,data=den,index=i
  if (i eq 0) then begin
    print,"You must calculate SWEA densities first."
    return
  endif

  store_data,'mvn_swe_n1d_over',data={x:den.x, y:den.y}
  options,'mvn_swe_n1d_over','color',6
  options,'mvn_swe_n1d_over','psym',-3
  
  pans = ['']

; Load SWIA fine spectra

  if keyword_set(fine) then begin
    mvn_swia_load_l2_data, /loadfine, /tplot
    mvn_swia_part_moments, type=['fs','fa']
    options,'mvn_swifs_density','ynozero',1
    get_data,'mvn_swifs_density',data=den
    dt = den.x - shift(den.x,1)
    indx = where(dt gt 600D, count)
    if (count gt 0L) then den.y[indx] = !values.f_nan
    store_data,'mvn_swifs_density',data=den
    store_data,'ie_density',data=['mvn_swifs_density','mvn_swe_n1d_over']
    options,'ie_density','ynozero',1
    options,'ie_density','ytitle','Ion-Electron!CDensity'

    divname = 'swe_swi_crosscal'
    div_data,'mvn_swifs_density',dname,newname=divname
    options,divname,'ynozero',1
    options,divname,'ytitle','Ratio!CSWE/SWI'
    options,divname,'yticklen',1
    options,divname,'ygridstyle',1
  endif else begin
    mvn_swia_load_l2_data, /loadcoarse, /tplot
    mvn_swia_part_moments, type=['cs','ca']
    options,'mvn_swics_density','ynozero',1
    get_data,'mvn_swics_density',data=den
    dt = den.x - shift(den.x,1)
    indx = where(dt gt 600D, count)
    if (count gt 0L) then den.y[indx] = !values.f_nan
    store_data,'mvn_swics_density',data=den
    store_data,'ie_density',data=['mvn_swics_density','mvn_swe_n1d_over']
    ylim,'ie_density',0,10,0
    options,'ie_density','ynozero',1
    options,'ie_density','ytitle','Ion-Electron!CDensity'

    divname = 'swe_swi_crosscal'
    div_data,'mvn_swics_density',dname,newname=divname
    options,divname,'ynozero',1
    options,divname,'ytitle','Ratio!CSWI/SWE'
    options,divname,'yticklen',1
    options,divname,'ygridstyle',1
  endelse

  pans = [pans,divname,'ie_density']

  return

end
