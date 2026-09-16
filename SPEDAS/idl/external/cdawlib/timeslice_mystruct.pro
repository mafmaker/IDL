;-----------------------------------------------------------------------------
; Subset all time dependent variables in the structure 'a' to the times
; specified by the tstart and tstop parameters.

function timeslice_mystruct,a,tstart,tstop,$
   START_MSEC=START_MSEC, STOP_MSEC=STOP_MSEC, START_USEC=START_USEC, $ 
   STOP_USEC=STOP_USEC, START_NSEC=START_NSEC, STOP_NSEC=STOP_NSEC, $
   START_PSEC=START_PSEC, STOP_PSEC=STOP_PSEC,$
   NOCOPY=NOCOPY

; Set up an error handler
CATCH, Error_status
if Error_status ne 0 then begin
   print, "STATUS= Error in timeslice_mystruct. "
   print,!ERR_STRING, "timeslice_mystruct" & return,a
endif


; Convert tstart to DOUBLE if in string format
s = size(tstart) & ns = n_elements(s)

ep16 = 0L
if s(ns-2) eq 7 then begin 
  tstart = encode_cdfepoch(tstart)
endif else if((s(ns-2) eq 5) or (s(ns-2) eq 9)) then begin
  if (s(ns-2) eq 9) then ep16=1L
endif else begin
print, 'timeslice: unknown datatype for the tstart parameter'
;following is for running w/ CDFX/widgets only
;  ok = dialog_message(/error, $
;    'timeslice:unknown datatype for the tstart parameter!')
  return,a
endelse

; Convert tstop to DOUBLE if in string format
s = size(tstop) & ns = n_elements(s)
if s(ns-2) eq 7 then begin 
  tstop = encode_cdfepoch(tstop)
endif else if (s(ns-2) eq 5 or s(ns-2) eq 9) then begin
  if (s(ns-2) eq 9) then ep16=1L
endif else begin
print, 'timeslice: unknown datatype for the tstop parameter'
;following is for cdfx/widgets only
;  ok = dialog_message(/error, $
;    'timeslice:unknown datatype for the tstop parameter!')
  return,a
endelse

; Initialize loop
b = a ; copy the input structure for modification
btags = tag_names(b) & nbtags = n_elements(btags)

; Loop through all variables searching for those typed as CDF_EPOCH.
for i=0,nbtags-1 do begin
  vtags = tag_names(b.(i)) & nvtags = n_elements(vtags)

;TJK 10/25/2006 change to check for epoch and epoch16
;TJK 11/16/2006 exclude subsetting the special range_epoch epoch
;variable since it only has two values and is special for THEMIS.
;  if b.(i).CDFTYPE eq 'CDF_EPOCH' then begin
  if ((strpos(b.(i).CDFTYPE, 'CDF_EPOCH') ge 0) and (b.(i).CDFRECVARY eq 'VARY')and strupcase(b.(i).VARNAME) ne 'RANGE_EPOCH') then begin

    epoch = get_mydata(b,i) ; retrieve the timing data
;    w = where(d ge tstart,wc) ; locate begining record of time span
;    if wc eq 0 then begin
;      ok = dialog_message(/error, 'timeslice:no data after tstart!')
;      return,a
;    endif else rbegin = w(0)
     if (!version.release ge '6.2') then begin
        if (ep16) then begin ;if epoch16 value passed in
           valid_recs = lonarr(n_elements(epoch))
           for r = 0L, n_elements(epoch)-1 do begin
             temp_epoch = epoch(r)
             valid_recs(r) = ((cdf_epoch_compare(tstop, temp_epoch) ge 0) and $
                              (cdf_epoch_compare(temp_epoch, tstart) ge 0))
             ;cdf_epoch_compare returns 0 for equal
             ;value and 1 for greater than
           endfor
           v_recs = where(valid_recs eq 1, rec_count)
           valid_recs = v_recs
       endif else $
         valid_recs = where(((epoch le tstop) and (epoch ge tstart)),rec_count)
     endif else begin
       ;original code for regular epoch value
        valid_recs = where(((epoch le tstop) and (epoch ge tstart)),rec_count)
    endelse
