;$Author: jimm $
;$Date: 2010-01-12 12:18:45 -0800 (Tue, 12 Jan 2010) $
;$Header: /home/cdaweb/dev/control/RCS/inventory.pro,v 1.24 2009/04/08 18:51:11 johnson Exp johnson $
;$Locker: johnson $
;$Revision: 7092 $
;---------------------------------------------------------------------------

FUNCTION striplabel,a

a=strtrim(a,2) 
b=strsplit(a,'>',/extract)
if (n_elements(b) eq 1) then s=b[0] else s=strjoin(b[1:*],'>')

return,s
end

;---------------------------------------------------------------------------

FUNCTION ingest_database,infile,DATASETS=DATASETS,DEBUG=DEBUG
print, ' '
print, 'Text file currently being processed: ',infile
print, ' '
alpha = 0B ; set this here so that hopefully more memory will
	   ; be freed up on each subsequent call.
a = STRING(REPLICATE(32B,300)) ; allocate buffer space
DATASET_counter=0L ; initialize dataset counter
OPENR,1,infile ; Open the existing database
while (NOT EOF(1)) do begin ; read next dataset from file
  ; initialize gattrs and vattrs structures to be filled during input
  ;gattrs = 0B
  ;beta = 0B
  ;gamma = 0B

  ;gattrs = {SOURCE_NAME:''   , DESCRIPTOR:''     , DATA_TYPE:'',$
  ;          LOGICAL_SOURCE:'', LOGICAL_FILE_ID:'', MISSION_GROUP:'',$
  ;          PI_NAME:''       , PI_AFFILIATION:'' , INSTRUMENT_TYPE:'',$
  ;          DATASET:''       , DATASET_LABEL:''}
  ; RCJ 12/11/2003  Don't need all of the elements above. These will do:
  gattrs = {INSTRUMENT_TYPE:'',DATASET:''}

  ;TJK took out since this information is not used in the plots.
  ;  vattrs = {VAR_NAME:'',VAR_TYPE:'',DICT_KEY:'',CATDESC:'',DEPEND_0:''}
  ;TJK doing this below based on the real size needed for each dataset
  ;  cpaths  = strarr(5000) & cnames = strarr(5000)
  ;  cstarts = strarr(5000) & cstops = strarr(5000)

  if (n_elements(DATASETS) gt 0) then num_req_datasets = n_elements(DATASETS) $
  else num_req_datasets = 50000 ; set to some arbitrarily large number
	

  ; read the global information
  readf,1,a 
  gattrs.DATASET=striplabel(a)
  ;if keyword_set(DEBUG) then print,'Processing ',gattrs.DATASET,'...'

  ;TJK added 4/11/2003 - goes w/ addition of DATASETS keyword - basically
  ;check to see is keyword DATASETS is defined, if so compare this one
  ;with what's requested in DATSETS - if its not defined, read them all.

  further_check = 1 ; initialize to go ahead w/ read
  if (n_elements(DATASETS) gt 0) then begin 
    ds = where (gattrs.DATASET eq DATASETS, ds_wc)
    if (ds_wc eq 0) then further_check = 0 ;if this DATASET wasn't specified skip. 
  endif

  if (not further_check) then begin

     ;can't do this on unix    skipf, 1, 10, R
     ;repeat readf,1,a until (strpos(a,'!!!') ge 0) ; read until next dataset
     repeat begin
        readf,1,a
	;print,'a = ',a 
     endrep until (strpos(a,'!!!') ge 0) ; read until next dataset
 
     ;TJK added 4/11/2003 - goes w/ addition of DATASETS keyword - basically
     ;check to see if we've found all of the requested datasets, if so get out.
     if (dataset_counter ge num_req_datasets) then begin
       print, 'Returning early because all datasets have been found'
       close, 1 ;close the database file
       return, ALPHA
     endif

   endif else begin

     ; RCJ 12/11/2003  Structure now will only take 'dataset' and 'instrument_type'
     readf,1,a ;& gattrs.SOURCE_NAME=striplabel(a)
     readf,1,a ;& gattrs.DESCRIPTOR=striplabel(a)
     readf,1,a ;& gattrs.DATA_TYPE=striplabel(a)
     readf,1,a ;& gattrs.PI_NAME=striplabel(a)
     readf,1,a ;& gattrs.PI_AFFILIATION=striplabel(a)
     readf,1,a ;& gattrs.MISSION_GROUP=striplabel(a)
     ;TJK - db text file can now have multiple mission_group lines so skip over them    
     readf,1,a
	while(strpos(a,'MISSION_GROUP') ne -1) do readf,1,a ; read next record in file

     gattrs.INSTRUMENT_TYPE=striplabel(a) ;store one instrument_type, skip the rest

     ;TJK - db text file can now have multiple instrument_type lines so skip over them    
     readf,1,a
     while(strpos(a,'INSTRUMENT_TYPE') ne -1) do readf,1,a ; read next record in file

     ;readf,1,a & gattrs.DATASET_LABEL=striplabel(a)
     ;readf,1,a & a=strtrim(a,2) ; read the time range

     a=strtrim(a,2) ; read the time range
     readf,1,a & a=strtrim(a,2) ; could be mastercdf or !VARS

     ;
     ; process the mastercdf field if it exists
     master_present = 0L
     if strpos(a,'MASTER') ne -1 then begin ; mastercdf found
       b=strsplit(a,'>',/extract)
       if (b(1) ne '') then begin
         ; RCJ 12/11/2003 No longer want cdf_path and cdf_name
	 ; so commented out most of what's below:
	 ;
         ;; split the path from filename and correct the path
         ;split_filename,b(1),cdf_path,cdf_name
         ;; strip cdf suffix if present to conserve string space
         ;s=strpos(cdf_name,'.cdf') 
	 ;if s ne -1 then cdf_name=strmid(cdf_name,0,s)
         ;if keyword_set(ROOT) then begin ; strip root directory to save space
         ;  s = strpos(cdf_path,myROOT)
         ;  if s ne -1 then cdf_path = strmid(cdf_path,strlen(myROOT),100)
         ;endif
         ;TJK moved this down below after the size of cpaths, etc. is known
         ;      cpaths(0) = cdf_path & cnames(0) = cdf_name
         ;      cstarts(0) = '2099/12/31 00:00:00' & cstops(0) = '2099/12/31 00:00:00'
         master_present = 1L
       endif
       ;readf,1,a ; read next record in file, find out number of variables to be used below
     endif

     ;TJK added this to handle additional link> lines - 12/10/99
     ; skip the LINK line(s) if they exists
     ;while(strpos(a,'LINK') ne -1) do readf,1,a ; read next record in file
     while(strpos(a,'CDFS') eq -1) do readf,1,a ; read next record in file


     ; read the metadata about the variables
     ;  if keyword_set(DEBUG) then print,'    reading variable metadata...'
     ;;b=break_mystring(a,delimiter='=') 
     ;b=strsplit(a,'=',/extract)
     ;nvars=long(b(1))
     ;for i=0L,nvars-1 do begin ; read each variable
     ;  readf,1,a 
     ;  a=strtrim(a,2) 
     ;  ;TJK took all of this out because this information is not used in the plots.
     ;  ;    b=break_mystring(a,delimiter='|')
     ;  ;    vattrs.VAR_TYPE = 'data' & vattrs.VAR_NAME = b(0)
     ;  ;    vattrs.DICT_KEY = b(1)   & vattrs.CATDESC  = b(2)
     ;  ;    if (i eq 0) then begin
     ;  ;      v = create_struct('VATTRS',vattrs) ; create vattrs struct
     ;  ;      VARS = create_struct(b(0),v) ; attach to variable name tag
     ;  ;    endif else begin
     ;  ;      v = create_struct('VATTRS',vattrs) ; create structure
     ;  ;      u = create_struct(b(0),v) ; attach to variable name tag
     ;  ;      VARS = create_struct(VARS,u) ; append new structure to existing one
     ;  ;      v = 0 & u = 0 ;TJK free up more memory
     ;  ;    endelse
     ;endfor

     ; read the number of cdfs
     ;readf,1,a 
     
     ;a=strtrim(a,2)
     b=strsplit(a,'=',/extract)
     ncdfs=long(b(1))
     ;TJK adding this to allocate the sizes of the cnames, cstarts,etc.
     ; arrays based on the number of cdfs actually present for a given datatype.
     ; RCJ 12/11/2003  No longer need cpaths or cnames
     ;cpaths  = strarr(ncdfs+1) 
     ;cnames = strarr(ncdfs+1)
     cstarts = strarr(ncdfs+1) 
     cstops = strarr(ncdfs+1)
     recent = intarr(ncdfs+1)
     if (master_present) then begin
       ;cpaths(0) = cdf_path 
       ;cnames(0) = cdf_name
       cstarts(0) = '2099/12/31 00:00:00' 
       cstops(0) = '2099/12/31 00:00:00'    
     endif
     if keyword_set(DEBUG) then print,'    reading ',ncdfs,' cdfs...'
     for i=0L,ncdfs-1 do begin ; read each cdf line
       readf,1,a 
       a=strtrim(a,2)
       b=strsplit(a,'>',/extract)
       ;; split the path from filename and correct the path
       ;split_filename,b(0),cdf_path,cdf_name
       ;; strip cdf suffix if present to conserve string space
       ;s=strpos(cdf_name,'.cdf')  
       ;if s ne -1 then cdf_name=strmid(cdf_name,0,s)
       ;if keyword_set(myROOT) then begin ; strip root directory to save space
       ;   s = strpos(cdf_path,myROOT)
       ;   if s ne -1 then cdf_path = strmid(cdf_path,strlen(myROOT),100)
       ;endif
       
       ;test whether this is a "fill" cdf or not - if the start and stop time
       ;are exactly the same, then we don't want to include this CDF as a valid
       ;CDF. TJK 7/20/1999

       if (b(1) ne b(2)) then begin
         cstarts(i) = b(1)
         cstops(i)  = b(2)
