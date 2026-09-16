;$Author: kenb $
;$Date: 2006-10-11 13:32:51 -0700 (Wed, 11 Oct 2006) $
;$Header: /home/rumba/cdaweb/dev/control/RCS/compare_struct.pro,v 1.1 1996/08/09 14:04:26 kovalick Exp kovalick $
;$Locker: kovalick $
;$Revision: 8 $
; Compare the two structures.  If they are the same return 1 else return 0
FUNCTION compare_struct, a, b
same=1L & as=size(a) & bs=size(b) & na=n_elements(as) & nb=n_elements(bs)
if (as(na-2) ne bs(nb-2)) then return,0 $ ; different types
else begin
  if (as(na-2) ne 8) then begin ; both types are not structures
    if (total(a ne b) ne 0.0) then return,0 else return,1
  endif else begin ; both a and b are structures, compare all fields
    ta = tag_names(a) & tb = tag_names(b)
    if (n_elements(ta) ne n_elements(tb)) then return,0 $ ; different # of tags
    else begin ; compare each tag name and then each tag field
      i=0L & j=0L & nta = n_elements(ta)
      while ((i le (nta-1)) AND (same eq 1)) do begin
        if (ta(i) ne tb(i)) then return,0 else i=i+1
      endwhile
      while ((j le (nta-1)) AND (same eq 1)) do begin
        same = compare_struct(a.(j),b.(j)) & j=j+1
      endwhile
    endelse
  endelse
endelse
return,same
end


