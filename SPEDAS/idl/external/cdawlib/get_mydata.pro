;----------------------------------------------------------------------------------

; Return the data for the given variable in the given structure
FUNCTION get_mydata,a,var
; Determine the variable number
s = size(var)  
if s(n_elements(s)-2) eq 7 then begin
  w = where(tag_names(a) eq var)
  if w[0] ne -1 then vnum = w(0) $
  else begin
    print,'ERROR>get_mydata:named variable not in structure!' & return,-1
  endelse
endif else vnum = var
; Retrieve the data for the variable
vtags = tag_names(a.(vnum))
ti = tagindex('HANDLE',vtags)
if ti ne -1 then begin
   b = handle_info(a.(vnum).HANDLE,/valid_id)
   if b eq 1 then handle_value,a.(vnum).handle,d else d=0
   ;handle_value,a.(vnum).handle,d 
endif else begin
  ti = tagindex('DAT',vtags)
  if ti ne -1 then d = a.(vnum).dat $
  else begin
    print,'ERROR>get_mydata:variable has neither HANDLE nor DAT tag!'
    return,-1
  endelse
endelse
if n_elements(d) gt 1 then d = reform(d)
return,d
end

;----------------------------------------------------------------------------------
