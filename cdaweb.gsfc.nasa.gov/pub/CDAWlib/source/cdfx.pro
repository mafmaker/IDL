
; Return TRUE(1) or FALSE(0) if the input parameter looks like one of the
; structures returned by the read_mycdf or restore_mystruct functions.
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


; Utilize IDL's SAVE procedure to save the structure a into the given filename.
PRO save_mystruct,a,fname
COMMON CDFmySHARE, v0  ,v1, v2, v3, v4, v5, v6, v7, v8, v9,$
                   v10,v11,v12,v13,v14,v15,v16,v17,v18,v19,v20
if tagindex('HANDLE',tag_names(a.(0))) eq -1 then begin
  ; data is stored directly in the structure
  SAVE,a,FILENAME=fname
endif else begin
  ; data is stored in handles.  Retrieve the data from the handles,
  ; and store the data into 'n' local variables, then SAVE.
  tn = tag_names(a) & nt = n_elements(tn) & cmd = 'SAVE,a'
  ; Preallocate some temporary variables.  The EXECUTE command cannot
  ; create new variables...they must already exist.  Lets hope 20 is enough.
  if nt ge 20 then begin
    print,'ERROR> too many handle values in structure to save' & return
  endif
;  v0=0L  & v1=0L  & v2=0L  & v3=0L  & v4=0L  & v5=0L  & v6=0L  & v7=0L
;  v8=0L  & v9=0L  & v10=0L & v11=0L & v12=0L & v13=0L & v14=0L & v15=0L
;  v16=0L & v17=0L & v18=0L & v19=0L & v20=0L
  for i=0,nt-1 do begin ; retrieve each handle value
    order = 'handle_value,a.(i).HANDLE,v' + strtrim(string(i),2)
    status = EXECUTE(order)
    cmd = cmd + ',v' +  strtrim(string(i),2)
  endfor
  ; Add the filename keyword to save command
  cmd = cmd+",FILENAME='"+fname+"'"
  status = execute(cmd) ; execute the save command
endelse
end

FUNCTION restore_mystruct,fname
; declare variables which exist at top level
COMMON CDFmySHARE, v0  ,v1, v2, v3, v4, v5, v6, v7, v8, v9,$
                   v10,v11,v12,v13,v14,v15,v16,v17,v18,v19,v20
; Use the IDL restore feature to reconstruct the anonymous structure a
RESTORE,FILENAME=fname
; The anonymous structure should now be in the variable 'a'.  Determine
; if the structure contains .DAT or .HANDLE fields
ti = tagindex('HANDLE',tag_names(a.(0)))
if ti ne -1 then begin
  tn = tag_names(a) & nt = n_elements(tn) ; determine number of variables
  for i=0,nt-1 do begin
    a.(i).HANDLE = handle_create()
    order = 'handle_value,a.(i).HANDLE,v' + strtrim(string(i),2) + ',/SET'
    status = EXECUTE(order)
  endfor
endif
return,a
end


; Return the data for the given variable in the given structure
FUNCTION get_mydata,a,var
; Determine the variable number
s = size(var) & ns = n_elements(s) & atags = tag_names(a)
if s(ns-2) eq 7 then begin
  w = where(atags eq var,wc)
  if wc gt 0 then vnum = w(0) $
  else begin
    print,'ERROR>get_mydata:named variable not in structure!' & return,-1
  endelse
endif else vnum = var

; Retrieve the data for the variable
vtags = tag_names(a.(vnum))
ti = tagindex('HANDLE',vtags)
if ti ne -1 then handle_value,a.(vnum).handle,d $
else begin
  ti = tagindex('DAT',vtags)
  if ti ne -1 then d = a.(vnum).dat $
  else begin
    print,'ERROR>get_mydata:variable has neither HANDLE or DAT tag!' & return,-1
  endelse
endelse
d = reform(d)
return,d
end


; Return the idl sizing information for the data in the given variable
FUNCTION get_mydatasize, a, var
; Determine the variable number
s = size(var) & ns = n_elements(s) & atags = tag_names(a)
if s(ns-2) eq 7 then begin
  w = where(atags eq var,wc)
  if wc gt 0 then vnum = w(0) $
  else begin
    print,'ERROR>get_mydata:named variable not in structure!' & return,-1
  endelse
endif else vnum = var

; Retrieve the idl sizing information for the variable
vtags = tag_names(a.(vnum))
ti = tagindex('HANDLE',vtags) ; search for handle tag
if ti ne -1 then begin
  ti = tagindex('IDLSIZE',vtags) ; search for idlsize tag
  if ti ne -1 then isize = a.(vnum).IDLSIZE $
  else begin ; must retrieve data to get the size
    handle_value,a.(vnum).handle,d & isize = size(d)
  endelse
endif else begin ; search for dat tag
  ti = tagindex('DAT',vtags)
  if ti ne -1 then isize = size(a.(vnum).dat) $
  else begin
    print,'ERROR>get_mydata:variable has neither HANDLE or DAT tag!' & return,-1
  endelse
endelse
return,isize
end


; Modify the given tag (name or number) in the given variable (name or number)
; in the given structure 'a' with the new value.
FUNCTION modify_mystruct,a,var,tag,value
; Initialize
atags = tag_names(a)

; Determine the variable number and validate
s = size(var) & ns = n_elements(s)
if s(ns-2) eq 7 then begin ; variable is given as a variable name
  w = where(atags eq strupcase(var),wc)
  if wc gt 0 then vnum = w(0) $
  else begin
    print,'ERROR>modify_mystruct:named variable not in structure!' & return,-1
  endelse
endif else begin
  if ((var ge 0)AND(var lt n_elements(atags))) then vnum = var $
  else begin
    print,'ERROR>modify_mystruct:variable# not in structure!' & return,-1
  endelse
endelse
vtags = tag_names(a.(vnum))

; Determine the tag number and validate
s = size(tag) & ns = n_elements(s)
if s(ns-2) eq 7 then begin ; tag is given as a tag name
  w = where(vtags eq strupcase(tag),wc)
  if wc gt 0 then tnum = w(0) $
  else begin
    print,'ERROR>modify_mystruct:named tag not in structure!' & return,-1
  endelse
endif else begin
  if ((tag ge 0)AND(tag lt n_elements(vtags))) then tnum = tag $
  else begin
    print,'ERROR>modify_mystruct:tag# not in structure!' & return,-1
  endelse
endelse

; Create and return new structure with only the one field modified
for i=0,n_elements(atags)-1 do begin ; loop through every variable
  if (i ne vnum) then b = a.(i) $ ; no changes to this variable
  else begin ; must handle this variable field by field
    tnames = tag_names(a.(i))
    for j=0,n_elements(tnames)-1 do begin
      if (j ne tnum) then c = create_struct(tnames(j),a.(i).(j)) $ ; no changes
      else c = create_struct(tnames(j),value) ; new value for this field
      ; Add the structure 'c' to the substructure 'b'
      if (j eq 0) then b = c $ ; create initial structure
      else b = create_struct(b,c) ; append to existing structure
    endfor
  endelse
  ; Add the substructure 'b' to the megastructure
  if (i eq 0) then aa = create_struct(atags(i),b) $ create initial structure
  else begin ; append to existing structure
    c = create_struct(atags(i),b) & aa = create_struct(aa,c)
  endelse
endfor
return,aa
end


; Subset all time dependent variables in the structure 'a' to the times
; specified by the tstart and tstop parameters.
FUNCTION timeslice_mystruct,a,tstart,tstop,NOCOPY=NOCOPY

; Convert tstart to DOUBLE if in string format
s = size(tstart) & ns = n_elements(s)
if s(ns-2) eq 7 then tstart = encode_cdfepoch(tstart) $
else if s(ns-2) ne 5 then begin
  print,'ERROR>timeslice:unknown datatype for the tstart parameter!' & return,a
endif

; Convert tstop to DOUBLE if in string format
s = size(tstop) & ns = n_elements(s)
if s(ns-2) eq 7 then tstop = encode_cdfepoch(tstop) $
else if s(ns-2) ne 5 then begin
  print,'ERROR>timeslice:unknown datatype for the tstop parameter!' & return,a
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
      print,'ERROR>timeslice:no data after tstart!' & return,a
    endif else rbegin = w(0)
    w = where(d le tstop,wc) ; locate last record of time span
    if wc eq 0 then begin
      print,'ERROR>timeslice:no data before tstop!' & return,a
    endif else rend = w(n_elements(w)-1)

    ; Subset the variable and plug the data back into a new structure
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


; Prior to destroying or deleting one of the anonymous structures, determine
; if any data handles exists, and if so, free them.
PRO delete_myhandles,a
for i=0,n_elements(tag_names(a))-1 do begin
  ti = tagindex('HANDLE',tag_names(a.(i)))
  if ti ne -1 then begin
    b = handle_info(a.(i).HANDLE,/valid_id)
    if b eq 1 then handle_free,a.(i).HANDLE
  endif
endfor
end