;TJK 8/22/2005 - new section to record whether file has recently been
;                put on the system or not - we want to color code this
;                on the inventory plot
         cdf_info = file_info(b(0)) ;file_info was added in IDL6.0/1, so not backward compatible.
         cdf_date = bin_date(systime(0,cdf_info.mtime))
         year = cdf_date(0)
         mm = cdf_date(1)
         if (((year eq 2003) and (mm gt 9)) or (year ge 2004)) then begin
;DEBUG        print, 'file ', b(0), 'put on system since 2003 Sept: ',cdf_date
             recent(i) = 1
         endif else recent(i) = 0

         ;cpaths(i)  = cdf_path
         ;b=strsplit(b[0],'/',/extract)
         ;b=strsplit(b[n_elements(b)-1],'.',/extract)
         ;cnames(i)  = b[n_elements(b)-1]
       endif else begin
         cstarts(i) = ''
         cstops(i)  = ''
         if keyword_set(DEBUG) then print, 'times match, not including cdf ';,cdf_name
       endelse
     endfor
     ; read the end of dataset marker
     readf,1,a 
     ; assemble the information gathered above into data structure
     ;  BETA = create_struct('GATTRS',gattrs,'VARS',VARS,'CPATHS',cpaths,$
     ;                       'CNAMES',cnames,'CSTARTS',cstarts,'CSTOPS',cstops)

     ;BETA = create_struct('GATTRS',gattrs,'CPATHS',cpaths,$
                       ;'CNAMES',cnames,'CSTARTS',cstarts,'CSTOPS',cstops)
     ; RCJ 12/11/2003  No longer need cpaths and cnames in structure:		       
