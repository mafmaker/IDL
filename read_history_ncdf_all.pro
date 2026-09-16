pro read_history_ncdf_all,filename,history,param_struct,$
	alts=alts,hour=hour

;   revised by CLH to autodetect version and ask user to select timestep
;   03/29/02
;   revised by CLH to include postprocess of v3 files (convert to mks, etc.)
;
;   Thomas Immel 10-29-99
;
;   Program to rip all info from NCDF files created by history_2_netcdf.
;
;   Issues - NCDF fields are transposed
;          - Number of NCDF fields is completely variable
;          - Units on NCDF fields vary as a function of which 
;           variables are selected (e.g calc_rho.pro converts mass den to m^-3)
;
;   Helpful points - history_parameters.idl indicates original (0:29) position
;                 
;   Inputs - filename -That's all. It's a netcdf or else....
;   Output - History  - A structure history(nfields).a(nlat,nlon,nalts)
;	                This is Transposed to the 'normal' format/order.
;			But who defines normal?
;
;   Keywords - alts : for v3 keywords, grabs every other altitude to duplicate
;                   : result of reading a v2 netcdf
;              hour : override interactive entry of hour by setting hour=1-24
;
;
;   Requires - history_parameters.idl (just for title strings, NOT good to
;					depend on this)
;   Version history 
;     1.0    11-99    -  release
;     1.01   12-1-99  -  return yyddd hhhh, etc in param_struct (a structure!)
;     1.1b   02-10-2000-  new netcdf attributes and array orders from NCAR 
;			   must be handled. Do it with a V2 flag. Or 
;     			   how about an autodetect!??! Later...
;
;     1.1b2  04-04-2000  what about attributes!? This is needed if you are
;                        going to write ANOTHER netcdf with the data from
;			 the current one! Ahh it's all in param_struct!
;     1.2a   08-13-2001  read latest NCAR ncdfs provided recently by GC.
;			 these have many more altitude steps it seems!
;     			 for the moment, these are Version 3
;			 add time keyword, to allow for extraction of particular
;			 timesteps!
;                        Now called read_history_ncdf_p2, to update the code
;
;
;notes	I should think about actually using the string codes that I used 
;       to sort the fields earlier, so that this reader spits out histories
;	which are 100% compatible with my earlier codes.
;
;  version 1 ncdf: output from history_2_netcdf (old SUN binary route)
;  version 2 ncdf: output from netcdf_2_netcdf (expected by tgcmplot)
;                  this is the same as version 1, but lat and alt are
;                  tranposed.  (lon,lat,alt)
;  version 3 ncdf: output from new TIMEGCM/ASPEN programs (as of ~2001)
;                  many new variables and attributes, some of which
;                  are discarded here, since they won't fit into V2 format.

debug_flag=0

version2_flag=0
version3_flag=0

version1_titles=['TN (K)', 'UN', 'VN', 'O2', 'O1', '[N4O]', '[NOz]', '[CO]',$
	 '[CO2]', '[H2O]', '[H2]', '[HOx]', 'O+ (M-3)' ,'[CH4]', '[O21D]',$
 '[NO2]', '[NO]', '[O3]', '[O1]', '[OH]', '[HO2]', 'H', '[N2D]', 'TI (K)',$
 'TE (K)', 'NE (M-3)', 'O2+ (M-3)', 'WN', 'Z','Phi'] 


;version3_titles=['TN', 'UN', 'VN', 'O2', 'N4S', 'NOZ', 'CO', 'CO2', $
;	'H2O', 'H2', 'HOX', 'OP', 'CH4', 'AR', 'HE', 'O21D', $
;	'NO', 'O1', 'OH', 'HO2', 'H', 'N2D', 'TI', 'TE',$
;	'NE', 'O2P', 'W', 'Z', 'POTEN']
version3_titles=['TN', 'UN', 'VN', 'O2', 'OX', 'N4S', 'NOZ', 'CO', 'CO2', $
	'H2O', 'H2', 'HOX', 'OP', 'CH4', 'O21D', $
	'NO2', 'NO', 'O3', 'O1', 'OH', 'HO2', 'H', 'N2D', 'TI', 'TE',$
	'NE', 'O2P', 'W', 'Z', 'POTEN', 'QJ', 'QT','QEI','QIC','QNC',$
	'QSRB','QSRC','QO3','QA','QEUV','QO2','QDH','QGW','QM']