FUNCTION compare_vars, a, b
sa = size(a) & nsa = n_elements(sa)
sb = size(b) & nsb = n_elements(sb)
if (nsa ne nsb) then return,0
for i=0,nsa-1 do if (sa(i) ne sb(i)) then return,0
case sa(0) of
  0    : if (a ne b) then return,0
  1    : for i=0,sa(1)-1 do if (a(i) ne b(i)) then return,0
  2    : begin
         for i=0,sa(1)-1 do begin
           for j=0,sa(2)-1 do if (a(i,j) ne b(i,j)) then return,0
         endfor
         end
  else : print,'WARNING>cannot yet compare vars with > 2 dimensions!'
endcase
return,1
end

; Determine all information about the variable in the varstruct parameter,
; which is required in order to create the variable in a CDF file
FUNCTION create_myCDF_variable,id,varstruct,DEBUG=DEBUG
vid = -1
vname = varstruct.VARNAME ; Determine the name of the variable
; Determine IDL sizing information about the data
ti = tagindex('HANDLE',tag_names(varstruct))
if ti ne -1 then begin
  handle_value,varstruct.HANDLE,d & c = size(d)
endif else begin
  d = varstruct.DAT & c = size(d)
endelse
nc = n_elements(c)

; Determine if this variable is RV or NRV
nrv = 0L & rv = 0L ; initialize
ti = tagindex('VAR_TYPE',tag_names(varstruct))
if (ti ne -1) then begin ; var_type is present
  if (strupcase(varstruct.VAR_TYPE) eq 'METADATA') then nrv=1L else rv=1L
endif else rv=1L ; assume RV

; Determine the dimensionality and the data type based on record variance
if (rv eq 1L) then begin
  case c(0) of
    0   : print,'ERROR>size of data cannot be 0! - write_mycdf internal error'
    1   : begin & dims = 0L & dvar=[0] & end
    2   : begin & dims = c(1) & dvar=[1] & end
    3   : begin & dims = [c(1),c(2)] & dvar=[1,1] & end
    4   : begin & dims = [c(1),c(2),c(3)] & dvar=[1,1,1] & end
    else: print,'WARNING>cannot write cdfs with vars with > 3 dimensions!'
  endcase
endif
if (nrv eq 1L) then begin
  case c(0) of
    0   : print,'ERROR>size of data cannot be 0! - write_mycdf internal error'
    1   : begin & dims = c(1) & dvar=[1] & end
    2   : begin & dims = [c(1),c(2)] & dvar=[1,1] & end
    3   : begin & dims = [c(1),c(2),c(3)] & dvar=[1,1,1] & end
    else: print,'WARNING>cannot write cdfs with vars with > 3 dimensions!'
  endcase
endif

; Determine the type of the CDF variable
dtype = lonarr(14) & nelems=1L ; initialize
case c(nc-2) of
  0   : print,'ERROR>Undefined data type'
  1   : dtype(0) = 1L ; cdf_byte
  2   : dtype(6) = 1L ; cdf_int2
  3   : dtype(7) = 1L ; cdf_int4
  4   : dtype(8) = 1L ; cdf_real4
  5   : begin ; determine if it is real8 or epoch
          if varstruct.CDFTYPE eq 'CDF_EPOCH' then dtype(3) = 1L $
          else dtype(9) = 1L ; cdf_real8
        end
  6   : print,'WARNING>CDF does not have complex_float type'
  7   : begin ; cdf_char
          dtype(1) = 1L
          nelems = strlen(d(0))
        end
  8   : print,'WARNING>CDF does not have structure type'
  9   : print,'WARNING>CDF does not have double_complex_float type'
  else: print,'ERROR>Unknown IDL data type'
endcase

; Create the variable
if keyword_set(DEBUG) then begin
  print,'creating the variable:',vname
  print,'rv=  ',rv,  ' nrv=  ',nrv,' nelems=',nelems
  print,'dims=',dims,' dvary=',dvar
endif
if (dims(0) eq 0) then begin
  vid = cdf_varcreate(id,vname,/ZVARIABLE,NUMELEM=nelems,$
        CDF_BYTE=dtype(0),CDF_CHAR=dtype(1),CDF_DOUBLE=dtype(2),$
        CDF_EPOCH=dtype(3),CDF_FLOAT=dtype(4),CDF_INT1=dtype(5),$
        CDF_INT2=dtype(6),CDF_INT4=dtype(7),CDF_REAL4=dtype(8),$
        CDF_REAL8=dtype(9),CDF_UCHAR=dtype(10),CDF_UINT1=dtype(11),$
        CDF_UINT2=dtype(12),CDF_UINT4=dtype(13),$
        REC_NOVARY=nrv,REC_VARY=rv)
endif else begin
  vid = cdf_varcreate(id,vname,dvar,DIMENSIONS=dims,NUMELEM=nelems,$
        CDF_BYTE=dtype(0),CDF_CHAR=dtype(1),CDF_DOUBLE=dtype(2),$
        CDF_EPOCH=dtype(3),CDF_FLOAT=dtype(4),CDF_INT1=dtype(5),$
        CDF_INT2=dtype(6),CDF_INT4=dtype(7),CDF_REAL4=dtype(8),$
        CDF_REAL8=dtype(9),CDF_UCHAR=dtype(10),CDF_UINT1=dtype(11),$
        CDF_UINT2=dtype(12),CDF_UINT4=dtype(13),$
        REC_NOVARY=nrv,REC_VARY=rv)
endelse

; write the data into the cdf with special handling for character data
if c(nc-2) ne 7 then cdf_varput,id,vname,d $
else begin ; special processing for character data
  if ((c(0) eq 0)AND(d(0) ne '')) then cdf_varput,id,vname,d $
  else begin ; data is a string array
    ; pad all elements to same length and concatenate into single buffer
    maxlength = max(strlen(d)) & buffer = ''
    for j=0,c(1)-1 do begin
      if strlen(d(j)) eq maxlength then buffer = buffer + d(j) $
      else begin
        pad = '' & for g=0,(strlen(d(j))-maxlength)-1 do pad = pad + ' '
        buffer = buffer + d(j) + pad
      endelse
    endfor
    cdf_varput,id,vname,buffer,OFFSET=[0],COUNT=[c(1)]
  endelse
endelse

return,vid
end


; This package of routines complements the read_myCDF package.  read_myCDF
; reads one or more cdf's, and returns all data and metadata as a single
; structure.  write_myCDF will do just the opposite, given a similar structure,
; it will write a cdf.

FUNCTION write_myCDF, a, filename, DEBUG=DEBUG

; Identify the global attributes.
b = tag_names(a.(0)) & w = where(b eq 'FIELDNAM',wc) & gattrs=indgen(w(0)-1)+1

; Determine the order of the variables to be written to the CDF.
b = tag_names(a) & nb = n_elements(b) & c = intarr(nb)
for i=0,nb-1 do begin
  if a.(i).CDFTYPE eq 'CDF_EPOCH' then c(i) = 2 $ ; time variable
  else if strupcase(a.(i).VAR_TYPE) eq 'DATA' then c(i) = 1 ; RV variable
endfor
s=sort(c) & d=indgen(nb) & order=d(reverse(s))

; Create the new CDF
if keyword_set(DEBUG) then print,'Now creating the CDF...'
id = cdf_create(filename,/NETWORK_ENCODING,/SINGLE_FILE)

; Write global attributes to the CDF
if keyword_set(DEBUG) then print,'Writing global attributes to the CDF...'
b = tag_names(a.(0)) ; get names of attributes
for i=0,n_elements(gattrs)-1 do begin
  aid = cdf_attcreate(id,b(gattrs(i)),/GLOBAL_SCOPE) ; create the attribute
  ; Now put the proper value in the attribute
  s = size(a.(0).(gattrs(i))) & ns = n_elements(s) & c=''
  if (s(ns-2) eq 7) then begin ; special case for string handling
    if s(0) eq 0 then begin
      c = a.(0).(gattrs(i)) & if c ne '' then cdf_attput,id,aid,0L,c
    endif else begin
      for j=0,s(1)-1 do begin
        c = a.(0).(gattrs(i))(j) & cdf_attput,id,aid,j,c
      endfor
    endelse
  endif else cdf_attput,id,aid,0L,a.(0).(gattrs(i))
endfor

; Create the variables
for i=0,n_elements(order)-1 do begin
  b = order(i) & vname = a.(b).VARNAME
  if keyword_set(DEBUG) then print,'Creating the variable:',vname
  vid = create_myCDF_variable(id, a.(b))
endfor ; create and write all variables


