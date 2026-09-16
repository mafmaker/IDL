; Given an input string, find that structure element name and return number
;TJK commented this function out - the source for this is in tagindex.pro
;
;FUNCTION tagindex, instring, tnames
;instring = STRUPCASE(instring) ; tagnames are always uppercase
;a = where(tnames eq instring,count)
;if count eq 0 then return, -1 $
;else return, a(0)
;end

;----------------------------------------------------------------------------------
; Return TRUE(1) or FALSE(0) if the input parameter looks like one of the
; structures returned by the read_mycdf or restore_mystruct functions.
; RCJ 03/05/2003 Moved this fnc to evaluate_image_struct.pro (called by
; xplot_images.pro which in turn is called by cdfx.pro.)
; The fnc is used there but not here....
;FUNCTION ami_mystruct,a
;ds = size(a) & nds = n_elements(ds)
;if (ds(nds-2) ne 8) then return,0
;for i=0,n_elements(tag_names(a))-1 do begin
;  ds = size(a.(i)) & nds = n_elements(ds)
;  if (ds(nds-2) ne 8) then return,0
;  tnames = tag_names(a.(i))
;  w = where(tnames eq 'VARNAME',wc1) & w = where(tnames eq 'CDFTYPE',wc2)
;  w = where(tnames eq 'HANDLE' ,wc3) & w = where(tnames eq 'DAT',wc4)
;  if wc1 eq 0 then return,0
;  if wc2 eq 0 then return,0
;  if (wc3 + wc4) ne 1 then return,0
;endfor
;return,1
;end

;;-------------------------------------------------------------------------------------
;; RCJ 02/06/2003 There's a separate procedure with the same name and save_mystruct 
;; is not called in write_mycdf.pro
;; Utilize IDL's SAVE procedure to save the structure a into the given filename.
;PRO save_mystruct,a,fname
;COMMON CDFmySHARE, v0  ,v1, v2, v3, v4, v5, v6, v7, v8, v9,$
;                   v10,v11,v12,v13,v14,v15,v16,v17,v18,v19,v20
;if tagindex('HANDLE',tag_names(a.(0))) eq -1 then begin
;  ; data is stored directly in the structure
;  SAVE,a,FILENAME=fname
;endif else begin
;  ; data is stored in handles.  Retrieve the data from the handles,
;  ; and store the data into 'n' local variables, then SAVE.
;  tn = tag_names(a) & nt = n_elements(tn) & cmd = 'SAVE,a'
;  ; Preallocate some temporary variables.  The EXECUTE command cannot
;  ; create new variables...they must already exist.  Lets hope 20 is enough.
;;TJK comment this check out since this is now done dynamically
;;  if nt ge 20 then begin
;;    print,'ERROR= too many handle values in structure to save' & return
;;  endif
;
;;  v0=0L  & v1=0L  & v2=0L  & v3=0L  & v4=0L  & v5=0L  & v6=0L  & v7=0L
;;  v8=0L  & v9=0L  & v10=0L & v11=0L & v12=0L & v13=0L & v14=0L & v15=0L
;;  v16=0L & v17=0L & v18=0L & v19=0L & v20=0L
;
;  for i=0,nt-1 do begin ; retrieve each handle value
;    order = 'handle_value,a.(i).HANDLE,v' + strtrim(string(i),2)
;     status = EXECUTE(order)
;    cmd = cmd + ',v' +  strtrim(string(i),2)
;   endfor
;
;  ; Add the filename keyword to save command
;  cmd = cmd+",FILENAME='"+fname+"'"
;  status = execute(cmd) ; execute the save command
;endelse
;end


;----------------------------------------------------------------------------------
;; RCJ 02/06/2003 There's a separate procedure with the same name and save_mystruct 
;; is not called in write_mycdf.pro
;FUNCTION restore_mystruct,fname
;; declare variables which exist at top level
;COMMON CDFmySHARE, v0  ,v1, v2, v3, v4, v5, v6, v7, v8, v9,$
;                   v10,v11,v12,v13,v14,v15,v16,v17,v18,v19,v20
;; Use the IDL restore feature to reconstruct the anonymous structure a
;RESTORE,FILENAME=fname
;; The anonymous structure should now be in the variable 'a'.  Determine
;; if the structure contains .DAT or .HANDLE fields
;ti = tagindex('HANDLE',tag_names(a.(0)))
;if ti ne -1 then begin
;  tn = tag_names(a) & nt = n_elements(tn) ; determine number of variables
;  for i=0,nt-1 do begin
;    a.(i).HANDLE = handle_create()
;    order = 'handle_value,a.(i).HANDLE,v' + strtrim(string(i),2) + ',/SET'
;    status = EXECUTE(order)
;  endfor
;endif
;return,a
;end

;----------------------------------------------------------------------------------

;; Return the data for the given variable in the given structure
;FUNCTION get_mydata,a,var
;; Determine the variable number
;s = size(var)  
;if s(n_elements(s)-2) eq 7 then begin
;  w = where(tag_names(a) eq var)
;  if w[0] ne -1 then vnum = w(0) $
;  else begin
;    print,'ERROR>get_mydata:named variable not in structure!' & return,-1
;  endelse
;endif else vnum = var
;; Retrieve the data for the variable
;vtags = tag_names(a.(vnum))
;ti = tagindex('HANDLE',vtags)
;if ti ne -1 then begin
;   b = handle_info(a.(vnum).HANDLE,/valid_id)
;   if b eq 1 then handle_value,a.(vnum).handle,d else d=0
;   ;handle_value,a.(vnum).handle,d 
;endif else begin
;  ti = tagindex('DAT',vtags)
;  if ti ne -1 then d = a.(vnum).dat $
;  else begin
;    print,'ERROR>get_mydata:variable has neither HANDLE nor DAT tag!'
;    return,-1
;  endelse
;endelse
;if n_elements(d) gt 1 then d = reform(d)
;return,d
;end

;----------------------------------------------------------------------------------

;; Return the idl sizing information for the data in the given variable
;; RCJ 02/06/2003 There's a separate fnc with the same name in cdfx.pro and get_mydatasize 
;; is not called in write_mycdf.pro
;FUNCTION get_mydatasize, a, var
;; Determine the variable number
;s = size(var) & ns = n_elements(s) & atags = tag_names(a)
;if s(ns-2) eq 7 then begin
;  w = where(atags eq var,wc)
;  if wc gt 0 then vnum = w(0) $
;  else begin
;    print,'ERROR>get_mydata:named variable not in structure!' & return,-1
;  endelse
;endif else vnum = var
;
;; Retrieve the idl sizing information for the variable
;vtags = tag_names(a.(vnum))
;ti = tagindex('HANDLE',vtags) ; search for handle tag
;if ti ne -1 then begin
;  ti = tagindex('IDLSIZE',vtags) ; search for idlsize tag
;  if ti ne -1 then isize = a.(vnum).IDLSIZE $
;  else begin ; must retrieve data to get the size
;    handle_value,a.(vnum).handle,d & isize = size(d)
;  endelse
;endif else begin ; search for dat tag
;  ti = tagindex('DAT',vtags)
;  if ti ne -1 then isize = size(a.(vnum).dat) $
;  else begin
;    print,'ERROR>get_mydata:variable has neither HANDLE nor DAT tag!'
;    return,-1
;  endelse
;endelse
;return,isize
;end

