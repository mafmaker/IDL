;+
;PROCEDURE:   mvn_swe_addsta
;PURPOSE:
;  Loads STATIC data and creates tplot variables using STATIC code.
;  By default APID's c0, c6, and ca are loaded.  This is sufficient
;  to generate energy and mass spectra, and to calculate densities
;  of O+ and O2+.  Optionally, you can also load additional APID's.
;
;USAGE:
;  mvn_swe_addsta
;
;INPUTS:
;    None:          Data are loaded based on timespan.
;
;KEYWORDS:
;    APID:          Additional APID's to load.  This procedure always 
;                   loads c0, c6, and ca.  For example, set this keyword
;                   to 'd0' (4D distributions) or 'd1' (4D distributions,
;                   burst).
;
;    NO1:           Calculate O+ density from STATIC data using moments.
;                   Method is from McFadden's key parameter code.  This
;                   routine attempts to correct for spacecraft potential 
;                   and ion suppression.  Use with caution!
;
;    NO2:           Calculate O2+ density from STATIC data using moments.
;                   Method is from McFadden's key parameter code.  This
;                   routine attempts to correct for spacecraft potential 
;                   and ion suppression.  Use with caution!
;
;    PANS:          Named variable to hold a space delimited string containing
;                   the tplot variable(s) created.
;
; $LastChangedBy: dmitchell $
; $LastChangedDate: 2016-06-27 10:38:45 -0700 (Mon, 27 Jun 2016) $
; $LastChangedRevision: 21369 $
; $URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/spdsoft/trunk/projects/maven/swea/mvn_swe_addsta.pro $
;
;CREATED BY:    David L. Mitchell  03/18/14
;-
pro mvn_swe_addsta, apid=apid, nO1=nO1, nO2=nO2, pans=pans

  sta_apid = ['c0','c6','ca']
  if (size(apid,/type) eq 7) then sta_apid = [sta_apid, apid]
  if (keyword_set(nO2) or keyword_set(nO1)) then dopot = 1 else dopot = 0

  mvn_sta_l2_load, sta_apid=sta_apid
  if (dopot) then begin
    tplot_options,get=topt
    kk2 = mvn_sta_get_kk2(topt.trange_full[0])
    if (kk2 gt 4.) then begin
      msg = string("Warning: STATIC ion suppression factor = ",kk2,format='(a,f3.1)')
      print,msg
      tplot_options,'title',msg
    endif
    mvn_sta_scpot_load
  endif
  mvn_sta_l2_tplot,/replace
  
  pans = ''
  
  get_data, 'mvn_sta_c0_E', index=i
  if (i gt 0) then begin
    pans = pans + ' ' + 'mvn_sta_c0_E'
    ylim,'mvn_sta_c0_E',4e-1,4e4
    options,'mvn_sta_c0_E','ytitle','sta c6!CEnergy!CeV'
  endif

  get_data, 'mvn_sta_c6_M', index=i
  if (i gt 0) then begin
    pans = pans + ' ' + 'mvn_sta_c6_M'
    options,'mvn_sta_c6_M','ytitle','sta c6!CMass!Camu'
  endif

  if (dopot) then begin
    get_data,'mvn_sta_c6_mode',data=tmp7
    ind_mode = where(tmp7.y ne 1 and tmp7.y ne 2, count)
  endif

; Calculate the O2+ density with ion suppression and s/c potential corrections

  if keyword_set(nO2) then begin

    mass_o2 = [25.,40.]
    m_o2 = 32.
    engy_o2 = [0.,100.]
    min_o2 = 25

    get_4dt,'nb_4d','mvn_sta_get_c6',mass=mass_o2,name='mvn_sta_O2+_raw_density',$
            energy=engy_o2,m_int=m_o2,mincnt=min_o2
    options,'mvn_sta_O2+_raw_density',ytitle='sta c6!C O2+!C!C1/cm!U3',colors=6
    ylim,'mvn_sta_O2+_raw_density',10,100000,1
    get_data,'mvn_sta_O2+_raw_density',data=tmp
    if (count gt 0L) then tmp.y[ind_mode] = !Values.F_NAN
    store_data,'mvn_sta_O2+_raw_density',data=tmp
      
    pans = pans + ' ' + 'mvn_sta_O2+_raw_density'

  endif
  
  if keyword_set(nO1) then begin

	mass_o = [14,20]
	m_o = 16
	engy_o = [0.0,100.]
	min_o = 25

	get_4dt,'nb_4d','mvn_sta_get_c6',mass=mass_o,name='mvn_sta_O+_raw_density',energy=engy_o,m_int=m_o,mincnt=min_o
		options,'mvn_sta_O+_raw_density',ytitle='sta c6!C  O+!C!C1/cm!U3',colors=4
		ylim,'mvn_sta_O+_raw_density',10,100000,1
	get_data,'mvn_sta_O+_raw_density',data=tmp
		tmp.y[ind_mode] = !Values.F_NAN
	store_data,'mvn_sta_O+_raw_density',data=tmp
      
    pans = pans + ' ' + 'mvn_sta_O+_raw_density'

  endif

  pans = strtrim(strcompress(pans),2)

  return
  
end
