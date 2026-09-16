FUNCTION timeslice_mystruct,a,tstart,tstop,NOCOPY=NOCOPY,DEBUG=DEBUG

; Convert tstart to DOUBLE if in string format
s = size(tstart) & ns = n_elements(s)
if s(ns-2) eq 7 then tstart = encode_cdfepoch(tstart) $
else if s(ns-2) ne 5 then begin
  print,'ERROR>timeslice:unknown datatype for the tstart parameter!' &
return,a
endif

; Convert tstop to DOUBLE if in string format
s = size(tstop) & ns = n_elements(s)
if s(ns-2) eq 7 then tstop = encode_cdfepoch(tstop) $
else if s(ns-2) ne 5 then begin
  print,'ERROR>timeslice:unknown datatype for the tstop parameter!' &
return,a
endif

; Initialize loop
b = a ; copy the input structure for modification
btags = tag_names(b) & nbtags = n_elements(btags)

; Loop through all variables searching for those typed as CDF_EPOCH.
for i=0,nbtags-1 do begin
  vtags = tag_names(b.(i)) & nvtags = n_elements(vtags)
  if b.(i).CDFTYPE eq 'CDF_EPOCH' then begin
    d = get_mydata(b,i) ; retrieve the timing data
    w = where(d ge tstart,wc) ; locate begining record of time span
    if wc eq 0 then begin
      print,'WARNING>timeslice:no data after tstart!' & return,-1
    endif else rbegin = w(0)
    w = where(d le tstop,wc) ; locate last record of time span
    if wc eq 0 then begin
      print,'WARNING>timeslice:no data before tstop!' & return,-1
    endif else rend = w(n_elements(w)-1)
    if rbegin ge rend then begin
      print,'WARNING>timeslice:no data between tstart and tstop!' &
return,-1
    endif

    ; Subset the variable and plug the data back into a new structure
    if keyword_set(DEBUG) then print,'INFO>timeslice_mystruct>rbegin:rend=',rbegin,rend
    d = d(rbegin:rend)
    if (vtags(nvtags-1) eq 'HANDLE') then begin
      newhandle = handle_create()                 ; create new handle
      handle_value,newhandle,d,/set               ; set handle value
      b = modify_mystruct(b,i,'HANDLE',newhandle) ; modify structure
    endif else b = modify_mystruct(b,i,'DAT',d)

    ; Loop through all variables for those which depend on this variable
    for j=0,nbtags-1 do begin
      ti = tagindex('DEPEND_0',tag_names(b.(j)))
      if ti ne -1 then begin
        if b.(j).DEPEND_0 eq b.(i).VARNAME then begin
          d = get_mydata(b,j) ; retrieve the data
          ds = size(d) & nds = n_elements(ds)
          case ds(0) of ; subset the data
            0: print,'ERROR>timeslice:cannot subset vars with 0 dims!'
            1: d = reform(d(rbegin:rend))
            2: d = reform(d(*,rbegin:rend))
            3: d = reform(d(*,*,rbegin:rend))
            else : print,'ERROR>timeslice:Cannot subset vars with > 3 dims!'
          endcase
          if (vtags(nvtags-1) eq 'HANDLE') then begin
            newhandle = handle_create()                 ; create new handle
            handle_value,newhandle,d,/set               ; set handle value
            b = modify_mystruct(b,j,'HANDLE',newhandle) ; modify structure
          endif else b = modify_mystruct(b,j,'DAT',d)
        endif
      endif
    endfor

  endif
endfor
return,b
end