;----------------------------------------------------------------------------------

; IDL always stores structure tags in uppercase.  The ISTP/IACG CDF
; Guidelines show that most required global attributes are not in
; uppercase.  This function performs a case-check on input attribute
; names, and returns the proper case according to the guidelines.
; Unrecognized attribute names are returned without change.
FUNCTION ISTP_gattr_casecheck, a

case a of
  'PROJECT'                    : a = 'Project'
  'DISCIPLINE'                 : a = 'Discipline'
  'SOURCE_NAME'                : a = 'Source_name'
  'DESCRIPTOR'                 : a = 'Descriptor'
  'DATA_TYPE'                  : a = 'Data_type'
  ; RCJ 02/06/2003 Bob does not want version number.
  ;'DATA_VERSION'               : a = 'Data_version'
  'ADID_REF'                   : a = 'ADID_ref'
  'LOGICAL_FILE_ID'            : a = 'Logical_file_id'
  'LOGICAL_SOURCE'             : a = 'Logical_source'
  'LOGICAL_SOURCE_DESCRIPTION' : a = 'Logical_source_description'
  'PI_NAME'                    : a = 'PI_name'
  'PI_AFFILIATION'             : a = 'PI_affiliation'
  'MISSION_GROUP'              : a = 'Mission_group'
  'INSTRUMENT_TYPE'            : a = 'Instrument_type'
  'TEXT'            	       : a = 'Text'
  else                          : b = 0 ; do nothing
endcase
return,a
end
;----------------------------------------------------------------------------------

;
FUNCTION parse_mytime,str
;
str1=strsplit(str,' ',/extract)
str2=strsplit(str1[0],'/',/extract)
str3=strsplit(str1[1],':',/extract)
s=[str2,str3]
return,s
;
end
;
;----------------------------------------------------------------------------------

; Determine name for a cdf file given the contents of the data structure
; and the ISTP/IACG filenaming conventions.
FUNCTION autoname_mycdf, a, longtime=longtime, bothtimes=bothtimes,  $
                            uppercase=uppercase, lowercase=lowercase

; Determine the variable that contains the timing information
atags = tag_names(a)  
tvar = -1
found = 0
for i=0,n_elements(atags)-1 do begin
  w = where(tag_names(a.(i)) eq 'CDFTYPE')
  ;if (w[0] ne -1) then if (a.(i).CDFTYPE eq 'CDF_EPOCH') then tvar = i
  ;if (w[0] ne -1 and found eq 0) then begin  ; Is this the best way to test this?
  ; RCJ 02/15/2008 Looking for 'novary' epochs will eliminate the epoch0's (see themis data) 
  if (w[0] ne -1 and a.(i).cdfrecvary ne 'NOVARY' and found eq 0) then begin  ; Is this the best way to test this?
     case a.(i).CDFTYPE of
     'CDF_EPOCH16': begin
        tvar = i
        found=1
	end
     'CDF_EPOCH': begin
        tvar = i
	found=1
	end
     else:	
     endcase
   endif  	
endfor
; Now that the 'tvar' is found, Determine the start and stop time of the data
if (tvar ne -1) then begin
  d = get_mydata(a,tvar) 
  w = where(d gt 0.0D0,wc)
  if (wc le 0) then begin
    stime = '00000000' & ptime = '00000000'
    if keyword_set(LONGTIME) then begin
      ;stime = stime + '00' & ptime = ptime + '00'
      stime = stime + '000000' & ptime = ptime + '000000'
    endif
  endif else begin
    s = parse_mytime(decode_cdfepoch(d(w(0))))
    stime = s(0) + s(1) + s(2)
    ; RCJ 02/06/2003  Added min (s(4)) to longtime:
    if keyword_set(LONGTIME) then stime = stime + s(3) + s(4)+ s(5)
    s = parse_mytime(decode_cdfepoch(d(w(n_elements(w)-1))))
    ptime = s(0) + s(1) + s(2)
    ; RCJ 02/06/2003  Added min (s(4)) to longtime:
    if keyword_set(LONGTIME) then ptime = ptime + s(3) + s(4)+ s(5)
  endelse
  d = 0 ; free the data space
endif else begin
  print,'ERROR>autoname_mycdf: Type CDF_EPOCH or CDF_EPOCH16 not found' & return,-1
endelse

; Determine the Logical source for using metadata from the structure
atags = tag_names(a.(0)) ; get names of the epoch attributes
w = where(atags eq 'LOGICAL_SOURCE')
if (w[0] ne -1) then begin 
  ; RCJ 02/06/2003 Bob suggested K0 -> K0s (s=subset of original cdf), H0 -> HOs, etc
  s=strsplit(a.(0).(w(0)),'_',/extract)
  ;lsource=s(0)+'_'+s(1)+'s_'+s(2)
  lsource=s(0)+'_'+s(1)+'s_'
  for i=2,n_elements(s)-2 do begin
     lsource=lsource+s(i)+'_'
  endfor
  lsource=lsource+s(n_elements(s)-1)
endif else begin ; construct lsource from other info
  s = '$' & t = '$' & d = '$'
  w = where(atags eq 'SOURCE_NAME')
  if (w[0] ne -1) then begin
    s=strsplit(a.(0).(w(0)),'>',/extract)
    ;s = strmid(s[0],0,2)
    s = s[0]
  endif
  w = where(atags eq 'DATA_TYPE')
  if (w[0] ne -1) then t=strsplit(a.(0).(w(0)),'>',/extract)
  w = where(atags eq 'DESCRIPTOR')
  if (w[0] ne -1) then d=strsplit(a.(0).(w(0)),'>',/extract)
  ; RCJ 02/06/2003 Bob suggested K0 -> K0s (s=subset of original cdf), H0 -> HOs, etc
  lsource = s(0) + '_' + t(0) + 's_' + d(0)
endelse

; Determine the version of the cdf file
; RCJ 02/06/2003 Bob does not want version number.
;v = '01' & w = where(atags eq 'DATA_VERSION',wc)
;if (wc gt 0) then v = a.(0).(w(0))
;if strlen(v) lt 2 then v = '0' + v

; create the filename
fname = lsource + '_' + stime
if keyword_set(BOTHTIMES) then fname = fname + '_' + ptime
;fname = fname + '_v' + v

; create the cdf filename by adding the cdf suffix
; RCJ 03/16/2003  It's useless to return the suffix in uppercase because
; cdf_create only creates cdfs w/ suffix '.cdf' and it will change your input
; if you try to call it w/ '.CDF'
if keyword_set(LOWERCASE) then fname = strlowcase(fname) + '.cdf' else $
   fname = strupcase(fname) + '.cdf'

;
return,fname
;
end

;-----------------------------------------------------------------------------------------