;saving argon and helium, tossing out NO and O3, this helps with compatibility
;with earlier reader/plotter, which expects a particular place for each 
;variable in the history output - TJI
; huh? version 1 has NO and O3.  It is important to keep the order
; the same as output by TIMEGCM, however.  Also note that TIMEGCM PS2
; variable is now OX = O1 + O3. - CLH
; 10/24/02: with new scan_index method order is no longer important.
; However, only fields listed in version3_titles will be read.
; Adding Q* for secondary history use.


version='1.2a'
print,'read_history_ncdf_all ' + version

timestep=0

if debug_flag eq 1 then print,'mark 1'

print,filename, '...opening'
id=ncdf_open(filename)

if debug_flag eq 1 then print,'mark 2'

;
; autodetect version and set appropriate flags
;
itmp = ncdf_dimid(id,'time')
if itmp gt -1 then begin ; is version 3
   version3_flag = 1
   ncdf_diminq, id, itmp, stmp, ntimes
   print, 'There are ', strcompress(string(ntimes)), ' times in the file'
   print, 'Model times (Day, Hour, Minute)'
   ncdf_varget, id, 'mtime', mtime
   print, mtime
   if keyword_set(hour) gt 0 then begin
     timestep=hour-1
     print, 'Selecting hour ' + strcompress(hour,/rem)
   endif else begin 
     print, 'Choose 0-',strcompress(string(ntimes-1))
     read, timestep
   endelse
endif else begin
   ncdf_diminq, id, 1, stmp, size1
   ncdf_diminq, id, 2, stmp, size2
   if size1 lt size2 then version2_flag = 1   ; should be more alts than lats
endelse

;
; scan for 3D fields
;

switch_save=0			   ;indicates a 3d array to save

thing=ncdf_inquire(id)	;thing.ngatts and thing.nvars are important

flat_or_3d=intarr(thing.nvars)	   ; 1 element for every possible non-3d out
flat_or_3d(*)=-1

if debug_flag eq 1 then print,'mark 3'

for i=0,thing.nvars-1 do begin	   ; search for 3D variables in the NCDF file
   if debug_flag eq 1 then print,i,ncdf_varinq(id,i)

   checkout=ncdf_varinq(id,i)
   is_it_3d=fix(checkout.ndims)

;--- here throw away "extra" variables including *_NM

   if version3_flag eq 1 then begin
        tosave=where(version3_titles eq checkout.name)
      endif else tosave=1
   if is_it_3D(0) ge 3 and tosave(0) gt -1 $
	then flat_or_3d(i) = 1
   if is_it_3D(0) le 1 then flat_or_3d(i)=0
   if is_it_3D(0) ge 3 and switch_save eq 0 then begin
	ncdf_varget,id,i,tomake_history
        switch_save = 999
   endif
endfor

count3d=where(flat_or_3d gt 0,topper)
countflat=where(flat_or_3d eq 0,top_flat)


Print,'Number of attributes :' + strcompress(thing.ngatts)
Print,'Number of 3D variables :' + strcompress(topper)
Print,'Number of non-3D variables :' + strcompress(top_flat)


param_struct=-1

;--- read attributes

  for i=0,thing.ngatts-1 do begin	   ; get atts, no follow up for now
    thing2=ncdf_attname(id,i,/global)
    if debug_flag eq 1 then print,thing2
    thing3=ncdf_attinq(id,thing2,/global)
