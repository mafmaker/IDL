;$Author: gallap $
;$Date: 1997/06/25 13:46:58 $
;$Header: /home/rumba/cdaweb/dev/control/RCS/overnight.pro,v 1.21 1997/06/25 13:46:58 gallap Exp gallap $
;$Locker: gallap $
;$Revision: 1.21 $
;-----------------------------------------------------------------------------
; CDFtoolkit5 - Functions for working with CDAWeb database files
;
; Main functions:
; FUNCTION ingest_database,infile,ROOT=ROOT
; FUNCTION examine_database, ALPHA, LOG=LOG, GAPLIMIT=GAPLIMIT
; FUNCTION generate_database, ALPHA, FILENAME=FILENAME, ROOT=ROOT
; FUNCTION crack_database,PATHS=PATHS,DEBUG=DEBUG,LOG=LOG,UPDATE=UPDATE,$
;                         ROOT=ROOT,VALIDATE_LFILEID=VALIDATE_LFILEID,$
;                         VALIDATE_VARS=VALIDATE_VARS
; PRO crack_cdffile, infile, gattrs, starttime, stoptime, status,
;                    RPATH=RPATH,LOG=LOG,DEBUG=DEBUG
; FUNCTION crack_varstruct, infile, LOG=LOG, DEBUG=DEBUG
; FUNCTION database_filter, ALPHA,IACG=IACG,ISTP=ISTP,SKIM=SKIM,PUBLIC=PUBLIC,$
;                           DEBUG=DEBUG
; FUNCTION version_fixer, ALPHA,DEBUG=DEBUG
; FUNCTION inventory, ALPHA, filename, TITLE=TITLE
; FUNCTION overnight (this is the main database generator program)
;
; Auxiliary functions:
; FUNCTION decode_CDFEPOCH, etime
; FUNCTION encode_CDFEPOCH, estr
; FUNCTION compare_struct, a, b
; FUNCTION extract_gattrs, metadata
; FUNCTION extract_vattrs, metadata
; FUNCTION abbreviate_source_name, source_name
; FUNCTION abbreviate_data_type, data_type
; FUNCTION validate_logicalfileid, cname, gattrs
; FUNCTION striplabel,a
; FUNCTION define_subscript, DSETid


; gather all filenames in all paths specified by PATHS keyword
; if in UPDATE mode then begin
;   read previous file with name given via UPDATE keyword
;   verify that all files from previous run still exist in file list
;   strip all filenames in previous file from file list
; endif
; for all files in file list do begin
;   open the cdf and get all of the variable names in it
;   get all metadata for the first variable
;   determine which variable is the time variable
;   get the start and stop times of the cdf
;   derive the dataset identifier and determine if it is new
;   if keyword set VALIDATE_LFILEID then validate it
;   if new dataset OR VALIDATE_VARS keyword set then get metadata for all vars
;   if new dataset then begin
;     add new structure to ALPHA, create root if needed
;   endif else begin
;     add file to ALPHA
;     if VALIDATE_VARS keyword set then compare variable structures
;   endelse
;   close cdf
; endfor
; dump the ALPHA data structure into the new metadata file
; return,ALPHA
;


FUNCTION extract_gattrs, metadata
; initialize gattrs structure
gattrs = {SOURCE_NAME:''   , DESCRIPTOR:''     , DATA_TYPE:'',$
          LOGICAL_SOURCE:'', LOGICAL_FILE_ID:'', MISSION_GROUP:'',$
          PI_NAME:''       , PI_AFFILIATION:'' , INSTRUMENT_TYPE:'',$
          DATASET:''       , DATASET_LABEL:''}
tags = tag_names(metadata)
; Process each of the pertinent ISTP global attributes
temp = where(tags eq 'SOURCE_NAME',count)
if count ne 0 then gattrs.SOURCE_NAME = metadata.SOURCE_NAME(0)
temp = where(tags eq 'DESCRIPTOR',count)
if count ne 0 then gattrs.DESCRIPTOR = metadata.DESCRIPTOR(0)
temp = where(tags eq 'DATA_TYPE',count)
if count ne 0 then gattrs.DATA_TYPE = metadata.DATA_TYPE(0)
temp = where(tags eq 'LOGICAL_SOURCE',count)
if count ne 0 then gattrs.LOGICAL_SOURCE = metadata.LOGICAL_SOURCE(0)
temp = where(tags eq 'LOGICAL_FILE_ID',count)
if count ne 0 then gattrs.LOGICAL_FILE_ID=strupcase(metadata.LOGICAL_FILE_ID(0))
temp = where(tags eq 'MISSION_GROUP',count)
if count ne 0 then gattrs.MISSION_GROUP = metadata.MISSION_GROUP(0)
temp = where(tags eq 'INSTRUMENT_TYPE',count)
if count ne 0 then gattrs.INSTRUMENT_TYPE = metadata.INSTRUMENT_TYPE(0)
temp = where(tags eq 'PI_NAME',count)
if count ne 0 then pins = metadata.PI_NAME else pins = ''
temp = where(tags eq 'PI_AFFILIATION',count)
if count ne 0 then pias = metadata.PI_AFFILIATION else pias = ''
temp = where(tags eq 'LOGICAL_SOURCE_DESCRIPTION',count)
if count ne 0 then begin
  s1 = metadata.LOGICAL_SOURCE_DESCRIPTION(0) + ' - '
  npins = n_elements(pins) & npias = n_elements(pias)
  for i=0,npins-1 do begin
    if npins eq npias then s1=s1+pins(i)+' ('+pias(i)+')'$
    else s1 = s1 + pins(i) + ' (' + pias(0) + ')'
  endfor
  gattrs.DATASET_LABEL = s1
endif else begin ; construct dataset label
  s1 = break_mySTRING(gattrs.SOURCE_NAME,DELIMITER='>')
  s2 = break_mySTRING(gattrs.DESCRIPTOR,DELIMITER='>')
  s3 = break_mySTRING(gattrs.DATA_TYPE,DELIMITER='>')
  if (n_elements(s2) ge 2)AND(n_elements(s3) ge 2) then begin
    s4 = s1(0) + ' ' + s2(1) + ' - '
    npins = n_elements(pins) & npias = n_elements(pias)
    for i=0,npins-1 do begin
      if npins eq npias then s4 = s4 + pins(i) + ' (' + pias(i) + ')' $
      else s4 = s4 + pins(i) + ' (' + pias(0) + ')'
    endfor
    gattrs.DATASET_LABEL = s4 + s3(1)
  endif else gattrs.DATASET_LABEL = 'Unable to construct dataset label'
endelse
for i=0,n_elements(pins)-1 do gattrs.PI_NAME = pins(i) + ' '
for i=0,n_elements(pias)-1 do gattrs.PI_AFFILIATION = pias(i) + ' '
return,gattrs
end


FUNCTION extract_vattrs, metadata
; initialize vattrs structure
vattrs = {VAR_NAME:'', VAR_TYPE:'', DICT_KEY:'', CATDESC:'', DEPEND_0:''}
tags = tag_names(metadata)
; save the variable name here, where its case is 'safe'
vattrs.VAR_NAME = metadata.VARNAME
; Process each of the pertinent ISTP variable attributes
data_var = 0 ; initialize flag
temp = where(tags eq 'VAR_TYPE',count)
if count eq 0 then data_var=1 $ ; no VAR_TYPE vattr, assume variable is 'DATA'
else begin
  if (strupcase(metadata.VAR_TYPE) eq 'DATA') then data_var=1
endelse
if (data_var eq 1) then begin
  vattrs.VAR_TYPE = 'DATA'
  temp = where(tags eq 'DICT_KEY',count)
  if count ne 0 then vattrs.DICT_KEY = metadata.DICT_KEY
  temp = where(tags eq 'DEPEND_0',count)
  if count ne 0 then vattrs.DEPEND_0 = metadata.DEPEND_0
  temp = where(tags eq 'FIELDNAM',count)
  if count ne 0 then vattrs.CATDESC = metadata.FIELDNAM
  temp = where(tags eq 'CATDESC',count)
  if count ne 0 then vattrs.CATDESC = metadata.CATDESC
endif
return,vattrs
end


; Given the input string, compare it to known sources and determine abbrev.
FUNCTION abbreviate_source_name, source_name
a = strupcase(source_name) ; ensure uppercase
if strpos(a,'CANOPUS')        ne -1 then return,'CN'
if strpos(a,'IMP-8')          ne -1 then return,'I8'
if strpos(a,'WIND')           ne -1 then return,'WI'
if strpos(a,'LANL1989')       ne -1 then return,'L9'
if strpos(a,'LANL1990')       ne -1 then return,'L0'
if strpos(a,'LANL1991')       ne -1 then return,'L1'
if strpos(a,'LANL1994')       ne -1 then return,'L4'
if strpos(a,'LANL_1989')      ne -1 then return,'L9'
if strpos(a,'LANL_1990')      ne -1 then return,'L0'
if strpos(a,'LANL_1991')      ne -1 then return,'L1'
if strpos(a,'LANL_1994')      ne -1 then return,'L4'
if strpos(a,'GEOTAIL')        ne -1 then return,'GE'
if strpos(a,'GOES 6')         ne -1 then return,'G6'
if strpos(a,'GOES 7')         ne -1 then return,'G7'
if strpos(a,'GOES 8')         ne -1 then return,'G8'
if strpos(a,'GOES 9')         ne -1 then return,'G9'
if strpos(a,'GOES_6')         ne -1 then return,'G6'
if strpos(a,'GOES_7')         ne -1 then return,'G7'
if strpos(a,'GOES_8')         ne -1 then return,'G8'
if strpos(a,'GOES_9')         ne -1 then return,'G9'
if strpos(a,'DARN')           ne -1 then return,'DN'
if strpos(a,'DE-1')           ne -1 then return,'D1'
if strpos(a,'POLAR')          ne -1 then return,'PO'
if strpos(a,'SAMPEX')         ne -1 then return,'SA'
if strpos(a,'SESAME')         ne -1 then return,'SE'
if strpos(a,'SOHO')           ne -1 then return,'SO'
if strpos(a,'SONDRESTROM')    ne -1 then return,'SN'
if strpos(a,'INTERBALL TAIL') ne -1 then return,'IT'
if strpos(a,'INTERBALL-TAIL') ne -1 then return,'IT'
if strpos(a,'INTERBALL GROUND') ne -1 then return,'IG'
if strpos(a,'INTERBALL-GROUND') ne -1 then return,'IG'
if strpos(a,'ULYSSES')        ne -1 then return,'ULY'
; No match yet, search for '>' and return the first
b=break_mystring(a,delimiter='>')
return,b(0)
end