; Write the variable attributes to the CDF
for i=0,n_elements(tag_names(a))-1 do begin ; loop through every variable
  vname = a.(i).VARNAME ; get the case sensitive variable name
  vtags = tag_names(a.(i)) ; get the attribute names
  from = tagindex('FIELDNAM',vtags) ; fieldnam is the first vattr
  to   = tagindex('CDFTYPE' ,vtags) ; cdftype is the next non-vattr
  for j=from,to-1 do begin ; process each variable attribute
    if i eq 0 then aid = cdf_attcreate(id,vtags(j),/VARIABLE_SCOPE) $
    else aid = cdf_attnum(id,vtags(j)) ; get id of existing attribute
    ; Special processing is required for ISTP-stype pointer attributes.
    ; If the current attribute is such an attribute, do not process it here.
    if (amI_ISTPptr(vtags(j)) ne 1) then begin
      s = size(a.(i).(j)) & ns = n_elements(s)
      if (s(ns-2) ne 7) then cdf_attput,id,aid,vname,a.(i).(j) $
      else begin ; special processing for character data
        if s(0) eq 0 then begin
          e = a.(i).(j) & if e ne '' then cdf_attput,id,aid,vname,e
        endif else begin ; data is a string array
          print,'WARNING: ',vtags(j),' vattr not written because of IDL bug!'
        endelse
      endelse
    endif
    endfor
endfor

; Perform special processing for ISTP pointer-type attributes.  When such an
; attribute is located, a new metadata variable may have to be created.
mvcount = 0L
for i=0,n_elements(tag_names(a))-1 do begin ; loop through every variable
  vtags = tag_names(a.(i)) ; get the name of every attribute
  for j=0,n_elements(vtags)-1 do begin
    if ((amI_ISTPptr(vtags(j)) eq 1)AND(a.(i).(j)(0) ne '')) then begin

      pvar = -1 ; determine if identical value has already been encountered
      for g=0,mvcount-1 do begin
        if compare_vars(a.(i).(j),a.(pv(g)).(pt(g))) eq 1 then pvar = g ; same
      endfor

      if (pvar eq -1) then begin ; MUST CREATE NEW VARIABLE
        ; determine the name for new variable
        vname = 'metavar' + strtrim(string(mvcount),2)
        ; create a variable structure
        va = create_struct('VARNAME',vname)
        vb = create_struct('VAR_TYPE','metadata')
        vc = create_struct('DAT',a.(i).(j))
        v  = create_struct(va,vb) & v = create_struct(v,vc)
        ; create the new variable in the CDF
        vid = create_myCDF_variable(id, v)
        cdf_attput,id,'VAR_TYPE',vname,'metadata'
        cdf_attput,id,'FIELDNAM',vname,vname
      endif else vname = a.(pvar).VARNAME

      ; point to the new variable via the istp pointer attribute
      cdf_attput,id,vtags(j),a.(i).VARNAME,vname

      ; record the variable number and tag number of this attribute
      if mvcount eq 0 then begin
        pv = i & pt = j
      endif else begin
        pv = [pv,i] & pt = [pt,j]
      endelse
      mvcount = mvcount + 1 ; increment metavariable count
    endif
  endfor
endfor

; Close the new CDF
cdf_close,id

return,0
end



PRO WindowList_Event, event
  if tag_names(event,/struct) eq 'WIDGET_LIST' then begin
    widget_control,event.id,get_uvalue=wids
    widget_control,wids(event.index),/show
  endif
  widget_control,event.top,/destroy
end

PRO WindowList
COMMON cdfxcom, CDFxwindows, CDFxprefs ; include the cdfx common
if XRegistered('WindowList') then return ; only one window list allowed
; Create list of realized window names
w = where(cdfxwindows.title ne '',wc)
if (wc gt 0) then begin
  wlist = cdfxwindows.title(w)
  wwids = cdfxwindows.wid(w)

  base1 = widget_base(/Column,Title='Open Windows')
  labl1 = widget_label(base1,value='Select Window')
  list1 = widget_list(base1,value=wlist,Ysize=10,uvalue=wwids)
  butn1 = widget_button(base1,value='Cancel')
  widget_control,base1,/realize
  Xmanager,'WindowList',base1,Event='WindowList_Event'
endif
end

PRO add_cdfxwindow, title, wid
COMMON cdfxcom, CDFxwindows, CDFxprefs ; include the cdfx common
w = where(CDFxwindows.title eq '',wc) & if (wc eq 0) then w=0
CDFxwindows.title(w(0)) = title
CDFxwindows.wid(w(0))   = wid
end

PRO remove_cdfxwindow,TITLE=TITLE,WID=WID
COMMON cdfxcom, CDFxwindows, CDFxprefs ; include the cdfx common
if keyword_set(TITLE) then begin
  w = where(CDFxwindows.title eq TITLE,wc)
  if (wc gt 0) then begin
    CDFxwindows.title(w(0)) = '' & CDFxwindows.wid(w(0)) = 0
  endif
endif
if keyword_set(WID) then begin
  w = where(CDFxwindows.wid eq WID,wc)
  if (wc gt 0) then begin
    CDFxwindows.title(w(0)) = '' & CDFxwindows.wid(w(0)) = 0
  endif
endif
end

PRO Restore_Objects_Event, event
COMMON cdfxcom, CDFxwindows, CDFxprefs ; include cdfx common
widget_control,event.top,get_uvalue=info
case event.id of
  info.ALL     : begin
                 widget_control,info.LIST,get_value=bvals
                 for i=0,n_elements(bvals)-1 do bvals(i)=1
                 widget_control,info.LIST,set_value=bvals
                 end
  info.NONE    : begin
                 widget_control,info.LIST,get_value=bvals
                 for i=0,n_elements(bvals)-1 do bvals(i)=0
                 widget_control,info.LIST,set_value=bvals
                 end
  info.CANCEL  : widget_control,event.top,/DESTROY
  info.RESTORE : begin
                 widget_control,info.LIST,get_value=bvals
                 for i=0,n_elements(bvals)-1 do begin
                   if (bvals(i) eq 1) then begin
                     widget_control,/hourglass
                     a = restore_mystruct(info.fnames(i))
                     cdfx_dataobject,a,GROUP=cdfxwindows.wid(0)
                     a=0 ; free the memory
                   endif
                 endfor
                 widget_control,event.top,/DESTROY
                 end
  else :         ; do nothing
endcase
end


PRO cdfx_ROCBox, wid
  remove_cdfxwindow,WID=wid
end


; Create a window to allow the user to restore saved data objects
PRO restore_dataobjects, GROUP=GROUP
fnames = findfile('*.sav')
if (fnames(0) eq '') then begin
  print,'No data objects found.  Unable to restore.' & return
endif
bvals = lonarr(n_elements(fnames)) & scroll=0 & ysize=0
if (n_elements(fnames) gt 10) then begin & scroll=1 & ysize=20 & endif

; Create the widget
base1 = widget_base(/Column,Title='Restore Data Objects',/frame)
lab1a = widget_label(base1,value='Select the data objects to')
lab1b = widget_label(base1,value='be restored as an x-window')
if n_elements(fnames) le 15 then begin
  list1 = CW_BGROUP(base1,fnames,/NONEXCLUSIVE,$
                    SET_VALUE=bvals,/FRAME)
endif else begin
  list1 = CW_BGROUP(base1,fnames,/NONEXCLUSIVE,SCROLL=scroll,SET_VALUE=bvals,$
                    X_SCROLL_SIZE=200,Y_SCROLL_SIZE=200,/FRAME)
endelse
base2 = widget_base(base1,/Row)
base3 = widget_base(base1,/Row)
but2a = widget_button(base2,value='Select All')
but2b = widget_button(base2,value='Select None')
but3a = widget_button(base3,value='Cancel')
but3b = widget_button(base3,value='RESTORE')

; Register this data object into the main window list
add_cdfxwindow,'Restore Objects',base1

; Save the widget id's of the buttons and list of this widget
info={LIST:list1,ALL:but2a,NONE:but2b,CANCEL:but3a,RESTORE:but3b,FNAMES:fnames}
widget_control,base1,set_uvalue=info

; Realize the data object
widget_control,base1,/realize
Xmanager,'Restore Objects',base1,Event='Restore_Objects_Event',$
         GROUP=GROUP,Cleanup='cdfx_ROCBox'
end


PRO cdfx_timeslice_Event, event
  ; Point to the common block containing window information
  COMMON cdfxcom, CDFxwindows, CDFxprefs ; include cdfx common
  etype = widget_info(event.id,/type) ; get event type
  child = widget_info(event.top,/child) ; get id of first child
  widget_control,child,get_uvalue=info  ; get id's of all widgets
  case etype of
    1 : begin ; button event
        case event.id of
          info.HELP   : print,'NOT YET HELPING'
          info.CANCEL                                     : begin
               remove_cdfxwindow,WID=event.id
               widget_control,event.top,/destroy
               end
          info.SAVE                                       : begin
               widget_control,info.slid1,get_value=v1
               widget_control,info.slid2,get_value=v2
               ; validate values on the sliders
               if v1 gt v2 then begin
                 print,'Start Time must be BEFORE Stop Time!' & return
               endif
               if (v1 eq 0)AND(v2 eq (n_elements(info.time)-1)) then begin
                 print,'No change to start and stop times' & return
               endif
               ; Perform the time subsetting
               widget_control,event.top,get_uvalue=a
               widget_control,/hourglass
               b = timeslice_mystruct(a,info.time(v1),info.time(v2))
               ; Create a new data object with the subsetted data
               cdfx_dataobject,b,GROUP=cdfxwindows.wid(0)
               ; Destroy the timeslice widget
               remove_cdfxwindow,WID=event.id
               widget_control,event.top,/destroy
               end
        endcase
        end
    2 : begin ; slider event
        if event.id eq info.slid1 then begin ; start time slider
          s = decode_cdfepoch(info.time(event.value))
          widget_control,info.labl1,set_value=s
        endif else begin ; stop time slider
          s = decode_cdfepoch(info.time(event.value))
          widget_control,info.labl2,set_value=s
        endelse
        end
    else : ; do nothing
  endcase
