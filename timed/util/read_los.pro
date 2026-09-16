 ;+
; NAME:
;	read_los
;
; PURPOSE:
;	.LOS file reader for TIDI Line of Sight ncdf files
;       reads only version 4 and later LOS files
;       (denoted by P0400 in the file name)
;
; CATEGORY:
;	Reading NCDF LOS files
;
; CALLING SEQUENCE:  
;	read_los, file, structure, (dir, /spectra, /all)
;
; INPUTS:
;	file, name of file to read
;	structure, returned structure where structure.variables
;	dir, directory of file, otherwise uses default
;       /spectra, returns the spectra and rawspectra in the structure
;       /all, returns every variable in the LOS file
;
; OUTPUTS:
;       Returns the variables listed in the default varaibles list (below)
;       in the structre.  
;       If the /spectra flag is present, it will also return the 
;       spectra and raw spectra, with one variable for
;       each, in the structure.
;       If the /all flag is present it will return all the variables
;       listed in the LOS file
;	
; COMMENTS:
;       Feel free to change the default directory
;       and also the default variables to suit your needs.
;       Warning: /all flag returns a LARGE amount of variables and
;                requires ~1GB+ of memory to execute.
;
;
; ROUTINES CALLED:
;	NCDF_OPEN, NCDF_VARGET, NCDF_VARINQ, NCDF_ATTGET, NCDF_ATTINQ
;       NCDF_INQUIRE, NCDF_DIMINQ
;
; MODIFICATION HISTORY:
;	Jason Craig	11-07-2003	Creation
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

pro read_los, filename, stru, dir, spectra=spectra, all=all

; Default directory to look for LOS file
directory = '/janus/d/l1/los/2003/'

; default attributes
attributes = ['title', 'data_product_type', 'mission', 'source', $ 
  'software_name', 'filename','magnetic_latitude_model', 'data_product_version' $
  ,'software_version', 'solar_beta_angle', 'att_s_var', 'att_h_var']

; Default variables (feel free to change):
variables = ['time', 'ms_time', 'ut_time', $
  'tp_lat', 'tp_lon', 'tp_alt', 'tp_lst', 'tp_sza', 'tp_sscat', $
  'tp_lza', 'tp_lscat', 'tp_track', 'tp_eci', 'sc_eci_pos', $
  'sc_eci_vel', 'sc_vlos', 'var_sc_vlos', 'sc_lat', 'sc_lon', 'sc_alt', $
  'sc_lst', 'sc_sza', 'sc_lza', 'sc_track', 'table_id', 'table_index', $
  'binning_id', 'tel_id', 'int_period', 'elevation', 'fw1_position', $
  'fw2_position', 'fw_config', 'los_direction', 'view_vector', $
  'ut_date', 'shut_position', 'flight_dir', 'in_saa', 'ascending', 'data_ok', $]
  'gain_values', 'b', 'var_b', 's', 'var_s', 't_doppler', 'var_t_doppler']


params = n_params()
if params lt 2 then begin
    print, 'Usage: read_LOS, filename, return_struct, (directory, /spectra, /all)
    return
endif
if params eq 3 then directory = dir

if keyword_set(spectra) then spectra=1 else spectra=0
if keyword_set(all) then begin
    all=1 
    spectra=1
endif else all=0

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

did = NCDF_DIMID(fid, 'nlos')
NCDF_DIMINQ, fid, did, name, nlos




if(not all) then begin
  number_of_global = N_ELEMENTS(attributes)
  for i = 0, number_of_global -1 do begin
    NCDF_ATTGET, fid, /GLOBAL, attributes[i], temp
    inq = NCDF_ATTINQ(fid, /GLOBAL, attributes[i])
    if(inq.datatype eq 'CHAR') then temp = strtrim(STRING(temp))
    if i eq 0 then stru = CREATE_STRUCT(attributes[i], temp) else $
      stru = CREATE_STRUCT(stru, attributes[i], temp)
  endfor
   
  number_of = N_ELEMENTS(variables)
  for i = 0, number_of-1 do begin
    id = NCDF_VARID(fid, variables[i])
    inq = NCDF_VARINQ(fid, id)
    number_dims = N_ELEMENTS(inq.dim)
    bad = 0
    for j = 0, number_dims -1 do if(dim_size[inq.dim[j]] eq 0) then bad = 1
    if(bad eq 0) then begin
      NCDF_VARGET, fid, id, temp
      if(inq.datatype eq 'CHAR') then $
        stru = CREATE_STRUCT(stru, variables[i], strtrim(string(temp))) else $
        stru = CREATE_STRUCT(stru, variables[i], temp)
      delvarx, temp
    endif
  endfor