; Given the input string, abbreviate it to two characters
FUNCTION abbreviate_data_type, data_type
a = strupcase(data_type) & b = break_mystring(data_type,delimiter='>')
if (n_elements(b) ge 1) AND (strlen(b(0)) eq 2) then begin
  ; Test for possible non-standard abbreviations
  if strpos(b(0),'KP')    ne -1 then return,'K0'
  return,b(0)
endif else begin ; attempt to derive correct abbreviation
  if strpos(a,'K0')       ne -1 then return,'K0'
  if strpos(a,'K1')       ne -1 then return,'K1'
  if strpos(a,'EVENT')    ne -1 then return,'ED'
  if strpos(a,'ATTITUDE') ne -1 then return,'AT'
  if strpos(a,'ORBIT')    ne -1 then return,'OR'
  if strpos(a,'EPHEM')    ne -1 then return,'OR'
  if strpos(a,'KP')       ne -1 then return,'K0'
endelse
return,a ; return as is
end


; Given the input string, abbreviate it to properper descriptor length
FUNCTION abbreviate_descriptor, descriptor
a = break_mystring(descriptor,delimiter='>')
return,a(0)
end

; Given the input string, fix it if is known to be one of the ever-growing
; list of kluge cases.
FUNCTION fix_logical_source, a
if (a eq 'SOHO_K0_CST') then a = 'SO_K0_CST'
if (a eq 'POLAR_CAM_KP') then a = 'PO_K0_CAM'
return,a
end

; Attempt to determine and fill the DATASET field of the gattrs structure
; using the source_name, descriptor, and data_type fields.  Dataset is
; defined as SS_TT_DDD where SS is source abbreviation, TT is datatype
; abbreviation and DDD is descriptor abbreviation.
PRO derive_dataset, gattrs
if gattrs.LOGICAL_SOURCE ne '' then begin
  gattrs.LOGICAL_SOURCE = fix_logical_source(gattrs.LOGICAL_SOURCE)
  gattrs.DATASET = gattrs.LOGICAL_SOURCE
endif else begin ; attempt to derive from source type and descriptor metadata
  sa = abbreviate_source_name(gattrs.SOURCE_NAME)
  ta = abbreviate_data_type(gattrs.DATA_TYPE)
  da = abbreviate_descriptor(gattrs.DESCRIPTOR)
  gattrs.DATASET = sa + '_' + ta + '_' + da
endelse
end


; verify that the logical file id in the gattrs structure matches filename
; and that it is formatted according to istp standards.
FUNCTION validate_logicalfileid, cname, gattrs
valid=1 ; assume valid until implemented
return,valid
end


FUNCTION striplabel,a
a=strtrim(a,2) & b=break_mystring(a,delimiter='>') & nb=n_elements(b)
if (nb eq 1) then s=b(0) else s=b(1)
for i=2,nb-1 do s=s+'>'+b(i)
return,s
end

FUNCTION define_subscript, DSETid

mission = strmid(DSETid, 0, 2)

case mission of

'CN': n = 8000
'DE': n = 5000
'DN': n = 5000
'G6': n = 5000
'G7': n = 5000
'G8': n = 5000
'G9': n = 5000
'GE': n = 5000
'I2': n = 9000
'I8': n = 5000
'IG': n = 5000
'IT': n = 5000
'L0': n = 5000
'L1': n = 5000
'L4': n = 5000
'L9': n = 5000
'PO': n = 5000
'SE': n = 5000
'SL': n = 5000
'SN': n = 5000
'SO': n = 5000
'SX': n = 5000
'WI': n = 8000
'GB': n = 10
'S1': n = 10
'S2': n = 10
'S3': n = 10
'T1': n = 10
'T2': n = 10
'T3': n = 10
'V1': n = 10

else: n = 5000
endcase

return, n

end


;Read the database pointed to by infile into an anonymous structure
FUNCTION ingest_database,infile,ROOT=ROOT,DEBUG=DEBUG

; Validate the root keyword if present
if keyword_set(ROOT) then begin
  if (strmid(ROOT,0,1) eq '/') then myROOT = strmid(ROOT,1,100) $
  else myROOT = ROOT
endif

a = STRING(REPLICATE(32B,300)) ; allocate buffer space
DATASET_counter=0L ; initialize dataset counter
OPENR,1,infile ; Open the existing database
while (NOT EOF(1)) do begin ; read next dataset from file
  ; initialize gattrs and vattrs structures to be filled during input
  gattrs = {SOURCE_NAME:''   , DESCRIPTOR:''     , DATA_TYPE:'',$
            LOGICAL_SOURCE:'', LOGICAL_FILE_ID:'', MISSION_GROUP:'',$
            PI_NAME:''       , PI_AFFILIATION:'' , INSTRUMENT_TYPE:'',$
            DATASET:''       , DATASET_LABEL:''}
  vattrs = {VAR_NAME:'',VAR_TYPE:'',DICT_KEY:'',CATDESC:'',DEPEND_0:''}
  cpaths  = strarr(2500) & cnames = strarr(2500)
  cstarts = strarr(2500) & cstops = strarr(2500)

  ; read the global information
  readf,1,a & gattrs.DATASET=striplabel(a)
  if keyword_set(DEBUG) then print,'Processing ',gattrs.DATASET,'...'
  readf,1,a & gattrs.SOURCE_NAME=striplabel(a)
  readf,1,a & gattrs.DESCRIPTOR=striplabel(a)
  readf,1,a & gattrs.DATA_TYPE=striplabel(a)
  readf,1,a & gattrs.PI_NAME=striplabel(a)
  readf,1,a & gattrs.PI_AFFILIATION=striplabel(a)
  readf,1,a & gattrs.MISSION_GROUP=striplabel(a)
  readf,1,a & gattrs.INSTRUMENT_TYPE=striplabel(a)
  readf,1,a & gattrs.DATASET_LABEL=striplabel(a)
  readf,1,a & a=strtrim(a,2) ; read the time range
  readf,1,a & a=strtrim(a,2) ; could be mastercdf or !VARS

  ; process the mastercdf field if it exists
  master_present = 0L
  if strpos(a,'MASTER') ne -1 then begin ; mastercdf found
    b=break_mystring(a,delimiter='>')
    if (b(1) ne '') then begin
      ; split the path from filename and correct the path
      split_filename,b(1),cdf_path,cdf_name
      ; strip cdf suffix if present to conserve string space
      s=strpos(cdf_name,'.cdf') & if s ne -1 then cdf_name=strmid(cdf_name,0,s)
      if keyword_set(ROOT) then begin ; strip root directory to save space
        s = strpos(cdf_path,myROOT)
        if s ne -1 then cdf_path = strmid(cdf_path,strlen(myROOT),100)
      endif
      cpaths(0) = cdf_path & cnames(0) = cdf_name
      cstarts(0) = '2099/12/31 00:00:00' & cstops(0) = '2099/12/31 00:00:00'
      master_present = 1L
    endif
    readf,1,a ; read next record in file
  endif

  ; read the metadata about the variables
  if keyword_set(DEBUG) then print,'    reading variable metadata...'
  b=break_mystring(a,delimiter='=') & nvars=long(b(1))
  for i=0,nvars-1 do begin ; read each variable
    readf,1,a & a=strtrim(a,2) 
    b=break_mystring(a,delimiter='|')
    vattrs.VAR_TYPE = 'data' & vattrs.VAR_NAME = b(0)
    vattrs.DICT_KEY = b(1)   & vattrs.CATDESC  = b(2)
    if (i eq 0) then begin
      v = create_struct('VATTRS',vattrs) ; create vattrs struct
      VARS = create_struct(b(0),v) ; attach to variable name tag
    endif else begin
      v = create_struct('VATTRS',vattrs) ; create structure
      u = create_struct(b(0),v) ; attach to variable name tag
      VARS = create_struct(VARS,u) ; append new structure to existing one
    endelse
  endfor

  ; read the number of cdfs
  readf,1,a & a=strtrim(a,2)
  b=break_mystring(a,delimiter='=') & ncdfs=long(b(1))
  if keyword_set(DEBUG) then print,'    reading ',ncdfs,' cdfs...'
  for i=0,ncdfs-1 do begin ; read each cdf line
    readf,1,a & a=strtrim(a,2)
    b=break_mystring(a,delimiter='>')
    ; split the path from filename and correct the path
    split_filename,b(0),cdf_path,cdf_name
    ; strip cdf suffix if present to conserve string space
    s=strpos(cdf_name,'.cdf') & if s ne -1 then cdf_name=strmid(cdf_name,0,s)
    if keyword_set(myROOT) then begin ; strip root directory to save space
      s = strpos(cdf_path,myROOT)
      if s ne -1 then cdf_path = strmid(cdf_path,strlen(myROOT),100)
    endif
    cpaths(i+master_present)  = cdf_path
    cnames(i+master_present)  = cdf_name
    cstarts(i+master_present) = b(1)
    cstops(i+master_present)  = b(2)
  endfor
  ; read the end of dataset marker
  readf,1,a 
  ; assemble the information gathered above into data structure
  BETA = create_struct('GATTRS',gattrs,'VARS',VARS,'CPATHS',cpaths,$
                       'CNAMES',cnames,'CSTARTS',cstarts,'CSTOPS',cstops)
  if (DATASET_counter eq 0) then ALPHA = create_struct(gattrs.DATASET,BETA) $
  else begin
    GAMMA = create_struct(gattrs.DATASET,BETA) ; attach to logical source tag
    ALPHA = create_struct(ALPHA,GAMMA) ; append to existing structure
  endelse
  DATASET_counter = DATASET_counter + 1
