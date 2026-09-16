; Generically useful IDL routines for use in CDFx.

;-----------------------------------------------------------------------------

pro nwin ; stub function that patches CDAWLib
end

;-----------------------------------------------------------------------------
; Return a string-ized version of the given CDF epoch that is suitable for
; passing to 'read_mycdf'.  Format is "YYYY/MM/DD hh:mm:ss".
; RCJ 11/15/2012  Format now is "YYYY/MM/DD hh:mm:ss.mmm".
function cdfx_time_string_of_epoch, epoch

;cdf_epoch, epoch, yr, mo, day, hr, mi, sec, /break
cdf_epoch, epoch, yr, mo, day, hr, mi, sec, mil,/break

;return, string(yr, mo, day, hr, mi, sec, $
  ;format='(i4.4,"/",i2.2,"/",i2.2," ",i2.2,":",i2.2,":",i2.2)')
return, string(yr, mo, day, hr, mi, sec, mil,$
  format='(i4.4,"/",i2.2,"/",i2.2," ",i2.2,":",i2.2,":",i2.2,".",i3.3)')
end

;-----------------------------------------------------------------------------
; Returns a uniq-ized sorted version of a given array.

function cdfx_uniq_sort, array

return, array[uniq(array, sort(array))]

end

;-----------------------------------------------------------------------------
; Determine the letter to identify the next data object

function determine_dataobject_letter

common cdfxcom, CDFxwindows, CDFxprefs ; include cdfx common

w = where(strpos(cdfxwindows.title,'Data Object') ne -1,wc)
if wc eq 0 then return, 'A' ; first data object

b = bytarr(wc)
; convert all of the existing letters to numbers
for i=0,wc-1 do begin
  b[i] = byte(strtrim(strmid(cdfxwindows.title[w[i]],11,8),2))
endfor

; find the earliest unused number beginning with 65 (i.e. 'A')
p = bindgen(26)  &  p = p + 65B
for i=0,wc-1 do begin
  w = where(p ne b[i])
  p = p[w]
endfor

return, string(p[0])
end

;-----------------------------------------------------------------------------

function cdfx_prune_struct, s, usertag

; RCJ 12/12/2012  Changed this function to look for depends, not only
;   check for var_type 'data'


sr = -1
tnames = tag_names(s)

ss=parse_mydepend0(s)
tn=tag_names(ss)
utag=where(tnames eq strupcase(usertag))
tags_utag=tag_names(s.(utag[0]))
dep0=-1
dep1=-1
dep2=-1
if (where(tags_utag eq 'DEPEND_0') ne -1) then dep0=s.(utag[0]).depend_0 ; usertag could be epoch, so no depend_0.
q=where(tn eq strupcase(dep0))
ss=ss.(q[0])
if (where(tags_utag eq 'DEPEND_1') ne -1) then dep1=s.(utag[0]).depend_1
if (where(tags_utag eq 'DEPEND_2') ne -1) then dep2=s.(utag[0]).depend_2


for i=0, n_tags(s)-1 do begin
  tname = tnames[i]
  ;if tname eq usertag  or  s.(i).var_type ne 'data' then begin
  if ((tname eq strupcase(usertag))  or  (tname eq strupcase(dep0)) or (tname eq strupcase(dep1)) $
     or (tname eq strupcase(dep2))) then begin
    if (size(sr))[0] eq 0 then $
      sr = create_struct(tname, s.(i)) $
    else $
      sr = create_struct(sr, tname, s.(i))
  endif
endfor

return, sr
end

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

;-----------------------------------------------------------------------------
; Create list of variables given the megastructure 'a'

function generate_varlist, a, ALL=ALL

atags = tag_names(a)
vnames = ''

for i=0, n_elements(atags)-1 do begin
  btags = tag_names(a.(i))
  d='DATA'  &  f=''  &  c=''
  w = where(btags eq 'VAR_TYPE',wc) & if (wc gt 0) then d = a.(i).(w[0])
  w = where(btags eq 'FIELDNAM',wc) & if (wc gt 0) then f = a.(i).(w[0])
  w = where(btags eq 'CATDESC',wc)  & if (wc gt 0) then c = a.(i).(w[0])

  if keyword_set(ALL) or (strupcase(d) eq 'DATA') then begin
    if (f eq '') then f = c ;TJK added for cases w/o fieldnam
    if (vnames[0] eq '') then $
      vnames[0] = (atags[i] + ' :' + f) $
    else $
      vnames = [vnames,(atags[i] + ' :' + f)]
  endif
;print, 'In generate_varlist, vnames = ',vnames
endfor

return, vnames
end

;-----------------------------------------------------------------------------
