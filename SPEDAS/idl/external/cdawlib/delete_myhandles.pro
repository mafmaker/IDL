;$Author: kenb-mac $
;$Date: 2007-01-24 14:23:38 -0800 (Wed, 24 Jan 2007) $
;$Header: $
;$Locker: $
;$Revision: 225 $
;-----------------------------------------------------------------------------
; Prior to destroying or deleting one of the anonymous structures, determine
; if any data handles exists, and if so, free them.

PRO delete_myhandles, a

for i=0, n_elements(tag_names(a))-1 do begin
  ti = tagindex('HANDLE', tag_names(a.(i)))
  if ti ne -1 then begin

;    b = handle_info(a.(i).HANDLE, /valid_id)
;    if b eq 1 then handle_free, a.(i).HANDLE
    if handle_info(a.(i).HANDLE, /valid_id) then $
      handle_free, a.(i).HANDLE

  endif
endfor

end
