;   program : read_nacs_p
;   date    : 11-11-03
;   author  : TJI
;   licence : BSD : http://www.opensource.org/licenses/bsd-license.php
;
;  notes : code is to read DE2NACS ASCII data from ftp://nssdc.gsfc.nasa.gov/
;  The filename convention is as follows:
;  1981275T005140_1_DE2_NACS_1S_V01.ASC
;  YYYYDDD?HHMMSS
;  
;  Design decision : We are only going to read one ASCII file per
;  request! It would be very easy to tack several files together, but
;  what is the point? Read only the first one that falls in the window.
;
;  If there are no data on the requested *day*, then quit 
;  INPUTS: starttime [yyyy,ddd,hh,mm]
;          stoptime  [yyyy,ddd,hh,mm]
;
;  OUTPUTS: data structure as follows    
;UT              FLOAT     Array[1555]
;   O_DEN           FLOAT     Array[1555]
;   O_ERR           FLOAT     Array[1555]
;   N2_DEN          FLOAT     Array[1555]
;   N2_ERR          FLOAT     Array[1555]
;   HE_DEN          FLOAT     Array[1555]
;   HE_ERR          FLOAT     Array[1555]
;   N_DEN           FLOAT     Array[1555]
;   N_ERR           FLOAT     Array[1555]
;   AR_DEN          FLOAT     Array[1555]
;   AR_ERR          FLOAT     Array[1555]
;   ORBIT           INT       Array[1555]
;   ALT             FLOAT     Array[1555]
;   LAT             FLOAT     Array[1555]
;   LON             FLOAT     Array[1555]
;   LST             FLOAT     Array[1555]
;   LMT             FLOAT     Array[1555]
;   LSHELL          FLOAT     Array[1555]
;   INVLAT          FLOAT     Array[1555]
;   SZA             FLOAT     Array[1555]
;
;
;  KEYWORDS: stopper (for debugging)
;            filename (full filename w/path to read specific file)
;
;  -one subroutine : read_ascii_nacs

pro read_ascii_nacs, infile, starttime, stoptime, datastructure

;normally would either read the file completely once and define
;variable arrays, since adding elements is inefficient, but the ascii
;files are not large

;  pass starttime and endtime here to limit
;
;

get_lun, unit
openr, unit, infile
holder = ' '
readf, unit, holder  ;read identifier line
readf, unit, holder  ;read units line
while not(eof(unit)) do begin

  readf, unit, holder
  data_string = strsplit(holder, /extract)
  if defined(ut) le 0 then begin
    ut = float(data_string(0))
    o_den = float(data_string(1))
    o_err = float(data_string(2))
    n2_den = float(data_string(3))
    n2_err = float(data_string(4))
    he_den = float(data_string(5))
    he_err = float(data_string(6))
    n_den = float(data_string(7))
    n_err = float(data_string(8))
    ar_den = float(data_string(9))
    ar_err = float(data_string(10))
    orbit = fix(data_string(11))
    alt =  float(data_string(12))
    lat = float(data_string(13))
    lon = float(data_string(14))
    lst = float(data_string(15))
    lmt = float(data_string(16))
    lshell = float(data_string(17))
    invlat =  float(data_string(18))
    sza = float(data_string(19))
  endif else begin
    ut = [ut, float(data_string(0))]
    o_den =[o_den, float(data_string(1))]
    o_err =[o_err, float(data_string(2))]
    n2_den =[n2_den, float(data_string(3))]
    n2_err =[n2_err, float(data_string(4))]
    he_den =[he_den, float(data_string(5))]
    he_err =[he_err, float(data_string(6))]
    n_den =[n_den, float(data_string(7))]
    n_err =[n_err, float(data_string(8))]
    ar_den =[ar_den, float(data_string(9))]
    ar_err =[ar_err, float(data_string(10))]
    orbit =[orbit, fix(data_string(11))]
    alt =[alt, float(data_string(12))]
    lat =[lat, float(data_string(13))]
    lon =[lon, float(data_string(14))]
    lst =[lst, float(data_string(15))]
    lmt =[lmt, float(data_string(16))]
    lshell =[lshell, float(data_string(17))]
    invlat =[invlat, float(data_string(18))]
    sza =[sza, float(data_string(19))]
  endelse
endwhile

ut = ut/3600./1000.

keep = where(ut gt starttime and ut lt stoptime) ;don't check size, if we 
                                         ;didn't have data, we 
                                ;wouldn't have gotten this far!


