 ;+
; NAME:
;	read_tidi
;
; PURPOSE:
;	File reader for TIDI ncdf files
;
; CATEGORY:
;	Reading NCDF files
;
; CALLING SEQUENCE:  
;	read_tidi, file, structure, (dir)
;
; INPUTS:
;       File      :  Input filename
;       Structure :  Output structure name
;       Dir       :  Optional directory
;
; COMMENTS:
;       Written for level 2 (PRF and invert) and level 3 (Vec) TIDI data files
;
; ROUTINES CALLED:
;	NCDF_OPEN, NCDF_VARGET, NCDF_VARINQ, NCDF_ATTGET, NCDF_ATTINQ
;       NCDF_INQUIRE, NCDF_DIMINQ
;
; MODIFICATION HISTORY:
;	Jason Craig	12-15-2003	Creation
;+

; delvarx HISTORY:
;	written by slf, 25-Feb-1993
;	Converted to IDL V5.0   W. Landsman   September 1997
PRO delvarx, p0,p1,p2,p3,p4,p5,p6,p7,p8,p9
   FOR i = 0, N_PARAMS()-1 DO BEGIN ; for each parameter
      param = STRCOMPRESS("p" + STRING(i),/remove)
;  only delete if defined on inpu (avoids error message)
      exestat = execute("defined=n_elements(" + param + ")" ) 
      IF defined GT 0 THEN BEGIN
         exestat = execute(param + "=0")
         exestat = execute("dvar=temporary(" + param + ")" )
      ENDIF
   ENDFOR
   RETURN
END

pro read_tidi, filename, stru, dir

; Default directory to look for LOS file
directory = '/janus/f/l3/vec/2003/'

params = n_params()
if params lt 2 then begin
    print, 'Usage: read_vec, filename, return_struct, (directory)
    return
endif
if params eq 3 then directory = dir

fid = NCDF_OPEN(directory+filename, /NOWRITE)

finq = NCDF_INQUIRE( fid )
dim_name = strarr( finq.ndims )
dim_size = lonarr( finq.ndims )
for k=0,finq.ndims-1 do begin
  NCDF_DIMINQ, fid, k, dimstr, dimsize
  dim_name[k] = dimstr
  if(dimsize eq 0) then print, "Error: a diminsion's size is 0, any variable with that diminsion will not be read in."
  dim_size[k] = dimsize
endfor

for i = 0, finq.ngatts -1 do begin
  attname = NCDF_ATTNAME(fid, /GLOBAL, i)
  NCDF_ATTGET, fid, /GLOBAL, attname, temp
  inq = NCDF_ATTINQ(fid, /GLOBAL, attname)
  if(inq.datatype eq 'CHAR') then temp = strtrim(STRING(temp))
  if i eq 0 then stru = CREATE_STRUCT(attname, temp) else $
    stru = CREATE_STRUCT(stru, attname, temp)
endfor

for i = 0, finq.nvars -1 do begin
  id = i
  inq = NCDF_VARINQ(fid, id)
  number_dims = N_ELEMENTS(inq.dim)
  bad = 0
  for j = 0, number_dims -1 do if(dim_size[inq.dim[j]] eq 0) then bad = 1
  if(bad eq 0) then begin
      if(inq.datatype eq 'CHAR') then begin  ; Convert chars to strings
         if(number_dims eq 1) then begin     
           NCDF_VARGET, fid, id, temp
           temp2 = bytarr(1,dim_size[inq.dim[0]])  ; To convert we need N+1 diminsion array
           temp2[0,*] = temp
           stru = CREATE_STRUCT(stru, inq.name, strtrim(string(temp2)))
           delvarx, temp2
         endif else begin
           NCDF_VARGET, fid, id, temp
           stru = CREATE_STRUCT(stru, inq.name, strtrim(string(temp)))
         endelse
      endif else begin
        NCDF_VARGET, fid, id, temp
        stru = CREATE_STRUCT(stru, inq.name, temp)
      endelse
      delvarx, temp
  endif
endfor
end
