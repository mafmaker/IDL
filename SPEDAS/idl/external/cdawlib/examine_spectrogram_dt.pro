;$Author: jimm $
;$Date: 2010-01-12 12:18:45 -0800 (Tue, 12 Jan 2010) $
;$Header: /home/cdaweb/dev/control/RCS/examine_SPECTROGRAM_DT.pro,v 1.10 2005/03/14 16:33:58 kovalick Exp kovalick $
;$Locker: kovalick $
;$Revision: 7092 $
;
;TJK April 17, 1997
;Modified to also parse the DISPLAY_TYPE string for STACK_PLOT type
;as well as Spectrograms and Ionograms.
;TJK July 30, 1999
;Modified to parse DISPLAY_TYPE for TIME_SERIES (y=flux(1))
;
FUNCTION examine_SPECTROGRAM_DT, instring

; Initialize local variables
xname='' & yname='' & zname='' & lptrn=1 & igram=0
npanels=0 & dvary=-1 & elist=lonarr(1)

; Verify that instring is for spectrogram plot and instructions exist
a = break_mystring(instring,delimiter='>')
if (strupcase(a(0)) eq 'IONOGRAM') then igram=1 $
else if (strupcase(a(0)) eq 'STACK_PLOT') then igram=0 $
else if (strupcase(a(0)) eq 'PLASMAGRAM') then igram=0 $
else if (strupcase(a(0)) eq 'TIME_SERIES') then igram=0 $
else if (strupcase(a(0)) eq 'TIME_TEXT') then igram=0 $
else if (strupcase(a(0)) ne 'SPECTROGRAM') then return,-1 ; neither
;TJK 02/14/2002 - chage this to return the initialized structure
; instead of -1 if (n_elements(a) eq 1) then return,-1 ; no instructions

if (n_elements(a) gt 1)then begin ;additional display type syntax found...

; Count the number of '=' to determine the number of instructions
b=0 & for i=0,strlen(a(1))-1 do if (strmid(a(1),i,1) eq '=') then b=b+1
if (b ge 1) then begin
   ilist = strarr(b) 
endif else begin ;syntax like time_series>noauto found
;TJK 10/12/2007 - try returning zero instead of 1 since not all
;                 timeseries variables are just a single panel.  Zero
;                 should force the code in the calling routine to
;                 determine the number of panels based on the data size.
;   npanels=1 ;return,-1 ; no valid instructions
   npanels=0 ;return,-1 ; no valid instructions
   ;return the structure instead of -1
   ; initialize the structure which is output from this function
   out = {x:xname,y:yname,z:zname,npanels:npanels,$
         dvary:dvary,elist:elist,lptrn:lptrn,igram:igram}
   return,out
endelse

; Dissect the input string into its separate instructions
inum = 0 & next_target=',' ; initialize
for i=0,strlen(a(1))-1 do begin
  c = strmid(a(1),i,1) ; get next character in string
  if (c eq next_target) then begin
    if (next_target eq ',') then inum = inum + 1
    if (next_target eq ')') then begin
      ilist(inum) = ilist(inum) + c & next_target = ','
    endif
  endif else begin
    ilist(inum) = ilist(inum) + c ; copy to instruction list
    if (c eq '(') then next_target = ')'
  endelse
endfor

; Determine if the xaxis variable is present as an instruction
for inum=0,n_elements(ilist)-1 do begin
  b=strpos(ilist(inum),'x=') & c=strpos(ilist(inum),'X=') & if c gt b then b=c
  if (b ne -1) then begin ; extract the name of the x variable
    c = break_mystring(ilist(inum),delimiter='=') & xname = c(1)
  endif
endfor

; Determine if the yaxis variable is present as an instruction
; looking for an instruction like y=flux(1) or y=flux

for inum=0,n_elements(ilist)-1 do begin
  b=strpos(ilist(inum),'y=') & c=strpos(ilist(inum),'Y=') & if c gt b then b=c
  if (b ne -1) then begin ; extract the name of the y variable and elist
    c = break_mystring(ilist(inum),delimiter='=') & yname = c(1)
    d = break_mystring(c(1),delimiter='(')
    if (n_elements(d) eq 2) then begin
      yname = d(0) & npanels = npanels + 1
      c = strmid(d(1),0,(strlen(d(1))-1)) ; remove closing quote
      d = break_mystring(c,delimiter=',') ; split into components
       if (n_elements(d) eq 1) then begin  ; just look for the index #
	dvary=0 
	lptrn=1
        if (npanels eq 1) then elist(0) = long(d(0)) $
	else elist = [elist,long(d(0))] ;this extends the size of elist
      endif
    endif
  endif
endfor

; Determine if the zaxis variable is present as an instruction
for inum=0,n_elements(ilist)-1 do begin
  b=strpos(ilist(inum),'z=') & c=strpos(ilist(inum),'Z=') & if c gt b then b=c
  if (b ne -1) then begin ; extract the name of the z variable and elist
    c = break_mystring(ilist(inum),delimiter='=') & zname = c(1)
    d = break_mystring(c(1),delimiter='(')
    if (n_elements(d) eq 2) then begin
      zname = d(0) & npanels = npanels + 1
      c = strmid(d(1),0,(strlen(d(1))-1)) ; remove closing quote
      d = break_mystring(c,delimiter=',') ; split into components
      if (n_elements(d) eq 2) then begin  ; the form is *,n or n,*
        if (d(0) eq '*') then begin & dvary=0 & lptrn=2
          if npanels eq 1 then elist(0) = long(d(1)) $
          else elist = [elist,long(d(1))]
        endif
        if (d(1) eq '*') then begin & dvary=1 & lptrn=1
          if npanels eq 1 then elist(0) = long(d(0)) $
          else elist = [elist,long(d(0))]
        endif
      endif
    endif
  endif
endfor

endif
;TJK 2/14/2002 regardless of what's found in the display_type, we'll 
;initialize the structure and return it.

; initialize the structure which is output from this function
out = {x:xname,y:yname,z:zname,npanels:npanels,$
       dvary:dvary,elist:elist,lptrn:lptrn,igram:igram}
return,out
end







