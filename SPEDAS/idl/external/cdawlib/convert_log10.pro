;$Author: kenb $
;$Date: 2006-10-11 13:32:51 -0700 (Wed, 11 Oct 2006) $
;$Header: /home/rumba/cdaweb/dev/control/RCS/convert_log10.pro,v 1.3 2004/03/03 22:21:37 kovalick Exp kovalick $
;$Locker: kovalick $
;$Revision: 8 $
;Functions: convert_log10, shiftdata_above_zero
;Purpose: to compute the virtual variables for several IMAGE cdf variables
;Author: Tami Kovalick, Raytheon ITSS, December 7, 2000
;Modification:
;
;
;
;
;When plotting linear data on a log scale, there are valid values that
;fall below zero.  This routine will scale these value up into the acceptable range 
;so as not to drop them off just because we're log scaling.
;
;
function shiftdata_above_one, data, fillval

;TJK 3/2/2004 made this new routine and changed from 0 to 1 since log of anything less 
;than 1 is negative or NAN (this routine is not used below but is called from plot_map_images
;when doing log color scaling).  
;	scase = where(((data le 0.0) and (data ne fillval)), sc)

	scase = where(((data le 1.0) and (data ne fillval)), sc)
	if (sc gt 0) then begin
;TJK 3/1/2004 same as above	  zcase = where((data gt 0.0) and (data ne fillval),zc) ;find the min of the vals above 0.
	  zcase = where((data gt 1.0) and (data ne fillval),zc) ;find the min of the vals above 0.
	  if (zc gt 0) then begin
	    newmin = min(data(zcase));
;TJK 3/1/2004	    print, 'reassigning values le 0.0 to lowest data value above zero = ',newmin
	    print, 'reassigning values le 1.0 to lowest data value above one = ',newmin
	    data(scase) = newmin ;reassign all values that are "valid" but because they
		   	         ;fall below 0 (w/ log scaling), they would be lost otherwise.
	  endif
	endif 

return, data
end

;When plotting linear data on a log scale, there are valid values that
;fall below zero.  This routine will scale these value up into the acceptable range 
;so as not to drop them off just because we're log scaling.
;
;
function shiftdata_above_zero, data, fillval

	scase = where(((data le 0.0) and (data ne fillval)), sc)
	if (sc gt 0) then begin
	  zcase = where((data gt 0.0) and (data ne fillval),zc) ;find the min of the vals above 0.
	  if (zc gt 0) then begin
	    newmin = min(data(zcase));
	    print, 'reassigning values le 0.0 to lowest data value above zero = ',newmin
	    data(scase) = newmin ;reassign all values that are "valid" but because they
		   	         ;fall below 0 (w/ log scaling), they would be lost otherwise.
	  endif
	endif 

return, data
end

function convert_log10, astruct, orig_names

;astruct will contain all of the variables, both virtual and real, and 
;metadata necessary to basically take the variable pointed to by the "data" variables
;COMPONENT_0 variable attribute, get its data values, convert them to log10
;values and store them into the virtual variables handle structure memeber. 

;First thing, get the virtual image variable metatdata and data.
atags = tag_names(astruct) ;get the variable names
vv_tagnames=strarr(1)
vv_tagindx = vv_names(astruct,names=vv_tagnames) ;find the virtual vars
if (vv_tagindx(0) lt 0) then return, -1

;print, 'In CONVERT_LOG10'


; Second, test to see whether all virtual variables, that need to call this
; function, have already been populated.  So return only if all of the 
; handles are ne 0.
;

ireturn=1
var_index = -1

for ig=0, n_elements(vv_tagindx)-1 do begin ; RTB added 9/98
  if (var_index eq -1) then begin ;haven't found a variable that needs populating yet
;    print, 'DEBUG In loop checking if all vv.s have been converted '
    vtags=tag_names(astruct.(vv_tagindx(ig))) 
    v = tagindex('DAT',vtags)
    if (v(0) ne -1) then begin
      im_val = astruct.(vv_tagindx(ig)).dat
    endif else begin
      if (astruct.(vv_tagindx(ig)).handle eq 0) then begin
         var_index = ig ; save the variable index of the next vv that needs converting
;	 print, '*** Set var_index = ',var_index
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
  endif