;TJK add "recent" flag to indicate that this particular file has been
;updated recently
;     BETA = create_struct('GATTRS',gattrs,'CSTARTS',cstarts,'CSTOPS',cstops)
     BETA = create_struct('GATTRS',gattrs,'CSTARTS',cstarts,'CSTOPS',cstops,'RECENT',recent)
     if (DATASET_counter eq 0) then $
       ALPHA = create_struct(gattrs.DATASET,temporary(BETA)) $
     else begin
       GAMMA = create_struct(gattrs.DATASET,temporary(BETA)) ; attach to logical source tag
       ;commented out the clearing because they are causing
       ; "% Unable to free memory: freeing string memory. No such device or address"
       ;    beta = 0B; TJK clear out this structure
       ALPHA = create_struct(temporary(ALPHA),temporary(GAMMA)) ; append to existing structure
     endelse
     DATASET_counter = DATASET_counter + 1

     ;clear out memory for these variables
     ;cpaths = ' '
     ;cnames= ' '
     ;cstarts = 0B
     ;cstops = 0B

     ;TJK added 4/11/2003 - goes w/ addition of DATASETS keyword - basically
     ;check to see if we've found all of the requested datasets, if so get out.
     if (dataset_counter gt num_req_datasets) then begin
       print, 'Returning early because all datasets have been found'
       close, 1 ;close the database file
       return, ALPHA
     endif

   endelse ;TJK added to go w/ the DATASETS keyword

endwhile
close,1 ; close the database file
return,ALPHA
end


;---------------------------------------------------------------------------


 FUNCTION draw_inventory,a,TITLE=TITLE,GIF=GIF,DEBUG=DEBUG, START_TIME=start_time,$
STOP_TIME=stop_time, BIGPLOT=bigplot, FIVEYEAR=fiveyear, COLORNEW=colornew, $
long_line=long_line, wide_margin=wide_margin

; long_line: toggle 0/1.  Used to connect availability bar to dataset name
;              Useful for graphs w/ long time spans where it's difficult
;              to tell what dataset name goes w/ what availability bar.  RCJ 04/08/2009
; wide_margin: toggle 0/1. Make left margin wider to accomodate longer dataset names.  RCJ 04/08/2009

;  arguments for old routine:  a,TITLE=TITLE,GIF=GIF,DEBUG=DEBUG


; Establish error handler
;Error_status = 0
;CATCH, Error_status
;if Error_status ne 0 then begin
;  print,'In draw_inventory. Error creating inventory graph'
;  print,!ERR_STRING 
;  return,-1
;endif

; Initialize
; RCJ 12/11/2003 Don't need these:
;CDF_EPOCH,masterstarttime,2100,1, 1, /COMPUTE_EPOCH ; used for MASTERCDF search
;CDF_EPOCH,btime,2100, 1, 1, /COMPUTE_EPOCH ; initialize inventory start time
;CDF_EPOCH,etime,1900, 1, 1, /COMPUTE_EPOCH ; initialize inventory stop time
;itypes='' ; initialize instrument types list


; Determine the number of datasets to be inventoried and their order
atags = tag_names(a) 
ntags = n_elements(atags) 
order = sort(atags)

;if keyword_set(DEBUG) then print,'Beginning begin and end times ', btime, etime

; Determine the min and max times contained in the metastructure.  Also
; need to keep a list of which datasets to use, and which ones are empty
; or have master cdfs only.

;TJK w/ start_time and stop_time keywords specified, they will override the
;default (start/stop from the data).
 
