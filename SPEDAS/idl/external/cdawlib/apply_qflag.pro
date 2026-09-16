;$Author: jimm $
;$Date: 2010-01-12 12:18:45 -0800 (Tue, 12 Jan 2010) $
;$Header: /home/cdaweb/dev/control/RCS/apply_qflag.pro,v 1.2 2000/03/09 20:25:24 kovalick Exp kovalick $
;$Locker: kovalick $
;$Revision: 7092 $
;Function: Apply_qflag
;Purpose: To use the quality variable to "filter out bad Polar_h0_tim flux 
;data points"
;Author: Tami Kovalick, Raytheon ITSS, January 5, 2000
;Modification: TJK 3/9/00 added more variables.
;
;
function apply_qflag, astruct, orig_names, index=index

;Input: astruct: the structure, created by read_myCDF that should
;		 contain at least one Virtual variable.
;	orig_names: the list of varibles that exist in the structure.
;	index: the virtual variable (index number) for which this function
;		is being called to compute.  If this isn't defined, then
;		the function will find the 1st virtual variable.

;this code assumes that the Component_0 is the original flux variable, 
;Component_1 should be the filter variable.

;astruct will contain all of the variables and metadata necessary
;to filter out the bad flux values (based on the filter variables values -
;a value >= 4 (bad). 

atags = tag_names(astruct) ;get the variable names.
vv_tagnames=strarr(1)
vv_tagindx = vv_names(astruct,names=vv_tagnames) ;find the virtual vars

if keyword_set(index) then begin
  index = index
endif else begin ;get the 1st vv

  index = vv_tagindx(0)
  if (vv_tagindx(0) lt 0) then return, -1

endelse

;print, 'In Apply_qflag'
;print, 'Index = ',index
;print, 'Virtual variable ', atags(index)
;print, 'original variables ',orig_names
;help, /struct, astruct
;stop;
c_0 = astruct.(index).COMPONENT_0 ;1st component var (real flux var)

if (c_0 ne '') then begin ;this should be the real data
  var_idx = tagindex(c_0, atags)
  itags = tag_names(astruct.(var_idx)) ;tags for the real data.

  d = tagindex('DAT',itags)
    if (d(0) ne -1) then  flux_data = astruct.(var_idx).DAT $
    else begin
      d = tagindex('HANDLE',itags)
      handle_value, astruct.(var_idx).HANDLE, flux_data
    endelse
  fill_val = astruct.(var_idx).fillval

endif else print, 'Flux variable not found'
;help, flux_data
;stop;TJK
data_size = size(flux_data)

;9/2/2008 - TJK - check for just one record, if found make it (1,*,*) and
;           continue on.  Otherwise it gets thrown out.
if (data_size(0) eq 2) then begin 
  dims = size(flux_data, /dimensions)
  tmp_flux = make_array(1,dims(0), dims(1))
  tmp_flux(0,*,*) = flux_data
  flux_data = tmp_flux
  data_size = size(flux_data)
endif


if (data_size(0) eq 3) then begin ;may need to change this test to fit the flux

c_0 = astruct.(index).COMPONENT_1 ; should be the quality variable

if (c_0 ne '') then begin ;
  var_idx = tagindex(c_0, atags)
  itags = tag_names(astruct.(var_idx)) ;tags for the real data.

  d = tagindex('DAT',itags)
    if (d(0) ne -1) then  quality_data = astruct.(var_idx).DAT $
    else begin
      d = tagindex('HANDLE',itags)
      handle_value, astruct.(var_idx).HANDLE, quality_data
    endelse
  
endif else print, 'Quality variable not found'

;quality_data should contain (4,num_recs)
;where element (0,num_recs) should be applied to the Flux_H
;where element (1,num_recs) should be applied to the Flux_0
;where element (2,num_recs) should be applied to the Flux_He_1
;where element (3,num_recs) should be applied to the Flux_He_2
;help, quality_data
;stop;

 case (strlowcase(astruct.(index).COMPONENT_0)) of
      'flux_h': begin
                        temp = where(quality_data(0,*) ge 4, badcnt)
			if (badcnt ge 1) then begin
			  print, 'found some bad flux_hq data ',badcnt, 'points'
			  flux_data(*,*,temp) = fill_val
			endif
                        end
      'flux_o': begin
                        temp = where(quality_data(1,*) ge 4, badcnt)
			if (badcnt ge 1) then begin
			  print, 'found some bad flux_oq data ',badcnt, 'points'
			  flux_data(*,*,temp) = fill_val
			endif
                        end
      'flux_he_1': begin
                        temp = where(quality_data(2,*) ge 4, badcnt)
			if (badcnt ge 1) then flux_data(*,*,temp) = fill_val
                        end
      'flux_he_2': begin
                        temp = where(quality_data(3,*) ge 4, badcnt)
			if (badcnt ge 1) then flux_data(*,*,temp) = fill_val
                        end
      'sigma_h': begin
                        temp = where(quality_data(0,*) ge 4, badcnt)
			if (badcnt ge 1) then begin
			  print, 'found some bad flux_hq data ',badcnt, 'points'
			  flux_data(*,*,temp) = fill_val
			endif
                        end
      'sigma_o': begin
                        temp = where(quality_data(1,*) ge 4, badcnt)
			if (badcnt ge 1) then begin
			  print, 'found some bad flux_oq data ',badcnt, 'points'
			  flux_data(*,*,temp) = fill_val
			endif
                        end
      'sigma_he_1': begin
                        temp = where(quality_data(2,*) ge 4, badcnt)
			if (badcnt ge 1) then flux_data(*,*,temp) = fill_val
                        end
      'sigma_he_2': begin
                        temp = where(quality_data(3,*) ge 4, badcnt)
			if (badcnt ge 1) then flux_data(*,*,temp) = fill_val
                        end

	else: print, 'WARNING= Variable, ',astruct.(index).COMPONENT_0,' not valid'
 endcase


;now, need to fill the virtual variable data structure with this new data array
;and "turn off" the original variable.

;
;print, 'badcnt',badcnt
;help, flux_data
;stop;

temp = handle_create(value=flux_data)


astruct.(index).HANDLE = temp

flux_data = 1B
quality_data = 1B

; Check astruct and reset variables not in orignal variable list to metadata,
; so that variables that weren't requested won't be plotted/listed.

   status = check_myvartype(astruct, orig_names)

return, astruct

endif else return, -1 ;if there's no flux data return -1

end





