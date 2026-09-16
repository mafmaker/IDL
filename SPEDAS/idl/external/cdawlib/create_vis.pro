;$Author: kenb $
;$Date: 2006-10-11 13:32:51 -0700 (Wed, 11 Oct 2006) $
;$Header: /home/cdaweb/dev/control/RCS/create_vis.pro,v 1.14 2004/11/17 20:58:50 kovalick Exp kovalick $
;$Locker: kovalick $
;$Revision: 8 $
;Function: create_vis
;Purpose: to compute the virtual variables for the Polar VIS
;instrument.
;Author: Tami Kovalick, Raytheon STX, April 23, 1998
;Modification:
;
;
function create_vis, astruct, orig_names

;this code assumes that an image, geolat and geolong variables are
;declared as virtual.  And that the "components" of the image virtual
;variable are the following list:
;Names =  ['Look_Dir_Vctr', 'Int_Time_Half', 'Limit_Lo', 'Limit_Hi', 'AltF',
; 'Post_Gap','V_Zenith', 'D_Qual', 'Sun_Vctr','Time_PB5', 'Rotatn_Matrix', 
; 'Filter', 'SC_Pos_GCI', 'SC_Vel_GCI', 'SC_SpinV_GCI', 'Sensor']


;astruct will contain all of the variables and metadata necessary
;to create the lat and long data arrays.  The Polar VIS original
;geographic coordinates (in the CDFs) only contain 1 location point
;for every 15, so in order to position these images on an earth
;map we must compute the lat and long for each image point.

;unfortunately the polar vis s/w relies on common blocks to pass
;its data variables, so for now I will just include them.  When/if
;this s/w works I may get bold and eliminate these.
COMMON XV_RECORD_DATA, Image, Record, XPos, YPos, ROI, LastImage, Curr_Limit
COMMON XV_DERIVED_DATA, LookV_GCI, ALTLS, Alts, Phis, SZAs, Locs, Glats, Glons
COMMON XV_FLAGS, Flags
COMMON XV_FILE_DATA, Path, Filename, Fid, MaxRecs, ImageNum, LookVector, Header, UnDistort
COMMON XV_DEBUG, dalts

;The code we are using to generate the full lat and long values was
;picked up from the polar vis web site mentioned in their polar vis
;CDFs. http://eiger.physics.uiowa.edu/~vis/software/.  The code is
;called compute_crds (below).

;First thing, get the virtual image variable metatdata and data.
atags = tag_names(astruct) ;get the variable names
vv_tagnames=strarr(1)
vv_tagindx = vv_names(astruct,names=vv_tagnames) ;find the virtual vars
if ((vv_tagindx(0) lt 0) or (n_elements(vv_tagnames) le 0)) then begin
  print, 'In CREATE_VIS, no virtual variables found'
  return, -1
endif
print, 'In CREATE_VIS'