;if (keyword_set(START_TIME) or keyword_set(STOP_TIME)) then begin
if (keyword_set(START_TIME) and keyword_set(STOP_TIME)) then begin
   ;keywords START_TIME and STOP_TIME set to override full (actual) time
   ;range in the data.  Can use either or both or none.
   print, 'Start and/or stop time keyword specified - using them.'
   btime = encode_cdfepoch(start_time)
   etime = encode_cdfepoch(stop_time)

   ;if keyword_set(DEBUG) then print,'Determining inventory start and stop times...'
   use = intarr(ntags)

   for i=0L,n_elements(tag_names(a))-1 do begin
     w = where(a.(i).cstarts ne '')
     if (w[0] ne -1) then begin
       b = a.(i).cstarts(w) 
       c = a.(i).cstops(w)
       time = a.(i).recent(w)
       if (b(0) eq '') then begin ; b(0) is cstarts for mastercdf
         use(i) = 0 
         m=0
       endif else begin
         if (b(0) eq '2099/12/31 00:00:00') then m=1 else m=0
         if (m eq 1) and (n_elements(b) eq 1) then begin
            use(i) = 0 
         endif else begin
            use(i) = 1
	    ; RCJ 12/11/2003  btime and etime are already determined because the
	    ; start and stop times were specified by the user, there's no need to
	    ; run the code below.
	    ;;print, 'Dataset original start/end time ',b(0+m),' to ', c(n_elements(c)-1)
            ;e = encode_cdfepoch(b(0+m))
            ;f = encode_cdfepoch(c(n_elements(c)-1))
            ;;if ((e le btime) and (f ge btime) and (keyword_set(START_TIME))) then begin
	    ;; RCJ 09/30/02 Replaced line above w/ line below. "f ge btime" doesn't
	    ;; seem to apply and it's making many datasets disappear in the 
	    ;; smaller time range inventory plots. 
            ;if ((e le btime) and (keyword_set(START_TIME))) then begin
	    ;  ; RCJ 01/24/2003 Commented line below. It was causing the inventory bar to show
	    ;  ;  data where there wasn't any. Used example wi_h0_mfi.
	    ;  ;;a.(i).cstarts(w) = start_time ;reassign the start time string for this dataset
            ;  ;if keyword_set(DEBUG) then print, 'Re-setting start time for dataset ',atags(i),' to ',start_time
            ;endif else begin
	    ;  if (e le btime) then begin
	    ;    use(i) = 0 ;TJK added because this dataset isn't in the desired
	    ;	       ;range
            ;    ;btime = e ;don't reset since we want a specific start/stop time
            ;    ;if keyword_set(DEBUG) then print, 'Setting btime to e',e
	    ;  endif
            ;endelse

            ;if ((f gt etime) and (keyword_set(STOP_TIME))) then begin
	    ;  ; RCJ 01/24/2003 Commented line below. It was causing the inventory bar to show
	    ;  ;  data where there wasn't any. Used example wi_h0_mfi.
	    ;  ;;a.(i).cstops(w) = stop_time
            ;  ;if keyword_set(DEBUG) then print, 'Re-setting stop time for dataset ',atags(i),' to ',stop_time
   	    ;endif else if (f gt etime) then etime = f
         endelse
       endelse
     endif
   endfor
endif else begin ;start_time and stop_time keywords not specified
   if keyword_set(DEBUG) then print,'Determining inventory start and stop times...'
   ;
   e=0
   f=0
   use = intarr(ntags)
   for i=0L,n_elements(tag_names(a))-1 do begin
     w = where(a.(i).cstarts ne '')
     if (w[0] ne -1) then begin
       b = a.(i).cstarts(w) 
       c = a.(i).cstops(w)
       time = a.(i).recent(w)
       if (b(0) eq '') then use(i) = 0 $
       else begin
         if (b(0) eq '2099/12/31 00:00:00') then m=1 else m=0
         if (m eq 1) and (n_elements(b) eq 1) then use(i) = 0 $
         else begin
           use(i) = 1
           e = [e,encode_cdfepoch(b(0+m))]
           f = [f,encode_cdfepoch(c(n_elements(c)-1))]
	   ; RCJ 12/11/2003  Just collect values for e and f. Decide btime and etime later
           ;if (e le btime) then begin
           ;  btime = e
           ;endif
           ;if (f gt etime) then etime = f
         endelse
       endelse
     endif
   endfor
   e=e[1:*]
   btime=min(e)
   f=f[1:*]
   etime=max(f)
endelse

if keyword_set(DEBUG) then begin
  ;print,'start btime=',btime
  ;print,'stop  etime=',etime
  print,'start time=',decode_cdfepoch(btime)
  print,'stop  time=',decode_cdfepoch(etime)
endif


; Compute the number of days between the inventory start and stop times
CDF_EPOCH,btime,y,m,d,h,n,s,ms,/BREAK 
bjul = julday(m,d,y)
CDF_EPOCH,etime,y,m,d,h,n,s,ms,/BREAK 
ejul = julday(m,d,y)
ndays=(ejul-bjul)+1
if keyword_set(debug) then print,'number of days = ',ndays

; Create array of CDF EPOCH times, one per julian day
times=dblarr(ndays) 
jds=indgen(ndays) 
jds=jds+bjul
for i=0L, ndays-1 do begin
  caldat,jds(i),m,d,y 
  CDF_EPOCH,t,y,m,d,/COMPUTE_EPOCH 
  times(i)=t
endfor

; Create color synonyms
;black=0 & magenta=1 & red=2 & orange=3 & yellow=4 & lime=5 & green=6
;cyan=7 & blue=8 & purple=9 & salmon=10 & gray=11 & white=247