;; Modify the given tag (name or number) in the given variable (name or number)
;; in the given structure 'a' with the new value.
;FUNCTION modify_mystruct,a,var,tag,value
;; Initialize
;atags = tag_names(a)
;
;; Determine the variable number and validate
;s = size(var) & ns = n_elements(s)
;if s(ns-2) eq 7 then begin ; variable is given as a variable name
;  w = where(atags eq strupcase(var),wc)
;  if wc gt 0 then vnum = w(0) $
;  else begin
;    print,'ERROR>modify_mystruct:named variable not in structure!' & return,-1
;  endelse
;endif else begin
;  if ((var ge 0)AND(var lt n_elements(atags))) then vnum = var $
;  else begin
;    print,'ERROR>modify_mystruct:variable# not in structure!' & return,-1
;  endelse
;endelse
;vtags = tag_names(a.(vnum))
;
;; Determine the tag number and validate
;s = size(tag)  
;;ns = n_elements(s)
;if s(n_elements(s)-2) eq 7 then begin ; tag is given as a tag name
;  w = where(vtags eq strupcase(tag))
;  if w[0] ne -1 then tnum = w[0] $
;  else begin
;    print,'ERROR>modify_mystruct:named tag not in structure!' & return,-1
;  endelse
;endif else begin
;  if ((tag ge 0)AND(tag lt n_elements(vtags))) then tnum = tag $
;  else begin
;    print,'ERROR>modify_mystruct:tag# not in structure!' & return,-1
;  endelse
;endelse
;
;; Create and return new structure with only the one field modified
;for i=0,n_elements(atags)-1 do begin ; loop through every variable
;  if (i ne vnum) then b = a.(i) $ ; no changes to this variable
;  else begin ; must handle this variable field by field
;    tnames = tag_names(a.(i))
;    for j=0,n_elements(tnames)-1 do begin
;      if (j ne tnum) then c = create_struct(tnames(j),a.(i).(j)) $ ; no changes
;      else c = create_struct(tnames(j),value) ; new value for this field
;      ; Add the structure 'c' to the substructure 'b'
;      if (j eq 0) then b = c $ ; create initial structure
;      else b = create_struct(b,c) ; append to existing structure
;    endfor
;  endelse
;  ; Add the substructure 'b' to the megastructure
;  if (i eq 0) then aa = create_struct(atags(i),b) $ create initial structure
;  else begin ; append to existing structure
;    c = create_struct(atags(i),b) & aa = create_struct(aa,c)
;  endelse
;endfor
;return,aa
;end

;;---------------------------------------------------------------------------------------
;; Subset all time dependent variables in the structure 'a' to the times
;; specified by the tstart and tstop parameters.
;; RCJ 02/06/2003 There's a separate fnc with the same name in cdfx.pro and timeslice_mystruct 
;; is not called in write_mycdf.pro
;FUNCTION timeslice_mystruct,a,tstart,tstop,NOCOPY=NOCOPY
;
;; Convert tstart to DOUBLE if in string format
;s = size(tstart) & ns = n_elements(s)
;if s(ns-2) eq 7 then tstart = encode_cdfepoch(tstart) $
;else if s(ns-2) ne 5 then begin
;  print,'ERROR>timeslice:unknown datatype for the tstart parameter!' & return,a
;endif
;
;; Convert tstop to DOUBLE if in string format
;s = size(tstop) & ns = n_elements(s)
;if s(ns-2) eq 7 then tstop = encode_cdfepoch(tstop) $
;else if s(ns-2) ne 5 then begin
;  print,'ERROR>timeslice:unknown datatype for the tstop parameter!' & return,a
;endif
;
;; Initialize loop
;b = a ; copy the input structure for modification
;btags = tag_names(b) & nbtags = n_elements(btags)
;
;; Loop through all variables searching for those typed as CDF_EPOCH.
;for i=0,nbtags-1 do begin
;  vtags = tag_names(b.(i)) & nvtags = n_elements(vtags)
;  if b.(i).CDFTYPE eq 'CDF_EPOCH' then begin
;    d = get_mydata(b,i) ; retrieve the timing data
;    w = where(d ge tstart,wc) ; locate begining record of time span
;    if wc eq 0 then begin
;      print,'ERROR>timeslice:no data after tstart!' & return,a
;    endif else rbegin = w(0)
;    w = where(d le tstop,wc) ; locate last record of time span
;    if wc eq 0 then begin
;      print,'ERROR>timeslice:no data before tstop!' & return,a
;    endif else rend = w(n_elements(w)-1)
;
;    ; Subset the variable and plug the data back into a new structure
;    d = d(rbegin:rend)
;    if (vtags(nvtags-1) eq 'HANDLE') then begin
;      newhandle = handle_create()                 ; create new handle
;      handle_value,newhandle,d,/set               ; set handle value
;      b = modify_mystruct(b,i,'HANDLE',newhandle) ; modify structure
;    endif else b = modify_mystruct(b,i,'DAT',d)
;
;    ; Loop through all variables for those which depend on this variable
;    for j=0,nbtags-1 do begin
;      ti = tagindex('DEPEND_0',tag_names(b.(j)))
;      if ti ne -1 then begin
;        if b.(j).DEPEND_0 eq b.(i).VARNAME then begin
;          d = get_mydata(b,j) ; retrieve the data
;          ds = size(d) & nds = n_elements(ds)
;          case ds(0) of ; subset the data
;            0: print,'ERROR>timeslice:cannot subset vars with 0 dims!'
;            1: d = reform(d(rbegin:rend))
;            2: d = reform(d(*,rbegin:rend))
;            3: d = reform(d(*,*,rbegin:rend))
;            else : print,'ERROR>timeslice:Cannot subset vars with > 3 dims!'
;          endcase
;          if (vtags(nvtags-1) eq 'HANDLE') then begin
;            newhandle = handle_create()                 ; create new handle
;            handle_value,newhandle,d,/set               ; set handle value
;            b = modify_mystruct(b,j,'HANDLE',newhandle) ; modify structure
;          endif else b = modify_mystruct(b,j,'DAT',d)
;        endif
;      endif
;    endfor
;
;  endif
;endfor
;return,b
;end

;----------------------------------------------------------------------------------

; Prior to destroying or deleting one of the anonymous structures, determine
; if any data handles exists, and if so, free them.
;; RCJ 02/06/2003 There's a separate procedure with the same name in cdfx.pro and
;; delete_myhandles is not called in write_mycdf.pro
;PRO delete_myhandles,a
;for i=0,n_elements(tag_names(a))-1 do begin
;  ti = tagindex('HANDLE',tag_names(a.(i)))
;  if ti ne -1 then begin
;    b = handle_info(a.(i).HANDLE,/valid_id)
;    if b eq 1 then handle_free,a.(i).HANDLE
;  endif
;endfor
;end

;----------------------------------------------------------------------------------
;; RCJ 02/06/2003 There's a separate fnc with the same name in cdfx.pro
FUNCTION compare_vars, a, b
sa = size(a) & nsa = n_elements(sa)
sb = size(b) & nsb = n_elements(sb)
if (nsa ne nsb) then return,0
for i=0,nsa-1 do if (sa(i) ne sb(i)) then return,0
case sa(0) of
  0    : if (a ne b) then return,0
  1    : begin 
         for i=0,sa(1)-1 do begin
	    if (a(i) ne b(i)) then return,0
	 endfor
	 end   
  2    : begin
         for i=0,sa(1)-1 do begin
           for j=0,sa(2)-1 do if (a(i,j) ne b(i,j)) then return,0
         endfor
         end
  else : print,'WARNING>cannot yet compare vars with > 2 dimensions!'
endcase
return,1
end
;----------------------------------------------------------------------------------

; Determine all information about the variable in the varstruct parameter,
; which is required in order to create the variable in a CDF file
FUNCTION create_myCDF_variable,id,varstruct,novirtual=novirtual,DEBUG=DEBUG
vid = -1
vname = varstruct.VARNAME ; Determine the name of the variable