;print, 'valid_recs = ',valid_recs
;print, 'epoch = ',epoch

;TJK 11/15/2006 - add the valid_recs check because we have datasets
;where not all variables are populated in a given file.  So this
;checks to make sure there are actually valid recs before trying to
;subset them.

;TJK 08/17/2007 try a slightly different approach when there are NO
;valid records this time (we have themis files that contain a
;different range of times than what they should...

  if (valid_recs(0) ge 0) then begin 
    rbegin = valid_recs(0)
    rend = valid_recs(n_elements(valid_recs)-1)
  endif else begin
      if (valid_recs(0) eq -1) then begin ;no records found
          rbegin = 0
          rend = 0
      endif
  endelse
;Replace the following w/ the above combined logic for start and end
;and also to deal w/ epoch16 data
;    w = where(d le tstop,wc) ; locate last record of time span
;    if wc eq 0 then begin
;      ok = dialog_message(/error, 'timeslice:no data before tstop!')
;      return,a
;    endif else rend = w(n_elements(w)-1)

    ; Subset the variable and plug the data back into a new structure
    epoch = epoch(rbegin:rend)
;print, 'after time filter, epoch = ',epoch
    if (vtags(nvtags-1) eq 'HANDLE') then begin
      newhandle = handle_create()                 ; create new handle
      handle_value,newhandle,epoch,/set               ; set handle value
      b = modify_mystruct(b,i,'HANDLE',newhandle) ; modify structure
    endif else b = modify_mystruct(b,i,'DAT',epoch)

    ; Loop through all variables for those which depend on this variable
    for j=0,nbtags-1 do begin
      ti = tagindex('DEPEND_0',tag_names(b.(j)))
      if ti ne -1 then begin
        if b.(j).DEPEND_0 eq b.(i).VARNAME then begin
          d = get_mydata(b,j) ; retrieve the data
          ds = size(d) & nds = n_elements(ds)
;TJK 8/20/2008 - 
;check to see if the data array (d) is at least as large as the epoch 
;variable that we're using for the time slice, if not, leave it
;alone.  This was needed for the th*_l2_fft data files - most
;variables don't have data in them, but they do have epochs, sometimes...
          ;if (n_elements(d) ge n_elements(epoch)) then begin
	  ; RCJ 06/01/2009  I believe this should be 'gt'.
          if (n_elements(d) gt n_elements(epoch)) then begin
           case ds(0) of ; subset the data
            0: print, 'timeslice: cannot subset vars with 0 dims!'
               ;ok = dialog_message(/error, $
               ;  'timeslice:cannot subset vars with 0 dims!')
            1: d = reform(d(rbegin:rend))
            2: d = reform(d(*,rbegin:rend))
            3: d = reform(d(*,*,rbegin:rend))
            else : print, 'timeslice: cannot subset vars w/ >3 dims!'
                   ;ok = dialog_message(/error, $
                   ; 'timeslice:Cannot subset vars with > 3 dims!')

           endcase
          endif
          if (vtags(nvtags-1) eq 'HANDLE') then begin
            newhandle = handle_create()                 ; create new handle
            handle_value,newhandle,d,/set               ; set handle value
            b = modify_mystruct(b,j,'HANDLE',newhandle) ; modify structure
          endif else b = modify_mystruct(b,j,'DAT',d)
        endif
      endif
    endfor
;   endif ;else begin   ;TJK 11/15/2006 - added to check value of valid_recs
     ; RCJ 08/10/2007 this below doesn't work if we have an additional 
     ;  variable requested which *does*
     ;  contain data within the time range.  This error just prevents the good data
     ;  from being displayed together w/ the bad/absent data.
;     print,'ERROR=Cannot execute timeslice_mystruct: no data within time range' & return,-1 
   ;endelse
endif ;if cdf_epoch variable found
endfor

return,b
end