;Second thing, if the 1st image virtual variable handle or dat structure
;elements are already set, then return astruct as is (because the other
;image variables, if requested, have already been set on the 1st call.
; 
; This is not true if create_plain_vis called 1st. IIMAGE_COUNTS variable will
; be set, but all other variables to be created in create_vis will not be set
; There is an ordering problem.
; Now return only if all of the handles are ne 0.
; RTB 9/98 
;

;vtags = tag_names(astruct.(vv_tagindx(0))) ;tags for the 1st Virtual image var.
ireturn=1
;print, vv_tagnames
;print, orig_names
for ig=0, n_elements(vv_tagindx)-1 do begin ; RTB added 9/98
 vtags=tag_names(astruct.(vv_tagindx(ig))) 
 v = tagindex('DAT',vtags)
 if (v(0) ne -1) then begin
   im_val = astruct.(vv_tagindx(ig)).dat
 endif else begin
   if (astruct.(vv_tagindx(ig)).handle eq 0) then begin
      ireturn=0
   endif
   im_val = 0
 endelse
 im_size = size(im_val)
;print, vv_tagindx(ig), astruct.(vv_tagindx(ig)).handle
 if (im_val(0) ne 0 or im_size(0) eq 3) then begin
  im_val = 0B ;free up space
  ireturn=0
 endif
endfor

if(ireturn) then return, astruct ; Return only if all orig_names are already
                                 ; populated.  RTB 9/98

;Set the index for where the latitude variable is located in astruct.
;This will vary depending on how many virtual image variables were
;selected.

l_index = n_elements(vv_tagnames) - 2 ;the lat and long are the last two vvs.

c_0 = astruct.(vv_tagindx(0)).COMPONENT_0 ;1st component var (real image var)

if (c_0 ne '') then begin ;this should be the real image data - get the image data
  real_image = tagindex(c_0, atags)
  itags = tag_names(astruct.(real_image)) ;tags for the real Image data.

  d = tagindex('DAT',itags)
    if (d(0) ne -1) then AllImage = astruct.(real_image).DAT $
    else begin
      d = tagindex('HANDLE',itags)
      handle_value, astruct.(real_image).HANDLE, AllImage
    endelse
  
endif else print, 'No image variable found'

im_size = size(AllImage)

if (im_size(0) eq 3 or (im_size(0) eq 2 and im_size(1) eq 256)) then begin

;Third thing, need to get all of the image support variables data 
;out of the astruct and place them into a simple data structure.

if (vv_tagnames(l_index) ne '') then begin ; this should be the latitude/long vv variable
  index = vv_tagindx(l_index)
  ltags = tag_names(astruct.(index)) ;tags names for the vv lat variable.

  ;find the "component_" attributes and construct a list
  a = where(strpos(ltags, 'COMPONENT_') eq 0, a_cnt)
  if (a_cnt ge 1) then begin
    Names = strarr(a_cnt)
    for j = 0, a_cnt-1 do begin 
      Names(j) = astruct.(index).(a(j))
    endfor
  endif 

endif

;now get the data for the these component variables from our
;structure and put them into a more simple structure which will
;be "passed" along to the vis s/w via the common block (xv_record_data).

;TJK - need to set the rec_number to the current record - because
; the low level compute_crds routine is expecting one structure
; named "record" for each image/time.

if (im_size(0) eq 3) then num_recs = im_size(3) else num_recs = 1
print, 'Number of images = ',num_recs
;Set up the arrays that all of the new data will be put in prior
;to final storage in their respective structure handles.
new_image = bytarr(im_size(1), im_size(2), im_size(3),/nozero)
new_lat = dblarr(im_size(1), im_size(2), im_size(3),/nozero)
new_lon = dblarr(im_size(1), im_size(2), im_size(3),/nozero)

; RTB add Epoch to Names list

Names1=strarr(n_elements(Names)+1);
Names1=[Names,"EPOCH"]
Names=Names1


for k = 0, num_recs-1 do begin 
  record = {RECORD:k+1}

  for i=0, n_elements(Names)-1 do begin
    var = tagindex(Names(i),atags) ;get each variables tag index
    vartags = tag_names(astruct.(var))
    d = tagindex('DAT',vartags)
      if (d(0) ne -1) then vardat = astruct.(var).DAT $
      else begin
        d = tagindex('HANDLE',vartags)
        handle_value, astruct.(var).HANDLE, vardat
      endelse
    var_size = size(vardat)
    ;need to only pass along one record worth of data
    ;for each "record structure".  What comes back in vardat is
    ;all records for each variable.  Also, for variables that
    ;aren't record varying, ie. look_dir_vctr and sensor, 
    ;we'll have to detect this and pass the same record along
    ;each time...
    if (num_recs gt 1) then begin
	var_size = size(vardat)
        case (var_size(0)) of
	  0: begin
		dat = vardat
	     end	 
	  1: begin
		if (var_size(1) eq num_recs) then dat = vardat(k) else $
		dat = vardat
	     end
	  2: begin
		if (var_size(2) eq num_recs) then dat = vardat(*,k) else $
		dat = vardat
	     end
	  3: begin
		if (var_size(3) eq num_recs) then dat = vardat(*,*,k) else $
		dat = vardat
	     end
	  4: begin
		if (var_size(4) eq num_recs) then dat = vardat(*,*,*,k) else $
		dat = vardat
	     end
	  else: begin
		  print, 'cannot handle greater than 4 dimension data yet',$
		  Names(i)
		end
	endcase

	endif else dat = vardat ;only one record

    vardat = 1B ;free up vardat
    record = CREATE_STRUCT(Names(i), dat, record)

  endfor ; all of the components

  Image = AllImage(*,*,k) ;just load in one image
  LookVector = record.Look_Dir_Vctr
  Imagenum = k
  ;Compute_crds is the main routine provided by the polar vis people
  ;that compute all sorts of things.

  compute_crds

  ;once the compute_crds routine runs, their resultant values needed
  ;for plotting the image should be in the common block XV_DERIVED_DATA
  ;as glats, glons which are each 256x256 arrays.  Now put these new
  ;data in the appropriate virtual variables dat or handle structure
  ;tag member.

  new_image(*,*,k) = transpose(Image)  
;  new_image(*,*,k) = Image
; RTB changes 9/98
  new_lat(*,*,k) =rotate(rotate(Glats,5),3)
  new_lon(*,*,k) =rotate(rotate(Glons,5),3)
  ;new_lat(*,*,k) = Glats
  ;new_lon(*,*,k) = Glons
  immin = min(Image,max=immax)
  
  print, 'Min and max values for this image, ',immin,' ',immax

  Image = 1B
  Glats = 1B
  Glons = 1B  

endfor; for each image

;TJK a bunch of varification information which can be taken out
;once we're confident things are working correctly...
wcnt = 0
wlat = where((new_lat ge -90.0 and new_lat le 90.0), wcnt)
if (wcnt gt 0) then latmin = min(new_lat(wlat),max=latmax)
if (wcnt gt 0) then print, 'Min and max latitudes for this image set, ',latmin,' ',latmax
if (wcnt gt 0) then print, 'Number of valid latitudes = ',wcnt

wcnt = 0
wlon = where((new_lon ge 0.0 and new_lon le 360.0), wcnt)
if (wcnt gt 0) then lonmin = min(new_lon(wlon),max=lonmax)
if (wcnt gt 0) then print, 'Min and max longitudes for this image set, ',lonmin,' ',lonmax
if (wcnt gt 0) then print, 'Number of valid latitudes = ',wcnt

;end of varification...TJK

im_temp = handle_create(value=new_image)
lat_temp = handle_create(value=new_lat)
lon_temp = handle_create(value=new_lon)

;astruct.(vv_tagindx(0)).HANDLE = im_temp
astruct.(vv_tagindx(l_index)).HANDLE = lat_temp
astruct.(vv_tagindx(l_index+1)).HANDLE = lon_temp

; Loop through all vv's and assign image handle to all w/ 0 handles RTB 9/98 
; Check if handle = 0 and if function = 'create_vis'
for ll=0, l_index-1 do begin
    vartags = tag_names(astruct.(vv_tagindx(ll)))
;11/5/04 - TJK - had to change FUNCTION to FUNCT for IDL6.* compatibility
;    findex = tagindex('FUNCTION', vartags) ; find the FUNCTION index number
    findex = tagindex('FUNCT', vartags) ; find the FUNCT index number
    if (findex(0) ne -1) then $
     func_name=strlowcase(astruct.(vv_tagindx(ll)).(findex(0)))
 if(func_name eq 'create_vis') then begin
  ;print, vv_tagnames(vv_tagindx(ll)), im_temp
  if(astruct.(vv_tagindx(ll)).HANDLE eq 0) then begin
   astruct.(vv_tagindx(ll)).HANDLE = im_temp
  endif
 endif
endfor
;The following should populate an extra 2 more virtual image variables.
;if (l_index gt 1) then begin ;asking for more than one image vv.
;  if l_index eq 2 then astruct.(vv_tagindx(1)).HANDLE = im_temp
;  if l_index eq 3 then astruct.(vv_tagindx(2)).HANDLE = im_temp
;endif

;free up space
new_image = 1B
new_lat = 1B
new_long = 1B

; Check astruct and reset variables not in orignal variable list to metadata,
; so that variables that weren't requested won't be plotted/listed.

   status = check_myvartype(astruct, orig_names)

return, astruct

endif else return, -1 ;if there's no image data return -1

end