end


PRO cdfx_timesliceCBox, wid
  remove_cdfxwindow,WID=wid
end


; Provide a widget interface to subset the given structure by time
PRO cdfx_timeslice, a, GROUP=GROUP

; Point to the common block containing window information
COMMON cdfxcom, CDFxwindows, CDFxprefs ; include cdfx common

; Determine a variable that contains the timing information
atags = tag_names(a) & tvar = -1
for i=0,n_elements(atags)-1 do begin
  btags = tag_names(a.(i)) & w = where(btags eq 'CDFTYPE',wc)
  if (wc gt 0) then if (a.(i).CDFTYPE eq 'CDF_EPOCH') then tvar = i
endfor
if tvar eq -1 then begin
  print,'ERROR>cdfx_timeslice: Unable to locate time variable!' & return
endif else ttags = tag_names(a.(tvar))

; Retrieve the timing data
ti = tagindex('HANDLE',ttags)
if ti ne -1 then handle_value,a.(tvar).HANDLE,d $
else begin
  ti = tagindex('DAT',ttags)
  if ti ne -1 then d = a.(tvar).DAT $
  else begin
    print,'ERROR>cdfx_timeslice:time var has no HANDLE or DAT tag!' & return
  endelse
endelse

; Validate the dimensionality of the time data
ds = size(d) & nds = n_elements(ds)
if ds(0) ne 1 then begin
  print,'ERROR>cdfx_timeslice:Epoch var is not an array!' & return
endif
if ds(nds-2) ne 5 then begin
  print,'ERROR>cdfx_timeslice:Epoch var is not DOUBLE float!' & return
endif
nd = n_elements(d)

; Determine the letter of the object being sliced
child = widget_info(GROUP,/child) & widget_control,child,get_uvalue=info
letter = info.letter & wtitle = 'Time Filter: Object '+letter

; Prepare instructions
m0 = 'Adjust the start and stop sliders to modify the time range  '
m1 = 'of all of the variables in the Data Object.  Click the SAVE '
m2 = 'button to create a new Data Object.  Click the CANCEL button'
m3 = 'to exit without changing the Data Object.                   '

; Create widget interface
base  = widget_base(/Column,Title=wtitle,/frame)
base0 = widget_base(base,/Column)
lab0a = widget_label(base0,value=m0)
lab0b = widget_label(base0,value=m1)
lab0c = widget_label(base0,value=m2)
lab0d = widget_label(base0,value=m3)
base1 = widget_base(base,/Row)
base2 = widget_base(base,/Row)
base3 = widget_base(base,/Row,/frame)
slid1 = widget_slider(base1,max=(nd-1),value=0,Title='Start Time',$
                      xsize=250,/drag)
labl1 = widget_label(base1,value=decode_cdfepoch(d(0)))
slid2 = widget_slider(base2,max=(nd-1),value=(nd-1),Title='Stop Time',$
                      xsize=250,/drag)
labl2 = widget_label(base2,value=decode_cdfepoch(d(nd-1)))
but3a = widget_button(base3,value='Save')
but3b = widget_button(base3,value='Cancel')
but3c = widget_button(base3,value='Help')

; Register the main menu into the window list and save in the cdfx common
add_cdfxwindow,wtitle,base

; Save the widget id's and time data for use in the event handler
junk = {slid1:slid1,labl1:labl1,slid2:slid2,labl2:labl2,$
        save:but3a,cancel:but3b,help:but3c,time:d}
child = widget_info(base,/child) ; get widget id of first child
widget_control,child,set_uvalue=junk ; save widget ids and time data

; Save the input structure in the base user value
widget_control,base,set_uvalue=a & a=0

; Realize and manage the window
widget_control,base,/realize
Xmanager,'TimeSlice',base,Event='cdfx_timeslice_Event',$
         GROUP=GROUP,Cleanup='cdfx_timesliceCBox'
end


FUNCTION generate_varlist,a,ALL=ALL
; Create list of variables given the megastructure 'a'
atags = tag_names(a) & vnames = ''
for i=0,n_elements(atags)-1 do begin
  btags = tag_names(a.(i)) & d='DATA' & f='' & c=''
  w = where(btags eq 'VAR_TYPE',wc) & if (wc gt 0) then d = a.(i).(w(0))
  w = where(btags eq 'FIELDNAM',wc) & if (wc gt 0) then f = a.(i).(w(0))
  w = where(btags eq 'CATDESC',wc)  & if (wc gt 0) then c = a.(i).(w(0))
  if (keyword_set(ALL)) OR (strupcase(d) eq 'DATA') then begin
    if (vnames(0) eq '') then vnames(0) = (atags(i) + ' :' + f) $
    else vnames = [vnames,(atags(i) + ' :' + f)]
  endif
endfor
return,vnames
end


PRO cdfx_editvattrs_Event,event
wtype = widget_info(event.id,/NAME) ; get name of widget type
case wtype of
  'BUTTON': begin
            widget_control,event.id,get_value=bname
            case bname of
              'Edit'   : begin
                         child = widget_info(event.top,/child)
                         widget_control,child,get_uvalue=junk
                         widget_control,event.top,get_uvalue=a
                         widget_control,/hourglass
                         ti = tagindex(junk.vname,tag_names(a))
                         vi = junk.first_vattr + junk.list
                         b = a.(ti).(vi) & c=b
                         xvaredit,b
                         ; determine if attr value has been changed
                         nb = n_elements(b) & new = 0
                         if nb eq 1 then begin
                           if b ne c then new = 1
                         endif else begin
                           for i=0,nb-1 do if b(i) ne c(i) then new = 1
                         endelse
                         ; if attr has changed then process the new attribute
                         if new eq 1 then begin
                           a.(ti).(vi) = b
                           ; regenerate the list of attributes
                           vtags = tag_names(a.(ti)) & text = ''
                           for i=0,n_elements(vtags)-1 do begin
                             b = a.(ti).(i) & h = gethelp('b')
                             strput,h,vtags(i),0 & text = [text,h]
                           endfor
                           text=text((junk.first_vattr+1):(n_elements(vtags)-2))
                           widget_control,event.top,set_uvalue=a
                           widget_control,junk.listwid,set_value=text
                           widget_control,junk.cbut,sensitive=1
                           widget_control,junk.sbut,sensitive=1
                         endif
                         end
              'Cancel' : widget_control,event.top,/destroy
              'Save'   : begin
                         child = widget_info(event.top,/child)
                         widget_control,child,get_uvalue=junk
                         widget_control,event.top,get_uvalue=a
                         widget_control,junk.objectwid,set_uvalue=a
                         widget_control,event.top,/destroy
                         end
              'Help'   : print,'helping is TBD'
              else     : print,'ERROR>editvattrs: unknown button name!'
            endcase
            end
  'LIST'  : begin
            child = widget_info(event.top,/child)
            widget_control,child,get_uvalue=junk
            junk.list = event.index ; save current attribute index
            widget_control,junk.ebut,sensitive=1 ; sensitize edit button
            widget_control,child,set_uvalue=junk
            end
  else    : print,'ERROR>cdfx_editvattrs: unknown event type!'
endcase
end

PRO cdfx_editvattrsCBox,wid
  remove_cdfxwindow,wid=wid
end

; Display all variable attributes for the given variable in the given struct.
; Allow the user to modify the values of these attributes.
PRO cdfx_editvattrs, a, vname, GROUP=GROUP

; Point to the common block containing window information
COMMON cdfxcom, CDFxwindows, CDFxprefs ; include cdfx common

; Validate the input parameters
; Validation TBD

; Initialize
text1 = '' & text2 = ''

; Locate the variable given by 'vname' in the structure 'a'
atags = tag_names(a) & natags = n_elements(atags) & v = tagindex(vname,atags)
if (v eq -1) then begin
  print,'ERROR>cdfx_editvattrs:named variable not in input structure' & return
endif else vtags = tag_names(a.(v))

; Retrieve the data and determine its idl size information
ti = tagindex('HANDLE',vtags)
if (ti ne -1) then handle_value,a.(v).HANDLE,d $
else begin
  ti = tagindex('DAT',vtags)
  if (ti ne -1) then d = a.(v).DAT $
  else begin
    print,'ERROR>cdfx_showstats:variable has no .DAT or .HANDLE tag!' & return
  endelse
endelse
ds = size(d) & nds = n_elements(ds)

