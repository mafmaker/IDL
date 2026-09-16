;$Author: kovalick $
;$Date: 2000/03/22 21:39:59 $
;$Header: /home/cdaweb/dev/control/RCS/TAGindex.pro,v 1.3 2000/03/22 21:39:59 kovalick Exp johnson $
;$Locker: johnson $
;$Revision: 1.3 $
; Search the tnames array for the instring, returning the index in tnames
; if it is present, or -1 if it is not.
FUNCTION TAGindex, instring, tnames
;TJK 3/7/2000 change this to strip instring of any blanks since
;its possible that a variable name can have trialing blanks in it (new
;cdaw9 cdfs).
instring = STRUPCASE(strtrim(instring,2)) ; tagnames are always uppercase
a = where(tnames eq instring,count)
if count eq 0 then return, -1 $
else return, a[0]
end
