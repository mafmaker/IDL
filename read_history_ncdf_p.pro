pro read_history_ncdf_p,filename,history,param_struct,v2=v2

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
;		     of fields in full histories. Uhh this thing cannot EVER
; 	             change. Argh!
;                  
;   Inputs - filename -That's all. It's a netcdf or else....
;   Output - History  - A structure history(nfields).a(nlat,nlon,nalts)
;	                This is Transposed to the 'normal' format.
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
;

debug_flag=0

version2_flag=0
if keyword_set(v2) then version2_flag=1

version='1.1b'
print,'read_history_ncdf_p ' + version
if keyword_set(v2) then Print,'Reading NCAR Netcdf Version 2 file'

if debug_flag eq 1 then print,'mark 1'
;restore,'/usr/local/rsi/idl/usr_lib/immel/history_parameters.idl' ;crucial
restore,'~/idl/history_parameters.idl'


;above will have to be different if files are version 2!!!

if debug_flag eq 1 then print,'mark 2'
print,filename, '...opening'
id=ncdf_open(filename)
if debug_flag eq 1 then print,'mark 3'
threeD_attributes=0
switch_save=0			   ;indicates a 3d array to save
switch_name=0			   ;indicates an array other than 3d!

possible_pos=intarr(45)		   ; 1 element for every possible 3d output
flat_pos=intarr(45)		   ; 1 element for every possible non-3d out
possible_pos(*)=0
flat_pos(*)=0


thing=ncdf_inquire(id)
if debug_flag eq 1 then print,'mark 4'

for i=0,thing.nvars-1 do begin	   ; search for 3D variables in the NCDF file
   if debug_flag eq 1 then print,ncdf_varinq(id,i)
   ncdf_varget,id,i,thevar
   if debug_flag eq 1 then help,thevar
   is_it_3d=size(thevar)
   possible_pos(switch_save)=i
   flat_pos(switch_name)=i
   if is_it_3D(0) eq 3 then threeD_attributes = threeD_attributes + 1
   if is_it_3D(0) eq 3 and switch_save eq 0 then tomake_history=thevar

   if is_it_3D(0) eq 3 then if switch_save eq 0 then switch_save = 1 $
       else switch_save = switch_save + 1   
   if is_it_3D(0) ne 3 then if switch_name eq 0 then switch_name = 1 $
       else switch_name = switch_name + 1   
endfor


if debug_flag eq 1 then print,possible_pos
topper=max(where(possible_pos gt 0))
top_flat=max(where(flat_pos gt 0))
att_names=strarr(20)

Print,'Number of attributes :' + strcompress(thing.ngatts)
Print,'Number of 3D variables :' + strcompress(topper)
Print,'Number of non-3D variables :' + strcompress(top_flat)


param_struct=-1

if version2_flag eq 0 then begin

  for i=0,thing.ngatts-1 do begin	   ; get atts, no follow up for now
    thing2=ncdf_attname(id,i,/global)
    if debug_flag eq 1 then print,thing2
    thing3=ncdf_attinq(id,thing2,/global)
    if debug_flag eq 1 then help,thing3,/struct
    ncdf_attget,id,thing2,thing4,/global
    if debug_flag eq 1 then print,thing4
    if i eq 0 then histvol=thing4
    if i eq 1 then mdmhmm=thing4
    if i eq 2 then yyddd=thing4
    if i eq 3 then hpcpby=thing4
    if i eq 4 then f107d_f107a=thing4
    if i eq 5 then iden=thing4
    if i eq 6 then ionvel=thing4
    if i eq 7 then isdyn=thing4
  endfor

param_struct={histvol:histvol,mdmhmm:mdmhmm,yyddd:yyddd,hpcpby:hpcpby,$
	f107d_f107a:f107d_f107a,iden:iden,ionvel:ionvel,isdyn:isdyn}

endif

;********************** v2 fix ************************
if version2_flag eq 1 then transpose_arr=[1,0,2] else $
transpose_arr=[2,0,1]

model=transpose(tomake_history,transpose_arr)	;create history from model arr

newthing=size(model)

nlat=newthing(1)  &  nlong=newthing(2)  &  nalts=newthing(3)
hist={a:fltarr(nlat,nlong,nalts),title:' '}	;adding a title field to the 
					        ;history!!!! 11-2-99
history=replicate(hist,threeD_attributes)

cut_newtitles=strmid(newtitles,0,6)
for i=0,topper do begin

  need_this = ncdf_varinq(id,possible_pos(i))	;inquire

  placement=where(cut_newtitles eq strmid(need_this.name,0,6))  ;Foster trick
	
  ncdf_varget,id,possible_pos(i),thevar				;get 3d var

  is_it_3d=size(thevar)
  if is_it_3d(0) eq 3 then history(i).a=transpose(thevar,transpose_arr) ;assign
  if is_it_3d(0) eq 3 then if placement(0) ne -1 then $
                   history(i).title=newtitles(placement) else $  ;entitle
 		   history(i).title=need_this.name               ;for O/N2, etc
  print,format='(a8,$)',strcompress(need_this.name)

  ;went to quite a bit of trouble to give history.title need_this.name no 
  ;matter what!!!@!@!#!#

endfor

if version2_flag eq 1 then begin

  string_array=['LON','LAT','LEV','TIME','MTIME','HISTVOLS',$
			'YYDDD','F107D','F107A','HP','CP','BYIMF']
  hpcpby=fltarr(3)
  f107_arr=fltarr(2)
  for i=0,top_flat-1 do begin

    need_this = ncdf_varinq(id,flat_pos(i))	;inquire
    print,need_this.name

    placement=where(string_array eq $
	strupcase(strcompress(need_this.name,/rem)))  ;Foster trick
	
    ncdf_varget,id,flat_pos(i),flatvar			;get non-3d var

    if placement(0) ne -1 then begin
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

    endif	;creating variables for attribute save

  endfor	;loop thorough all attributes

   iden=0 & ionvel=0 & isdyn=0

  param_struct={histvol:histvols,mdmhmm:mtime,yyddd:yyddd,hpcpby:hpcpby,$
	f107d_f107a:f107_arr,iden:iden,ionvel:ionvel,isdyn:isdyn}

endif	;end loading variables which used to be attributes


ncdf_close,id			;DON'T FORGET TO CLOSE IT, OR YOU WILL 
				;GET NASTY CORE DUMPS!

return
end