; Capture type and dimensionality information
h = gethelp('d') & h = strtrim(strmid(h(0),1,strlen(h(0))-1),2)
s = str_sep(h(0),'=') & text1 = 'Variable name : ' + a.(v).VARNAME
text1 = [text1,('Variable type : ' + strtrim(s(0),2))]
text1 = [text1,('Dimensionality: ' + strtrim(s(1),2))]
d = 0L ; delete the data to same memory

; Construct another text array about the variable attributes
for i=0,n_elements(vtags)-1 do begin
  b = a.(v).(i) & h = gethelp('b')
  strput,h,vtags(i),0 & text2 = [text2,h]
endfor

; Slice out the variable attributes out of the text string array
fi = tagindex('FIELDNAM',vtags)
if (fi eq -1) then begin
  print,'ERROR>cdfx_editvattrs:missing required vattr:FIELDNAM. ' & return
endif else text2 = text2((fi+1):(n_elements(vtags)-2))

; list width and height needed for good layout
twidth = max(strlen(text1)) & theight = n_elements(text1)
lwidth = max(strlen(text2)) & lheight = n_elements(text2)
if lheight gt 25 then lheight = 25
if lwidth  gt 80 then lwidth  = 80

; Create a widget to display the information
base  = widget_base(/Column,Title=('Variable Attributes: '+vname),$
                    /frame,uvalue=a)
base1 = widget_base(base,/Column)
base2 = widget_base(base,/Column)
base3 = widget_base(base,/Row,/frame)
text1 = widget_text(base1,value=text1,ysize=theight,xsize=twidth)
list2 = widget_list(base2,value=text2,ysize=lheight,xsize=lwidth,/frame)
but3a = widget_button(base3,value='Edit')
but3b = widget_button(base3,value='Cancel')
but3c = widget_button(base3,value='Save')
but3d = widget_button(base3,value='Help')

; Register the main menu into the window list and save in the cdfx common
add_cdfxwindow,('Variable Attributes: ' + vname),base

; save required information in a structure in the first child widget
junk = {ebut:but3a,cbut:but3b,sbut:but3c,hbut:but3d,vname:vname,$
        list:-1L,first_vattr:fi,listwid:list2,objectwid:GROUP}
child = widget_info(base,/child) & widget_control,child,set_uvalue=junk
widget_control,but3a,sensitive=0 ; desensitize edit button
widget_control,but3b,sensitive=0 ; desensitize cancel button
widget_control,but3c,sensitive=0 ; desensitize save button

; Realize and manage the window
widget_control,base,/realize
Xmanager,'VarAttrs',base,Event='cdfx_editvattrs_Event',$
         GROUP=GROUP,Cleanup='cdfx_editvattrsCBox'

end


PRO cdfx_showstats_Event, event
  print,'No events for showstats'
end

PRO cdfx_showstatsCBox,wid
  remove_cdfxwindow,wid=wid
end

; Compute and display pertinent statistical information about the variable
; contained in the structure a, in a non-editable text widget.
PRO cdfx_showstats, a, GROUP=GROUP

; Point to the common block containing window information
COMMON cdfxcom, CDFxwindows, CDFxprefs ; include cdfx common

; Initialize
text = ''

; Verify that a is a record varying structure
as = size(a) & nas = n_elements(as)
if (as(nas-2) ne 8) then begin
  print,'ERROR>cdfx_showstats:input parameter is not a structure.' & return
endif else atags = tag_names(a)
ti = tagindex('VAR_TYPE',atags)
if (ti ne -1) then begin
  if strupcase(a.VAR_TYPE eq 'METADATA') then begin
    print,'CAN ONLY PRODUCE STATS FOR RECORD VARYING VARIABLES!' & return
  endif
endif


; Retrieve the data and determine its idl size information
ti = tagindex('HANDLE',atags)
if (ti ne -1) then handle_value,a.HANDLE,d $
else begin
  ti = tagindex('DAT',atags)
  if (ti ne -1) then d = a.DAT $
  else begin
    print,'ERROR>cdfx_showstats:variable has no .DAT or .HANDLE tag!' & return
  endelse
endelse
d = reform(d) & ds = size(d) & nds = n_elements(ds)

; Verify that the data is not character data
if ds(nds-2) eq 7 then begin
  print,'ERROR>cdfx_showstats:no status for character data.' & return
endif

; Capture type and dimensionality information
h = gethelp('d') & h = strtrim(strmid(h(0),1,strlen(h(0))-1),2)
s = str_sep(h(0),'=') & text = 'Variable name : ' + a.VARNAME
text = [text,('Variable type : ' + strtrim(s(0),2))]
text = [text,('Dimensionality: ' + strtrim(s(1),2))]

; Determine the fill value if one exists
ti = tagindex('FILLVAL',tag_names(a))
if (ti ne -1) then fill = a.FILLVAL else fill = 'n/a'
s = 'fill value=' + string(fill)
text = [text,' '] & text = [text,s]

; Compute statistics
if ds(0) eq 1 then begin ; variable is record-varying scalar
  w = where(d eq fill,fc) & w = where(d ne fill,wc)
  if (wc ne 0) then d = d(w) ; filter out fill values
  dmin = min(d) & dmax = max(d)
  davg = total(d)/n_elements(d)
  text = [text,('fill count= ' + string(fc))]
  text = [text,('minimum   = ' + string(dmin))]
  text = [text,('maximum   = ' + string(dmax))]
  text = [text,('average   = ' + string(davg))]
endif
if ds(0) eq 2 then begin ; variable is record-varying vector
  w = where(d eq fill,fc) & w = where(d ne fill,wc)
  if (wc ne 0) then e = d(w) ; filter out fill values
  dmin = min(e) & dmax = max(e)
  davg = total(e)/n_elements(e) & e=0
  text = [text,('fill count= ' + strtrim(string(fc),2))]
  text = [text,('minimum   = ' + strtrim(string(dmin),2))]
  text = [text,('maximum   = ' + strtrim(string(dmax),2))]
  text = [text,('average   = ' + strtrim(string(davg),2))]
  text = [text,' '] & text = [text,' Element by Element Checking:']
  ; get stats for each element of vector
  for i=0,ds(1)-1 do begin
    e = d(i,*) & w = where(e eq fill,fc)
    w = where(e ne fill,wc) & if (wc ne 0) then e = e(w) ; filter out fills
    dmin = min(e) & dmax = max(e) & davg = total(e)/n_elements(e) & e=0
    text = [text,('Element ' + strtrim(string(i+1),2))]
    text = [text,('   fill count= ' + strtrim(string(fc),2))]
    text = [text,('   minimum   = ' + strtrim(string(dmin),2))]
    text = [text,('   maximum   = ' + strtrim(string(dmax),2))]
    text = [text,('   average   = ' + strtrim(string(davg),2))]
  endfor
endif
if ds(0) ge 3 then begin ; variable is record-varying image
  print,'CANNOT PRODUCE STATS FOR 3D+ VARIABLES' & return
endif

; Create a widget to display the text
net = n_elements(text)
base1 = widget_base(/Column,Title='Variable Stats',/frame)
if net le 30 then begin
  txt1  = widget_text(base1,value=text,ysize=net,xsize=max(strlen(text)))
endif else begin
  txt1  = widget_text(base1,value=text,ysize=30,xsize=max(strlen(text)),/scroll)
endelse

; Register the main menu into the window list and save in the cdfx common
add_cdfxwindow,'Variable Stats',base1

; Realize and manage the window
widget_control,base1,/realize
Xmanager,'VarStats',base1,Event='cdfx_showstats_Event',$
         GROUP=GROUP,Cleanup='cdfx_showstatsCBox'
end