; Create the inventory array
bars=intarr(total(use),ndays) 
bar_names = strarr(total(use))
help, bars
; Fill the bar and color arrays
index = 0
; RCJ 12/11/2003 itypes doesn't seem to be used anywhere. Commented out.
;itypes='' ; initialize instrument types list
for i=0L,ntags-1 do begin
  if (use(order(i)) eq 1) then begin
    ;if keyword_set(DEBUG) then print,'Processing ',atags(order(i)),'...'
    bar_names(index) = atags(order(i))
    ; extract the instrument type and determine a unique number for each type
    if keyword_set(GIF) then begin
       color = 48 
    endif else begin 
      b = a.(order(i)).gattrs.instrument_type 
      ;w = where(itypes eq b,wc)
      ;if (wc eq 0) then itypes = [itypes,b] ; new instrument type
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
    endelse   
    ; remove master cdfs from b and c
    ;w = where(a.(order(i)).cnames ne '')
    w = where(a.(order(i)).cstarts ne '')
    b = a.(order(i)).cstarts(w) 
    c = a.(order(i)).cstops(w)
    time = a.(order(i)).recent(w)
    ;if n_elements(c) gt 3 then begin
       ;for t=0,3 do print,'starts = ',t,'  ',b(t)
       ;for t=0,3 do print,'stops = ',t,'  ',c(t)
    ;endif   
    ;if (b(0) eq '2099/12/31 00:00:00') then begin
    ; RCJ 09/30/02 Want to test c(0) too. This problem came up when we decided
    ; to have smaller range inventory plots. All b's were set to a new starting
    ; time before getting here so the condition never existed.
    if (b(0) eq '2099/12/31 00:00:00') $
    or (c(0) eq '2099/12/31 00:00:00') then begin
      ;sizeb = n_elements(b)-1 
      ;sizec = n_elements(c)-1
      b = b(1:n_elements(b)-1) 
      c = c(1:n_elements(c)-1)
      time = time(1:n_elements(time)-1)
    endif
    ;if (b(n_elements(b)-1) eq '2099/12/31 00:00:00') then begin
    if (b(n_elements(b)-1) eq '2099/12/31 00:00:00') $
    or (c(n_elements(c)-1) eq '2099/12/31 00:00:00') then begin
      b = b(0:n_elements(b)-2) 
      c = c(0:n_elements(c)-2)
      time = time(1:n_elements(time)-1)
    endif
    ; Convert each start and stop time to a julian day
    e = lonarr(n_elements(b)) 
    f = lonarr(n_elements(b))
    ;if n_elements(c) gt 3 then begin
       ;for t=0,3 do print,'starts again = ',t,'  ',b(t)
       ;for t=0,3 do print,'stops again = ',t,'  ',c(t)
    ;endif   
    for j=0L, n_elements(b)-1 do begin
      ; RCJ 12/11/2003  Rewrote this for loop. 'reads' are not necessary.
      ; Also decide what values of e and f will be equal to bjul or ejul later.
      parts=strsplit(b[j],/extract) ; will split on the blank space
      parts=fix(strsplit(parts[0],'/',/extract)) ; turns strings into integers
      e[j]=julday(parts[1],parts[2],parts[0])
      ;
      parts=strsplit(c[j],/extract) ; will split on the blank space
      parts=fix(strsplit(parts[0],'/',/extract)) ; turns strings into integers
      f[j]=julday(parts[1],parts[2],parts[0])
      ;reads,strmid(b(j),0,4),y,FORMAT='(I)'
      ;reads,strmid(b(j),5,2),m,FORMAT='(I)'
      ;reads,strmid(b(j),8,2),d,FORMAT='(I)'
      ;e(j) = julday(m,d,y)
      ;if (e(j) lt bjul) then begin
      ;  ;print, 'time less than begin time-resetting' 
      ;	e(j) = bjul
      ;endif
      ;if (e(j) gt ejul) then begin
      ;	;print, 'time exceeds known end time, resetting to endtime, j= ',j
      ;	e(j) = ejul
      ;      endif
      ;reads,strmid(c(j),0,4),y,FORMAT='(I)'
      ;reads,strmid(c(j),5,2),m,FORMAT='(I)'
      ;reads,strmid(c(j),8,2),d,FORMAT='(I)'
      ;f(j) = julday(m,d,y)
      ;if (f(j) lt bjul) then begin
      ;  ;print, 'time less than begin time-resetting' 
      ;	f(j) = bjul
      ;endif
      ;if (f(j) gt ejul) then begin
      ;  ;print,'j,c(j) = ',j,'  ',c(j)
      ;  ;print,'m,d,y,julday,c(j) = ',m,d,y,julday(m,d,y),'  ',c(j)
      ;	;print, 'time exceeds known end time, resetting to endtime, j= ',j
      ;	;print,f(j),ejul
      ;	f(j) = ejul
      ;	;print,f(j)-bjul,f(j)-ejul
      ;      endif
    endfor
    q=where(e lt bjul)
    if q[0] ne -1 then e[q]=bjul
    q=where(e gt ejul)
    if q[0] ne -1 then e[q]=ejul
    q=where(f lt bjul)
    if q[0] ne -1 then f[q]=bjul
    q=where(f gt ejul)
    if q[0] ne -1 then f[q]=ejul
    ; Fill in bar array for those days where data exists for current dataset
    save_color = color
    for j=0L, n_elements(e)-1 do begin
      if ((e(j)-bjul) gt (f(j)-bjul)) then print, ' bad file ', j
      ;TJK try to assign a different color to new files
      if (time(j) eq 1) then color = 100 else color = save_color
      ;TJK put in following check - 5/5/1999
      if ((e(j)-bjul) le (f(j)-bjul)) then bars(index,(e(j)-bjul):(f(j)-bjul)) = color
      ;if index eq 128 then print,'bars: ',index,f(j),bjul,(f(j)-bjul)
    endfor
    ; increment the bars index
    index = index + 1
  endif