endwhile
close,1 ; close the database file
return,ALPHA
end


FUNCTION crack_varstruct, cname, LOG=LOG, DEBUG=DEBUG

if keyword_set(DEBUG) then print,'VAR-Cracking ',cname

; establish error handler
Error_status = 0
CATCH, Error_status
if Error_status ne 0 then begin
  print,'UNKNOWN ERROR WHILE VAR-CRACKING THE FILE ',cname
  print,'VNAME=',vnames(var_number)
  print,!ERR_STRING
  if keyword_set(LOG) then begin
    printf,1,'UNKNOWN ERROR WHILE VAR-CRACKING THE FILE ',cname
    printf,1,'VNAME=',vnames(var_number)
    printf,1,!ERR_STRING
  endif
  return,-1
endif

; open the cdf and get all of the variable names in it
CDFid = CDF_OPEN(cname) ; open the cdf file
CDFinfo = CDF_INQUIRE(CDFid) ; inquire about the cdf

; get all metadata for the first variable
VARS=0L & data_var_counter=0L ; initialize
vnames = get_allvarnames(CDFid=CDFid) ; get all variable names
for var_number = 0,n_elements(vnames)-1 do begin
  if keyword_set(DEBUG) then print,'Inquiring about ',vnames(var_number)
  varinq = CDF_VARINQ(CDFid,vnames(var_number))
  varinq.name = strtrim(varinq.name,2) ; strip any padding blanks
  if keyword_set(DEBUG) then print,'Now getting metadata for ',varinq.name
  metadata = read_myMETADATA(varinq.name,CDFid)
  vattrs = extract_vattrs(metadata)
  ; save the information about the variable if it has var_type of data
  if (vattrs.VAR_TYPE eq 'DATA') then begin
    if (data_var_counter eq 0) then begin ; create new structure
        data_var_counter = data_var_counter + 1
        v = create_struct('VATTRS',vattrs,'VARINQ',varinq)
        VARS = create_struct(varinq.name,v)
    endif else begin ; add to existing structure
        v = create_struct('VATTRS',vattrs,'VARINQ',varinq)
        u = create_struct(varinq.name,v) ; attach to name tag
        VARS = create_struct(VARS,u) ; append to existing structure
    endelse
  endif
endfor
return,VARS
end



; Crack the given file and return information about the file
PRO crack_cdffile, cname, gattrs, cdf_start, cdf_stop, status, $
    RPATH=RPATH,LOG=LOG,DEBUG=DEBUG

if keyword_set(DEBUG) then print,'Opening ',cname

; establish error handler
Error_status = 0
CATCH, Error_status
if Error_status ne 0 then begin
  print,'UNKNOWN ERROR WHILE CRACKING THE FILE ',cname
  print,!ERR_STRING
  if keyword_set(LOG) then begin
    printf,1,'UNKNOWN ERROR WHILE CRACKING THE FILE ',cname
    printf,1,!ERR_STRING
  endif
  status = -1 & return
endif

; open the cdf and get all of the variable names in it
CDFid = CDF_OPEN(cname) ; open the cdf file
CDFinfo = CDF_INQUIRE(CDFid) ; inquire about the cdf

; get all metadata for the first variable
vnames = get_allvarnames(CDFid=CDFid) ; get all variable names
if keyword_set(DEBUG) then print,'Reading metadata for ',vnames(0)
metadata = read_myMETADATA(vnames(0),CDFid)
gattrs = extract_gattrs(metadata) ; get important global metadata

; determine which variable in vnames is the time variable
tvarname = '' ; initialize name of time variable
for i=0,n_elements(vnames)-1 do begin
  if (strupcase(strtrim(vnames(i),2)) eq 'EPOCH') then tvarname = vnames(i)
endfor
if (tvarname eq '') then begin
  if keyword_set(LOG) then begin
    printf,1,'ERROR> Unable to determine the time variable for this CDF.'
    printf,1,'       Start/Stop required for CDAWeb application.'
  endif
  if keyword_set(DEBUG) then begin
    print,'ERROR> Unable to determine the time variable for this CDF.'
    print,'       Start/Stop required for CDAWeb application.'
  endif
  status = -1 & return
endif

; read the start and stop times from the cdf
CDF_EPOCH,maxstarttime,2100,/COMPUTE_EPOCH
CDF_EPOCH,minstoptime ,1900,/COMPUTE_EPOCH
if keyword_set(DEBUG) then print,'Determine start and stop times'
times = read_myVARIABLE(tvarname,CDFid,vary,dtype,recs)
npoints = n_elements(times)
; validate all epoch times
mintime = (1000.0D0 * 60.0D0 * 60.0D0 * 24.0D0 * 365.0D0) ; 1 year
w = where(times lt mintime,wc)
if (wc gt 0) then begin
  ; Determine if cdf is a master or not
  if (strpos(cname,'00000000') eq -1) then begin ; not a master
    if keyword_set(LOG) then begin
      printf,1,'WARNING:',wc,' INVALID EPOCH VALUE(S) IN ',cname
    endif
    print,'WARNING:',wc,' INVALID EPOCH VALUE(S) IN ',cname
    status = -1 & return
  endif else begin
    if (times(0) eq 0.0) then begin ; cdf is a skeleton with no data
      start_time = maxstarttime & stop_time = minstoptime
    endif
  endelse
endif else begin
  start_time = times(0) & stop_time = times(npoints-1)
  ; validate start and stop times
  if (stop_time lt start_time) then begin
    if keyword_set(LOG) then begin
      printf,1,'tvarname=',tvarname,' npoints=',npoints
      printf,1,'    stop  EPOCH=',decode_cdfepoch(stop_time),' before '
      printf,1,'    start EPOCH=',decode_cdfepoch(start_time),' in ',cname
    endif
    if keyword_set(DEBUG) then print,'stop EPOCH before start EPOCH in ',cname
    status = -1 & return
  endif
endelse
cdf_start = decode_CDFEPOCH(start_time)
cdf_stop  = decode_CDFEPOCH(stop_time)

; close the open cdf
CDF_CLOSE,CDFid
status = 0
return
end


; Locate all .cdf files in directories given by paths, crack them all,
; and accumulate all pertinent information into an anonymous structure.
FUNCTION crack_database,PATHS=PATHS,DEBUG=DEBUG,LOG=LOG,UPDATE=UPDATE,$
                        ROOT=ROOT,VALIDATE_LFILEID=VALIDATE_LFILEID,$
                        VALIDATE_VARS=VALIDATE_VARS,NOQUIET=NOQUIET

quiet_flag = !quiet ; save current state of quiet flag
if not keyword_set(NOQUIET) then !quiet=1 ; turn off annoying cdf messages

; verify that conflicting keyword do not exits
if keyword_set(UPDATE) AND keyword_set(VALIDATE_VARS) then begin
  print,'Cannot validate variables during an update run!'
  return,0
endif
if keyword_set(VALIDATE_VARS) then begin
  print,'VALIDATE_VARS is temporarily disabled...call Rick '
  return,0
endif

; Initialize
CDF_EPOCH,maxstarttime,2100,/COMPUTE_EPOCH
CDF_EPOCH,minstoptime ,1900,/COMPUTE_EPOCH
maxlen = 80 ; initialize file width
cd,current=cwd ; get current directory
NUMBER_OF_PATHS = 0L
DATASET_counter = 0L
Zero = 0L


; Open log file if keyword is set
if keyword_set(LOG) then begin 
  OPENW,1,LOG & logflag = 1
endif else logflag = 0
if keyword_set(DEBUG) then debugflag = 1 else debugflag = 0


; get list of all cdf files in the directory tree pointed to by PATHS keywords
if keyword_set(PATHS) then begin
  if keyword_set(LOG) then printf,1,'Locating all cdf files...'
  if keyword_set(DEBUG) then print, 'Locating all cdf files...'
  p = break_mystring(PATHS,delimiter=',') ; possible multiple paths
  NUMBER_OF_PATHS = n_elements(p)
  for pi = 0,NUMBER_OF_PATHS-1 do begin ; process all paths
    Validate_myPATH,p(pi) & cd,p(pi) ; ensure path is correct for current !OS
    find_myfiles,'',p(pi),cnames
    w = where(strpos(cnames,'.cdf') ne -1,wc) ; locate .cdf files
    cnames = cnames(w)                        ; filter
    a = sort(cnames) & cnames = cnames(a) ; sort the filenames
    ; SPECIAL ERROR CHECK - version numbers left over from ftp from vax
    w = where(strpos(cnames,';') ne -1,wc) ; search for VAX version #'s
    if (wc gt 0) then begin
      print,'VAX VERSION NUMBERS DETECTED!' & stop
    endif
  endfor
