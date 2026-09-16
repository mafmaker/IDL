;$Author: kovalick $
;$Date: 1999/07/20 18:35:35 $
;$Header: /home/rumba/cdaweb/dev/control/RCS/inventory.pro,v 1.13 1999/07/20 18:35:35 kovalick Exp kovalick $
;$Locker: kovalick $
;$Revision: 1.13 $
;---------------------------------------------------------------------------

FUNCTION striplabel,a

a=strtrim(a,2) & b=break_mystring(a,delimiter='>')
nb = n_elements(b)

if (nb eq 1) then s=b(0) else s = b(1)

for i=2, nb-1 do s = s+'>' + b(i)

return,s
end


FUNCTION ingest_database,infile,DEBUG=DEBUG
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
  gattrs = 0B
  beta = 0B
  gamma = 0B

  gattrs = {SOURCE_NAME:''   , DESCRIPTOR:''     , DATA_TYPE:'',$
            LOGICAL_SOURCE:'', LOGICAL_FILE_ID:'', MISSION_GROUP:'',$
            PI_NAME:''       , PI_AFFILIATION:'' , INSTRUMENT_TYPE:'',$
            DATASET:''       , DATASET_LABEL:''}

;TJK took out since this information is not used in the plots.
;  vattrs = {VAR_NAME:'',VAR_TYPE:'',DICT_KEY:'',CATDESC:'',DEPEND_0:''}
;TJK doing this below based on the real size needed for each dataset
;  cpaths  = strarr(5000) & cnames = strarr(5000)
;  cstarts = strarr(5000) & cstops = strarr(5000)


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

;
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
;TJK moved this down below after the size of cpaths, etc. is known
;      cpaths(0) = cdf_path & cnames(0) = cdf_name
;      cstarts(0) = '2099/12/31 00:00:00' & cstops(0) = '2099/12/31 00:00:00'
      master_present = 1L
    endif
    readf,1,a ; read next record in file
  endif

;TJK added this to handle additional link> lines - 12/10/99
; skip the LINK line(s) if they exists
  while(strpos(a,'LINK') ne -1) do readf,1,a ; read next record in file


  ; read the metadata about the variables
;  if keyword_set(DEBUG) then print,'    reading variable metadata...'
  b=break_mystring(a,delimiter='=') & nvars=long(b(1))
  for i=0L,nvars-1 do begin ; read each variable
    readf,1,a & a=strtrim(a,2) 
;TJK took all of this out because this information is not used in the plots.
;    b=break_mystring(a,delimiter='|')
;    vattrs.VAR_TYPE = 'data' & vattrs.VAR_NAME = b(0)
;    vattrs.DICT_KEY = b(1)   & vattrs.CATDESC  = b(2)
;    if (i eq 0) then begin
;      v = create_struct('VATTRS',vattrs) ; create vattrs struct
;      VARS = create_struct(b(0),v) ; attach to variable name tag
;    endif else begin
;      v = create_struct('VATTRS',vattrs) ; create structure
;      u = create_struct(b(0),v) ; attach to variable name tag
;      VARS = create_struct(VARS,u) ; append new structure to existing one
;      v = 0 & u = 0 ;TJK free up more memory
;    endelse
  endfor

  ; read the number of cdfs
  readf,1,a & a=strtrim(a,2)
  b=break_mystring(a,delimiter='=') 
  ncdfs=long(b(1))
  ;TJK adding this to allocate the sizes of the cnames, cstarts,etc.
  ; arrays based on the number of cdfs actually present for a given datatype.
  cpaths  = strarr(ncdfs+1) & cnames = strarr(ncdfs+1)
  cstarts = strarr(ncdfs+1) & cstops = strarr(ncdfs+1)
  if (master_present) then begin
    cpaths(0) = cdf_path & cnames(0) = cdf_name
    cstarts(0) = '2099/12/31 00:00:00' & cstops(0) = '2099/12/31 00:00:00'    
  endif
  if keyword_set(DEBUG) then print,'    reading ',ncdfs,' cdfs...'
  for i=0L,ncdfs-1 do begin ; read each cdf line
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
    ;test whether this is a "fill" cdf or not - if the start and stop time
    ;are exactly the same, then we don't want to include this CDF as a valid
    ;CDF. TJK 7/20/1999
    if (b(1) ne b(2)) then begin
      cpaths(i)  = cdf_path
      cnames(i)  = cdf_name
      cstarts(i) = b(1)
      cstops(i)  = b(2)
    endif else begin
       if keyword_set(DEBUG) then print, 'times match, not including cdf ',cdf_name
    endelse
  endfor
  ; read the end of dataset marker
  readf,1,a 
  ; assemble the information gathered above into data structure
;  BETA = create_struct('GATTRS',gattrs,'VARS',VARS,'CPATHS',cpaths,$
;                       'CNAMES',cnames,'CSTARTS',cstarts,'CSTOPS',cstops)

  BETA = create_struct('GATTRS',gattrs,'CPATHS',cpaths,$
                       'CNAMES',cnames,'CSTARTS',cstarts,'CSTOPS',cstops)
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
  cpaths = ' '
  cnames= ' '
  cstarts = 0B
  cstops = 0B
