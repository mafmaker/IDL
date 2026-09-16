;$Author: kenb $
;$Date: 2006-10-11 13:32:51 -0700 (Wed, 11 Oct 2006) $
;$Header: /home/rumba/cdaweb/dev/control/RCS/create_plain_vis.pro,v 1.14 2001/03/14 19:19:41 kovalick Exp kovalick $
;$Locker: kovalick $
;$Revision: 8 $
;Function: create_plain_vis
;Purpose: to compute a plain image for the Polar VIS
;images in Kilorayleighs.
;Author: Tami Kovalick, Raytheon STX, July 15, 1998
;Modification:
;
;
function create_plain_vis, astruct, orig_names

;this code assumes that an image variable is declared as virtual.  
;And that the "components" of the image virtual variable are
;the "parent" variable "Image_Counts" and the additional variable
;"Intens_Table".

;First thing, get the virtual image variable metatdata and data.
atags = tag_names(astruct) ;get the variable names
vv_tagnames=strarr(1)
vv_tagindx = vv_names(astruct,names=vv_tagnames) ;find the virtual vars
if (vv_tagindx(0) lt 0) then return, -1
;Get the real image data

print, 'In Create_plain_vis.pro'

ireturn=1
;print, vv_tagnames
;print, orig_names
im_val_arr=intarr(n_elements(vv_tagindx))
for ig=0, n_elements(vv_tagindx)-1 do begin ; RTB added 9/98
 vtags=tag_names(astruct.(vv_tagindx(ig)))

;TJK 3/14/01 added check for function name, so we're not waisting time looking at
;virtual variables that aren't suppose to be processed by this function.
;11/5/04 - TJK - had to change FUNCTION to FUNCT for IDL6.* compatibility
; findex = tagindex('FUNCTION', vtags) ; find the FUNCTION index number
 findex = tagindex('FUNCT', vtags) ; find the FUNCTION index number
 if (findex(0) ne -1) then $
   func_name=strlowcase(astruct.(vv_tagindx(ig)).(findex(0)))

 if(func_name eq 'create_plain_vis') then begin
     v = tagindex('DAT',vtags)
     if (v(0) ne -1) then begin
       im_val = astruct.(vv_tagindx(ig)).dat
     endif else begin
       im_val = astruct.(vv_tagindx(ig)).handle
       if (im_val eq 0) then ireturn=0
     endelse
     im_val_arr(ig)=im_val
     im_size = size(im_val)
     im_val=0
     ;print, vv_tagindx(ig), im_val_arr(ig)
     if (im_val(0) ne 0 or im_size(0) eq 3) then begin
       im_val = 0B ;free up space
       ireturn=0
     endif
 endif else im_val_arr(ig) = -1 ;function isn't create_plain_vis, don't need to look at it

endfor

if(ireturn) then return, astruct ; Return only if all orig_names are already
                                 ; populated.  RTB 9/98

; Determine 1st vv which has not yet been populated. If there are other
; vv's (after this current vv) which have not been set, they will be
; populated below if approriate or in another vv function called be
; read_myCDF.   RTB  11/20/98
;
im_v=where(im_val_arr eq 0,im_vn)

if (im_vn le 0) then return, astruct ;TJK added 3/14/01

c_0 = astruct.(vv_tagindx(im_v(0))).COMPONENT_0 ;1st component var (real image var)
c_1 = astruct.(vv_tagindx(im_v(0))).COMPONENT_1 ;2nd component var (intensity var)

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

;Second thing, need to get the image support variable data 
;out of astruct.

if (c_1 ne '') then begin ;this should be the real intensity data
  intensity = tagindex(c_1, atags)
  itags = tag_names(astruct.(intensity)) ;tags for the real Image data.

  d = tagindex('DAT',itags)
    if (d(0) ne -1) then Intens = astruct.(intensity).DAT $
    else begin
      d = tagindex('HANDLE',itags)
      handle_value, astruct.(intensity).HANDLE, Intens
    endelse
  
endif else print, 'No intensity variable found'

if (im_size(0) eq 3) then num_recs = im_size(3) else num_recs = 1
print, 'Number of images = ',num_recs

;Set up the arrays that all of the new data will be put in prior
;to final storage in their respective structure handles.

new_image = fltarr(im_size(1), im_size(2), im_size(3),/nozero)

for k = 0, num_recs-1 do begin 

  Image = AllImage(*,*,k) ;just load in one image
;don't do yet...TJK 7/22/98  new_image(*,*,k) = transpose(Image)
  new_image(*,*,k) = Image
  new_image(*,*,k) = Intens(new_image(*,*,k)+1)
  immin = min(new_image,max=immax)
  
  print, 'Min and max values for this image, ',immin,' ',immax

  Image = 1B

endfor; for each image

;TJK a bunch of varification information which can be taken out
;once we're confident things are working correctly...
wcnt = 0

im_temp = handle_create(value=new_image)

; Line below replaced w/ for loop  RTB
;astruct.(vv_tagindx(0)).HANDLE = im_temp
;
; Loop through all vv's and assign image handle to all w/ 0 handles RTB 11/98
; Check if handle = 0 and if function = 'create_plain_vis'
;print, n_elements(vv_tagindx)
;print, vv_tagnames
;if(n_elements(vv_tagindx) gt 1) then begin
 for ll=0, n_elements(vv_tagindx)-1 do begin
;print, ll
;print, vv_tagindx(ll)
    vartags = tag_names(astruct.(vv_tagindx(ll)))
;11/5/04 - TJK - had to change FUNCTION to FUNCT for IDL6.* compatibility
;    findex = tagindex('FUNCTION', vartags) ; find the FUNCTION index number
    findex = tagindex('FUNCT', vartags) ; find the FUNCT index number
    if (findex(0) ne -1) then $
     func_name=strlowcase(astruct.(vv_tagindx(ll)).(findex(0)))
     if(func_name eq 'create_plain_vis') then begin
;      print, vv_tagnames(vv_tagindx(ll)), im_temp
      if(astruct.(vv_tagindx(ll)).HANDLE eq 0) then begin
       astruct.(vv_tagindx(ll)).HANDLE = im_temp
      endif
     endif
 endfor
;endif else begin
 

;free up space
new_image = 1B

; Check astruct and reset variables not in orignal variable list to metadata,
; so that variables that weren't requested won't be plotted/listed.

   status = check_myvartype(astruct, orig_names)

return, astruct

endif else return, -1 ;if there's no image data return -1

end





