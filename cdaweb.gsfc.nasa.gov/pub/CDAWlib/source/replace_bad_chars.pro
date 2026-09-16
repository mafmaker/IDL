;Name: Replace_bad_chars
;Purpose: to find "illegal" characters and replace them w/ the "replacement'
;character.
;
;calling sequence:
;	outstring = replace_bad_chars(instring, repchar=repchar, found)
;
;arguments:
;		instring: input string or array of strings to examine
;		found: = 1 if bad characters are found and replaced
;		       = 0 if no bad characters are found.
;keyword:
;		repchar: character to replace bad character with
;			 the only valid values here are "$" and "_"
;			 default is "$"
; History:
;	RCJ 03/30/01 - Modified so this function works for array of strings too.
;			And initialized found=0L instead of 1L. Found becomes
;			1L if a bad char is replaced in a string.

function replace_bad_chars, instring, repchar=repchar, found

badChars=['\','/','.','%','!','@','#','^','&','*','(',')','-','+','=', $
   '`','~','|','?','<','>',' ']



if not keyword_set(repchar) then repchar = "$"

if not(repchar eq "$" or repchar eq "_") then repchar = "$"

found = 0L

outstring = instring

for i=0,n_elements(instring)-1 do begin
   for k=0L,n_elements(badChars)-1 do begin
      outstring(i)=repchr(outstring(i),badChars[k],repchar)
   endfor
   if (instring(i) ne outstring(i)) then found = 1L
endfor

return, outstring
end