endwhile
close,1 ; close the database file
return,ALPHA
end


 FUNCTION draw_inventory,a,TITLE=TITLE,GIF=GIF,DEBUG=DEBUG, START_TIME=start_time,$
STOP_TIME=stop_time


;  arguments for old routine:  a,TITLE=TITLE,GIF=GIF,DEBUG=DEBUG


; Establish error handler
Error_status = 0
CATCH, Error_status
if Error_status ne 0 then begin
  print,'Unknown error creating inventory graph'
  print,!ERR_STRING & return,-1
endif

; Initialize
CDF_EPOCH,masterstarttime,2100,1, 1, /COMPUTE_EPOCH ; used for MASTERCDF search
CDF_EPOCH,btime,2100, 1, 1, /COMPUTE_EPOCH ; initialize inventory start time
CDF_EPOCH,etime,1900, 1, 1, /COMPUTE_EPOCH ; initialize inventory stop time
itypes='' ; initialize instrument types list



; Determine the number of datasets to be inventoried and their order
atags = tag_names(a) & ntags = n_elements(atags) & order = sort(atags)

if keyword_set(DEBUG) then print,'Beginning begin and end times ', btime, etime

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
  w = where(a.(i).cnames ne '',wc)
  if (wc gt 0) then begin
    b = a.(i).cstarts(w) & c = a.(i).cstops(w)
;	print, 'b, c', b, c
    if (b(0) eq '')AND(c(0) eq '') then use(i) = 0 $
    else begin
      if (b(0) eq '2099/12/31 00:00:00') then m=1 else m=0
      if (m eq 1)AND(n_elements(b) eq 1) then use(i) = 0 $
      else begin
        use(i) = 1
;	print, 'Dataset original start/end time ',b(0+m),' to ', c(n_elements(c)-1)
        e = encode_cdfepoch(b(0+m))
        f = encode_cdfepoch(c(n_elements(c)-1))

        if ((e le btime) and (f ge btime) and (keyword_set(START_TIME))) then begin
	  a.(i).cstarts(w) = start_time ;reassign the start time string for this dataset
          if keyword_set(DEBUG) then print, 'Re-setting start time for dataset ',atags(i),' to ',start_time
        endif else begin
	  if (e le btime) then begin
	    use(i) = 0 ;TJK added because this dataset isn't in the desired
		       ;range
;            btime = e ;don't reset since we want a specific start/stop time
;            if keyword_set(DEBUG) then print, 'Setting btime to e',e
	  endif
        endelse

        if ((f gt etime) and (keyword_set(STOP_TIME))) then begin
	  a.(i).cstops(w) = stop_time
          if keyword_set(DEBUG) then print, 'Re-setting stop time for dataset ',atags(i),' to ',stop_time
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
  w = where(a.(i).cnames ne '',wc)
  if (wc gt 0) then begin
    b = a.(i).cstarts(w) & c = a.(i).cstops(w)
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
          if keyword_set(DEBUG) then print, 'Setting btime to e',e
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

  print,'start btime=',btime
  print,'stop  etime=',etime
  print,'start time=',decode_cdfepoch(btime)
  print,'stop  time=',decode_cdfepoch(etime)
endif


; Compute the number of days between the inventory start and stop times
CDF_EPOCH,btime,y,m,d,h,n,s,ms,/BREAK & bjul = julday(m,d,y)
CDF_EPOCH,etime,y,m,d,h,n,s,ms,/BREAK & ejul = julday(m,d,y)
ndays=(ejul-bjul)+1
if keyword_set(debug) then print,'number of days = ',ndays

; Create array of CDF EPOCH times, one per julian day
times=dblarr(ndays) & jds=indgen(ndays) & jds=jds+bjul
for i=0L, ndays-1 do begin
  caldat,jds(i),m,d,y & CDF_EPOCH,t,y,m,d,/COMPUTE_EPOCH & times(i)=t
endfor

; Create color synonyms
;black=0 & magenta=1 & red=2 & orange=3 & yellow=4 & lime=5 & green=6
;cyan=7 & blue=8 & purple=9 & salmon=10 & gray=11 & white=247

; Create the inventory array
bars=intarr(total(use),ndays) & bar_names = strarr(total(use))
help, bars
; Fill the bar and color arrays
index = 0
for i=0L,ntags-1 do begin
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
      sizeb = n_elements(b)-1 & sizec = n_elements(c)-1
      b = b(1:sizeb) & c = c(1:sizec)
    endif
    if (b(n_elements(b)-1) eq '2099/12/31 00:00:00') then begin
      b = b(0:n_elements(b)-2) & c = c(0:n_elements(c)-2)
    endif
    ; Convert each start and stop time to a julian day
    e = lonarr(n_elements(b)) & f = lonarr(n_elements(b))
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

if keyword_set(TITLE) then mytitle=TITLE else mytitle=''
if keyword_set(GIF) then begin
  myGIF=GIF & s = bar_chart(bar_names,bars,times,TITLE=mytitle,GIF=myGIF)