PRO cdfx_DataObject_Event, event
COMMON cdfxcom, CDFxwindows, CDFxprefs ; include cdfx common
tnames = tag_names(event)
if tnames(3) eq 'VALUE' then begin ; must be from pull down menu
  case event.value of
    'Object Actions>.Save Object.as IDL save file' : begin
        child = widget_info(event.top,/child) ; get widget id of first child
        widget_control,child,get_uvalue=info
        widget_control,info.labl,get_value=olabel
        widget_control,/hourglass
        widget_control,event.top,get_uvalue=a
        olabel=strtrim(olabel,2)
        s = break_mystring(olabel,delimiter=' ')
        t = break_mystring(s(2),delimiter='/')
        u = s(0)+'_'+t(0)+t(1)+t(2)+'.sav'
        print,'Creating the save file:',u
        save_mystruct,a,u
        a=0
        end
    'Object Actions>.Save Object.as a CDF file'    : begin
        child = widget_info(event.top,/child)
        widget_control,child,get_uvalue=info
        widget_control,info.labl,get_value=olabel
        widget_control,/hourglass
        widget_control,event.top,get_uvalue=a
        olabel=strtrim(olabel,2)
        s = break_mystring(olabel,delimiter=' ')
        t = break_mystring(s(2),delimiter='/')
        u = s(0)+'_'+t(0)+t(1)+t(2)+'.cdf'
        print,'Creating the cdf file:',u
        s = write_mycdf(a,u)
        a=0
        end
    'Object Actions>.List Object'                  : begin
        widget_control,event.top,get_uvalue=a
        print,'Generating list file...'
        widget_control,/hourglass
        s=list_mystruct(a,filename='cdfx.txt',/NOGATT,MAXRECS=950)
        if (s ne -1) then XDISPLAYFILE,'cdfx.txt'
        end
    'Object Actions>.Time Filter'                  : begin
        widget_control,/hourglass
        widget_control,event.top,get_uvalue=a
        cdfx_timeslice,a,GROUP=event.top
        end
    'Object Actions>.Plot Object.as an Xwindow'    : begin
        widget_control,/hourglass
        widget_control,event.top,get_uvalue=a
        s=plotmaster(a,xsize=600,/auto,/slow,/smooth,debug=CDFxprefs.debug)
        end
    'Object Actions>.Plot Object.as a GIF file'    : begin
        widget_control,/hourglass
        widget_control,event.top,get_uvalue=a
        s=plotmaster(a,xsize=600,/auto,/slow,/smooth,/GIF,debug=CDFxprefs.debug)
        end
    'Object Actions>.Destroy Object'               : begin
        widget_control,event.top,get_uvalue=a
        delete_myhandles,a ; free any handles
        child = widget_info(event.top,/child)
        widget_control,child,get_uvalue=info
        remove_cdfxwindow,title=('Data Object '+info.letter)
        widget_control,event.top,/destroy
        end
    'Variable Actions>.Show/Edit vattrs'           : begin
        widget_control,/hourglass
        widget_control,event.top,get_uvalue=a
        child = widget_info(event.top,/child)
        widget_control,child,get_uvalue=b
        widget_control,b.list,get_uvalue=vnames
        vname = str_sep(vnames(b.vnum),' ')
        vname = strtrim(vname(0),2)
        cdfx_editvattrs,a,vname,GROUP=event.top
        end
    'Variable Actions>.Compute Statistics'       : begin
        widget_control,/hourglass
        widget_control,event.top,get_uvalue=a
        child = widget_info(event.top,/child)
        widget_control,child,get_uvalue=b
        widget_control,b.list,get_uvalue=vnames
        vname = str_sep(vnames(b.vnum),' ')
        vname = strtrim(vname(0),2)
        ti = tagindex(vname,tag_names(a))
        cdfx_showstats,a.(ti),GROUP=event.top
        end
    'Variable Actions>.Plot Variable'        : begin
        widget_control,/hourglass
        widget_control,event.top,get_uvalue=a
        child = widget_info(event.top,/child)
        widget_control,child,get_uvalue=b
        widget_control,b.list,get_uvalue=vnames
        vname = str_sep(vnames(b.vnum),' ')
        vname = strtrim(vname(0),2)
        s = xplot_images(a,vname)
        end
    'Variable Actions>.List Variable'        : print,'NOT YET LISTING VARS'
    else : print,'UNKNOWN VALUE FOR PULLDOWN!'
  endcase
endif
if tnames(3) eq 'INDEX' then begin ; must be from variable list
  widget_control,event.id,get_uvalue=vnames & s = size(vnames)
  if (s(n_elements(s)-2) eq 7) then begin ; event is from the list
    child = widget_info(event.top,/child) ; get widget id of first child
    widget_control,child,get_uvalue=b ; get the widget ids from first child
    b.vnum = event.index ; record which variable is selected
    widget_control,child,set_uvalue=b ; set the updated widget ids
    widget_control,b.vmenu,/sensitive ; sensitize the variable functions
  endif else begin ; event is from the droplist
    widget_control,/hourglass
    widget_control,event.top,get_uvalue=a
    if (event.index eq 0) then vnames = generate_varlist(a) $ ; DATA only
    else vnames = generate_varlist(a,/ALL) ; ALL variables
    widget_control,event.id,get_uvalue=b
    widget_control,b,set_value=vnames
    widget_control,b,set_uvalue=vnames
    a=0 ; free up the memory
  endelse
endif
end


PRO cdfx_D0CBox, wid
  remove_cdfxwindow,WID=wid
  widget_control,wid,get_uvalue=a
  delete_myhandles,a ; free any handles
end


FUNCTION determine_dataobject_letter
COMMON cdfxcom, CDFxwindows, CDFxprefs ; include cdfx common
; Determine the letter to identify the next data object
w = where(strpos(cdfxwindows.title,'Data Object') ne -1,wc)
if (wc eq 0) then return,'A' $ ; first data object
else begin & b = bytarr(wc)
  ; convert all of the existing letters to numbers
  for i=0,wc-1 do begin
    c = strtrim(  strmid(cdfxwindows.title(w(i)),11,8),2)
    b(i) = byte(c)
  endfor
  ; find the earliest unused number beginning with 65 (i.e. 'A')
  p = bindgen(26) & p = p + 65B
  for i=0,wc-1 do begin & w=where(p ne b(i)) & p=p(w) & endfor
  letter = string(p(0))
endelse
return,letter
end


PRO cdfx_dataobject, a, GROUP=GROUP
COMMON cdfxcom, CDFxwindows, CDFxprefs ; include cdfx common
; Determine the letter to identify this object
letter = determine_dataobject_letter()

; Create a string array holding all of the global attributes in structure
atags = tag_names(a.(0)) & w=where(atags eq 'FIELDNAM') & gattrs='' & p='    '
for i=1,w(0)-1 do begin
  if (n_elements(a.(0).(i)) eq 1) then begin
    val = atags(i) + ': ' + string(a.(0).(i))
    if (gattrs(0) eq '') then gattrs = val else gattrs = [gattrs,val]
  endif else begin
    gattrs = [gattrs,(atags(i)+':')]
    for j=0,n_elements(a.(0).(i))-1 do gattrs = [gattrs,p+string(a.(0).(i)(j))]
  endelse
endfor

; Determine a variable that contains the timing information
atags = tag_names(a) & tvar = -1
for i=0,n_elements(atags)-1 do begin
  btags = tag_names(a.(i)) & w = where(btags eq 'CDFTYPE',wc)
  if (wc gt 0) then if (a.(i).CDFTYPE eq 'CDF_EPOCH') then tvar = i
endfor
if (tvar ne -1) then begin ; Determine the start and stop time of the data
  d = get_mydata(a,tvar)
  start_time = decode_cdfepoch(min(d))
  stop_time  = decode_cdfepoch(max(d)) & d=0
endif

; Create label for this object from logical source and start/stop time
lsource = '' & atags = tag_names(a.(0)) ; get names of the epoch attributes
w = where(atags eq 'LOGICAL_SOURCE',wc)
if (wc gt 0) then lsource = lsource + a.(0).(w(0))
if (strlen(lsource) le 1) then begin ; construct lsource from other info
  s = '' & t = '' & d = ''
  w = where(atags eq 'SOURCE_NAME',wc)
  if (wc gt 0) then s = break_mystring(a.(0).(w(0)),delimiter='>')
  w = where(atags eq 'DATA_TYPE',wc)
  if (wc gt 0) then t = break_mystring(a.(0).(w(0)),delimiter='>')
  w = where(atags eq 'DESCRIPTOR',wc)
  if (wc gt 0) then d = break_mystring(a.(0).(w(0)),delimiter='>')
  lsource = s(0) + '_' + t(0) + '_' + d(0)
endif
olabel = '   ' + lsource + ' from ' + start_time + ' till ' + stop_time + '   '

; Create a list of variables and pertinent metadata
vnames = generate_varlist(a)

; Create the widget
base1 = widget_base(/Column,Title=('Data Object '+letter),/frame)
base2 = widget_base(base1,/Column)
base3 = widget_base(base1,/Row)
labl1 = widget_label(base2,value=olabel,/align_center)
text1 = widget_text(base2,value=gattrs,/scroll,ysize=10,xsize=40)
list1 = widget_list(base2,value=vnames,/frame,ysize=6,uvalue=vnames)
but1  = widget_droplist(base3,uvalue=list1,$
                        value=['Show DATA vars','Show ALL vars'])
junk1 =  {CW_PDMENU_S,flags:0,name:''}
puld1 = [{CW_PDMENU_S,1,'Object Actions>'},$
         {CW_PDMENU_S,1,'Save Object'},$
         {CW_PDMENU_S,0,'as IDL save file'},$
         {CW_PDMENU_S,2,'as a CDF file'},$
         {CW_PDMENU_S,1,'Plot Object'},$
         {CW_PDMENU_S,0,'as an Xwindow'},$
         {CW_PDMENU_S,2,'as a GIF file'},$
         {CW_PDMENU_S,0,'List Object'},$
         {CW_PDMENU_S,0,'Time Filter'},$
         {CW_PDMENU_S,2,'Destroy Object'}]
but2  =   CW_PDMENU(base3,puld1,/return_full_name)
puld2 = [{CW_PDMENU_S,1,'Variable Actions>'},$
         {CW_PDMENU_S,0,'Show/Edit vattrs'} ,$
         {CW_PDMENU_S,0,'Compute Statistics'} ,$
         {CW_PDMENU_S,0,'Plot Variable'},$
         {CW_PDMENU_S,2,'List Variable'}]