endfor

if keyword_set(TITLE) then mytitle=TITLE else mytitle=''
if keyword_set(BIGPLOT) then print, 'DEBUG, BIGPLOT being requested'
if keyword_set(FIVEYEAR) then print, 'DEBUG, FIVEYEAR being requested'
if keyword_set(GIF) then begin
  myGIF=GIF 
  ; RCJ 12/11/2003. Added xsize=800
  s = bar_chart(bar_names,bars,times,TITLE=mytitle,GIF=myGIF,xsize=800,BIGPLOT=bigplot,$
      FIVEYEAR=fiveyear,COLORNEW=colornew,long_line=long_line,wide_margin=wide_margin)
endif else s = bar_chart(bar_names,bars,times,TITLE=mytitle,xsize=800,BIGPLOT=bigplot, $
               FIVEYEAR=fiveyear,COLORNEW=colornew,long_line=long_line,wide_margin=wide_margin)
;try to free up memory
help, bars, times
bars = 0B
times = 0B
bar_names = ' '
a = 0B
b = 0B
return,0
end

;---------------------------------------------------------------------------


 FUNCTION inventory_stats,a,TITLE=TITLE,DEBUG=DEBUG, START_TIME=start_time,$
STOP_TIME=stop_time, file=file
;
;This is a greatly modified version of draw_inventory that will give statistics across
;the datasets for the data coverage that we have in CDAWeb.  TJK 11/9/1999
;

; Establish error handler
Error_status = 0
CATCH, Error_status
if Error_status ne 0 then begin
  print,'Unknown error creating inventory stats'
  print,!ERR_STRING 
  return,-1
endif

if keyword_set(file) then file = file else file = inv_stats.txt
print, 'Stats being sent to ',file

; Initialize
;CDF_EPOCH,masterstarttime,2100,1, 1, /COMPUTE_EPOCH ; used for MASTERCDF search
CDF_EPOCH,btime,2100, 1, 1, /COMPUTE_EPOCH ; initialize inventory start time
CDF_EPOCH,etime,1900, 1, 1, /COMPUTE_EPOCH ; initialize inventory stop time
itypes='' ; initialize instrument types list



; Determine the number of datasets to be inventoried and their alphabetic order
atags = tag_names(a) 
ntags = n_elements(atags) 
order = sort(atags)

;if keyword_set(DEBUG) then print,'Beginning begin and end times ', btime, etime

; Determine the min and max times contained in the metastructure.  Also
; need to keep a list of which datasets to use, and which ones are empty
; or have master cdfs only.

;TJK w/ start_time and stop_time keywords specified, they will override the
;default (start/stop from the data).

if (keyword_set(START_TIME) or keyword_set(STOP_TIME)) then begin
 ;keywords START_TIME and STOP_TIME set to override full (actual) time
 ;range in the data.  Can use either or both or none.
  print, 'Start and/or stop time keyword specified - using them.'
  if (keyword_set(START_TIME)) then btime = encode_cdfepoch(start_time)
  if (keyword_set(STOP_TIME)) then  etime = encode_cdfepoch(stop_time)

if keyword_set(DEBUG) then print,'Determining inventory start and stop times...'
use = intarr(ntags)
for i=0L,n_elements(tag_names(a))-1 do begin
;  w = where(a.(i).cnames ne '',wc)
  w = where(a.(i).cstarts ne '',wc)
  if (wc gt 0) then begin
    b = a.(i).cstarts(w) 
    c = a.(i).cstops(w)
    ;print, 'b, c', b, c
    if (b(0) eq '')AND(c(0) eq '') then use(i) = 0 $
    else begin
      if (b(0) eq '2099/12/31 00:00:00') then m=1 else m=0
      if (m eq 1)AND(n_elements(b) eq 1) then use(i) = 0 $
      else begin
        use(i) = 1
        ;print, 'Dataset original start/end time ',b(0+m),' to ', c(n_elements(c)-1)
        e = encode_cdfepoch(b(0+m))
        f = encode_cdfepoch(c(n_elements(c)-1))

        if ((e le btime) and (f ge btime) and (keyword_set(START_TIME))) then begin
	  a.(i).cstarts(w) = start_time ;reassign the start time string for this dataset
          ;if keyword_set(DEBUG) then print, 'Re-setting start time for dataset ',atags(i),' to ',start_time
        endif else begin
	  if (e le btime) then begin
	    use(i) = 0 ;TJK added because this dataset isn't in the desired
		       ;range
            ;btime = e ;don't reset since we want a specific start/stop time
            ;if keyword_set(DEBUG) then print, 'Setting btime to e',e
	  endif
        endelse

        if ((f gt etime) and (keyword_set(STOP_TIME))) then begin
	  a.(i).cstops(w) = stop_time
          ;if keyword_set(DEBUG) then print, 'Re-setting stop time for dataset ',atags(i),' to ',stop_time
	endif else if (f gt etime) then etime = f
      endelse
    endelse
  endif
if (btime le 0.0) then begin ;DEBUGGING
  help, btime, etime
  print, i
endif ;TJK
endfor

endif else begin ;start_time and stop_time keywords not specified