;    if debug_flag eq 1 then help,thing3,/struct
    ncdf_attget,id,thing2,thing4,/global
    if debug_flag eq 1 then print,thing4
    if version3_flag ne 1 then begin

      if i eq 0 then histvol=thing4
      if i eq 1 then mdmhmm=thing4
      if i eq 2 then yyddd=thing4
      if i eq 3 then hpcpby=thing4
      if i eq 4 then f107d_f107a=thing4
      if i eq 5 then iden=thing4
      if i eq 6 then ionvel=thing4
      if i eq 7 then isdyn=thing4
    endif else begin
      if i eq 0 then rundate=string(thing4)
      if i eq 1 then logname=string(thing4)
      if i eq 2 then host=string(thing4)
      if i eq 3 then system=string(thing4)
      if i eq 4 then model_name=string(thing4)
      if i eq 5 then model_version=string(thing4)
      if i eq 6 then mss_path=string(thing4)
      if i eq 7 then history_type=string(thing4)
      if i eq 8 then mss_source=string(thing4)
      if i eq 9 then start_year=(thing4)
      if i eq 10 then start_day=(thing4)
      if i eq 11 then start_mtime=(thing4)
      if i eq 12 then missing_value=(thing4)
      if i eq 13 then lev_to_mb=string(thing4)
      if i eq 14 then nhist=string(thing4)
      if i eq 15 then delhist_mins=string(thing4)
      if i eq 16 then contents=string(thing4)
      if i eq 17 then contents_desc=string(thing4)

    endelse

  endfor
if version3_flag ne 1 then $
param_struct={histvol:histvol,mdmhmm:mdmhmm,yyddd:yyddd,hpcpby:hpcpby,$
	f107d_f107a:f107d_f107a,iden:iden,ionvel:ionvel,isdyn:isdyn} 

; else do the big save later!
; will v2 crash out on this? I don't think so. It will be assigned the 
; wrong variables, but I don't have an example of a v2 ncdf right now...

;********************** v2 fix ************************
if version2_flag eq 1 or version3_flag eq 1 then transpose_arr=[1,0,2] else $
transpose_arr=[2,0,1]



model=transpose(tomake_history,transpose_arr)	;create history from model arr
newthing=size(model)

nlat=newthing(1)  &  nlong=newthing(2)  &  nalts=newthing(3)
altindices=indgen(nalts)
new_alts = indgen(nalts)
; force to 45 alts from 89 (double-Z version) or 29 (tgcm-15r)
if keyword_set(alts) then begin
   ; chop 89 alts down to 45 alts if requested
   if nalts eq 89 then begin
      nalts=nalts/2 + 1
      altindices=indgen(nalts)*2
      new_alts = indgen(nalts)
   endif
   ; 29 alts is -7 to +7; kill top 4 levels, pad up to 45, zero in lower levels
   if nalts eq 29 then begin
      new_alts = indgen(nalts) + 20 ; 20,21,...,47,48 to populate upper indices
      new_alts(25:28) = 0           ; map Z=+5.5 to +7 to bottom level
      nalts = 45
   endif
endif


hist={a:fltarr(nlat,nlong,nalts),title:' '}
; for v3, need to add a wrap-around longitude column
if version3_flag eq 1 then hist={a:fltarr(nlat,nlong+1,nalts),title:' '}
history=replicate(hist,topper)

;--- read 3d variables

for i=0,topper-1 do begin

  need_this = ncdf_varinq(id,count3d(i))	;inquire for title
  ncdf_varget,id,count3d(i),thevar				;get 3d var
;  if debug_flag eq 1 then help,thevar
  if version3_flag eq 1 then begin
	thevar=reform(thevar(*,*,altindices,timestep))
        ; need to add duplicate longitude for wrap-around
	newvar = fltarr(nlong+1, nlat, nalts)
        newvar(0:nlong-1, *, new_alts) = thevar(*,*,*)
        newvar(nlong,*,new_alts) = thevar(0,*,*)
        thevar = newvar
  endif else thevar=reform(thevar(*,altindices,*))
        ; what about version 2? -CLH 03/2002
  history(i).a=transpose(float(thevar),transpose_arr) ;
  history(i).title=need_this.name               ;for O/N2, etc
  print,format='(a7,$)',need_this.name
endfor

; post-process for version 3 files
; presumably, this work has already been done on v1 or v2 files
if version3_flag eq 1 then post_process_ncdfv3, history


;--- read some flat variables and save them in the params structure as if
;--- they were attributes!