but3  =   CW_PDMENU(base3,puld2,/return_full_name)

; Register this data object into the main window list
add_cdfxwindow,('Data Object '+letter),base1
; Save the widget id's of the buttons and list of this widget
junk = {labl:labl1,text:text1,list:list1,drop:but1,$
        omenu:but2,vmenu:but3,letter:letter,vnum:-1L}
child = widget_info(base1,/child) ; get widget id of first child
widget_control,child,set_uvalue=junk ; save widget ids in first child
widget_control,but3,sensitive=0 ; desensitize variable functions for now

; Save the structure into the base user value
widget_control,base1,set_uvalue=a & a=0

; Realize the data object
widget_control,base1,/realize
Xmanager,'DataObject',base1,Event='cdfx_DataObject_Event',$
         GROUP=GROUP,Cleanup='cdfx_D0CBox'
end


PRO cdfx_pre_xinteranimate_Event,event
COMMON cdfxcom, CDFxwindows, CDFxprefs ; include cdfx common
wtype = widget_info(event.id,/type)
widget_control,event.top,get_uvalue=info
case wtype of
  1 : begin ; button event
      case event.id of
        info.proceed : begin
            widget_control,info.xwid,get_value=width
            widget_control,info.ywid,get_value=height
            width  = long(width)  & width  = width(0)
            height = long(height) & height = height(0)
            ; determine the name of the selected variable
            s = str_sep(info.vnames(info.vindex),':')
            for i=0,n_elements(s)-1 do s(i)=strtrim(s(i),2)
            w = where(cdfxwindows.title eq s(0),wc)
            if wc eq 0 then begin
              print,'ERROR>Data Object does not exist!' & return
            endif else begin
              widget_control,cdfxwindows.wid(w(0)),get_uvalue=a
              widget_control,/hourglass

              ; extract the validmin and validmax values
              vnum = tagindex(s(1),tag_names(a))
              b = tagindex('VALIDMIN',tag_names(a.(vnum)))
              if (b(0) ne -1) then begin & c=size(a.(vnum).VALIDMIN)
                if (c(0) eq 0) then zvmin = a.(vnum).VALIDMIN $
                else begin
                  zvmin = 0 ; default for image data
                  print,'WARNING>Unable to determine validmin for ',s(1)
                endelse
              endif
              b = tagindex('VALIDMAX',tag_names(a.(vnum)))
              if (b(0) ne -1) then begin & c=size(a.(vnum).VALIDMAX)
                if (c(0) eq 0) then zvmax = a.(vnum).VALIDMAX $
                else begin
                  zvmax = 2000 ; guestimate
                  print,'WARNING>Unable to determine validmax for ',s(1)
                endelse
              endif

              print,'Retrieving the image data...'
              d = get_mydata(a,s(1)) ; extract the data from the structure

              ; Perform any requested data manipulations
              widget_control,info.valids,get_value=onoff
              if onoff eq 0 then begin
                print,'Performing validmin/max filtering...'
                w = where(((d lt zvmin)OR(d gt zvmax)),wc)
                if wc gt 0 then begin
                  print,'WARNING>filtering bad values from image data...'
                  d(w) = 0 & w = 0 ; set pixels to black and free space
                endif
              endif

              widget_control,info.noise,get_value=onoff
              if onoff eq 0 then begin
                print,'Performing noise reduction...'
                semiMinMax,d,zvmin,zvmax
                w = where(((d lt zvmin)OR(d gt zvmax)),wc)
                if wc gt 0 then begin
                  print,'WARNING>filtering values > 3-sigma from image data...'
                  d(w) = 0 & w = 0 ; set pixels to black and free space
                endif
              endif

              widget_control,info.maxcolor,get_value=onoff
              if onoff eq 0 then begin
                print,'Performing color enhancement...'
                d = bytscl(d,max=max(d),min=min(d),top=!d.n_colors-1)
              endif

              s = size(d) ; get the idl sizing info
              if ((width ne s(1))OR(height ne s(2))) then begin
                print,'Resizing the image data...'
                d = congrid(d,width,height,s(3))
              endif

              widget_control,info.edges,get_value=onoff
              if onoff eq 0 then begin
                print,'Performing edge enhancement...'
                s = size(d)
                for i=0,s(3)-1 do d(*,*,i) = roberts(temporary(d(*,*,i)))
              endif

              ; Show the animation
              print,'Loading image data into animation frames...'
              xinteranimate,set=[width,height,s(3)]
              for i=0,s(3)-1 do xinteranimate,frame=i,image=d(*,*,i)
              d = 0 ; delete the data now that it has been loaded
              xinteranimate,GROUP=info.group
              ; remove the current starter widget
              remove_cdfxwindow,WID=event.top
              widget_control,event.top,/destroy
            endelse
            end
        info.cancel  : begin
                       remove_cdfxwindow,WID=event.top
                       widget_control,event.top,/destroy
                       end
        info.help    : print,'not yet helping'
        else         : begin
                       print,'ERROR>cdfx_animator:unknown button event!'
                       stop
                       end
      endcase
      end
  3 : print,'nothing to do for text'
  6 : begin ; list widget
      ; Get the idl size information for the selected variable
      s = str_sep(info.vnames(event.index),':') ; get object name and varname
      for i=0,n_elements(s)-1 do s(i)=strtrim(s(i),2) ; trim blanks
      w = where(cdfxwindows.title eq s(0),wc)
      if wc eq 0 then begin
        print,'ERROR>Data Object containing variable does not exist!' & return
      endif else begin
        widget_control,cdfxwindows.wid(w(0)),get_uvalue=a
        isize = get_mydatasize(a,s(1)) ; get idl sizing information
        widget_control,info.xwid,set_value=string(isize(1))
        widget_control,info.ywid,set_value=string(isize(2))
        widget_control,info.xwid,sensitive=1
        widget_control,info.ywid,sensitive=1
      endelse
      info.vindex = event.index
      widget_control,info.proceed,sensitive=1
      widget_control,event.top,set_uvalue=info
      end
   else : x=0 ; do nothing
endcase
end


PRO cdfx_pre_xinteranimateCBox, wid
  remove_cdfxwindow,WID=wid
end


PRO cdfx_pre_xinteranimate, GROUP=GROUP
COMMON cdfxcom, CDFxwindows, CDFxprefs ; include cdfx common
if XRegistered('ImageAnimator') then begin
  print,'WARNING:Only 1 Image Animator setup allowed at a time.' & return
endif

; Assemble a list of variables which can be displayed via xinteranimate
numvars = 0L ; initialize
w = where(strpos(cdfxwindows.title,'Data Object') ne -1,wc)
for i=0,wc-1 do begin ; examine every data object
  widget_control,cdfxwindows.wid(w(i)),get_uvalue=a
  vnames = tag_names(a) & nvnames = n_elements(vnames)
  for j=0,nvnames-1 do begin ; examine each variable
    ; Retrieve the sizing information for the variable
    isize = get_mydatasize(a,j)
    if isize(0) eq 3 then begin ; data dimensionality ok for xinteranimate
      s = cdfxwindows.title(w(i)) + ' : ' + vnames(j)
      if numvars eq 0 then text = s else text = [text,s]
      numvars = numvars + 1 ; increment variable counter
    endif
  endfor
endfor

; If no variables can be displayed via xinteranimate inform user and exit
if numvars eq 0 then begin
  t0 = 'ERROR: No Data Objects contain variables '
  t1 = 'which can be displayed via xinteranimate.'
  t2 = 'Click OK to continue.'
  but = widget_message([t0,t1,t2]) & return
endif

; Construct a widget interface
base1 = widget_base(/Column,Title='Image Animation')
lab1a = widget_label(base1,value='Select variable to display')
list1 = widget_list(base1,/frame,value=text,ysize=5)
lab1b = widget_label(base1,value='Display sizing:')
base2 = widget_base(base1,Row=2)
lab2x = widget_label(base2,value='Image Width  ')
txt2x = widget_text(base2,value= ' 100',/editable)
lab2y = widget_label(base2,value='Image Height ')
txt2y = widget_text(base2,value= ' 100',/editable)
base3 = widget_base(base1,/Column,/frame)
lab3a = widget_label(base3,value='Data Manipulation Options')
but3a = CW_BGROUP(base3,['On','Off'],label_left='Valid min/max filter:',$
                  /row,/exclusive,set_value=0)
but3b = CW_BGROUP(base3,['On','Off'],label_left='Noise Reduction     :',$
                  /row,/exclusive,set_value=1)
but3c = CW_BGROUP(base3,['On','Off'],label_left='Color Enhancement   :',$
                  /row,/exclusive,set_value=1)
but3d = CW_BGROUP(base3,['On','Off'],label_left='Edge Enhancement    :',$
                  /row,/exclusive,set_value=1)
base4 = widget_base(base1,/Row,/frame)
but4a = widget_button(base4,value='PROCEED')
but4b = widget_button(base4,value='Cancel')
but4c = widget_button(base4,value='Help')