endif else begin ; the path is the current working directory
    PATHS=cwd & NUMBER_OF_PATHS = 1L ; set number of paths
    p=cwd & Validate_myPATH,p ; ensure path is correct for current !OS
    find_myfiles,'*.cdf',p,cnames ; find all cds in subdirectories too
    find_myfiles,'*.CDF',p,cnames ; find uppercase cdf's too
    a = sort(cnames) & cnames = cnames(a) ; sort the filenames
endelse
if keyword_set(LOG) then printf,1,'Number of cdf files=',n_elements(cnames)
if keyword_set(DEBUG) then help,cnames


; Special processing for update mode only
if keyword_set(UPDATE) then begin
  if keyword_set(LOG) then printf,1,'Ingesting previous database'
  if keyword_set(DEBUG) then print, 'Ingesting previous database'
  ALPHA = ingest_database(UPDATE,ROOT=ROOT)
  if keyword_set(LOG) then printf,1,'Database ingest complete'
  if keyword_set(DEBUG) then print, 'Database ingest complete'

  ;Compare the cnames array to the file name and path information from
  ;the ingested database.  Verify that all files in the database exist
  ;in the cnames array.  Strip from the cnames list those files which
  ;are already included in the database, so that only un-cracked files
  ;remain.
  stop
  lsources = tag_names(ALPHA) ; get all logical source names
  for i=0,n_elements(lsources)-1 do begin ; test each source
    if keyword_set(DEBUG) then print,'Processing ',lsources(i)
    w = where(ALPHA.(i).CNAMES ne '',file_count)  ; find all files
    for j=0,file_count-1 do begin ; test each file from the database
      fname = ROOT + ALPHA.(i).CPATHS(j) + ALPHA.(i).CNAMES(j) + '.cdf'
      w = where(cnames eq fname,wc)
      if (wc eq 0) then begin ; filename not found
        if keyword_set(DEBUG) then print, 'ERROR>Missing file:',fname
        if keyword_set(LOG) then printf,1,'ERROR>Missing file:',fname
      endif else begin
        if (wc gt 1) then begin ; duplicate filename
          if keyword_set(DEBUG) then print, 'ERROR>Duplicate file:',fname
          if keyword_set(LOG) then printf,1,'ERROR>Duplicate file:',fname
        endif
        cnames(w) = ''
      endelse
    endfor
    ; shorten the cnames array by eliminating blanked-out filenames
    w = where(cnames ne '',wc)
    if (wc gt 0) then cnames = cnames(w)
  endfor
  ; Examine cnames array to determine if cracking should proceed or can stop
  w = where(cnames ne '',wc)
  if (wc eq 0) then begin
    if keyword_set(DEBUG) then print, 'NO NEW FILES TO CRACK'
    if keyword_set(LOG) then printf,1,'NO NEW FILES TO CRACK'
    return,ALPHA
  endif
  stop
endif ; if in update mode

; Establish an error handler to catch when an unforseen problem occurs
Error_status = 0L
CATCH, Error_status
if Error_status ne 0 then begin
  print,'CRACK_DATABASE: Unknown error has occured...halting program.'
  print, 'Might want to check the array size specs in define_subscript'
  print, 'to see if the number of files for a given mission has exceeded'
  print, 'the sizes specified.'
  print,!ERR_STRING
  stop
endif

; MAIN LOOP: Process each of the cdfs in the cnames array
for cdf_number = 0L,n_elements(cnames)-1L do begin

  ; Open the cdf file and get global attributes and determine start/stop times
  crack_cdffile, cnames(cdf_number),gattrs,cdf_start,cdf_stop,status, $
                 RPATH=PATHS(0),LOG=logflag,DEBUG=debugflag
  if (status eq 0) then begin

    ; To control length of the cdf_name and cdf_path strings which are
    ; accumulated during execution, strip the .cdf extension and root
    ; path from the cdf name and path.
    split_filename, cnames(cdf_number),cdf_path,cdf_name
    s=strpos(cdf_name,'.cdf') & if s ne -1 then cdf_name=strmid(cdf_name,0,s)
    if NUMBER_OF_PATHS eq 1 then begin ; reduce path from absoluate to relative
; Case: 2 paths; '/ncf/xfiles/istp/' and '/ncf/xfiles/sp_ingest/eics/'  They
; both share the '/ncf/xfiles/' portion. I could, rather than depending on the
; number of paths, have checked at the top of this function, where the paths
; were the same and determined the roots were the same?
      split_filename,PATHS(0),p,junk ; remove first '/' if present
      s=strpos(cdf_path,p)
      if s ne -1 then cdf_path=strmid(cdf_path,strlen(p),100)
    endif

    ; derive the dataset identifier and determine if it is new
    derive_dataset,gattrs
    new_dataset = 0 & DSETid = gattrs.DATASET & DATASET_INDEX=0
    if DATASET_counter eq 0 then new_dataset=1 $
    else begin
      w = where(tag_names(ALPHA) eq gattrs.DATASET,wc)
      if wc eq 0 then new_dataset=1 else DATASET_INDEX=w(0)
    endelse

    if (new_dataset eq 1) then begin
      ; get all needed information about every variable
      VARS = crack_varstruct(cnames(cdf_number),LOG=logflag,DEBUG=debugflag)
      s = size(VARS) & ns = n_elements(s)
      if (s(ns-2) eq 8) then status = 0 else status = -1
    endif

    ; The name of the cdf is no longer needed in the cnames array.  Free this
    ; space.  When cracking large numbers of cdfs this saves lots of space.
    cnames(cdf_number) = ''

    ; if this cdf is from a new dataset then add it to the ALPHA structure
    if ((new_dataset eq 1)AND(status eq 0)) then begin
      if keyword_set(DEBUG) then print,'New dataset=',DSETid
      BETA = create_struct('GATTRS' ,gattrs,'VARS',VARS,$
                           'CPATHS' ,strarr(define_subscript(DSETid)),$
                           'CNAMES' ,strarr(define_subscript(DSETid)),$
                           'CSTARTS',strarr(define_subscript(DSETid)),$
                           'CSTOPS' ,strarr(define_subscript(DSETid)))
      BETA.cpaths(0)  = cdf_path  & BETA.cnames(0)  = cdf_name
      BETA.cstarts(0) = cdf_start & BETA.cstops(0)  = cdf_stop
      if (DATASET_counter eq 0) then begin ; create root
        ALPHA = create_struct(DSETid,BETA) ; attach to logical source tag
      endif else begin ; add new structure to existing structure
        GAMMA = create_struct(DSETid,BETA) ; attach to logical source tag
        ALPHA = create_struct(ALPHA,GAMMA) ; append to existing structure
      endelse
      DATASET_counter = DATASET_counter + 1
    endif else begin ; structure for this logical source already exists
      ; append file name and time information to info strings
      w = where(ALPHA.(DATASET_INDEX).CNAMES eq '')
      ALPHA.(DATASET_INDEX).CPATHS(w(0))  = cdf_path
      ALPHA.(DATASET_INDEX).CNAMES(w(0))  = cdf_name
      ALPHA.(DATASET_INDEX).CSTARTS(w(0)) = cdf_start
      ALPHA.(DATASET_INDEX).CSTOPS(w(0))  = cdf_stop
    endelse

  endif ; if cdf was cracked ok

endfor ; loop thru all cdf's
if keyword_set(LOG) then close,1 ; close the log file
cd,cwd ; return to original directory
return,ALPHA
end


; Examine the contents of the ALPHA data structure by looking for data
; overlaps and data gaps within a dataset.  Output the evaluation to
; the screen and/or a log file.
FUNCTION examine_database, ALPHA, LOG=LOG, GAPLIMIT=GAPLIMIT

; Initialize
if keyword_set(LOG) then OPENW,1,LOG ; open log file
if keyword_set(GAPLIMIT) then maxgap=GAPLIMIT $
else maxgap = double(1000.0 * 60.0 * 60.0 * 25.0) ; default is 25 hours
CDF_EPOCH,maxstarttime,2100,/COMPUTE_EPOCH ; used to 'MASTERCDF' search

lsources = tag_names(ALPHA) ; get name of each dataset
for i=0,n_elements(lsources)-1 do begin
  if keyword_set(LOG) then printf,1,'Extracting data for:',lsources(i)
  print,'Extracting data for:',lsources(i)
  ; extract information about times and filenames
  w = where(ALPHA.(i).cnames ne '')
  cpaths  = ALPHA.(i).cpaths(w)
  cnames  = ALPHA.(i).cnames(w)
  cstarts = ALPHA.(i).cstarts(w)
  cstops  = ALPHA.(i).cstops(w)
  nc = n_elements(cnames) & estarts=dblarr(nc) & estops=dblarr(nc)
  ; convert start and stop times into cdf epoch times
  for j=0,nc-1 do begin
    estarts(j) = encode_CDFEPOCH(cstarts(j))
    estops(j)  = encode_CDFEPOCH(cstops(j))
  endfor
  ; strip 'master' cdfs from list
  w = where(estarts ne maxstarttime,wc)
  if (wc ne n_elements(estarts)-1) then begin
    cpaths  = cpaths(w)  & cnames = cnames(w)
    cstarts = cstarts(w) & cstops = cstops(w)
    estarts = estarts(w) & estops = estops(w)
  endif
  ; sort the files in ascending order by time
  a = sort(estarts)
  cpaths  = cpaths(a)  & cnames = cnames(a)
  cstarts = cstarts(a) & cstops = cstops(a)
  estarts = estarts(a) & estops = estops(a)
  ; Perform time gap checking.  The time between the stop time of a file
  ; and the start time of the next file must be lt than maxgap.
  if keyword_set(LOG) then printf,1,'Performing data gap checking...'
  print,'Performing data gap checking...'
  for j=1,n_elements(estarts)-1 do begin
    if (double(estarts(j) - estops(j-1)) gt maxgap) then begin
      print,'DATAGAP at:',(cpaths(j)+cnames(j))
      if keyword_set(LOG) then $
      printf,1,'DATAGAP at:',(cpaths(j)+cnames(j))
    endif
  endfor
  ; Perform data overlap checking.  The end time of a file should not be
  ; greater than the start time of the next file in the dataset.
  if keyword_set(LOG) then printf,1,'Performing data overlap checking...'
  print,'Performing data overlap checking...'
  for j=0,n_elements(estarts)-2 do begin
    if (estops(j) gt estarts(j+1)) then begin
      print,'OVERLAP at :',(cpaths(j)+cnames(j))
      print,'        and:',(cpaths(j+1)+cnames(j+1))
      if keyword_set(LOG) then begin
        printf,1,'OVERLAP at:',(cpaths(j)+cnames(j))
        printf,1,'        and:',(cpaths(j+1)+cnames(j+1))
      endif
    endif
  endfor
