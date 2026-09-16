;$Author: kenb $
;$Date: 2006-10-11 13:32:51 -0700 (Wed, 11 Oct 2006) $
;$Header: /home/rumba/cdaweb/dev/control/RCS/restore_mystruct.pro,v 1.1 1996/08/09 14:32:09 kovalick Exp kovalick $
;$Locker: kovalick $
;$Revision: 8 $
FUNCTION restore_mystruct,fname
; declare variables which exist at top level
COMMON CDFmySHARE, v0  ,v1, v2, v3, v4, v5, v6, v7, v8, v9,$
                   v10,v11,v12,v13,v14,v15,v16,v17,v18,v19,v20
; Use the IDL restore feature to reconstruct the anonymous structure a
RESTORE,FILENAME=fname
; The anonymous structure should now be in the variable 'a'.  Determine
; if the structure contains .DAT or .HANDLE fields
ti = tagindex('HANDLE',tag_names(a.(0)))
if ti ne -1 then begin
  tn = tag_names(a) & nt = n_elements(tn) ; determine number of variables
  for i=0,nt-1 do begin
    a.(i).HANDLE = handle_create()
    order = 'handle_value,a.(i).HANDLE,v' + strtrim(string(i),2) + ',/SET'
    status = EXECUTE(order)
  endfor
endif
return,a
end