; desensitize some widgets at start
widget_control,but4a,sensitive=0
widget_control,txt2x,sensitive=0
widget_control,txt2y,sensitive=0

; assemble structure of needed information and save in top uvalue
info = {vnames:text,vindex:-1L,xwid:txt2x,ywid:txt2y,$
        valids:but3a,noise:but3b,maxcolor:but3c,edges:but3d,$
        proceed:but4a,cancel:but4b,help:but4c,group:GROUP}
widget_control,base1,set_uvalue=info

; Register this window into the common block
add_cdfxwindow,'Image Animation',base1

; Realize the widget
widget_control,base1,/realize
Xmanager,'ImageAnimator',base1,Event='cdfx_pre_xinteranimate_Event',$
         GROUP=GROUP,Cleanup='cdfx_pre_xinteranimateCBox'

; If only a single variable exists, then set automatically select it
widget_control,list1,set_list_select=0
e = {ID:list1,TOP:base1,HANDLER:base1,INDEX:0L,CLICKS:1L}
widget_control,list1,send_event=e
end


PRO cdfx_shutdown
COMMON cdfxcom, CDFxwindows, CDFxprefs ; include cdfx common
; Free any data held in handles before destroying the objects
w = where(strpos(cdfxwindows.title,'Data Object') ne -1,wc)
for i=0,wc-1 do begin
  widget_control,cdfxwindows.wid(w(i)),get_uvalue=a
  delete_myhandles,a
endfor
remove_cdfxwindow,title='Main Menu'
end


PRO cdfx_MMenu_Event, event
COMMON cdfxcom, CDFxwindows, CDFxprefs ; include cdfx common
tnames = tag_names(event)
if tnames(3) eq 'VALUE' then begin ; must be from pull down menu
  case event.value of
    'Open a new Window >.Time Series Plot Window' : print,'NOT YET IMPLEMENTED'
    'Open a new Window >.Spectrogram Plot Window' : print,'NOT YET IMPLEMENTED'
    'Open a new Window >.Image Animator Window'   : begin
        widget_control,/hourglass
        cdfx_pre_xinteranimate, GROUP=event.top
        end
    'Open a new Window >.Radar Plot Window'       : print,'NOT YET IMPLEMENTED'
    'Open a new Window >.Data Manipulator Window' : print,'NOT YET IMPLEMENTED'
    'Modify Preferences>.Font Preferences'        : begin
        s = XFONT()
        if (s ne '') then widget_control,default_font=s
        end
    'Modify Preferences>.Color Table Preferences' : xloadct
    'Modify Preferences>.Data Object Preferences' : print,'NOT YET IMPLEMENTED'
    'Modify Preferences>.Time Series Preferences' : print,'NOT YET IMPLEMENTED'
    'Modify Preferences>.Spectrogram Preferences' : print,'NOT YET IMPLEMENTED'
    'Modify Preferences>.Image Preferences'       : print,'NOT YET IMPLEMENTED'
    'Modify Preferences>.Listing Preferences'     : print,'NOT YET IMPLEMENTED'
    'Shut Down>....and Save all Data Objects'      : begin
        w = where(strpos(CDFxwindows.title,'Data Object') ne -1,wc)
        for i=0,wc-1 do begin
          child = widget_info(CDFxwindows.wid(w(i)),/child)
          widget_control,child,get_uvalue=info
          widget_control,info.labl,get_value=olabel
          widget_control,/hourglass
          widget_control,CDFxwindows.wid(w(i)),get_uvalue=a
          olabel=strtrim(olabel,2)
          s = break_mystring(olabel,delimiter=' ')
          t = break_mystring(s(2),delimiter='/')
          u = s(0)+'_'+t(0)+t(1)+t(2)+'.sav'
          print,'Creating the save file:',u
          save_mystruct,a,u
          a=0
        endfor
        cdfx_shutdown
        widget_control,event.top,/destroy
        end
    'Shut Down>....and Destroy all Data Objects'   : begin
        cdfx_shutdown
        widget_control,event.top,/destroy
        end
    else : print,'UNKNOWN VALUE FOR PULLDOWN!'
  endcase
endif else begin ; must be a regular button or the draw widget
  if tnames(3) eq 'TYPE' then begin ; must be the draw widget
    if event.press ne 0 then begin
      print,'CDFx Version 1.0     Date: 5/22/96'
      print,'Available at URL: http://nssdc.gsfc.nasa.gov/spdf/'
      print,'Written by R. Burley of Code 632.0 of NASA/GSFC'
      print,'email: burley@nssdca.gsfc.nasa.gov'
      print,'phone: (410)286-2864'
    endif
  endif else begin ; must be a regular button
    child = widget_info(event.top,/child)
    widget_control,child,get_uvalue=button_ids
    case event.id of
      button_ids.but1 : begin ; Read CDF files
                        widget_control,/hourglass
                        print,'Generating cdf list...'
                        a = xread_mycdf(/nodatastruct,debug=CDFxprefs.debug)
                        ; verify that 'a' is a structure
                        b = size(a) & c = b(n_elements(b)-2)
                        if (c eq 8) then begin
                          print,'Generating data object...'
                          widget_control,/hourglass
                          cdfx_dataobject,a,GROUP=event.top
                          a = 0 ; delete structure
                        endif
                        end
      button_ids.but2 : begin
                        widget_control,/hourglass
                        restore_dataobjects,GROUP=event.top
                        end
      button_ids.but3 : begin
                        widget_control,/hourglass
                        WindowList
                        end
      button_ids.butm : help,/memory
      else : print,'UNKNOWN BUTTON!'
    endcase
  endelse
endelse
end

PRO cdfx_MMenuCBox, wid
  cdfx_shutdown
end


PRO CDFX, DEBUG=DEBUG
if (XRegistered('CDFx Main Menu') ne 0) then return; only 1 main menu allowed

; Create the common block containing window information
COMMON cdfxcom, CDFxwindows, CDFxprefs
CDFxwindows = { title:strarr(50) , wid:lonarr(50) }
CDFxprefs   = { debug:0 }

; Read in the title image
read_gif,'cdfx.gif',cdf_image
v = where(cdf_image ge 12) & w = where(cdf_image eq 0)
cdf_image(v) = cdf_image(v) + 200
cdf_image = hist_equal(cdf_image,top=240)
cdf_image(w) = 255

; Create the main menu
base1 = widget_base(/Column,Title='Main Menu',/frame,/base_align_center)
drw1  = widget_draw(base1,xsize=131,ysize=126,/button_events,/frame)
but1  = widget_button(base1,value='Read CDF files')
but2  = widget_button(base1,value='Restore Data Objects')
but3  = widget_button(base1,value='Window List')
if keyword_set(DEBUG) then begin
  CDFxprefs.debug = 1
  butm  = widget_button(base1,value='IDL Memory')
endif else butm = -1L
base2 = widget_base(base1,/Column,/BASE_ALIGN_CENTER)
junk1 =  {CW_PDMENU_S,flags:0,name:''}
puld1 = [{CW_PDMENU_S,1,'Open a new Window >'},$
         {CW_PDMENU_S,0,'Time Series Plot Window'},$
         {CW_PDMENU_S,0,'Spectrogram Plot Window'},$
         {CW_PDMENU_S,0,'Image Animator Window'},$
         {CW_PDMENU_S,0,'Radar Plot Window'},$
         {CW_PDMENU_S,2,'Data Manipulator Window'}]
but4  =   CW_PDMENU(base2,puld1,/return_full_name)
puld2 = [{CW_PDMENU_S,1,'Modify Preferences>'},$
         {CW_PDMENU_S,0,'Font Preferences'},$
         {CW_PDMENU_S,0,'Color Table Preferences'},$
         {CW_PDMENU_S,0,'Data Object Preferences'},$
         {CW_PDMENU_S,0,'Time Series Preferences'},$
         {CW_PDMENU_S,0,'Spectrogram Preferences'},$
         {CW_PDMENU_S,0,'Image Preferences'},$
         {CW_PDMENU_S,0,'Listing Preferences'}]
but5  =   CW_PDMENU(base2,puld2,/return_full_name)
puld3 = [{CW_PDMENU_S,1,'Shut Down>'},$
         {CW_PDMENU_S,0,'...and Save all Data Objects'},$
         {CW_PDMENU_S,2,'...and Destroy all Data Objects'}]
but6  =   CW_PDMENU(base2,puld3,/return_full_name)


; Register the main menu into the window list and save in the cdfx common
add_cdfxwindow,'Main Menu',base1

; Save the widget id's of the buttons in the first child uvalue
button_ids = {drw1:drw1,but1:but1,but2:but2,but3:but3,but4:but4,butm:butm}
child = widget_info(base1,/child)
widget_control,child,set_uvalue=button_ids

; Realize the main menu
widget_control,base1,/realize
widget_control,get_value=index,drw1
wset,index & tv,cdf_image

; Manage the window
Xmanager,'MMenu',base1,Event='cdfx_MMenu_Event',Cleanup='cdfx_MMenuCBox'
end