endfor

if(ireturn) then return, astruct ; Return only if all orig_names are already
                                 ; populated.  RTB 9/98


;TJK 3/1/2004 - replace (0) w/ (var_index), so that we can work on the "next" variable
;that has been defined to need convert_log10.
;
;c_0 = astruct.(vv_tagindx(0)).COMPONENT_0 ; 1st vvs component var (real image var)
c_0 = astruct.(vv_tagindx(var_index)).COMPONENT_0 ; Get the component var (points to the real image var)

if (c_0 ne '') then begin ;this should be the real image data - get the image data
  real_image = tagindex(c_0, atags)
  itags = tag_names(astruct.(real_image)) ;tags for the real Image data.

  d = tagindex('DAT',itags)
    if (d(0) ne -1) then AllImage = astruct.(real_image).DAT $
    else begin
      d = tagindex('HANDLE',itags)
      handle_value, astruct.(real_image).HANDLE, AllImage
    endelse
  no_images = 0
endif else begin
  no_images = 1
  print, 'No image variable found'
endelse

im_size = size(AllImage)

;get the fill value

  fillval =  -1.0e31
  fill_idx = tagindex('FILLVAL',itags)
  if (fill_idx(0) ne -1) then fillval = astruct.(real_image).FILLVAL

print, 'min = ',min(AllImage, max=maxval), 'max = ',maxval, ' before shift'
AllImage = shiftdata_above_zero(AllImage, fillval)
print, 'min = ',min(AllImage, max=maxval), 'max = ',maxval, ' after shift'

;The following is suppose to test for whether there are many records or just a 
;single one.

if (im_size(0) eq 3 or (im_size(0) eq 2 and no_images eq 0)) then begin 

  filldat = where(AllImage eq fillval, fwc) ; determine where the fill values are
  nfilldat = where(AllImage ne fillval, nfwc) ; determine where the good values are
  new_image = AllImage ;define the new image to be the same as the original (carry forth the fill values, if any)

  if (fwc gt 0 and nfwc gt 0) then begin ; if fill and good data found
	j = 0L
	i = nfilldat(j)
	while (j le nfwc-1) do begin
	  i = nfilldat(j)
          new_image(i) = alog10(AllImage(i)) 
	  j = j + 1
	endwhile
  endif else begin ; no fill data to deal with
    new_image = alog10(AllImage) ;define the new_image array 
	  		         ;which is just the log10 of the original.
  endelse

  im_temp = handle_create(value=new_image)


; Loop through all vv's and assign image handle to all w/ 0 handles
; Check if handle = 0 and if function = 'convert_log10' 
; TJK 2/26/2004 - this was wrong before - also need to compare this variables component_0 to make
; sure we're putting the right array w/ the right variable.

;for ll=0, n_elements(vv_tagindx)-1 do begin ;start the index at the current vv variable
for ll=var_index, n_elements(vv_tagindx)-1 do begin
  vartags = tag_names(astruct.(vv_tagindx(ll)))
;11/5/04 - TJK - had to change FUNCTION to FUNCT for IDL6.* compatibility
;  findex = tagindex('FUNCTION', vartags) ; find the FUNCTION index number
  findex = tagindex('FUNCT', vartags) ; find the FUNCTION index number
  cindex = tagindex('COMPONENT_0', vartags) ; find the Component_0 value

  if (findex(0) ne -1 and cindex(0) ne -1) then $
     func_name=strlowcase(astruct.(vv_tagindx(ll)).(findex(0)))
     next_0=astruct.(vv_tagindx(ll)).(cindex(0))
  if(func_name eq 'convert_log10' and (strlowcase(next_0) eq strlowcase(c_0))) then begin
  ;print, vv_tagnames(vv_tagindx(ll)), im_temp
    if(astruct.(vv_tagindx(ll)).HANDLE eq 0) then begin
      astruct.(vv_tagindx(ll)).HANDLE = im_temp
    endif
  endif
endfor

;free up space
new_image = 1B

; Check astruct and reset variables not in orignal variable list to metadata,
; so that variables that weren't requested won't be plotted/listed.

   status = check_myvartype(astruct, orig_names)

return, astruct

endif else return, -1 ;if there's no image data return -1

end