if keyword_set(DEBUG) then print,'Determining inventory start and stop times...'
use = intarr(ntags)
for i=0L,n_elements(tag_names(a))-1 do begin
;  w = where(a.(i).cnames ne '',wc)
  w = where(a.(i).cstarts ne '',wc)
  if (wc gt 0) then begin
    b = a.(i).cstarts(w) 
    c = a.(i).cstops(w)
;	print, 'b, c', b, c
    if (b(0) eq '')AND(c(0) eq '') then use(i) = 0 $
    else begin
      if (b(0) eq '2099/12/31 00:00:00') then m=1 else m=0
      if (m eq 1)AND(n_elements(b) eq 1) then use(i) = 0 $
      else begin
        use(i) = 1
        e = encode_cdfepoch(b(0+m))
        f = encode_cdfepoch(c(n_elements(c)-1))
        if (e le btime) then begin
          btime = e
          ;if keyword_set(DEBUG) then print, 'Setting btime to e',e
        endif
        if (f gt etime) then etime = f
      endelse
    endelse
  endif
  if (btime le 0.0) then begin ;DEBUGGING
     help, btime, etime
     print, i
  endif ;TJK
endfor

endelse

if keyword_set(DEBUG) then begin

  ;print,'start btime=',btime
  ;print,'stop  etime=',etime
  print,'start time=',decode_cdfepoch(btime)
  print,'stop  time=',decode_cdfepoch(etime)
endif


; Compute the number of days between the inventory start and stop times
CDF_EPOCH,btime,y,m,d,h,n,s,ms,/BREAK 
bjul = julday(m,d,y)
CDF_EPOCH,etime,y,m,d,h,n,s,ms,/BREAK 
ejul = julday(m,d,y)
ndays=(ejul-bjul)+1
if keyword_set(debug) then print,'number of days = ',ndays

; Create array of CDF EPOCH times, one per julian day
times=dblarr(ndays) 
jds=indgen(ndays) 
jds=jds+bjul
for i=0L, ndays-1 do begin
  caldat,jds(i),m,d,y 
  CDF_EPOCH,t,y,m,d,/COMPUTE_EPOCH 
  times(i)=t
endfor

; Create color synonyms
;black=0 & magenta=1 & red=2 & orange=3 & yellow=4 & lime=5 & green=6
;cyan=7 & blue=8 & purple=9 & salmon=10 & gray=11 & white=247

; Create the inventory array
bars=intarr(total(use),ndays) 
bar_names = strarr(total(use))
help, bars
; Fill the bar and color arrays
index = 0
for i=0L,ntags-1 do begin
  if (use(order(i)) eq 1) then begin
    ;if keyword_set(DEBUG) then print,'Processing ',atags(order(i)),'...'
    bar_names(index) = atags(order(i))
    ; extract the instrument type and determine a unique number for each type
    b = a.(order(i)).gattrs.instrument_type 
    w = where(itypes eq b,wc)
    color = 48

    ; remove master cdfs from b and c  
;TJK try not to need cnames anymore, use cstarts instead
;    w = where(a.(order(i)).cnames ne '')
    w = where(a.(order(i)).cstarts ne '')
    b = a.(order(i)).cstarts(w) 
    c = a.(order(i)).cstops(w)
    if (b(0) eq '2099/12/31 00:00:00') then begin
      sizeb = n_elements(b)-1 
      sizec = n_elements(c)-1
      b = b(1:sizeb) 
      c = c(1:sizec)
    endif
    if (b(n_elements(b)-1) eq '2099/12/31 00:00:00') then begin
      b = b(0:n_elements(b)-2) 
      c = c(0:n_elements(c)-2)
    endif
    ; Convert each start and stop time to a julian day
    e = lonarr(n_elements(b)) 
    f = lonarr(n_elements(b))
    for j=0L, n_elements(b)-1 do begin
      reads,strmid(b(j),0,4),y,FORMAT='(I)'
      reads,strmid(b(j),5,2),m,FORMAT='(I)'
      reads,strmid(b(j),8,2),d,FORMAT='(I)'
      e(j) = julday(m,d,y)
      if (e(j) lt bjul) then begin
;        print, 'time less than begin time-resetting' 
	e(j) = bjul
      endif
      if (e(j) gt ejul) then begin
;	print, 'time exceeds known end time, resetting to endtime, j= ',j
	e(j) = ejul
      endif
      reads,strmid(c(j),0,4),y,FORMAT='(I)'
      reads,strmid(c(j),5,2),m,FORMAT='(I)'
      reads,strmid(c(j),8,2),d,FORMAT='(I)'
      f(j) = julday(m,d,y)
      if (f(j) lt bjul) then begin
;        print, 'time less than begin time-resetting' 
	f(j) = bjul
      endif
      if (f(j) gt ejul) then begin
;	print, 'time exceeds known end time, resetting to endtime, j= ',j
	f(j) = ejul
      endif
    endfor
    ; Fill in bar array for those days where data exists for current dataset
    for j=0L, n_elements(e)-1 do begin
	if ((e(j)-bjul) gt (f(j)-bjul)) then print, ' bad file ', j
;TJK put in following check - 5/5/1999
      if ((e(j)-bjul) le (f(j)-bjul)) then bars(index,(e(j)-bjul):(f(j)-bjul)) = color
    endfor
    ; increment the bars index
    index = index + 1
  endif