endif else begin  ; /all flag, Get every variable in the file

 finq = NCDF_INQUIRE(fid)
 number_of_global = finq.ngatts
 for i = 0, number_of_global -1 do begin
   name = NCDF_ATTNAME(fid, /global, i)
   NCDF_ATTGET, fid, /GLOBAL, name, temp
   inq = NCDF_ATTINQ(fid, /GLOBAL, name)
   if(inq.datatype eq 'CHAR') then temp = strtrim(STRING(temp))
   if i eq 0 then stru = CREATE_STRUCT(name, temp) else $
     stru = CREATE_STRUCT(stru, name, temp)
 endfor

 dim_name = strarr( finq.ndims )
 dim_size = lonarr( finq.ndims )
 for k=0,finq.ndims-1 do begin
   NCDF_DIMINQ, fid, k, dimstr, dimsize
   dim_name[k] = dimstr
   if(dimsize eq 0) then print, "A diminsion size is 0, any variable for that diminsion will not be read in."
   dim_size[k] = dimsize
 endfor

 number_of = finq.nvars
 for i = 0, number_of-1 do begin
   inq = NCDF_VARINQ(fid, i)
   name = inq.name
   if(not(name eq 'spec405' or name eq 'spec045' or name eq 'spec135' or name eq 'spec225' or $
      name eq 'spec315' or name eq 'rawspec405' or name eq 'rawspec045' or name eq 'rawspec135' or $
      name eq 'rawspec225' or name eq 'rawspec315' or name eq 'vspec405' or name eq 'vspec045' or $
      name eq 'vspec135' or name eq 'vspec225' or name eq 'vspec315' or name eq 'spec_index')) then begin
     number_dims = N_ELEMENTS(inq.dim)
     bad = 0   ; If any of the dimensions are 0 dont read it
     for j = 0, number_dims -1 do if(dim_size[inq.dim[j]] eq 0) then bad = 1
     if(bad eq 0) then begin
         NCDF_VARGET, fid, i, temp
         if(inq.datatype eq 'CHAR') then $
           stru = CREATE_STRUCT(stru, name, strtrim(string(temp))) else $
           stru = CREATE_STRUCT(stru, name, temp)
         delvarx, temp
     endif
   endif
 endfor

endelse

if(spectra) then begin
  merge = 1
