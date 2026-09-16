;-----------------------------------------------------------------------------------------

; Modify the given tag (name or number) in the given variable (name or number)
; in the given structure 'a' with the new value.
FUNCTION modify_mystruct,a,var,tag,value
; Initialize
atags = tag_names(a)

; Determine the variable number and validate
s = size(var) & ns = n_elements(s)
if s(ns-2) eq 7 then begin ; variable is given as a variable name
  w = where(atags eq strupcase(var),wc)
  if wc gt 0 then vnum = w(0) $
  else begin
    print,'ERROR>modify_mystruct:named variable not in structure!' & return,-1
  endelse
endif else begin
  if ((var ge 0)AND(var lt n_elements(atags))) then vnum = var $
  else begin
    print,'ERROR>modify_mystruct:variable# not in structure!' & return,-1
  endelse
endelse
vtags = tag_names(a.(vnum))

; Determine the tag number and validate
s = size(tag)  
;ns = n_elements(s)
if s(n_elements(s)-2) eq 7 then begin ; tag is given as a tag name
  w = where(vtags eq strupcase(tag))
  if w[0] ne -1 then tnum = w[0] $
  else begin
    print,'ERROR>modify_mystruct:named tag not in structure!' & return,-1
  endelse
endif else begin
  if ((tag ge 0)AND(tag lt n_elements(vtags))) then tnum = tag $
  else begin
    print,'ERROR>modify_mystruct:tag# not in structure!' & return,-1
  endelse
endelse

; Create and return new structure with only the one field modified
for i=0,n_elements(atags)-1 do begin ; loop through every variable
  if (i ne vnum) then b = a.(i) $ ; no changes to this variable
  else begin ; must handle this variable field by field
    tnames = tag_names(a.(i))
    for j=0,n_elements(tnames)-1 do begin
      if (j ne tnum) then c = create_struct(tnames(j),a.(i).(j)) $ ; no changes
      else c = create_struct(tnames(j),value) ; new value for this field
      ; Add the structure 'c' to the substructure 'b'
      if (j eq 0) then b = c $ ; create initial structure
      else b = create_struct(b,c) ; append to existing structure
    endfor
  endelse
  ; Add the substructure 'b' to the megastructure
  if (i eq 0) then aa = create_struct(atags(i),b) $ create initial structure
  else begin ; append to existing structure
    c = create_struct(atags(i),b) & aa = create_struct(aa,c)
  endelse
endfor
return,aa
end