endfor ; test each logical source
if keyword_set(LOG) then close,1 ; close the log file
return,0
end  


; Examine the contents of the ALPHA data structure, looking for EXACT
; data overlaps.  These conditions are usually caused due to different
; versions of the cdf file.  Discard the first cdf causing the overlap.
FUNCTION version_fixer, ALPHA, DEBUG=DEBUG

BETA=ALPHA ; copy for modification
CDF_EPOCH,maxstarttime,2100,/compute_epoch
lsources = tag_names(BETA) ; get name of each dataset
for i=0,n_elements(lsources)-1 do begin
  if keyword_set(DEBUG) then print,'Examining ',lsources(i)
  ; extract information about times and filenames
  w = where(BETA.(i).cnames ne '',wc)
  if (wc gt 0) then begin
    cpaths  = BETA.(i).cpaths(w)
    cnames  = BETA.(i).cnames(w)
    cstarts = BETA.(i).cstarts(w)
    cstops  = BETA.(i).cstops(w)
    ; sort by filenames
    w = sort(cnames) & cnames=cnames(w) & cpaths=cpaths(w)
    cstarts=cstarts(w) & cstops=cstops(w)
    ; Search for exact time overlaps and eliminate them
    if (n_elements(cnames) gt 1) then begin
      for j=0,n_elements(cnames)-2 do begin
        if ((cstarts(j) eq cstarts(j+1))AND(cstops(j) eq cstops(j+1)))then begin
          if keyword_set(DEBUG) then begin
            print,' Exact time overlap found with ',cnames(j)
          endif
          cpaths(j)='' & cnames(j)='' & cstarts(j)='' & cstops(j)='' ; drop file
        endif
      endfor
      ; reset file information
      for j=0,n_elements(BETA.(i).cnames)-1 do begin
        BETA.(i).cpaths(j)  = '' & BETA.(i).cnames(j) = ''
        BETA.(i).cstarts(j) = '' & BETA.(i).cstops(j) = ''
      endfor
      ; erase dropped files
      w = where(cnames ne '',wc)
      cpaths = cpaths(w)   & cnames = cnames(w)
      cstarts = cstarts(w) & cstops = cstops(w)
      ; save filtered information
      for j=0,n_elements(cnames)-1 do begin
        BETA.(i).cpaths(j)  = cpaths(j)  & BETA.(i).cnames(j) = cnames(j)
        BETA.(i).cstarts(j) = cstarts(j) & BETA.(i).cstops(j) = cstops(j)
      endfor
    endif
  endif
endfor
return,BETA
end  


; Return arrays of dataset names and access numbers
PRO Access_definitions, dsets, access
;
; bit masks
; 1 = istp pub
; 2 = istp private
; 3 = iacg public
; 4 = iacg private
; 5 = skimming
; 6 = cdaw9
;
; Modified by Emily to open Datasets.dat file and read in
; instead of using the following commented out code. See below.
;
;  This file is created from the CDAWeb spreadsheet used to track the
;  public and proprietary status of all datatypes, and which catalogs
;  they belong in.
;
;  To create the file Datasets.dat, load the spreadsheet into Excel
;  Move the "datatypes" column to be after the "Mask" column.  Select
;  the two columns, and use the clipboard to copy and paste them into
;  an ASCII file.  Edit the ASCII file to place the total number of
;  datasets by itself in the first line.
;           - EAG 8/9/96
;

;Define datasets and their accessibility. 
;dsets = strarr(89) & access=intarr(89)
;dsets(0) ='CN_K0_ASI'     & access(0) =31
;dsets(1) ='CN_K0_MARI'    & access(1) =31
;dsets(2) ='CN_K0_MPA'     & access(2) =31
;dsets(3) ='CN_K1_MARI'    & access(3) =31
;dsets(4) ='DE_VS_EICS'    & access(4) =64
;dsets(5) ='DN_K0_GBAY'    & access(5) =31
;dsets(6) ='DN_K0_ICEW'    & access(6) =31
;dsets(7) ='DN_K0_KAPU'    & access(7) =31
;dsets(8) ='DN_K0_PACE'    & access(8) =26
;dsets(9) ='DN_K0_SASK'    & access(9) =31
;dsets(10)='G6_K0_EPS'     & access(10)=15
;dsets(11)='G6_K0_MAG'     & access(11)=15
;dsets(12)='G7_K0_EPS'     & access(12)=31
;dsets(13)='G7_K0_MAG'     & access(13)=31
;dsets(14)='G8_K0_MAG'     & access(14)=31
;dsets(15)='G9_K0_MAG'     & access(15)=31
;dsets(16)='GB_ED_FMI'     & access(16)=32
;dsets(17)='I8_ED_M3'      & access(17)=32
;dsets(18)='I8_ED_PA'      & access(18)=32
;dsets(19)='GE_AT_DEF'     & access(19)=31
;dsets(20)='GE_AT_PRE'     & access(20)=31
;dsets(21)='GE_ED_MGF'     & access(21)=16
;dsets(22)='GE_H0_LEP'     & access(22)=16
;dsets(23)='GE_K0_CPI'     & access(23)=31
;dsets(24)='GE_K0_EFD'     & access(24)=31
;dsets(25)='GE_K0_EPI'     & access(25)=31
;dsets(26)='GE_K0_LEP'     & access(26)=31
;dsets(27)='GE_K0_MGF'     & access(27)=31
;dsets(28)='GE_K0_SPHA'    & access(28)=31
;dsets(29)='GE_OR_DEF'     & access(29)=31
;dsets(30)='GE_OR_PRE'     & access(30)=31
;dsets(31)='I8_K0_MAG'     & access(31)=31
;dsets(32)='I8_K0_PLA'     & access(32)=31
;dsets(33)='IG_K0_PCI'     & access(33)=31
;dsets(34)='IT_K0_ELE'     & access(34)=31
;dsets(35)='IT_K0_EPI'     & access(35)=31
;dsets(36)='IT_K0_ICD'     & access(36)=31
;dsets(37)='IT_K0_MFI'     & access(37)=31
;dsets(38)='IT_K0_PCI'     & access(38)=31
;dsets(39)='IT_OR_DEF'     & access(39)=31
;dsets(40)='L0_K0_MPA'     & access(40)=31
;dsets(41)='L0_K0_SPA'     & access(41)=31
;dsets(42)='L1_K0_MPA'     & access(42)=31
;dsets(43)='L1_K0_SPA'     & access(43)=31
;dsets(44)='L4_K0_MPA'     & access(44)=15
;dsets(45)='L4_K0_SPA'     & access(45)=15
;dsets(46)='L9_K0_MPA'     & access(46)=31
;dsets(47)='L9_K0_SPA'     & access(47)=31
;dsets(48)='PO_AT_DEF'     & access(48)= 2
;dsets(49)='PO_AT_PRE'     & access(49)= 2
;dsets(50)='PO_K0_CAM'     & access(50)= 2
;dsets(51)='PO_K0_PWI'     & access(51)= 2
;dsets(52)='PO_K0_SPHA'    & access(52)= 2
;dsets(53)='PO_K0_TIM'     & access(53)= 2
;dsets(54)='PO_K0_UVI'     & access(54)=31
;dsets(55)='PO_OR_DEF'     & access(55)= 2
;dsets(56)='PO_OR_PRE'     & access(56)= 2
;dsets(57)='S1_ED_EP'      & access(57)=32
;dsets(58)='S2_ED_EP'      & access(58)=32
;dsets(59)='S3_ED_EP'      & access(59)=32
;dsets(60)='SE_K0_AIS'     & access(60)=26
;dsets(61)='SE_K0_MAG'     & access(61)=26
;dsets(62)='SE_K0_RIO'     & access(62)=26
;dsets(63)='SE_K0_VLF'     & access(63)=26
;dsets(64)='SN_K0_GISR'    & access(64)=31
;dsets(65)='SO_AT_DEF'     & access(65)=10
;dsets(66)='SO_AT_PRE'     & access(66)=10
;dsets(67)='SO_K0_CST'     & access(67)=10
;dsets(68)='SO_K0_ERN'     & access(68)=10
;dsets(69)='SO_OR_DEF'     & access(69)=10
;dsets(70)='SO_OR_PRE'     & access(70)=10
;dsets(71)='SL_K0_210'     & access(71)=26
;dsets(72)='SL_K1_210'     & access(72)=26
;dsets(73)='T1_ED_EP'      & access(73)=32
;dsets(74)='T2_ED_EP'      & access(74)=32
;dsets(75)='T3_ED_EP'      & access(75)=32
;dsets(76)='VI_ED_AI'      & access(76)=32
;dsets(77)='WI_AT_DEF'     & access(77)=31
;dsets(78)='WI_AT_PRE'     & access(78)=31
;dsets(79)='WI_ED_MFI'     & access(79)=24
;dsets(80)='WI_K0_3DP'     & access(80)=31
;dsets(81)='WI_K0_EPA'     & access(81)= 2
;dsets(82)='WI_K0_MFI'     & access(82)=31
;dsets(83)='WI_K0_SPHA'    & access(83)=31
;dsets(84)='WI_K0_SWE'     & access(84)=31
;dsets(85)='WI_K0_WAV'     & access(85)=31
;dsets(86)='WI_OR_DEF'     & access(86)=31
;dsets(87)='WI_OR_PRE'     & access(87)=31
;dsets(88)='ULY_K0_MERGE'  & access(88)= 0