;  if merge = 1 , then merge the telescopes back into one variable
;  scan number will appear 5 times per time stamp, once for each telescope
;  use tel_id variable to determine telescope #
;  Spectra( Channel #, Scan #)
  did = NCDF_DIMID(fid, 'spec405_dim')
  NCDF_DIMINQ, fid, did, did, dim405
  did = NCDF_DIMID(fid, 'spec045_dim')
  NCDF_DIMINQ, fid, did, did, dim045
  did = NCDF_DIMID(fid, 'spec135_dim')
  NCDF_DIMINQ, fid, did, did, dim135
  did = NCDF_DIMID(fid, 'spec225_dim')
  NCDF_DIMINQ, fid, did, did, dim225
  did = NCDF_DIMID(fid, 'spec315_dim')
  NCDF_DIMINQ, fid, did, did, dim315
  dim405 = dim405 -1
  dim045 = dim045 -1
  dim135 = dim135 -1
  dim225 = dim225 -1
  dim315 = dim315 -1

  id = NCDF_VARID(fid, "spec_index")
  NCDF_VARGET, fid, id, spec_index
  if(merge eq 0) then begin

    ;print, "Spectras are not alligned, and will not be merged"

    did = NCDF_DIMID(fid, 'spec405')
    NCDF_DIMINQ, fid, did, did, dim405
    stru = CREATE_STRUCT(stru, "spec405", spec405)
    delvarx, spec405

    did = NCDF_DIMID(fid, 'spec045')
    NCDF_DIMINQ, fid, did, did, dim045
    stru = CREATE_STRUCT(stru, "spec045", spec045)
    delvarx, spec045

    did = NCDF_DIMID(fid, 'spec135_')
    NCDF_DIMINQ, fid, did, did, dim135
    stru = CREATE_STRUCT(stru, "spec135", spec135)
    delvarx, spec135

    did = NCDF_DIMID(fid, 'spec225')
    NCDF_DIMINQ, fid, did, did, dim225
    stru = CREATE_STRUCT(stru, "spec225", spec225)
    delvarx, spec225

    did = NCDF_DIMID(fid, 'spec315')
    NCDF_DIMINQ, fid, did, did, dim315
    stru = CREATE_STRUCT(stru, "spec315", spec315)
    delvarx, spec315

  endif else begin
    spectra = fltarr(63, nlos)

    w1 = where(stru.tel_id eq 405)
    w2 = spec_index[w1]
    id = NCDF_VARID(fid, "spec405")
    NCDF_VARGET, fid, id, spec405
    n_spec405 = n_elements(spec405[0,*])
    spectra[0:dim405,w1] = spec405[*,w2]
    delvarx, spec405
    
    w1 = where(stru.tel_id eq 045)
    w2 = spec_index[w1]
    id = NCDF_VARID(fid, "spec045")
    NCDF_VARGET, fid, id, spec045
    n_spec045 = n_elements(spec045[0,*])
    spectra[0:dim045,w1] = spec045[*,w2]
    delvarx, spec045
    
    w1 = where(stru.tel_id eq 135)
    w2 = spec_index[w1]
    id = NCDF_VARID(fid, "spec135")
    NCDF_VARGET, fid, id, spec135
    n_spec135 = n_elements(spec135[0,*])
    spectra[0:dim135,w1] = spec135[*,w2]
    delvarx, spec135
    
    w1 = where(stru.tel_id eq 225)
    w2 = spec_index[w1]
    id = NCDF_VARID(fid, "spec225")
    NCDF_VARGET, fid, id, spec225
    n_spec225 = n_elements(spec225[0,*])
    spectra[0:dim225,w1] = spec225[*,w2]
    delvarx, spec225
    
    w1 = where(stru.tel_id eq 315)
    w2 = spec_index[w1]
    id = NCDF_VARID(fid, "spec315")
    NCDF_VARGET, fid, id, spec315
    n_spec315 = n_elements(spec315[0,*])
    spectra[0:dim315,w1] = spec315[*,w2]
    delvarx, spec315

;  if((n_spec405 + n_spec045 + n_spec135 + n_spec225 + n_spec315) ne nlos) then no_merge = 1


    stru = CREATE_STRUCT(stru, "spectra", spectra)
    delvarx, spectra
  endelse
  if(all) then begin
    if(merge eq 0) then begin
      id = NCDF_VARID(fid, "vspec405")
      NCDF_VARGET, fid, id, vspec405
      stru = CREATE_STRUCT(stru, "vspec405", vspec405)
      delvarx, vspec405

      id = NCDF_VARID(fid, "vspec045")
      NCDF_VARGET, fid, id, vspec045
      stru = CREATE_STRUCT(stru, "vspec045", vspec045)
      delvarx, vspec045

      id = NCDF_VARID(fid, "vspec135")
      NCDF_VARGET, fid, id, vspec135
      stru = CREATE_STRUCT(stru, "vspec135", vspec135)
      delvarx, vspec135

      id = NCDF_VARID(fid, "vspec225")
      NCDF_VARGET, fid, id, vspec225
      stru = CREATE_STRUCT(stru, "vspec225", vspec225)
      delvarx, vspec225

      id = NCDF_VARID(fid, "vspec315")
      NCDF_VARGET, fid, id, vspec315
      stru = CREATE_STRUCT(stru, "vspec315", vspec315)
      delvarx, vspec315

    endif else begin
      vspectra = fltarr(63, nlos)

      w1 = where(stru.tel_id eq 405)
      w2 = spec_index[w1]
      id = NCDF_VARID(fid, "vspec405")
      NCDF_VARGET, fid, id, vspec405
      vspectra[0:dim405,w1] = vspec405[*,w2]
      delvarx, vspec405

      w1 = where(stru.tel_id eq 045)
      w2 = spec_index[w1]
      id = NCDF_VARID(fid, "vspec045")
      NCDF_VARGET, fid, id, vspec045
      vspectra[0:dim045,w1] = vspec045[*,w2]
      delvarx, vspec045

      w1 = where(stru.tel_id eq 135)
      w2 = spec_index[w1]
      id = NCDF_VARID(fid, "vspec135")
      NCDF_VARGET, fid, id, vspec135
      vspectra[0:dim135,w1] = vspec135[*,w2]
      delvarx, vspec135

      w1 = where(stru.tel_id eq 225)
      w2 = spec_index[w1]
      id = NCDF_VARID(fid, "vspec225")
      NCDF_VARGET, fid, id, vspec225
      vspectra[0:dim225,w1] = vspec225[*,w2]
      delvarx, vspec225

      w1 = where(stru.tel_id eq 315)
      w2 = spec_index[w1]
      id = NCDF_VARID(fid, "vspec315")
      NCDF_VARGET, fid, id, vspec315
      vspectra[0:dim315,w1] = vspec315[*,w2]
      delvarx, vspec315

      stru = CREATE_STRUCT(stru, "vspectra", vspectra)
      delvarx, vspectra
    endelse
  endif

  if(merge eq 0) then begin
    id = NCDF_VARID(fid, "rawspec405")
    NCDF_VARGET, fid, id, rawspec405
    stru = CREATE_STRUCT(stru, "rawspec405", rawspec405)
    delvarx, rawspec405

    id = NCDF_VARID(fid, "rawspec045")
    NCDF_VARGET, fid, id, rawspec045
    stru = CREATE_STRUCT(stru, "rawspec045", rawspec045)
    delvarx, rawspec045

    id = NCDF_VARID(fid, "rawspec135")
    NCDF_VARGET, fid, id, rawspec135
    stru = CREATE_STRUCT(stru, "rawspec135", rawspec135)
    delvarx, rawspec135

    id = NCDF_VARID(fid, "rawspec225")
    NCDF_VARGET, fid, id, rawspec225
    stru = CREATE_STRUCT(stru, "rawspec225", rawspec225)
    delvarx, rawspec225

    id = NCDF_VARID(fid, "rawspec315")
    NCDF_VARGET, fid, id, rawspec315
    stru = CREATE_STRUCT(stru, "rawspec315", rawspec315)
    delvarx, rawspec315

    stru = CREATE_STRUCT(stru, "spec_index", spec_index) ; include the spec_index
    delvarx, spec_index
  endif else begin
    rawspectra = fltarr(63, nlos)
    w1 = where(stru.tel_id eq 405)
    w2 = spec_index[w1]
    id = NCDF_VARID(fid, "rawspec405")
    NCDF_VARGET, fid, id, rawspec405
    rawspectra[0:dim405,w1] = rawspec405[*,w2]
    delvarx, rawspec405

    w1 = where(stru.tel_id eq 045)
    w2 = spec_index[w1]
    id = NCDF_VARID(fid, "rawspec045")
    NCDF_VARGET, fid, id, rawspec045
    rawspectra[0:dim045,w1] = rawspec045[*,w2]
    delvarx, rawspec045

    w1 = where(stru.tel_id eq 135)
    w2 = spec_index[w1]
    id = NCDF_VARID(fid, "rawspec135")
    NCDF_VARGET, fid, id, rawspec135
    rawspectra[0:dim135,w1] = rawspec135[*,w2]
    delvarx, rawspec135

    w1 = where(stru.tel_id eq 225)
    w2 = spec_index[w1]
    id = NCDF_VARID(fid, "rawspec225")
    NCDF_VARGET, fid, id, rawspec225
    rawspectra[0:dim225,w1] = rawspec225[*,w2]
    delvarx, rawspec225

    w1 = where(stru.tel_id eq 315)
    w2 = spec_index[w1]
    id = NCDF_VARID(fid, "rawspec315")
    NCDF_VARGET, fid, id, rawspec315
    rawspectra[0:dim315,w1] = rawspec315[*,w2]
    delvarx, rawspec315

    stru = CREATE_STRUCT(stru, "rawspectra", rawspectra)
    delvarx, rawspectra
  endelse
endif


end