; Determine IDL sizing information about the data
ti = tagindex('HANDLE',tag_names(varstruct))
if ti ne -1 then handle_value,varstruct.HANDLE,d else d = varstruct.DAT

; This is great. But if novirtual is set and this is a virtual var then d will be =0
if keyword_set(novirtual) then begin
   ti = tagindex('VIRTUAL',tag_names(varstruct))
   if ti ne -1 then begin
      if strtrim(varstruct.(ti),2) ne '' then d=0B
   endif   
endif

c = size(d)
nc = n_elements(c)

; Determine if this variable is RV or NRV
nrv = 0L & rv = 0L ; initialize
ti = tagindex('VAR_TYPE',tag_names(varstruct))
if (ti ne -1) then begin ; var_type is present
  ;if (strupcase(varstruct.VAR_TYPE) eq 'METADATA') then nrv=1L else rv=1L
  ; RCJ 03/05/2003 Going to use cdfrecvary instead if var_type to determine nrv or rv:
  if (strupcase(varstruct.cdfrecvary) eq 'NOVARY') then nrv=1L else rv=1L
endif else rv=1L ; assume RV

; Determine the dimensionality and the data type based on record variance
if (rv eq 1L) then begin
  ; RCJ 10/22/2003 Changed these cases based on data tests.
  case c(0) of
    0   : begin
            ;print,'ERROR>size of data cannot be 0! - write_mycdf rv internal error'
            dims = 0L & dvar=[0]
          end
    1   : begin
             if strupcase(varstruct.CDFTYPE) eq 'CDF_EPOCH' then begin 
                dims = 0L
	        dvar=[0]
	     endif else begin
	        dims = 0L  ;c(1)  
	        dvar=[1]  
 	     endelse
	  end
          ; RCJ Below was the original:
          ;1   : begin & dims = 0L & dvar=[0] & end
    2   : begin
          pos=strpos(strupcase(tag_names(varstruct)),'DISPLAY_TYPE')
          if pos[0] ne -1 then begin
             if strpos(strupcase(varstruct.display_type),'TIME_SERIES') ne -1 or $
	        strpos(strupcase(varstruct.display_type),'STACK_PLOT') ne -1  or $  
	        varstruct.display_type eq '' or  varstruct.display_type eq ' ' or $  
	        strpos(strupcase(varstruct.display_type),'SPECTROGRAM') ne -1 then begin    
                dims = c(1) & dvar=[1]
             endif else begin
	        dims = [c(1),c(2)] & dvar=[1,1]
	     endelse
	  endif else begin
	     dims = c(1) & dvar=[1]
	  endelse    
          end   
         ; RCJ Below was the original:
         ;2   : begin &  dims = c(1) & dvar=[1] & end
    3   : begin & dims = [c(1),c(2)] & dvar=[1,1] & end
         ; RCJ Below was the original:
         ;3   : begin & dims = [c(1),c(2),c(3)] & dvar=[1,1,1] & end
    4   : begin & dims = [c(1),c(2),c(3)] & dvar=[1,1,1] & end
    else: print,'WARNING>cannot write cdfs with vars with > 3 dimensions!'
  endcase
endif
if (nrv eq 1L) then begin
  case c(0) of
    0   : begin
            ;print,'ERROR>size of data cannot be 0! - write_mycdf nrv internal error'
            dims = 0L & dvar=[0]
          end
    1   : begin & dims = c(1) & dvar=[1] & end
    2   : begin & dims = [c(1),c(2)] & dvar=[1,1] & end
    3   : begin & dims = [c(1),c(2),c(3)] & dvar=[1,1,1] & end
    else: print,'WARNING>cannot write cdfs with vars with > 3 dimensions!'
  endcase
endif

; Determine the type of the CDF variable 
dtype = lonarr(15) & nelems=1L ; initialize

;RCJ 06/01/2009  Added this first portion of if test.
;  Testing the case based on 'size' alone wasn't enough.
;  Some datasets have their own datatype as described in cdftype.
if rv eq 1 then begin  ; reasonable to say if rv=1 then cdftype exists ?
   case strupcase(varstruct.cdftype) of
        'CDF_BYTE': dtype(0)=1
	'CDF_CHAR': dtype(1)=1
	'CDF_DOUBLE': dtype(2)=1
        'CDF_EPOCH': dtype(3)=1
	'CDF_FLOAT': dtype(4)=1
	'CDF_INT1': dtype(5)=1
        'CDF_INT2': dtype(6)=1
	'CDF_INT4': dtype(7)=1
	'CDF_REAL4': dtype(8)=1        
	'CDF_REAL8': dtype(9)=1
	'CDF_UCHAR': dtype(10)=1
	'CDF_UINT1': dtype(11)=1
        'CDF_UINT2': dtype(12)=1
	'CDF_UINT4': dtype(13)=1
	'CDF_EPOCH16': dtype(14)=1
	; RCJ 07/30/09  cdf_long_epoch is now cdf_epoch16.  NOTE: in cdf_varcreate
	;  cdf_long_epoch still exists, so cdf_epoch16 would not to be confused w/ cdf_epoch.
	;'CDF_LONG_EPOCH': dtype(14)=1
   endcase  	
endif else begin
   ;print,'case: ',c(nc-2)
   case c(nc-2) of
     ; RCJ 09/01/06  These codes are based on idl's 'size' function 
     0   : print,'ERROR>Undefined data type'
     1   : dtype(0) = 1L ; cdf_byte
     2   : dtype(6) = 1L ; cdf_int2
     3   : dtype(7) = 1L ; cdf_int4
     4   : dtype(8) = 1L ; cdf_real4
     5   : begin ; determine if it is real8 or epoch
          ; determine if a CDFTYPE tag is present, if not then assume real8
          if tagindex('CDFTYPE',tag_names(varstruct)) eq -1 then dtype(9)=1L $
          else begin
            if varstruct.CDFTYPE eq 'CDF_EPOCH' then dtype(3) = 1L $
            else dtype(9) = 1L ; cdf_real8
          endelse
        end
     6   : print,'WARNING>CDF does not have complex_float type'
     7   : begin ; cdf_char
          dtype(10) = 1L
          ;nelems = strlen(d(0))
	  ; RCJ 08/13/2003 When saving labels of different lengths the line
	  ; above cuts off labels longer than the first element of these labels.
	  ; The line below works better:
          nelems = max(strlen(d))
        end
     8   : print,'WARNING>CDF does not have structure type'
     9   : begin
          dtype(14) = 1L
	end
     10  : print,'WARNING>CDF does not have pointer type'
     ; RCJ 10/22/2003 Added a few more types.
     ; RCJ 09/01/06  Fixing/Adding types based on idl6.3
     11  : print,'WARNING>CDF does not have object reference type'
     12  : dtype(12) = 1L ; cdf_uint2
     13  : dtype(13) = 1L ; cdf_uint4
     14  : print,'WARNING>CDF does not have long64 type'
     15  : print,'WARNING>CDF does not have ulong64 type'
     else: print,'ERROR>Unknown IDL data type'
   endcase
endelse

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
        CDF_UINT2=dtype(12),CDF_UINT4=dtype(13),CDF_LONG_EPOCH=dtype(14),$
        REC_NOVARY=nrv,REC_VARY=rv)