datastructure = { ut:ut(keep),  $
o_den:o_den(keep),  o_err:o_err(keep), $
n2_den:n2_den(keep),  n2_err:n2_err(keep), $
he_den:he_den(keep),  he_err:he_err(keep),  $
n_den:n_den(keep),  n_err:n_err(keep),  $
ar_den: ar_den(keep),  ar_err: ar_err(keep),  $
orbit: orbit(keep),  alt: alt(keep),  $
lat: lat(keep),  lon: lon(keep), $
lst: lst(keep),  lmt: lmt(keep), $
lshell: lshell(keep),  invlat: invlat(keep),  $
sza: sza(keep)}



close, unit
free_lun, unit

return
end


pro read_nacs_p, starttime, stoptime, de2data, filepath = filepath, stopper = stopper, filename = filename


file_path = '/home/immel/fat/sci/de2/nacs/'
if keyword_set(filepath) gt 0 then file_path = filepath
if keyword_set(filename) gt 0 then begin
  filetoread = filename
  decimalstart = 0.
  decimalend = 24.   ;set these to pass to the ascii reader
  GOTO, GOTFILE
endif

;check to see if there are any data on any of the days in the interval

startyear = fix(starttime(0))
startday =  fix(starttime(1))
starthour = fix(starttime(2)) - 1
startmin = fix(starttime(3))

;--- open the window by an hour to capture the tail end of any data
;    from an earlier  timestamp-ed file.

if starthour lt 0 then begin & startday = startday-1 & starthour = 23 & endif


sstartyear = strcompress(startyear, /rem)
sstartday = strcompress(startday, /rem) 
if startday lt 100 then sstartday = '0' + sstartday
if startday lt 10 then sstartday = '0' + sstartday
sstarthour = strcompress(starthour, /rem) 
if starthour lt 10 then sstarthour = '0' + sstarthour


;found =  -1
;while found lt 0 then do

  filelist = findfile(file_path + sstartyear + sstartday + '*')
 
if strlen(filelist(0)) lt 2 then goto, getout else begin
  print, 'Found ' + strcompress(n_elements(filelist), /rem) + ' files on the day you specified.'
;  print, filelist
endelse

;--- If there is only one file in the filelist, this is completely
;    doubtful, but if this is the case, it could have no data in the
;    time window of interest, so check it.

good_file = 0
sparefilelist = filelist
starthour =  starthour + 1  ;--- I never used the wider window for anything

;--- flip through the filelist looking for The One.

get_out = 0

while good_file ne 1 and get_out eq 0 do begin ;  n_elements(filelist) ge 1 do begin


  decimalstart = float(starthour) + float(startmin)/60.
  decimalend = float(stoptime(2)) + float(stoptime(3))/60.


  name_path_extract, filelist(0), fileone, somepath
  fileonestart = float(strmid(fileone, 8, 2)) + $
      float(strmid(fileone, 10, 2)) /60.


  if fileonestart ge decimalstart and fileonestart lt decimalend then begin
    filetoread = filelist(0)

;--- do a tail on the file if the datafile start is within 2 hours of
;--- the specified window. Otherwise forget it.
  endif else if fileonestart lt decimalstart and fileonestart gt decimalstart-2 then begin
   
;--- this spawn can take a good bit of time, unfortunately
    spawn, 'tail -1l ' + filelist(0), tailer
    fileoneend = float(strmid(tailer, 0, 9))/1000./3600. &  fileoneend = fileoneend(0)


    if fileoneend gt decimalstart then begin
      filetoread = filelist(0)
      good_file = 1
    endif
  endif


;  if good_file eq 0 and n_elements(filelist) gt 1 then begin;

;    name_path_extract, filelist(1), fileone, somepath
;    filetwostart = float(strmid(fileone, 8, 2)) + $
;      float(strmid(fileone, 10, 2)) /60.;
;
;    if decimalstart lt filetwostart and decimalend gt filetwostart then begin
 ;     filetoread = filelist(1)
;      good_file = 1
;    endif
;
;  endif
  
  if n_elements(filelist) gt 1 then filelist = filelist(1:*) else get_out =  1

endwhile


if defined(filetoread) gt 0 then print, 'INFILE ' + filetoread else goto, GETOUT

GOTFILE:

;--- call this procedure to read all the data in from one file

print, 'Reading ' + filetoread
read_ascii_nacs, filetoread,decimalstart, decimalend, de2data






;endwhile

if keyword_set(stopper) gt 0 then stop

return

GETOUT:

  de2data = {ut:-1}
  print, 'There are no NACS data in the time frame you specified'

if keyword_set(stopper) gt 0 then stop


return
end
