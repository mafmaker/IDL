;$Author: kenb $
;$Date: 2006-10-11 13:32:51 -0700 (Wed, 11 Oct 2006) $
;$Header: /home/rumba/cdaweb/dev/control/RCS/handle_check.pro,v 1.3 1996/09/05 12:40:24 baldwin Exp baldwin $
;$Locker: baldwin $
;$Revision: 8 $
FUNCTION handle_check, astruct

; Verify the type of the first parameter and retrieve the data
a = size(astruct)
if (a(n_elements(a)-2) ne 8) then begin
  print,'ERROR= 1st parameter is not a structure' & return,-1
endif else begin
  a = tagindex('DAT',tag_names(astruct))
  if (a(0) ne -1) then idat = astruct.DAT $
  else begin
    a = tagindex('HANDLE',tag_names(astruct))
    if (a(0) ne -1) then handle_value,astruct.HANDLE,idat $
    else begin
      print,'ERROR= 1st parameter does not have DAT or HANDLE tag' & return,-1
    endelse
  endelse
endelse

return, idat
end