endif else begin
  vid = cdf_varcreate(id,vname,dvar,DIMENSIONS=dims,NUMELEM=nelems,$
        CDF_BYTE=dtype(0),CDF_CHAR=dtype(1),CDF_DOUBLE=dtype(2),$
        CDF_EPOCH=dtype(3),CDF_FLOAT=dtype(4),CDF_INT1=dtype(5),$
        CDF_INT2=dtype(6),CDF_INT4=dtype(7),CDF_REAL4=dtype(8),$
        CDF_REAL8=dtype(9),CDF_UCHAR=dtype(10),CDF_UINT1=dtype(11),$
        CDF_UINT2=dtype(12),CDF_UINT4=dtype(13),CDF_LONG_EPOCH=dtype(14),$
        REC_NOVARY=nrv,REC_VARY=rv)
endelse

; write the data into the cdf with special handling for character data

if c(nc-2) ne 7 then begin
   cdf_varput,id,vname,d 
endif else begin ; special processing for character data
  if ((c(0) eq 0)AND(d(0) ne '')) then cdf_varput,id,vname,d $
  else begin ; data is a string array
    ; pad all elements to same length and concatenate into single buffer
    maxlength = max(strlen(d))  
    buffer = ''
    for j=0,c(1)-1 do begin
      if strlen(d(j)) eq maxlength then buffer = [buffer , d(j)]  $
      else begin
        pad=' '
        for g=strlen(d(j)),(maxlength)-2 do pad = pad + ' '
        buffer = [buffer , d(j) + pad] 
      endelse
    endfor
    buffer=buffer[1:*]
    cdf_varput,id,vname,buffer,COUNT=[c(1)]
  endelse
endelse

return,vid
end

;-------------------------------------------------------------------------
; NAME: WRITE_MYCDF
; PURPOSE:
;       To input up to 15 idl structures of the type returned by read_mycdf,
;       and to output each as a CDF file.
; CALLING SEQUENCE:
;       status = write_mycdf(a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14)
; INPUTS:
;       instruct = input data structure
; KEYWORD PARAMETERS:
;       filename = the names of the cdf files being created (['file1.cdf','file2.cdf',...])
;       autoname = if set, then override the filename parameter by
;                  generating the name for the cdf file according to
;                  the ISTP filenaming conventions.  This will also
;                  cause the global attribute LOGICAL_FILE_ID to
;                  be set accordingly.
;       longtime = if set, is used in conjunction with the autoname
;                  keyword, but will cause a deviation from the ISTP
;                  filenaming conventions in that the timestamp in the
;                  filename will also include the starting hour of the data.
;       bothtimes = if set, is used in conjunction with the autoname and
;                   longtime keywords, will cause a deviation from the ISTP
;                   filenaming conventions in that the timestamp in the
;                   filename will include both start and stop times.
;       uppercase = if set, is used in conjunction with the autoname and
;                   longtime keywords such that the automatically deter-
;                   mined filename will be in all uppercase.
;       lowercase = if set, is used in conjunction with the autoname and
;                   longtime keywords such that the automatically deter-
;                   mined filename will be in all lowercase.
;       outdir    = if set, is used in conjunction with the autoname keywords
;                   to create the file in the specified directory.
;       cdf27_comp = 0/1  Create a cdf that's cdf2.7 backward compatible
;                   so it can be read by versions of idl previous to 6.3.
;                   The default is cdf3.0 when using idl6.3
;	novirtual = 0/1  If set the virtual vars will have only one data element:0 ,
;		    the their attributes FUNC, COMPONENT_0 and  VIRTUAL will
;		    remain unaltered.
;
; OUTPUTS:
;       status = integer indicating success (0) or failure (-1)
; EXAMPLE:
;       a = read_mycdf('','file1.cdf',/all) ; read all vars from file1.cdf
;       s = write_mycdf(a,filename='file2.cdf')      ; create same file named file2.cdf
;       s = write_mycdf(a0,a1,a2,/autoname)    ; create filename based on contents
;                                           ;  of structures 'a0,a1,a2'.
; AUTHOR:
;       Richard J. Burley, NASA/GSFC/Code 632,  June, 1998
;       burley@nssdca.gsfc.nasa.gov    (301)286-2864
; MODIFICATION HISTORY:
;   	Rita C Johnson, 01/06/2003. We want to be able to input more than 1 structure
;   	    	and come out with just as many cdfs.
;   	    	Also added a few print lines at the end of the program so it can
;   	    	be integrated into the CDAWeb system.
;-------------------------------------------------------------------------

; This package of routines complements the read_myCDF package.  read_myCDF
; reads one or more cdf's, and returns all data and metadata as a single
; structure.  write_myCDF will do just the opposite, given a similar structure,
; it will write a cdf.

FUNCTION write_myCDF, a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,$
                      filename=filename, AUTONAME=AUTONAME,  LONGTIME=LONGTIME,  $
                                   BOTHTIMES=BOTHTIMES,OUTDIR=OUTDIR,      $
                                   UPPERCASE=UPPERCASE,LOWERCASE=LOWERCASE,$
                                   CDF27_COMP=CDF27_COMP, NOVIRTUAL=NOVIRTUAL, $
				   DEBUG=DEBUG
; Verify that number of parameters is acceptable
if ((n_params() le 0)OR(n_params() gt 15)) then begin
  print, 'STATUS= No data selected for plotting'
  print,'ERROR=Number of parameters must be from 1 to 15' & return,-1
endif

if keyword_set(filename) then begin
   if (n_elements(filename) ne n_params()) then begin
      print,'ERROR=Enter a string array with one filename for each input structure' 
      return,-1
   endif
endif else autoname=1


files=''
datasets=''
if keyword_set(filename) then cdfnames=filename
ttime = systime(1)