openr, iunit, '/usr/users/cdaweb/dev/source/Datasets.dat', /GET_LUN
readf, iunit, nsets

;Define datasets and their accessibility.
dsets = strarr(nsets) & access=intarr(nsets)
a = ' '
for i = 0, nsets-1 do begin
         readf, iunit, b, a
         dsets(i) = strtrim(a, 2)
         access(i) = b
;         print, i, dsets(i), access(i)
endfor
close, iunit
free_lun, iunit

end



; Filter from the ALPHA data structure, those files and times identified
; within this routine.  This process allows multiple views of the same
; set of data by this filtering process.
FUNCTION database_filter, ALPHA,IACG=IACG,ISTP=ISTP,SKIM=SKIM,PUBLIC=PUBLIC,$
                                CDAW9=CDAW9,SP_PHYS=SP_PHYS,SP_TEST=SP_TEST,$
                                BOWSHOCK=BOWSHOCK,DEBUG=DEBUG

key=0L & keycount=0L
if keyword_set(ISTP) then begin
  if keyword_set(PUBLIC) then key = 1 else key = 2
  keycount = keycount + 1
  n_intervals=1
  ibegin=strarr(n_intervals) & istop=strarr(n_intervals)
  ib=dblarr(n_intervals) & is=dblarr(n_intervals)
  ibegin(0) ='1900/12/29 00:00:00' & istop(0)='2525/12/29 23:59:59'
  for i=0,n_intervals-1 do ib(i)=encode_CDFEPOCH(ibegin(i))
  for i=0,n_intervals-1 do is(i)=encode_CDFEPOCH(istop(i))
endif
if keyword_set(IACG) then begin
  if keyword_set(PUBLIC) then key = 4 else key = 8
  keycount = keycount + 1
  n_intervals=12
  ibegin=strarr(n_intervals) & istop=strarr(n_intervals)
  ib=dblarr(n_intervals) & is=dblarr(n_intervals)
  ibegin(0) ='1995/10/18 00:00:00' & istop(0) ='1995/10/21 23:59:59'
  ibegin(1) ='1995/10/26 00:00:00' & istop(1) ='1995/10/27 23:59:59'
  ibegin(2) ='1995/10/31 00:00:00' & istop(2) ='1995/11/01 23:59:59'
  ibegin(3) ='1995/11/11 00:00:00' & istop(3) ='1995/11/12 23:59:59'
  ibegin(4) ='1995/11/17 00:00:00' & istop(4) ='1995/11/17 23:59:59'
  ibegin(5) ='1995/11/27 00:00:00' & istop(5) ='1995/11/30 23:59:59'
  ibegin(6) ='1995/12/03 00:00:00' & istop(6) ='1995/12/04 23:59:59'
  ibegin(7) ='1995/12/07 00:00:00' & istop(7) ='1995/12/07 23:59:59'
  ibegin(8) ='1995/12/15 00:00:00' & istop(8) ='1995/12/15 23:59:59'
  ibegin(9) ='1995/12/18 00:00:00' & istop(9) ='1995/12/20 23:59:59'
  ibegin(10)='1996/01/12 00:00:00' & istop(10)='1996/01/12 23:59:59'
  ibegin(11)='1996/10/01 00:00:00' & istop(11)='1997/02/28 23:59:59'
  for i=0,n_intervals-1 do ib(i)=encode_CDFEPOCH(ibegin(i))
  for i=0,n_intervals-1 do is(i)=encode_CDFEPOCH(istop(i))
endif
if keyword_set(SKIM) then begin
  key = 16 & keycount = keycount + 1
  n_intervals=6
  ibegin=strarr(n_intervals) & istop=strarr(n_intervals)
  ib=dblarr(n_intervals) & is=dblarr(n_intervals)
  ibegin(0) ='1994/12/11 00:00:00' & istop(0) ='1994/12/12 23:59:59'
  ibegin(1) ='1994/12/17 00:00:00' & istop(1) ='1994/12/19 23:59:59'
  ibegin(2) ='1994/12/27 00:00:00' & istop(2) ='1994/12/28 23:59:59'
  ibegin(3) ='1996/01/08 00:00:00' & istop(3) ='1996/01/10 23:59:59'
  ibegin(4) ='1996/01/18 00:00:00' & istop(4) ='1996/01/20 23:59:59'
  ibegin(5) ='1996/01/24 00:00:00' & istop(5) ='1996/01/26 23:59:59'
  for i=0,n_intervals-1 do ib(i)=encode_CDFEPOCH(ibegin(i))
  for i=0,n_intervals-1 do is(i)=encode_CDFEPOCH(istop(i))
endif
if keyword_set(CDAW9) then begin
  key = 32 & keycount = keycount + 1
  n_intervals=1
  ibegin=strarr(n_intervals) & istop=strarr(n_intervals)
  ib=dblarr(n_intervals) & is=dblarr(n_intervals)
  ibegin(0) ='1900/12/29 00:00:00' & istop(0)='2525/12/29 23:59:59'
  for i=0,n_intervals-1 do ib(i)=encode_CDFEPOCH(ibegin(i))
  for i=0,n_intervals-1 do is(i)=encode_CDFEPOCH(istop(i))
endif
if keyword_set(SP_PHYS) then begin
  key = 64 & keycount = keycount + 1
  n_intervals=1
  ibegin=strarr(n_intervals) & istop=strarr(n_intervals)
  ib=dblarr(n_intervals) & is=dblarr(n_intervals)
  ibegin(0) ='1900/12/29 00:00:00' & istop(0)='2525/12/29 23:59:59'
  for i=0,n_intervals-1 do ib(i)=encode_CDFEPOCH(ibegin(i))
  for i=0,n_intervals-1 do is(i)=encode_CDFEPOCH(istop(i))
endif
if keyword_set(SP_TEST) then begin
  key = 128 & keycount = keycount + 1
  n_intervals=1
  ibegin=strarr(n_intervals) & istop=strarr(n_intervals)
  ib=dblarr(n_intervals) & is=dblarr(n_intervals)
  ibegin(0) ='1900/12/29 00:00:00' & istop(0)='2525/12/29 23:59:59'
  for i=0,n_intervals-1 do ib(i)=encode_CDFEPOCH(ibegin(i))
  for i=0,n_intervals-1 do is(i)=encode_CDFEPOCH(istop(i))
endif
if keyword_set(BOWSHOCK) then begin
  key = 256 & keycount = keycount + 1
  n_intervals=2
  ibegin=strarr(n_intervals) & istop=strarr(n_intervals)
  ib=dblarr(n_intervals) & is=dblarr(n_intervals)
  ibegin(0) ='1995/04/25 00:00:00' & istop(0)='1995/04/25 12:00:00'
  ibegin(1) ='1996/02/15 12:00:00' & istop(1)='1996/02/16 12:00:00'
  for i=0,n_intervals-1 do ib(i)=encode_CDFEPOCH(ibegin(i))
  for i=0,n_intervals-1 do is(i)=encode_CDFEPOCH(istop(i))
endif

; Validate keyword input
if (keycount ne 1) then begin
  print,'ERROR> one and only one of the keywords(ISTP,IACG,SKIM) must be set'
  return,-1
endif

; Initialize loop
BETA=ALPHA ; copy structure for modification
CDF_EPOCH,maxstarttime,2100,/COMPUTE_EPOCH ; used for 'MASTER' cdf search
Access_definitions, dsets, access ; get arrays of dataset names and access keys


; Main loop - test each dataset in the BETA structure
tags = tag_names(BETA)
for i=0,n_elements(tags)-1 do begin
  w = where(dsets eq tags(i),wc) ; determine the dataset
  if wc gt 0 then begin ; process the recognized dataset
    if ((key AND access(w(0))) gt 0) then begin
      if keyword_set(DEBUG) then print,'Processing ',tags(i)
      ; extract information from the BETA structure
      w = where(BETA.(i).cnames ne '')
      cpaths  = BETA.(i).cpaths(w)
      cnames  = BETA.(i).cnames(w)
      cstarts = BETA.(i).cstarts(w)
      cstops  = BETA.(i).cstops(w)
      ; encode the start/stop times for comparison
      nc = n_elements(cnames) & cb=dblarr(nc) & cs=dblarr(nc)
      for j=0,nc-1 do cb(j)=encode_CDFEPOCH(cstarts(j))
      for j=0,nc-1 do cs(j)=encode_CDFEPOCH(cstops(j))
      ; screen out those cdf's whose times are not within event intervals
      ikeep = intarr(nc) ; keep a flag for each file
      for j=0,nc-1 do begin ; test each cdf file
        for k=0,n_intervals-1 do begin ; test each interval
          if (cb(j) eq maxstarttime) then ikeep(j)=1  ; mastercdf
          if ((cb(j) lt is(k))AND(cs(j) gt ib(k))) then ikeep(j)=1
        endfor
      endfor
      ; reinitialize file information
      for j=0,n_elements(BETA.(i).cnames)-1 do begin
        BETA.(i).cpaths(j)  = '' & BETA.(i).cnames(j) = ''
        BETA.(i).cstarts(j) = '' & BETA.(i).cstops(j) = ''
      endfor
      ; reset file information
      if (total(ikeep) le 0) then begin
        print,'Dropping the dataset:',tags(i),' cause: no cdfs in time range'
      endif else begin ; one or more cdf's to scrub
        for j=0,nc-1 do begin
          BETA.(i).cpaths(j)  = cpaths(j)  & BETA.(i).cnames(j) = cnames(j)
          BETA.(i).cstarts(j) = cstarts(j) & BETA.(i).cstops(j) = cstops(j)
        endfor
      endelse
    endif else begin
      print,'Dropping the dataset:',tags(i),' cause: not accessible'
      for j=0,n_elements(BETA.(i).cnames)-1 do begin
        BETA.(i).cpaths(j)  = '' & BETA.(i).cnames(j) = ''
        BETA.(i).cstarts(j) = '' & BETA.(i).cstops(j) = ''
      endfor
    endelse
  endif else print,'UNRECOGNIZED DATASET:',tags(i)