endif else s = bar_chart(bar_names,bars,times,TITLE=mytitle)
;try to free up memory
help, bars, times
bars = 0B
times = 0B
bar_names = ' '
a = 0B
b = 0B
return,0
end

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
  print,!ERR_STRING & return,-1
endif

if keyword_set(file) then file = file else file = inv_stats.txt
print, "Stats being sent to ',file

; Initialize
CDF_EPOCH,masterstarttime,2100,1, 1, /COMPUTE_EPOCH ; used for MASTERCDF search
CDF_EPOCH,btime,2100, 1, 1, /COMPUTE_EPOCH ; initialize inventory start time
CDF_EPOCH,etime,1900, 1, 1, /COMPUTE_EPOCH ; initialize inventory stop time
itypes='' ; initialize instrument types list



; Determine the number of datasets to be inventoried and their alphabetic order
atags = tag_names(a) & ntags = n_elements(atags) & order = sort(atags)

if keyword_set(DEBUG) then print,'Beginning begin and end times ', btime, etime

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
  w = where(a.(i).cnames ne '',wc)
  if (wc gt 0) then begin
    b = a.(i).cstarts(w) & c = a.(i).cstops(w)
;	print, 'b, c', b, c
    if (b(0) eq '')AND(c(0) eq '') then use(i) = 0 $
    else begin
      if (b(0) eq '2099/12/31 00:00:00') then m=1 else m=0
      if (m eq 1)AND(n_elements(b) eq 1) then use(i) = 0 $
      else begin
        use(i) = 1
;	print, 'Dataset original start/end time ',b(0+m),' to ', c(n_elements(c)-1)
        e = encode_cdfepoch(b(0+m))
        f = encode_cdfepoch(c(n_elements(c)-1))

        if ((e le btime) and (f ge btime) and (keyword_set(START_TIME))) then begin
	  a.(i).cstarts(w) = start_time ;reassign the start time string for this dataset
          if keyword_set(DEBUG) then print, 'Re-setting start time for dataset ',atags(i),' to ',start_time
        endif else begin
	  if (e le btime) then begin
	    use(i) = 0 ;TJK added because this dataset isn't in the desired
		       ;range
;            btime = e ;don't reset since we want a specific start/stop time
;            if keyword_set(DEBUG) then print, 'Setting btime to e',e
	  endif
        endelse

        if ((f gt etime) and (keyword_set(STOP_TIME))) then begin
	  a.(i).cstops(w) = stop_time
          if keyword_set(DEBUG) then print, 'Re-setting stop time for dataset ',atags(i),' to ',stop_time
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
  w = where(a.(i).cnames ne '',wc)
  if (wc gt 0) then begin
    b = a.(i).cstarts(w) & c = a.(i).cstops(w)
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
          if keyword_set(DEBUG) then print, 'Setting btime to e',e
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

  print,'start btime=',btime
  print,'stop  etime=',etime
  print,'start time=',decode_cdfepoch(btime)
  print,'stop  time=',decode_cdfepoch(etime)
endif


; Compute the number of days between the inventory start and stop times
CDF_EPOCH,btime,y,m,d,h,n,s,ms,/BREAK & bjul = julday(m,d,y)
CDF_EPOCH,etime,y,m,d,h,n,s,ms,/BREAK & ejul = julday(m,d,y)
ndays=(ejul-bjul)+1
if keyword_set(debug) then print,'number of days = ',ndays

; Create array of CDF EPOCH times, one per julian day
times=dblarr(ndays) & jds=indgen(ndays) & jds=jds+bjul
for i=0L, ndays-1 do begin
  caldat,jds(i),m,d,y & CDF_EPOCH,t,y,m,d,/COMPUTE_EPOCH & times(i)=t
endfor

; Create color synonyms
;black=0 & magenta=1 & red=2 & orange=3 & yellow=4 & lime=5 & green=6
;cyan=7 & blue=8 & purple=9 & salmon=10 & gray=11 & white=247

; Create the inventory array
bars=intarr(total(use),ndays) & bar_names = strarr(total(use))
help, bars
; Fill the bar and color arrays
index = 0
for i=0L,ntags-1 do begin
  if (use(order(i)) eq 1) then begin
    if keyword_set(DEBUG) then print,'Processing ',atags(order(i)),'...'
    bar_names(index) = atags(order(i))
    ; extract the instrument type and determine a unique number for each type
    b = a.(order(i)).gattrs.instrument_type & w = where(itypes eq b,wc)
    color = 48

    ; remove master cdfs from b and c
    w = where(a.(order(i)).cnames ne '')
    b = a.(order(i)).cstarts(w) & c = a.(order(i)).cstops(w)
    if (b(0) eq '2099/12/31 00:00:00') then begin
      sizeb = n_elements(b)-1 & sizec = n_elements(c)-1
      b = b(1:sizeb) & c = c(1:sizec)
    endif
    if (b(n_elements(b)-1) eq '2099/12/31 00:00:00') then begin
      b = b(0:n_elements(b)-2) & c = c(0:n_elements(c)-2)
    endif
    ; Convert each start and stop time to a julian day
    e = lonarr(n_elements(b)) & f = lonarr(n_elements(b))
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