if version2_flag eq 1 or version3_flag eq 1 then begin

  if version2_flag eq 1 then $
  string_array=['LON','LAT','LEV','TIME','MTIME','HISTVOLS',$
			'YYDDD','F107D','F107A','HP','CP','BYIMF']

  if version3_flag eq 1 then $
  string_array=['LON','LAT','LEV','TIME','F107D','F107A',$
			'HPOWER','CTPOTEN','BYIMF']

  hpcpby=fltarr(3) 
  f107_arr=fltarr(2)
  for i=0,top_flat-1 do begin

    need_this = ncdf_varinq(id,countflat(i))	;inquire
    print,format='(a9,$)',need_this.name

    placement=where(string_array eq $
	strupcase(strcompress(need_this.name,/rem)))  ;Foster trick
	
    ncdf_varget,id,countflat(i),flatvar			;get non-3d var

    if placement(0) ne -1 then begin

      if version2_flag gt 0 then begin
	if placement(0) eq 0 then lon=flatvar
	if placement(0) eq 1 then lat=flatvar
	if placement(0) eq 2 then lev=flatvar
	if placement(0) eq 3 then time=flatvar
	if placement(0) eq 4 then mtime=flatvar
	if placement(0) eq 5 then histvols=flatvar
	if placement(0) eq 6 then yyddd=flatvar
	if placement(0) eq 7 then f107_arr(0)=flatvar
	if placement(0) eq 8 then f107_arr(1)=flatvar
	if placement(0) eq 9 then hpcpby(0)=flatvar
	if placement(0) eq 10 then hpcpby(1)=flatvar
	if placement(0) eq 11 then hpcpby(2)=flatvar
      endif else begin
	if placement(0) eq 0 then lon=flatvar
	if placement(0) eq 1 then lat=flatvar
	if placement(0) eq 2 then lev=flatvar
	if placement(0) eq 3 then time=flatvar
	histvols=' '
	if placement(0) eq 4 then f107_arr(0)=flatvar(timestep)
	if placement(0) eq 5 then f107_arr(1)=flatvar(timestep)
	if placement(0) eq 6 then hpcpby(0)=flatvar(timestep)
	if placement(0) eq 7 then hpcpby(1)=flatvar(timestep)
	if placement(0) eq 8 then hpcpby(2)=flatvar(timestep)
      endelse
    endif	;creating variables for attribute save

  endfor	;loop thorough all attributes
  if version3_flag eq 1 then begin ; get yyddd, model time info
     ncdf_varget, id, 'year' , yyyy
     ncdf_varget, id, 'day' , ddd
     yyyy = yyyy(timestep)
     ddd = ddd(timestep)
     if yyyy gt 1999 then yyddd = (yyyy-2000)*1000 + ddd $
     else yyddd = (yyyy-1900)*1000 + ddd
     print, ' '
     print, 'YYDDD', yyddd
 
     mtime = mtime(*,timestep)
     print, 'MTIME', mtime
  endif

   iden=0 & ionvel=0 & isdyn=0
if version3_flag ne 1 then $
  param_struct={histvol:histvols,mdmhmm:mtime,yyddd:yyddd,hpcpby:hpcpby,$
	f107d_f107a:f107_arr,iden:iden,ionvel:ionvel,isdyn:isdyn} $
else $
param_struct = {lon:lon,lat:lat,lev:lev,$
	histvol:histvols,mdmhmm:mtime,yyddd:yyddd,hpcpby:hpcpby,$
	f107d_f107a:f107_arr,iden:iden,ionvel:ionvel,isdyn:isdyn,$
	rundate:rundate,logname:logname,host:host,model_name:model_name,$
	model_version:model_version,mss_path:mss_path,history_type:history_type,$
        mss_source:mss_source,start_year:start_year,start_day:start_day,$
	start_mtime:start_mtime,missing_value:missing_value,$
	lev_to_mb:lev_to_mb,nhist:nhist,delhist_mins:delhist_mins,$
	contents:contents,contents_desc:contents_desc}




endif	;end loading variables which used to be attributes


ncdf_close,id			;DON'T FORGET TO CLOSE IT, OR YOU WILL 
				;GET NASTY CORE DUMPS!

return
end


