; Return TRUE(1) or FALSE(0) if the input parameter looks like one of the
; structures returned by the read_mycdf or restore_mystruct functions.
; RCJ 03/05/2003 Moved this fnc from write_mycdf.pro to here.
FUNCTION ami_mystruct,a
ds = size(a) & nds = n_elements(ds)
if (ds(nds-2) ne 8) then return,0
for i=0,n_elements(tag_names(a))-1 do begin
  ds = size(a.(i)) & nds = n_elements(ds)
  if (ds(nds-2) ne 8) then return,0
  tnames = tag_names(a.(i))
  w = where(tnames eq 'VARNAME',wc1) & w = where(tnames eq 'CDFTYPE',wc2)
  w = where(tnames eq 'HANDLE' ,wc3) & w = where(tnames eq 'DAT',wc4)
  if wc1 eq 0 then return,0
  if wc2 eq 0 then return,0
  if (wc3 + wc4) ne 1 then return,0
endfor
return,1
end

;;-------------------------------------------------------------------------------------

; Given the input data structure and variable name to be plotted as
; thumbnail images, determine the correct window size needed to plot
; all of the images.

FUNCTION evaluate_image_struct,a,vname,$
         THUMBSIZE=THUMBSIZE,XSIZE=XSIZE,COLORBAR=COLORBAR,$
         TSTART=TSTART,TSTOP=TSTOP


; Verify that the first parameter is the properly formatted structure.
if ami_mystruct(a) ne 1 then begin
  print,'ERROR:input param not a properly formatted structure' & return,-1
endif


; Determine the field number associated with the variable 'vname'
w = where(tag_names(a) eq strupcase(vname),wc)
if (wc eq 0) then begin
  print,'ERROR=No variable with the name:',vname,' in structure' & return,-1
endif else vnum = w(0)


; Size the image data in the input structure
tn = tag_names(a.(vnum)) & w = where(tn eq 'DAT',wc)
if wc ne 0 then i = size(a.(vnum).DAT) else i = a.(vnum).idlsize
if i(0) eq 2 then nimages = 1 else nimages = i(i(0))
firstframe = 0 & lastframe = nimages


; Determine which variable in the structure is the 'Epoch' var
tn = tag_names(a.(vnum)) & w = where(tn eq 'DEPEND_0',wc)
if wc ne 0 then begin
  tname = a.(vnum).DEPEND_0 & tnum = tagindex(tname,tag_names(a))
endif else begin
  print,'ERROR:',vname,' is missing DEPEND_0 vattr to point to timetag'
  return,-1
endelse

; Retrieve the timetag data from the structure
;tn = tag_names(a.(tnum)) & w = where(tn eq 'DAT',wc)
tn = tag_names(a.(tnum)) & w = where(tn eq 'DAT',wc)
if wc ne 0 then tdat = a.(tnum).DAT else handle_value,a.(tnum).HANDLE,tdat

; Modify nimages and frame#'s if subsetting by time
if (keyword_set(TSTART) or keyword_set(TSTOP)) then begin
  if keyword_set(TSTART) then begin
    w = where(tdat gt TSTART,wc)
    if wc gt 0 then firstframe = w(0) $
    else begin
      print,'ERROR:No images frames after TSTART.' & return,-1
    endelse
  endif
  if keyword_set(TSTOP) then begin
    w = where(tdat le TSOP,wc)
    if wc gt 0 then lastframe = w(wc-1) $
    else begin
      print,'ERROR:No images frames before TSTOP.' & return,-1
    endelse
  endif
  nimages = lastframe - firstframe & t = 0 ; memory release
endif

; Determine the thumbnail sizes, checking if square or rectangle thumbnails
if keyword_set(THUMBSIZE) then begin & i=size(THUMBSIZE) & j=i(n_elements(i)-2)
  if ((j eq 0)OR(j ge 6)) then begin
    print,'ERROR:THUMBSIZE keyword of illegal data type' & return,-1
  endif
  if i(0) eq 0 then tsizes=[THUMBSIZE,THUMBSIZE]
  if i(0) eq 1 then tsizes=[THUMBSIZE(0),THUMBSIZE(1)]
  if i(0) ge 2 then begin
    print,'ERROR:THUMBSIZE keyword of illegal array size' & return,-1
  endif
endif else tsizes = [50,50] ; default thumbnail size


; Determine width of display set via keyword or by default
if keyword_set(COLORBAR) then xco = 80 else xco = 0
if keyword_set(XSIZE) then begin & i=size(XSIZE) & j=i(n_elements(i)-2)
  if ((j eq 0)OR(j ge 6)) then begin
    print,'ERROR:XSIZE keyword of illegal data type' & return,-1
  endif else xs = XSIZE
endif else xs = 512 ; default window width


; Init other vars to accomodate timetag, title and subtitle fields
timetag_height  = 12 & tsizes(1) = tsizes(1) + timetag_height
title_height    = 15
subtitle_height = 50 ;TJK change from 40 to 50.

 
; Compute the number of rows and columns required to display all images
ncols = (xs-xco) / tsizes(0) & nrows = (nimages / ncols) + 1
ys = (nrows * (tsizes(1) + timetag_height)) + title_height + subtitle_height

; Return a structure containing all sizing information
s = {vnum:vnum,tnum:tnum,tdat:tdat,nimages:nimages,xsize:xs,ysize:ys,$
     nrows:nrows,ncols:ncols,tsizes:tsizes,timetag_height:timetag_height,$
     title_height:title_height,subtitle_height:subtitle_height,$
     firstframe:firstframe,lastframe:lastframe}
return,s
end

