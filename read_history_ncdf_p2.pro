pro read_history_ncdf_p2,filename,history,param_struct,v2=v2,v3=v3,$
	time=time,alts=alts

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
;   Requires - history_parameters.idl (just for title strings, NOT good to
;					depend on this)
;
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
;			 time keyword is in, to allow for extraction of particular
;			 timesteps!
;                        Now called read_history_ncdf_p2, to update the code
;
;
;notes	I should think about actually using the string codes that I used 
;       to sort the fields earlier, so that this reader spits out histories
;	which are 100% compatible with my earlier codes.
;

debug_flag=1

version2_flag=0
version3_flag=0
if keyword_set(v2) gt 0 then version2_flag=1
if keyword_set(v3) gt 0 then version3_flag=1

version1_titles=['TN (K)', 'UN', 'VN', 'O2', 'O1', '[N4O]', '[NOz]', '[CO]',$
	 '[CO2]', '[H2O]', '[H2]', '[HOx]', 'O+ (M-3)' ,'[CH4]', '[O21D]',$
 '[NO2]', '[NO]', '[O3]', '[O1]', '[OH]', '[HO2]', 'H', '[N2D]', 'TI (K)',$
 'TE (K)', 'NE (M-3)', 'O2+ (M-3)', 'WN', 'Z','Phi'] 


version3_titles=['TN', 'UN', 'VN', 'O2', 'N4S', 'NOZ', 'CO', 'CO2', $
	'H2O', 'H2', 'HOX', 'OP', 'CH4', 'AR', 'HE', 'O21D', $
	'NO', 'O1', 'OH', 'HO2', 'H', 'N2D', 'TI', 'TE',$
	'NE', 'O2P', 'W', 'Z', 'POTEN']

;saving argon and helium, tossing out NO and O3, this helps with compatibility
;with earlier reader/plotter, which expects a particular place for each 
;variable in the history output


version='1.2a'
print,'read_history_ncdf_p ' + version
if keyword_set(v2) then Print,'Reading NCAR Netcdf Version 2 file'
if keyword_set(v3) then Print,'Reading NCAR Netcdf Version 3 file'

;--- program will transparently read the first time step in a multiple
;--- step history if no special keyword (time=X) is provided

timestep=0
if keyword_set(time) gt 0 then timestep=time

if debug_flag eq 1 then print,'mark 1'
;restore,'/home/immel/idl/history_parameters.idl' ;crucial
;above will have to be different if files are version 2!!!


print,filename, '...opening'
id=ncdf_open(filename)

if debug_flag eq 1 then print,'mark 2'

threeD_attributes=0		   ;will hold number of 3d variables 
				   ;---the variable name is POORLY chosen!
switch_save=0			   ;indicates a 3d array to save
switch_name=0			   ;indicates an array other than 3d!


thing=ncdf_inquire(id)	;thing.ngatts and thing.nvars are important

flat_or_3d=intarr(thing.nvars)	   ; 1 element for every possible non-3d out
flat_or_3d(*)=-1

;stop

if debug_flag eq 1 then print,'mark 3'

for i=0,thing.nvars-1 do begin	   ; search for 3D variables in the NCDF file
   if debug_flag eq 1 then print,i,ncdf_varinq(id,i)

   checkout=ncdf_varinq(id,i)
;   ncdf_varget,id,i,thevar
;   if debug_flag eq 1 then help,thevar
   is_it_3d=fix(checkout.ndims)

;--- here sort out those extra _NM variables

;   if is_it_3D(0) ge 3 and strpos(checkout.name,'_NM') eq -1 $
   if version3_flag eq 1 then tosave=where(version3_titles eq checkout.name)$
	else tosave=1
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

;if version2_flag eq 0 then begin

;--- read attributes

  for i=0,thing.ngatts-1 do begin	   ; get atts, no follow up for now
    thing2=ncdf_attname(id,i,/global)
    if debug_flag eq 1 then print,thing2
    thing3=ncdf_attinq(id,thing2,/global)
    if debug_flag eq 1 then help,thing3,/struct
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
if keyword_set(alts) eq 1 then nalts=nalts/2 + 1
if keyword_set(alts) eq 1 then altindices=indgen(nalts)*2


hist={a:fltarr(nlat,nlong,nalts),title:' '}	;adding a title field to the 
					        ;history!!!! 11-2-99
history=replicate(hist,topper)

;--- read 3d variables

for i=0,topper-1 do begin

  need_this = ncdf_varinq(id,count3d(i))	;inquire
;  title=need_this
;  placement=where(cut_newtitles eq strmid(need_this.name,0,6))  ;Foster trick
  ncdf_varget,id,count3d(i),thevar				;get 3d var
  if debug_flag eq 1 then help,thevar
  if keyword_set(time) eq 1 then $
		thevar=reform(thevar(*,*,altindices,timestep)) else $
		thevar=reform(thevar(*,*,altindices))
  history(i).a=transpose(float(thevar),transpose_arr) ;
  history(i).title=need_this.name               ;for O/N2, etc
  print,format='(a7,$)',need_this.name
endfor

;--- read some flat variables and save them in the params structure as if
;--- they were attributes!

if version2_flag eq 1 or version3_flag eq 1 then begin

  if version2_flag eq 1 then $
  string_array=['LON','LAT','LEV','TIME','MTIME','HISTVOLS',$
			'YYDDD','F107D','F107A','HP','CP','BYIMF']

  if version3_flag eq 1 then $
  string_array=['LON','LAT','LEV','TIME','F107D','F107A',$
						'HP','CP','BYIMF']

  hpcpby=fltarr(3) ;& if version
  f107_arr=fltarr(2) ;& if version3_flag eq 1 then f107_arr=fltarr(2,2)
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
	yyddd=' '
        mtime=' '
	if placement(0) eq 4 then f107_arr(0)=flatvar(timestep)
	if placement(0) eq 5 then f107_arr(1)=flatvar(timestep)
	if placement(0) eq 6 then hpcpby(0)=flatvar(timestep)
	if placement(0) eq 7 then hpcpby(1)=flatvar(timestep)
	if placement(0) eq 8 then hpcpby(2)=flatvar(timestep)
      endelse
    endif	;creating variables for attribute save

  endfor	;loop thorough all attributes

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