endfor

help, bars
help, bar_names
help, times
;instead of calling bar_chart we want to look at the arrays

s = print_inv_stats(bar_names,bars,times,TITLE=mytitle, File=file)

if keyword_set(TITLE) then mytitle=TITLE else mytitle=''
;if keyword_set(GIF) then begin
;  myGIF=GIF & s = bar_chart(bar_names,bars,times,TITLE=mytitle,GIF=myGIF)
;endif else s = bar_chart(bar_names,bars,times,TITLE=mytitle)
;try to free up memory
help, bars, times
bars = 0B
times = 0B
bar_names = ' '
a = 0B
b = 0B
return,0
end ;inventory_stats

;Create_inv_gif will generate a single inventory gif file for a given
;metadatabase catalog file.
;Tami Kovalick - Jan. 31, 1998
;

;---------------------------------------------------------------------------

function create_inv_gif, text_file, gif_file, title=title, debug=debug
;text_file needs to be a valid cdaweb metadatabase path name & text file, ie.
;          '/home/rumba/cdaweb/metadata/istp_cdfmetafile.txt'
;gif_file needs to be valid path name and unix file name, ie.
;         '/home/rumba/cdaweb/metadata/istp_cdfmetafile.gif'
;title is the title you'd like placed on the inventory plot.

a = ingest_database(text_file,DEBUG=DEBUG)
; Draw inventory graph...
s=draw_inventory(a,TITLE=title,GIF=gif_file, debug=debug)

return, s
end


;---------------------------------------------------------------------------

FUNCTION inventory

; Generated inventory graphs for CDAWeb from info in the cdf metafiles...

debug = 1
; Read the metadata file...
;a = ingest_database('/home/rumba/cdaweb/metadata/full_cdfmetafile.txt',DEBUG=DEBUG)
; Draw inventory graph...
;s=draw_inventory(a,TITLE='FULL CDAWEB HOLDINGS',GIF='/home/rumba/cdaweb/metadata/full_cdfmetafile.gif',/debug)

; Read the metadata file...
a = ingest_database('/home/rumba/cdaweb/metadata/istp_cdfmetafile.txt',DEBUG=DEBUG)
; Draw inventory graph...
s=draw_inventory(a,TITLE='ISTP PROPRIETARY DATA',GIF='/home/rumba/cdaweb/metadata/istp_cdfmetafile.gif',/debug)

; Read the metadata file...
a = ingest_database('/home/rumba/cdaweb/metadata/istp_public_cdfmetafile.txt',DEBUG=DEBUG)
; Draw inventory graph...
s=draw_inventory(a,TITLE='ISTP PUBLIC DATA',GIF='/home/rumba/cdaweb/metadata/istp_public_cdfmetafile.gif',/debug)

; Read the metadata file...
a = ingest_database('/home/rumba/cdaweb/metadata/iacg_cdfmetafile.txt',DEBUG=DEBUG)
; Draw inventory graph...
s=draw_inventory(a,TITLE='IACG PROPRIETARY DATA',GIF='/home/rumba/cdaweb/metadata/iacg_cdfmetafile.gif',/debug)

; Read the metadata file...
a = ingest_database('/home/rumba/cdaweb/metadata/iacg_public_cdfmetafile.txt',DEBUG=DEBUG)
; Draw inventory graph...
s=draw_inventory(a,TITLE='IACG PUBLIC DATA',GIF='/home/rumba/cdaweb/metadata/iacg_public_cdfmetafile.gif',/debug)

; Read the metadata file...
a = ingest_database('/home/rumba/cdaweb/metadata/mpause_cdfmetafile.txt',DEBUG=DEBUG)
; Draw inventory graph...
s=draw_inventory(a,TITLE='SKIMMING CAMPAIGN',GIF='/home/rumba/cdaweb/metadata/mpause_cdfmetafile.gif',/debug)

; Read the metadata file...
a = ingest_database('/home/rumba/cdaweb/metadata/bowshock_cdfmetafile.txt',DEBUG=DEBUG)
; Draw inventory graph...
s=draw_inventory(a,TITLE='BOWSHOCK',GIF='/home/rumba/cdaweb/metadata/bowshock_cdfmetafile.gif',/debug)

; Read the metadata file...
a = ingest_database('/home/rumba/cdaweb/metadata/cdaw9_cdfmetafile.txt',DEBUG=DEBUG)
; Draw inventory graph...
s=draw_inventory(a,TITLE='CDAW-9 CAMPAIGN',GIF='/home/rumba/cdaweb/metadata/cdaw9_cdfmetafile.gif',/debug)

; Read the metadata file...
a = ingest_database('/home/rumba/cdaweb/metadata/sp_phys_cdfmetafile.txt',DEBUG=DEBUG)
; Draw the inventory graph...
s=draw_inventory(a,TITLE='SPACE PHYSICS',GIF='/home/rumba/cdaweb/metadata/sp_phys_cdfmetafile.gif',/debug)

; Read the metadata file...
a = ingest_database('/home/rumba/cdaweb/metadata/sp_test_cdfmetafile.txt',DEBUG=DEBUG)
; Draw the inventory graph...
s=draw_inventory(a,TITLE='SPACE PHYSICS TEST DATA',GIF='/home/rumba/cdaweb/metadata/sp_test_cdfmetafile.gif',/debug)

return, s
end
