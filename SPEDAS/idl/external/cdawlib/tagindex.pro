;$Author: kenb $
;$Date: 2006-10-11 13:32:51 -0700 (Wed, 11 Oct 2006) $
;$Header: /home/rumba/cdaweb/dev/control/RCS/TAGindex.pro,v 1.2 1996/08/09 15:54:30 kovalick Exp kovalick $
;$Locker: kovalick $
;$Revision: 8 $
; Search the tnames array for the instring, returning the index in tnames
; if it is present, or -1 if it is not.
FUNCTION TAGindex, instring, tnames
;TJK 3/7/2000 change this to strip instring of any blanks since
;its possible that a variable name can have trialing blanks in it (new
;cdaw9 cdfs).
instring = STRUPCASE(strtrim(instring,2)) ; tagnames are always uppercase
a = where(tnames eq instring,count)
if count eq 0 then return, -1 $
else return, a(0)
end