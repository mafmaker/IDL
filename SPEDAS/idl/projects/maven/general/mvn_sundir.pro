;+
;PROCEDURE:   mvn_sundir
;PURPOSE:
;  Determines the direction of the Sun in spacecraft coordinates.
;  Optionally, calculates the direction of the Sun in additional 
;  frames specified by keyword.  The results are stored in TPLOT 
;  variables.
;
;  Spacecraft frame:
;    X --> APP boom axis
;    Y --> +Y solar array axis
;    Z --> HGA axis
;
;USAGE:
;  mvn_sundir, trange
;
;INPUTS:
;       trange:   Optional.  Time range for calculating the Sun direction.
;                 If not specified, then use current range set by timespan.
;
;                 Note: the user is responsible for making sure SPICE
;                 kernels are loaded for the desired time range.
;                 (See mvn_swe_spice_init for an example.)
;
;KEYWORDS:
;       DT:       Time resolution (sec).  Default = 1.
;
;       PANS:     Named variable to hold the tplot variables created.
;
;       FRAME:    Also calculate the Sun direction in one or more 
;                 frames specified by this keyword.  Set this keyword to
;                 a single string or an array of strings.  Some possible
;                 frames are: 'MAVEN_SWEA', 'MAVEN_SWIA', 'MAVEN_STATIC', 
;                 'MAVEN_APP', etc.
;
; $LastChangedBy: dmitchell $
; $LastChangedDate: 2016-10-19 17:53:55 -0700 (Wed, 19 Oct 2016) $
; $LastChangedRevision: 22156 $
; $URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/spdsoft/trunk/projects/maven/general/mvn_sundir.pro $
;
;CREATED BY:    David L. Mitchell  09/18/13
;-
pro mvn_sundir, trange, dt=dt, pans=pans, frame=frame

  if (size(trange,/type) eq 0) then begin
    tplot_options, get_opt=topt
    if (max(topt.trange_full) gt time_double('2013-11-18')) then trange = topt.trange_full
    if (size(trange,/type) eq 0) then begin
      print,"You must specify a time range."
      return
    endif
  endif
  tmin = min(time_double(trange), max=tmax)

  mk = spice_test('*', verbose=-1)
  indx = where(mk ne '', count)
  if (count eq 0) then mvn_swe_spice_init, trange=[tmin,tmax]

  if not keyword_set(dt) then dt = 1D else dt = double(dt[0])
  
  if (size(frame,/type) ne 7) then frame = ''

; First calculate the Sun direction in the spacecraft frame

  npts = floor((tmax - tmin)/dt) + 1L
  x = tmin + dt*dindgen(npts)
  y = replicate(1.,npts) # [1.,0.,0.]  ; MAVEN_SSO direction of Sun
  store_data,'Sun',data={x:x, y:y, v:indgen(3)}
  options,'Sun','ytitle','Sun (PL)'
  options,'Sun','labels',['X','Y','Z']
  options,'Sun','labflag',1
  options,'Sun',spice_frame='MAVEN_SSO',spice_master_frame='MAVEN_SPACECRAFT'
  spice_vector_rotate_tplot,'Sun','MAVEN_SPACECRAFT',trange=[tmin,tmax],check='MAVEN_SPACECRAFT'
  pans = 'Sun_MAVEN_SPACECRAFT'

; Next calculate the Sun direction in frame(s) specified by keyword FRAME
  
  indx = where(frame ne '', nframes)
  for i=0,(nframes-1) do begin
    to_frame = strupcase(frame[indx[i]])
    spice_vector_rotate_tplot,'Sun',to_frame,trange=[tmin,tmax],check='MAVEN_SPACECRAFT'
    pans = [pans, 'Sun_' + to_frame]
  endfor
  
  return

end
