;$Author: kovalick $
;$Date: 1996/08/09 14:34:37 $
;$Header: /home/rumba/cdaweb/dev/control/RCS/split_filename.pro,v 1.1 1996/08/09 14:34:37 kovalick Exp kovalick $
;$Locker: kovalick $
;$Revision: 1.1 $
PRO split_filename, instring, outpath, outfile
; split the instring into path and filename information
temp = break_mystring(instring,delimiter='/') ; assume UNIX
if n_elements(temp) eq 1 then begin ; no path information present
  outpath='' & outfile=temp(0) & return
endif else begin
  if temp(0) ne '' then outpath=temp(0) + '/' else outpath = ''
  for i=1,n_elements(temp)-2 do outpath = outpath + temp(i) + '/'
  outfile=temp(n_elements(temp)-1)
endelse
return
end


