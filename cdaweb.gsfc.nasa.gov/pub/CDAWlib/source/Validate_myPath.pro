;$Author: $
;$Date: $
;$Header:$
;$Locker: $
;$Revision: $
PRO Validate_myPath,path
case !VERSION.OS of
  'vms'     : separator = ''
  'windows' : separator = '\'
  'MacOS'   : separator = ":"
  else      : separator = '/'
endcase
if (strpos(path,separator,strlen(path)-1) eq -1)AND(path ne separator) then $
   path = path + separator
end
