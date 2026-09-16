;+
;PROCEDURE:   mvn_swe_lpw_scpot_restore
;PURPOSE:
;  Reads in scpot data precalculated by mvn_swe_lpw_scpot_resample
;  and stored in a tplot save/restore file.  Command line used to create the tplot
;
;USAGE:
;  mvn_swe_lpw_scpot_restore, trange
;
;INPUTS:
;       trange:        Restore data over this time range.  If not specified, then
;                      uses the current tplot range or timerange() will be called
;
;KEYWORDS:
;       ORBIT:         Restore pad data by orbit number.
;
;       LOADONLY:      Download but do not restore any pad data.
;

; $LastChangedBy: haraday $
; $LastChangedDate: 2017-01-13 15:07:18 -0800 (Fri, 13 Jan 2017) $
; $LastChangedRevision: 22599 $
; $URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/spdsoft/trunk/projects/maven/swea/mvn_swe_lpw_scpot_restore.pro $
;
;CREATED BY:    Yuki Harada  03-24-16
;FILE: mvn_swe_lpw_scpot_restore.pro
;-
pro mvn_swe_lpw_scpot_restore, trange, orbit=orbit, loadonly=loadonly, suffix=suffix

; Process keywords
  if ~keyword_set(suffix) then suffix = ''  ;- to be updated -> suffix = '_v??_r??'

  rootdir = 'maven/data/sci/swe/l3/swe_lpw_scpot/YYYY/MM/'
  fname = 'mvn_swe_lpw_scpot_YYYYMMDD'+suffix+'.tplot'

  
  if keyword_set(orbit) then begin
    imin = min(orbit, max=imax)
    trange = mvn_orbit_num(orbnum=[imin-0.5,imax+0.5])
  endif

  tplot_options, get_opt=topt
  tspan_exists = (max(topt.trange_full) gt time_double('2013-11-18'))
  if ((size(trange,/type) eq 0) and tspan_exists) then trange = topt.trange_full

; Get file names associated with trange or from one or more named
; file(s).  If you specify a time range and are working off-site, 
; then the files are downloaded to your local machine, which might
; take a while.

  if (size(trange,/type) eq 0) then begin
     trange = timerange()
  endif
  tmin = min(time_double(trange), max=tmax)
  file = mvn_pfp_file_retrieve(rootdir+fname,trange=[tmin,tmax],/daily_names,/last_version)
  nfiles = n_elements(file)
  
  finfo = file_info(file)
  indx = where(finfo.exists, nfiles, comp=jndx, ncomp=n)
  for j=0,(n-1) do print,"File not found: ",file[jndx[j]]  
  if (nfiles eq 0) then return
  file = file[indx]

  if keyword_set(loadonly) then begin
    print,''
    print,'Files found:'
    for i=0,(nfiles-1) do print,file[i],format='("  ",a)'
    print,''
    return
  endif

; Restore tplot save file(s)

  tplot_restore,filename=file,/append

  if suffix eq '' then begin
  dprint,'***********************************************'
  dprint,'*** mvn_swe_lpw_scpot is still experimental ***'
  dprint,'***********************************************'
  endif

  return

end