endfor
return,BETA
end


; Dump the contents of the ALPHA data structure into an ASCII file.  This
; file is to be used as a 'database' containing information about all of
; the CDFs in the ingested directory tree.
FUNCTION generate_database, ALPHA, FILENAME=FILENAME, ROOT=ROOT, DEBUG=DEBUG

CDF_EPOCH,maxstarttime,2100,/COMPUTE_EPOCH ; used for 'MASTER' cdf search
if not keyword_set(FILENAME) then FILENAME='cdfmetafile.txt'
print,'Opening the file ',FILENAME
OPENW,1,FILENAME,300,WIDTH=300
if not keyword_set(ROOT) then ROOT=''

lsources = tag_names(ALPHA) ; get name of each dataset
for i=0,n_elements(lsources)-1 do begin
  if keyword_set(DEBUG) then print,'Processing ',lsources(i),' data...'
  ; extract information about times and filenames
  w = where(ALPHA.(i).cnames ne '',wc)
  if (wc gt 0) then begin
    cpaths  = ALPHA.(i).cpaths(w)
    cnames  = ALPHA.(i).cnames(w)
    cstarts = ALPHA.(i).cstarts(w)
    cstops  = ALPHA.(i).cstops(w)
    nc = n_elements(cnames) & if ((nc eq 1)AND(cnames(0) eq '')) then nc = 0
    if (nc gt 0) then begin
      if keyword_set(DEBUG) then print,'Number of files= ',n_elements(cnames)
      estarts=dblarr(nc) & estops=dblarr(nc)
      ; convert start and stop times into cdf epoch times
      for j=0,nc-1 do begin
        estarts(j) = encode_CDFEPOCH(cstarts(j))
        estops(j)  = encode_CDFEPOCH(cstops(j))
      endfor

      ; deal with MASTER cdfs
      w = where(estarts eq maxstarttime,MASTER_count) & ALL_MASTERS=0
      if (MASTER_count eq n_elements(estarts)) then ALL_MASTERS=1 $
      else begin ; get name of MASTER if it exists then strip it out
        if (MASTER_count eq 0) then MASTER='' $
        else begin
          MASTER = cpaths(w(0)) + cnames(w(0))
          w = where(estarts ne maxstarttime,wc)
          cpaths  = cpaths(w)  & cnames = cnames(w)
          cstarts = cstarts(w) & cstops = cstops(w)
          estarts = estarts(w) & estops = estops(w)
        endelse
      endelse

      ; sort the files in ascending order by time
      a = sort(estarts)
      cpaths  = cpaths(a)   & cnames = cnames(a)
      cstarts = cstarts(a) & cstops = cstops(a)
      estarts = estarts(a) & estops = estops(a)

      ; determine time range
      start_time = cstarts(0) & stop_time = cstops(n_elements(cstops)-1)

      ; assemble pertinent information about variables
      vnames = tag_names(ALPHA.(i).VARS) & varinfo=strarr(n_elements(vnames))
      if keyword_set(DEBUG) then print,'Number of variables= ',n_elements(vnames)
      for j=0,n_elements(vnames)-1 do begin
        varinfo(j) = ALPHA.(i).VARS.(j).VATTRS.VAR_NAME + '|' + $
                     ALPHA.(i).VARS.(j).VATTRS.DICT_KEY + '|' + $
                     ALPHA.(i).VARS.(j).VATTRS.CATDESC
      endfor

      ; Output all pertinent data to ASCII file
      if ALL_MASTERS ne 1 then begin
        PRINTF,1,'DATASET>',lsources(i)
        PRINTF,1,'SOURCE_NAME>',ALPHA.(i).GATTRS.SOURCE_NAME
        PRINTF,1,'DESCRIPTOR>',ALPHA.(i).GATTRS.DESCRIPTOR
        PRINTF,1,'DATA_TYPE>',ALPHA.(i).GATTRS.DATA_TYPE
        PRINTF,1,'PI_NAME>',ALPHA.(i).GATTRS.PI_NAME
        PRINTF,1,'PI_AFFILIATION>',ALPHA.(i).GATTRS.PI_AFFILIATION
        PRINTF,1,'MISSION_GROUP>',ALPHA.(i).GATTRS.MISSION_GROUP
        PRINTF,1,'INSTRUMENT_TYPE>',ALPHA.(i).GATTRS.INSTRUMENT_TYPE
        PRINTF,1,'DATASET_LABEL>',ALPHA.(i).GATTRS.DATASET_LABEL
        PRINTF,1,'TIME_RANGE>',start_time,'>',stop_time
        if MASTER ne '' then PRINTF,1,'MASTERCDF>',MASTER
        PRINTF,1,'!VARIABLES=',n_elements(varinfo)
        for j=0,n_elements(varinfo)-1 do PRINTF,1,varinfo(j)
        PRINTF,1,'!CDFS=',n_elements(cnames)
        for j=0,n_elements(cnames)-1 do begin
          cstring = ROOT+cpaths(j)+cnames(j)+'.cdf>'+cstarts(j)+'>'+cstops(j)
          PRINTF,1,cstring
        endfor
        PRINTF,1,'!!!' ; End of dataset indicator
      endif
    endif
  endif
endfor
print,'closing ',FILENAME
close,1 ; close output file
return,0
end

FUNCTION inventory,a,TITLE=TITLE,GIF=GIF,DEBUG=DEBUG

; Establish error handler
Error_status = 0
CATCH, Error_status
if Error_status ne 0 then begin
  print,'Unknown error creating inventory graph'
  print,!ERR_STRING & return,-1
endif

; Initialize
CDF_EPOCH,masterstarttime,2100,/COMPUTE_EPOCH ; used for MASTERCDF search
CDF_EPOCH,btime,2100,/COMPUTE_EPOCH ; initialize inventory start time
CDF_EPOCH,etime,1900,/COMPUTE_EPOCH ; initialize inventory stop time
itypes='' ; initialize instrument types list

; Determine the number of datasets to be inventoried and their order
atags = tag_names(a) & ntags = n_elements(atags) & order = sort(atags)


; Determine the min and max times contained in the metastructure.  Also
; need to keep a list of which datasets to use, and which ones are empty
; or have master cdfs only.
if keyword_set(DEBUG) then print,'Determining inventory start and stop times...'
use = intarr(ntags)
for i=0,n_elements(tag_names(a))-1 do begin
  w = where(a.(i).cnames ne '',wc)
  if (wc gt 0) then begin
    b = a.(i).cstarts(w) & c = a.(i).cstops(w)
    if (b(0) eq '')AND(c(0) eq '') then use(i) = 0 $
    else begin
      if (b(0) eq '2099/12/31 00:00:00') then m=1 else m=0
      if (m eq 1)AND(n_elements(b) eq 1) then use(i) = 0 $
      else begin
        use(i) = 1
        e = encode_cdfepoch(b(0+m))
        f = encode_cdfepoch(c(n_elements(c)-1))
        if (e le btime) then btime = e
        if (f gt etime) then etime = f
      endelse
    endelse
  endif
endfor

if keyword_set(DEBUG) then begin
  print,'start time=',decode_cdfepoch(btime)
  print,'stop  time=',decode_cdfepoch(etime)
endif


; Compute the number of days between the inventory start and stop times
CDF_EPOCH,btime,y,m,d,h,n,s,ms,/BREAK & bjul = julday(m,d,y)
CDF_EPOCH,etime,y,m,d,h,n,s,ms,/BREAK & ejul = julday(m,d,y)
ndays=(ejul-bjul)+1

; Create array of CDF EPOCH times, one per julian day
times=dblarr(ndays) & jds=indgen(ndays) & jds=jds+bjul
for i=0,ndays-1 do begin
  caldat,jds(i),m,d,y & CDF_EPOCH,t,y,m,d,/COMPUTE_EPOCH & times(i)=t
endfor

; Create color synonyms
;black=0 & magenta=1 & red=2 & orange=3 & yellow=4 & lime=5 & green=6
;cyan=7 & blue=8 & purple=9 & salmon=10 & gray=11 & white=247

; Create the inventory array
bars=intarr(total(use),ndays) & bar_names = strarr(total(use))

