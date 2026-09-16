;$Author: kenb $
;$Date: 2006-10-11 13:32:51 -0700 (Wed, 11 Oct 2006) $
;$Header:  $
;$Locker: $
;$Revision: 8 $
;Function: region_filt
;Purpose: To filter each proton or ion variable by region number - for
;the IMP8 MIT dataset.
;Author: Tami Kovalick, QSS, September, 16, 2004
;Modification: 
;
;
function region_filt, astruct, orig_names, index=index

;Input: astruct: the structure, created by read_myCDF that should
;		 contain at least one Virtual variable.
;	orig_names: the list of varibles that exist in the structure.
;	index: the virtual variable (index number) for which this function
;		is being called to compute.  If this isn't defined, then
;		the function will find the 1st virtual variable.

;this code assumes that the Component_0 is the original variable, 
;Component_1 should be the region variable.

;astruct will contain all of the variables and metadata necessary
;Bob wants to return values when region = 1 (solar wind)

atags = tag_names(astruct) ;get the variable names.
vv_tagnames=strarr(1)
vv_tagindx = vv_names(astruct,names=vv_tagnames) ;find the virtual vars

if keyword_set(index) then begin
  index = index
endif else begin ;get the 1st vv

  index = vv_tagindx(0)
  if (vv_tagindx(0) lt 0) then return, -1

endelse

print, 'In region_filt'
;print, 'Index = ',index
;print, 'Virtual variable ', atags(index)
;print, 'original variables ',orig_names
;help, /struct, astruct
;stop;
c_0 = astruct.(index).COMPONENT_0 ;1st component var (parent variable)

if (c_0 ne '') then begin ;this should be the real data
  var_idx = tagindex(c_0, atags)
  itags = tag_names(astruct.(var_idx)) ;tags for the real data.

  d = tagindex('DAT',itags)
    if (d(0) ne -1) then  real_data = astruct.(var_idx).DAT $
    else begin
      d = tagindex('HANDLE',itags)
      handle_value, astruct.(var_idx).HANDLE, real_data
    endelse
  fill_val = astruct.(var_idx).fillval

endif else print, ' variable not found'
;help, real_data
;stop;TJK
data_size = size(real_data)


c_0 = astruct.(index).COMPONENT_1 ; should be the region variable

if (c_0 ne '') then begin ;
  var_idx = tagindex(c_0, atags)
  itags = tag_names(astruct.(var_idx)) ;tags for the real data.

  d = tagindex('DAT',itags)
    if (d(0) ne -1) then  quality_data = astruct.(var_idx).DAT $
    else begin
      d = tagindex('HANDLE',itags)
      handle_value, astruct.(var_idx).HANDLE, region_data
    endelse
  

;help, region_data
;stop;TJK

temp = where(region_data ne 1, cnt)
if (cnt ge 1) then begin
  print, 'found regions we want to exclude ',cnt, 'points'
  real_data(temp) = fill_val
endif


;now, need to fill the virtual variable data structure with this new data array
;and "turn off" the original variable.

;
;print, 'badcnt',badcnt
;help, real_data
;stop;

temp = handle_create(value=real_data)


astruct.(index).HANDLE = temp

real_data = 1B
region_data = 1B

; Check astruct and reset variables not in orignal variable list to metadata,
; so that variables that weren't requested won't be plotted/listed.

   status = check_myvartype(astruct, orig_names)

return, astruct

endif else return, -1 ;if there's no flux data return -1

end