for k=0,n_params()-1 do begin ; process each structure parameter

   w = execute('a=a'+strtrim(string(k),2))
   already_created='' ;  to be used before one of the calls to create_myCDF_variable
   new_order=1000  ;  dummy # to start array. use to eliminate redundant var names but keep the same order

   ; RCJ 05/05/2003 Temporary test to exclude isis, rpi. These are not producing good cdfs
   ; RCJ 06/04/2003 I think I fixed the case for isis data. Will test in dev.
   ; RCJ 07/31/2003 RPI seems fixed too. I added some logic a little bit further
   ;     down that includes the ignore_data vars if they are depends or components
   ;
   ;b = tag_names(a.(0)) & w = where(b eq 'MISSION_GROUP')
   ;if w[0] ne -1 then begin
      ;case strupcase(a.(0).MISSION_GROUP) of
      ;'ISIS': begin
      ;   print, 'STATUS=Currently cannot write cdf for ISIS data'
      ;   print,'ERROR=Cannot write cdf for ISIS data'
      ;   return,-1
      ;end 
      ;'IMAGE': begin
      ;   if strpos(strupcase(a.(0).DESCRIPTOR),'RPI') ne -1 then begin
      ;     print, 'STATUS=Currently cannot write cdf for RPI data'
      ;	    print,'ERROR=Cannot write cdf for RPI data'
      ;     return,-1
      ; 	 endif   
      ;end
      ;else:
      ;endcase
   ;endif

   ;is there any good data? should we even start processing the structure?
   ok=0
   for j=0,n_elements(tag_names(a))-1 do begin
      b = evaluate_varstruct(a.(j))
      if b.ptype ne 0 then ok=[ok,1] else ok=[ok,0]
   endfor
   ok=ok[1:*]

   q=where(ok ne 0)   
   if q[0] eq -1 then begin
      ;print,'STATUS=No valid data for '+strupcase(a.(k).logical_source)+'. Please try another time range.' 
      print,'STATUS=No valid data for '+strupcase(a.(0).logical_source)+'. Please try another time range.' 
   endif else begin   
      ; Identify the global attributes.
      b = tag_names(a.(0)) 
      w = where(b eq 'FIELDNAM',wc) 
      gattrs=indgen(w(0)-1)+1
      ; Determine the order of the variables to be written to the CDF.
      b = tag_names(a) 
      nb = n_elements(b)
      c = intarr(nb)
      d = indgen(nb)
      ; RCJ 09/08/2003 Look for all depends and components. Even if the vars are 'ignore_data' we will
      ; want them.
      ; RCJ 09/17/2003 Also look at the display_type attribute. For example, in the case of
      ; RPI data there were variables needed for a plasmagram (labels) whose names were
      ; only found in the display_type attribute. 
      needed_vars=''
      for i=0,nb-1 do begin
         if (tagindex('DISPLAY_TYPE',tag_names(a.(i)))) ne -1 then begin        
	    out=parse_display_type(a.(i).display_type)
	    if strtrim(out[0],2) ne '-1' then needed_vars=[needed_vars, out]
	 endif
	 for ii=0,3 do begin
	 ;print,tagindex('DEPEND_0',tag_names(a.(i)))
         ;if (tagindex('DEPEND_0',tag_names(a.(i)))) ne -1 then needed_vars=[needed_vars,a.(i).depend_0]
	 comm='if (tagindex("DEPEND_'+strtrim(ii,2)+ $
	    '",tag_names(a.(i)))) ne -1 then needed_vars=[needed_vars,a.(i).depend_' + $
	    strtrim(ii,2)+']'
	 s=execute(comm)   
	 endfor
	 for ii=0,14 do begin
	 ;if (tagindex('COMPONENT_0',tag_names(a.(i)))) ne -1 then needed_vars=[needed_vars,a.(i).component_0]
	 comm='if (tagindex("COMPONENT_'+strtrim(ii,2)+ $
	    '",tag_names(a.(i)))) ne -1 then needed_vars=[needed_vars,a.(i).component_' + $
	    strtrim(ii,2)+']'
	 s=execute(comm)
	 endfor
	 ; RCJ 10/22/2003 Delta plus and minus vars have to be added at this point too.
	 if (tagindex('DELTA_MINUS_VAR',tag_names(a.(i)))) ne -1 then $
	    needed_vars=[needed_vars,a.(i).delta_minus_var]
 	 if (tagindex('DELTA_PLUS_VAR',tag_names(a.(i)))) ne -1 then $
	    needed_vars=[needed_vars,a.(i).delta_plus_var]
     endfor
      if (needed_vars[0] ne '') then needed_vars=needed_vars[1:*]  
      needed_vars=needed_vars(uniq(needed_vars,sort(needed_vars))) 
      ;print,'needed_vars = ',needed_vars
      for i=0,nb-1 do begin
         ;if a.(i).CDFTYPE eq 'CDF_EPOCH' then c(i) = 2 $ ; time variable
         ;else if strupcase(a.(i).VAR_TYPE) eq 'DATA' then c(i) = 1 ; RV variable
         if strupcase(a.(i).VAR_TYPE) eq 'SUPPORT_DATA' then c(i) = 1 ; RV variable
         if a.(i).CDFTYPE eq 'CDF_EPOCH' then c(i) = 2 ; time variable
         if strupcase(a.(i).VAR_TYPE) eq 'DATA' then c(i) = 1 ; RV variable
         ;if strupcase(a.(i).VAR_TYPE) eq 'IGNORE_DATA' then c(i) = -1 ; RV variable
         pos_needed_vars=where(strupcase(needed_vars) eq strupcase(a.(i).varname))
         ;print,'varname: ',strupcase(a.(i).VARname),'  vartype: ',strupcase(a.(i).VAR_type)
	 ;print,'zeros: ',pos_needed_vars[0]
	 ;
	 ; RCJ 09/2003 If var_type is ignore_data *and* the variable is not a depend_0,1,2
	 ; or component_0,1,2 to any other variable, then don't include it in the cdf,
	 ; make c[i]=-1
         if (strupcase(a.(i).VAR_TYPE) eq 'IGNORE_DATA') and $
	 (pos_needed_vars[0] eq -1) $
	 then c(i) = -1 ; RV variable
	 ; RCJ 09/10/2003 Now that we decided if this ignore_data var should
	 ; be added to the new cdf, let's make it support_data, basically
	 ; not to confuse SKTEditor.
         if (strupcase(a.(i).VAR_TYPE) eq 'IGNORE_DATA') then begin
	    a.(i).var_type='support_data'
	    ;print,'new var_type: ',a.(i).var_type,'  ',a.(i).varname
	 endif   
      endfor
      w2 = where(c eq 2,wc2) & if wc2 gt 0 then s=d(w2)
      w1 = where(c eq 1,wc1) & if wc1 gt 0 then s=[s,d(w1)]
      w0 = where(c eq 0,wc0) & if wc0 gt 0 then s=[s,d(w0)]
      order = s
      ; Determine the name of the new CDF if autonaming option is turned on
      if keyword_set(AUTONAME) then begin
        filename = autoname_mycdf(a,LONGTIME=LONGTIME,BOTHTIMES=BOTHTIMES,$
                            UPPERCASE=UPPERCASE,LOWERCASE=LOWERCASE)
        s = size(filename) & i = n_elements(s)
        if (s(i-2) ne 7) then begin
	   print,'ERROR: In autoname'
	   return,-1 ; fatal error in autoname
	endif   
      endif else begin
         filename=cdfnames(k)
      endelse
      
      ; Create the new CDF
      ;
      if keyword_set(OUTDIR) then begin
         case (strupcase(!version.os_family)) of 
                'UNIX': begin
		; RCJ 12/11/2006  If buf1,buf2,buf3,...  /'s can accumulate
		   if strmid(outdir,strlen(outdir)-1L,1) ne '/' $
		      then outdir=outdir+'/'
		 end  
                'MACOS': begin
		   if strmid(outdir,strlen(outdir)-1L,1) ne '/' $
		      then outdir=outdir+'/'; osX ?
		 end  
                'WINDOWS': begin
		   if strmid(outdir,strlen(outdir)-1L,1) ne '\' $
		      then outdir=outdir+'\' 
		 end  
                else: print, 'Warning! Unknown OS. ' 
         endcase
         res=findfile(outdir+filename)
      endif else res=findfile(filename)
      if res[0] ne '' then begin	 
         case (strupcase(!version.os_family)) of 
            'UNIX': begin
	       if keyword_set(outdir) then spawn,'rm -f '+outdir+filename $
	       else spawn,'rm -f '+filename
	     end  
            'MACOS': begin
	       if keyword_set(outdir) then spawn,'rm -f '+outdir+filename $
	       else spawn,'rm -f '+filename
	     end  
            'WINDOWS': begin
	       if keyword_set(outdir) then spawn,'del '+outdir+filename $
	       else spawn,'del '+filename
	       ; DOS window will flash on screen!!
	       ; RCJ 09/2006  From IDL help: "Issuing a SPAWN command when 
	       ; IDL's current working directory is set to a UNC path 
	       ; will cause Windows to generate an error"
	       ; UNC=Universal/Uniform Naming Convention
	       ; and it looks like this:  \\server\volume\directory\file
	     end  
            else: begin
	       if keyword_set(outdir) then print, 'Unknown OS. Could not remove already existing ',outdir+filename $
               else print, 'Unknown OS. Could not remove already existing ',filename 
            end
         endcase
      endif	 
      if keyword_set(DEBUG) then begin
         print,'Now creating the CDF ',filename 
         if keyword_set(outdir) then print, 'in ',outdir
      endif	 
      if keyword_set (cdf27_comp) then cdf_set_cdf27_backward_compatible, /yes
      if keyword_set (outdir) then $
         id = cdf_create(outdir+filename,/clobber,/NETWORK_ENCODING,/SINGLE_FILE,/COL_MAJOR)$
         else id = cdf_create(filename,/clobber,/NETWORK_ENCODING,/SINGLE_FILE,/COL_MAJOR)
      ;
      ; RCJ 04/28/2008  Adding call to md5checksum. For cdf3.1 or earlier this command seems to be ignored.
      ;cdf_set_md5checksum,id,/yes
      ;
      ; Write global attributes to the CDF
      if keyword_set(DEBUG) then print,'Writing global attributes to the CDF...'
      b = tag_names(a.(0)) ; get names of attributes
      for i=0,n_elements(gattrs)-1 do begin
        g = ISTP_gattr_casecheck(b(gattrs(i)))  ; perform ISTP-case checking
        ; RCJ 03/14/2003  Update some logical attributes:
	fname=strsplit(filename,'.',/extract)
	if strupcase(g) eq 'LOGICAL_FILE_ID' then a.(0).(gattrs(i))=fname[0]
	lsrc=a.(0).(gattrs(i))
	lsrc=strsplit(lsrc[0],'_',/extract)
	if strupcase(g) eq 'LOGICAL_SOURCE' then begin
	   case n_elements(lsrc) of
	      3:  a.(0).(gattrs(i))=strupcase(lsrc[0]+'_'+lsrc[1]+'s_'+lsrc[2])
	      4:  a.(0).(gattrs(i))=strupcase(lsrc[0]+'_'+lsrc[1]+'s_'+lsrc[2]+'_'+lsrc[3])
              5:  a.(0).(gattrs(i))=strupcase(lsrc[0]+'_'+lsrc[1]+'s_'+lsrc[2]+'_'+lsrc[3]+'_'+lsrc[4])
              6:  a.(0).(gattrs(i))=strupcase(lsrc[0]+'_'+lsrc[1]+'s_'+lsrc[2]+'_'+lsrc[3]+'_'+lsrc[4]+'_'+lsrc[5])
	   endcase
	endif   
        if (strupcase(g) eq 'LOGICAL_SOURCE_DESCRIPTION' or $
	   strupcase(g) eq 'DATA_TYPE') then $
	   a.(0).(gattrs(i))='DERIVED FROM: '+a.(0).(gattrs(i))
	if strupcase(g) eq 'TEXT' then begin
	   if strupcase(!version.os_family) eq 'WINDOWS' then begin
	      spawn,'date /T',d
	      spawn,'time /T',t
	      d=d+t  ; to get date *and* time
	   endif else spawn,'date',d
	   der='CDAWeb'
	   spawn,'printenv SCRIPT_NAME',dd
	   if strpos(dd[0],'cdawdev') ne -1 then der='CDAWeb dev'
	   if strpos(dd[0],'cdaweb') ne -1 then der='CDAWeb ops'
	   ;string(13B))  =  <CR>   and  string(10B)) = <LF> 
	   a.(0).(gattrs(i))= $
	      ;;der + ' interface derived data on '+ d +string(13B)+ $
	      ;;string(10B) + a.(0).(gattrs(i))
	      ;der + ' interface derived data on '+ d +'  '+ $
	      ; RCJ 10/22/2003 Added contacts:
	      der + ' interface derived data on '+ d +'. Contacts:  '+ $
	   'Tami.J.Kovalick@gsfc.nasa.gov, Rita.C.Johnson@gsfc.nasa.gov. ' + $ 
	      a.(0).(gattrs(i))
	endif   
	;
        aid = cdf_attcreate(id,g,/GLOBAL_SCOPE) ; create the attribute
        ; Now put the proper value in the attribute
        s = size(a.(0).(gattrs(i)))  
	ns = n_elements(s)  
	c=''
        if (s(ns-2) eq 7) then begin ; special case for string handling
          if s(0) eq 0 then begin ; single string, not an array of strings
            c = a.(0).(gattrs(i))  
	    if c ne '' then cdf_attput,id,aid,0L,c
          endif else begin ; attribute value is an array of strings
             for j=0,s(1)-1 do begin
               c=a.(0).(gattrs(i))(j) 
	       ;if c[0] ne '' then cdf_attput,id,aid,j,c
	       if c[0] eq '' then c[0]=' '
	       cdf_attput,id,aid,j,c
             endfor
          endelse
        endif else cdf_attput,id,aid,0L,a.(0).(gattrs(i))
      endfor

      ; Create the variables
      for i=0,n_elements(order)-1 do begin
        b = order(i) 
	;vname = a.(b).VARNAME
	q=where(already_created eq a.(b).varname)
        if q[0] eq -1 then begin
	   vid = create_myCDF_variable(id, a.(b),novirtual=novirtual,DEBUG=DEBUG)
           already_created=[already_created,a.(b).varname]
	   new_order=[new_order,b]
	endif   
      endfor ; create and write all variables
      order=new_order[1:*]

      ; Write the variable attributes to the CDF
      for i=0,n_elements(order)-1 do begin ; loop through every variable
      ;for i=0,n_elements(tag_names(a))-1 do begin ; loop through every variable
        ;vname = a.(i).VARNAME ; get the case sensitive variable name
        vname = a.(order(i)).VARNAME ; get the case sensitive variable name
        ;vtags = tag_names(a.(i)) ; get the attribute names
        vtags = tag_names(a.(order(i))) ; get the attribute names
        from = tagindex('FIELDNAM',vtags) ; fieldnam is the first vattr
        to   = tagindex('CDFTYPE' ,vtags) ; cdftype is the next non-vattr
        for j=from,to-1 do begin ; process each variable attribute
            ;print,'vtags(j) = ',vtags(j)
	  case vtags(j) of 
	     'DELTA_MINUS_VAR': a.(order(i)).(j)=replace_bad_chars(a.(order(i)).(j),diff)
	     'DELTA_PLUS_VAR': a.(order(i)).(j)=replace_bad_chars(a.(order(i)).(j),diff)
	     ;'COMPONENT_0': a.(order(i)).(j)=''
	     'COMPONENT_0': if not keyword_set(novirtual) then a.(order(i)).(j)=''
	     'COMPONENT_1': if not keyword_set(novirtual) then a.(order(i)).(j)=''
             ;11/5/04 - TJK - had to change FUNCTION to FUNCT for IDL6.* compatibility
             ;	     'FUNCTION': a.(order(i)).(j)=''
	     'FUNCT': if not keyword_set(novirtual) then a.(order(i)).(j)=''
	     'VIRTUAL': if not keyword_set(novirtual) then a.(order(i)).(j)=''
	     else: ; do nothing
	  endcase     
          if i eq 0 then aid = cdf_attcreate(id,vtags(j),/VARIABLE_SCOPE) $
          else aid = cdf_attnum(id,vtags(j)) ; get id of existing attribute
          ;if i eq 0 then begin
             ;aid = cdf_attnum(id,vtags(j)) ; get id of existing attribute
             ;help,aid
             ;if aid eq -1 then $
             ;aid = cdf_attcreate(id,vtags(j),/VARIABLE_SCOPE) 
          ;endif   
          ; Special processing is required for ISTP-stype pointer attributes.
          ; If the current attribute is such an attribute, do not process it here.
          if (amI_ISTPptr(vtags(j)) ne 1) then begin
            ;s = size(a.(i).(j)) & ns = n_elements(s)
            s = size(a.(order(i)).(j)) 
	    ns = n_elements(s)
            ;if (s(ns-2) ne 7) then cdf_attput,id,aid,vname,a.(i).(j) $
            ;if (s(ns-2) ne 7) then cdf_attput,id,aid,vname,a.(order(i)).(j) $
            if (s(ns-2) ne 7) then begin
	       if not keyword_set(novirtual) then cdf_attput,id,aid,vname,a.(order(i)).(j)
            endif else begin ; special processing for character data
              if s(0) eq 0 then begin
                ;e = a.(i).(j)
                e = a.(order(i)).(j)
		if e ne '' then cdf_attput,id,aid,vname,e
              endif else begin ; data is a string array
                print,'WARNING: ',vtags(j),' vattr not written because of IDL bug!'
              endelse
            endelse
          endif 
          ;endif; my if
        endfor
      endfor

      ; Perform special processing for ISTP pointer-type attributes.  When such an
      ; attribute is located, a new metadata variable may have to be created.  This
      ; depends on how the original cdf was read.  If the original cdf was read
      ; with the /all keyword, then all variables, including non-record-varying
      ; metadata were read into the structure.  If not, then those non-record-
      ; varying variables may have been lost, in which case new variables must
      ; be created.
      mvcount = 0L
      for i=0,n_elements(tag_names(a))-1 do begin ; loop through every variable
         vtags = tag_names(a.(i)) ; get the name of every attribute
         for j=0,n_elements(vtags)-1 do begin
	    q=where(a.(i).(j) ne '')
            if ((amI_ISTPptr(vtags(j)) eq 1)AND $
	       ;(a.(i).(j)(0) ne '') and $
	       ; RCJ 11/14/2003 Replaced line above w/ line below.
	       ; If a.(i).(j) is an array we have to check all of its elements
	       ; not only the first one.
	       (q[0] ne -1) and $
	       (strupcase(a.(i).var_type) ne 'IGNORE_DATA')) then begin
                ;print,'special processing for istpptr for var '$
		;,a.(i).varname,' attr ', vtags(j)
               ; determine if any other variable in the structure has the same
               ; value as a.(i).(j) so that unneeded metavars are not created.
               pvar = -1 ; initialize flag
               ; print,'searching existing variables for correct value'
               for g=0,n_elements(tag_names(a))-1 do begin ; loop through every var
                  if compare_vars(a.(i).(j),get_mydata(a,g)) eq 1 then begin
                     pvar  = g ; variable with matching value already exists
                     ;vname = (tag_names(a))(g)
		     ; RCJ 10/08/2003 Line above causes problems. Vname is all
		     ; capitalized , masking the real var name which can be
		     ; a combination of capital and non-capital letters.
		     ; The line below gives us the real varname.
                     vname = a.(g).varname
                     print,'value found in the variable ',vname,' pvar=',pvar
                   endif
               endfor

               ; if no existing variable in the structure has the correct value,
               ; then determine if any metavar has already been created with that value.
               if pvar eq -1 then begin
                  ; print,'searching previously created metavars for correct value'
                  for g=0,mvcount-1 do begin
                     if compare_vars(a.(i).(j),a.(pv(g)).(pt(g))) eq 1 then begin
                        pvar  = g ; same attribute value exists
                        vname = pvn(g) ; get name of metavar which already exists
                        ;print,'value found in the variable ',vname,' pvar=',pvar
                     endif
                  endfor
               endif

               ; if pvar still equals -1, then no variable with a matching value exists
               ; in the original structure, or has been previously created as a metavar.
               ; In this case, a new metavar must now be created.
               if (pvar eq -1) then begin
                  ; determine the name for new variable
                  vname = 'metavar' + strtrim(string(mvcount),2)
                  ; print,'creating new metavar named ',vname
                  ; create a variable structure
                  va = create_struct('VARNAME',vname)
                  vb = create_struct('VAR_TYPE','metadata')
		  ; RCJ 10/06/2003 If a.(i).(j) is not array it cannot
		  ; be reformed
		  if n_elements(a.(i).(j)) eq 1 then $
		     vc = create_struct('DAT',a.(i).(j)) else $
                     vc = create_struct('DAT',reform(a.(i).(j)))
		  ; RCJ I added the line below because I look for this attr later on...
                  vd = create_struct('CDFRECVARY','novary')
                  v  = create_struct(va,vb) & v = create_struct(v,vc) 
		  v = create_struct(v,vd)
                  ; create the new variable in the CDF
                  vid = create_myCDF_variable(id, v,novirtual=novirtual)
                  cdf_attput,id,'VAR_TYPE',vname,'metadata'
                  cdf_attput,id,'FIELDNAM',vname,vname
		  ; RCJ 10/22/2003 Vars need catdesc and format to pass skteditor test.
                  cdf_attput,id,'CATDESC',vname, 'Metadata for variable '+ $
		     a.(i).varname + ' and possibly other variables.'
                  cdf_attput,id,'FORMAT',vname,'a'+strtrim(strlen(v.dat(0)),2)
                  ; record the number of the new variable and attribute tag number
                  if mvcount eq 0 then begin
                     pv = i & pt = j & pvn = vname
                  endif else begin
                     pv = [pv,i] & pt = [pt,j] & pvn = [pvn,vname]
                  endelse
                  mvcount = mvcount + 1 ; increment metavariable count
               endif
               ; point to the correct variable from the istp-pointer type attribute
               ; print,'setting ',a.(i).VARNAME,' ',vtags(j),' to ',vname
               cdf_attput,id,vtags(j),a.(i).VARNAME,vname
            endif
         endfor
      endfor ; end i
      ; Close the new CDF
      cdf_close,id
      files=[files,filename]
      datasets=[datasets,a.(0).logical_source]
   endelse
endfor
print, 'write_mycdf took ',systime(1)-ttime, ' seconds to run'
; RCJ 12/30/2002
; the 'print' lines below are needed so parse.ph will be able to get this information from 
; the idl log file. You have to make sure each print line fits in one line of output.
; If the filename, for example, ends up in the next line parse.ph will read 'new_cdf' as empty.
if n_elements(files) gt 1 then begin 
   files=files[1:*]
   datasets=datasets[1:*]
   for k=0,n_elements(files)-1 do begin
      print, 'DATASET=',strupcase(datasets[k])
      ; RCJ  This next line is needed for the web interface
      if keyword_set(outdir) then print, 'CDF_OUTDIR=',outdir
      print, 'NEW_CDF'+strtrim(string(k),2)+'=',files[k]
   endfor
endif ;else return,-1
;
return,0
end