; Fill the bar and color arrays
index = 0
for i=0,ntags-1 do begin
  if (use(order(i)) eq 1) then begin
    if keyword_set(DEBUG) then print,'Processing ',atags(order(i)),'...'
    bar_names(index) = atags(order(i))
    ; extract the instrument type and determine a unique number for each type
    b = a.(order(i)).gattrs.instrument_type & w = where(itypes eq b,wc)
    if (wc eq 0) then begin ; new instrument type
      if itypes(0) eq '' then itypes(0) = b else itypes = [itypes,b]
    endif
    case strlowcase(b) of
      'ground-based imagers'                             : color = 185
      'ground-based magnetometers, riometers, sounders'  : color = 142
      'ground-based vlf/elf/ulf, photometers'            : color = 142
      'ground-based hf-radars'                           : color = 208
      'particles (space)'                                : color = 185
      'magnetic fields (space)'                          : color = 89
      'ephemeris'                                        : color = 31
      'plasma and solar wind'                            : color = 246
      'electric fields (space)'                          : color = 82
      'radio and plasma waves (space)'                   : color = 48
      else                                               : color = 247
    endcase
    if keyword_set(GIF) then color = 48
    ; remove master cdfs from b and c
    w = where(a.(order(i)).cnames ne '')
    b = a.(order(i)).cstarts(w) & c = a.(order(i)).cstops(w)
    if (b(0) eq '2099/12/31 00:00:00') then begin
      b = b(1:n_elements(b)-1) & c = c(1:n_elements(c)-1)
    endif
    if (b(n_elements(b)-1) eq '2099/12/31 00:00:00') then begin
      b = b(0:n_elements(b)-2) & c = c(0:n_elements(c)-2)
    endif
    ; Convert each start and stop time to a julian day
    e = lonarr(n_elements(b)) & f = lonarr(n_elements(b))
    for j=0,n_elements(b)-1 do begin
      reads,strmid(b(j),0,4),y,FORMAT='(I)'
      reads,strmid(b(j),5,2),m,FORMAT='(I)'
      reads,strmid(b(j),8,2),d,FORMAT='(I)'
      e(j) = julday(m,d,y)
      if (e(j) lt bjul) then print, 'e(j) = ', e(j), ' for file ', j
      reads,strmid(c(j),0,4),y,FORMAT='(I)'
      reads,strmid(c(j),5,2),m,FORMAT='(I)'
      reads,strmid(c(j),8,2),d,FORMAT='(I)'
      f(j) = julday(m,d,y)
      if (f(j) lt bjul) then print, 'f(j) = ', f(j), ' for file ', j
    endfor
    ; Fill in bar array for those days where data exists for current dataset
    for j=0,n_elements(e)-1 do bars(index,(e(j)-bjul):(f(j)-bjul)) = color
    ; increment the bars index
    index = index + 1
  endif
endfor

if keyword_set(TITLE) then mytitle=TITLE else mytitle=''
if keyword_set(GIF) then begin
  myGIF=GIF & s = bar_chart(bar_names,bars,times,TITLE=mytitle,GIF=myGIF)
endif else s = bar_chart(bar_names,bars,times,TITLE=mytitle)
return,0
end


;
;  This routine create the metatdatabase catalogs for all of the currently
;  defined catalogs.
;
FUNCTION overnight
  ;TJK added the following logic so that if the data
  ; is located somewhere besides on our rumba machine,
  ; just set the CDAWDATA environment variable before
  ; running overnight, and everything will be fine!
  roots = getenv('CDAWDATA')
  if (roots eq '') then roots='/ncf/rumba1/istp/'

; create log file names
  month = strlowcase(strmid(systime(0), 4, 3))
  day = strtrim(strmid(systime(0), 8, 2), 1)
  errorlog = '/usr/users/cdaweb/log/' + month + day + '.log'
  gaplog = '/usr/users/cdaweb/log/' + month + day  +'.gap'

  a=crack_database(paths=roots,log=errorlog)
  b=examine_database(a, log=gaplog)
  b=version_fixer(a) ; filter out exact time overlaps within datasets
  a=0
  s=generate_database(b,filename='full_cdfmetafile.txt',root=roots)
  s=inventory(b,TITLE='ALL CDAWEB HOLDINGS',GIF='full_cdfmetafile.gif',/debug)

  ; generate the ISTP proprietary dbase
  c=database_filter(b,/ISTP)
  s=generate_database(c,filename='istp_cdfmetafile.txt',root=roots)
  s=inventory(c,TITLE='ISTP KPs',GIF='istp_cdfmetafile.gif',/debug)
  c=0

  ; generate the ISTP public dbase
  c=database_filter(b,/ISTP,/PUBLIC)
  s=generate_database(c,filename='istp_public_cdfmetafile.txt',root=roots)
  s=inventory(c,TITLE='ISTP PUBLIC',GIF='istp_public_cdfmetafile.gif',/debug)
  c=0

  ; generate the IACG proprietary dbase
  c=database_filter(b,/IACG)
  s=generate_database(c,filename='iacg_cdfmetafile.txt',root=roots)
  s=inventory(c,TITLE='IACG',GIF='iacg_cdfmetafile.gif',/debug)
  c=0

  ; generate the IACG public dbase
  c=database_filter(b,/IACG,/PUBLIC)
  s=generate_database(c,filename='iacg_public_cdfmetafile.txt',root=roots)
  s=inventory(c,TITLE='IACG',GIF='iacg_public_cdfmetafile.gif',/debug)
  c=0

  ; generate the magnetopause skimming proprietary dbase
  c=database_filter(b,/SKIM)
  s=generate_database(c,filename='mpause_cdfmetafile.txt',root=roots)
  s=inventory(c,TITLE='MAGNETOPAUSE SKIMMING',$
                GIF='mpause_cdfmetafile.gif',/debug)
  c=0

  ; generate the space physics public dbase
  c=database_filter(b,/SP_PHYS)
  s=generate_database(c,filename='sp_phys_cdfmetafile.txt',root=roots)
  s=inventory(c,TITLE='SPACE PHYSICS',$
                GIF='sp_phys_cdfmetafile.gif',/debug)
  c=0

  ; generate the space physics test dbase
  c=database_filter(b,/SP_TEST)
  s=generate_database(c,filename='sp_test_cdfmetafile.txt',root=roots)
  s=inventory(c,TITLE='SPACE PHYSICS TEST',$
                GIF='sp_test_cdfmetafile.gif',/debug)
  c=0

  ; generate the bow shock proprietary dbase
  c=database_filter(b,/BOWSHOCK)
  s=generate_database(c,filename='bowshock_cdfmetafile.txt',root=roots)
  s=inventory(c,TITLE='COLLABORATIVE BOW SHOCK STUDY',$
                GIF='bowshock_cdfmetafile.gif',/debug)
;
  c=database_filter(b,/CDAW9)
  s=generate_database(c,filename='cdaw9_cdfmetafile.txt',root=roots)
  s=inventory(c,TITLE='CDAW 9', GIF='cdaw9_cdfmetafile.gif',/debug)
;
  return,b
end

;
;  This routine create the metatdatabase catalogs for all of the currently
;  defined catalogs.
;
FUNCTION selected_overnight, catalog, log_file
  print, "This is a modified version of the overnight program that will"
  print, "create all catalogs for CDAWeb - this program will create only"
  print, "ONE catalog."
  print, "selected_overnight should be called as follows:"
  print, "	a = selected_overnight(catalog, logfile_name)"
  print, "	where valids for catalog are: iacg_pub, iacg_cdf, cdaw9,"
  print, "	mpause, full, istp_pub, istp_cdf, iacg_pub, iacg_cdf, "
  print, "	and mpause_cdf. "
  print, "      and valids for the logfile_name are: Mmmday ie. Aug9"
  print, "The output log files produced from this program will be the "
  print, "logfilename.log and logfilename.gap and are stored in "
  print, "the directory that this program is run from and the "
  print, "database files are stored in /ncf/rumba/istp"

;TJK - need to finish this routine...

  roots='/ncf/rumba1/istp/'
  a=crack_database(paths=roots,log='Aug9.log')
  b=examine_database(a, log='Aug9.gap')
  b=version_fixer(a) ; filter out exact time overlaps within datasets
  a=0
  s=generate_database(b,filename='full_cdfmetafile.txt',root=roots)
  s=inventory(b,TITLE='ALL CDAWEB HOLDINGS',GIF='full_cdfmetafile.gif',/debug)

  ; generate the ISTP proprietary dbase
  c=database_filter(b,/ISTP)
  s=generate_database(c,filename='istp_cdfmetafile.txt',root=roots)
  s=inventory(c,TITLE='ISTP KPs',GIF='istp_cdfmetafile.gif',/debug)
  c=0

  ; generate the ISTP public dbase
  c=database_filter(b,/ISTP,/PUBLIC)
  s=generate_database(c,filename='istp_public_cdfmetafile.txt',root=roots)
  s=inventory(c,TITLE='ISTP PUBLIC',GIF='istp_public_cdfmetafile.gif',/debug)
  c=0

  ; generate the IACG proprietary dbase
  c=database_filter(b,/IACG)
  s=generate_database(c,filename='iacg_cdfmetafile.txt',root=roots)
  s=inventory(c,TITLE='IACG',GIF='iacg_cdfmetafile.gif',/debug)
  c=0

  c=database_filter(b,/IACG,/PUBLIC)
  s=generate_database(c,filename='iacg_public_cdfmetafile.txt',root=roots)
  s=inventory(c,TITLE='IACG',GIF='iacg_public_cdfmetafile.gif',/debug)
  c=0

  c=database_filter(b,/SKIM)
  s=generate_database(c,filename='mpause_cdfmetafile.txt',root=roots)
  s=inventory(c,TITLE='MAGNETOPAUSE SKIMMING',$
                GIF='mpause_cdfmetafile.gif',/debug)

  c=database_filter(b,/CDAW9)
  s=generate_database(c,filename='cdaw9_cdfmetafile.txt',root=roots)
  s=inventory(c,TITLE='CDAW 9',$
                GIF='cdaw9_cdfmetafile.gif',/debug)
  return,b
end






