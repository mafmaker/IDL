
pro load_dmsp,sat,year,startday,stopday,dmsp_struct_ret,orbit=orbit

;program to load dmsp data into the dmsp common block for access by
;other procedures. OK and handed back to the calling routine
;IDL> print,headline
;0 Date 
;1 Time 
;2 R
;3 I
;4 Alt.
;5 GLAT
;6 GLONG
;7 MLAT
;8 MLT
;9 Vx
;10 Vy
;11 Vz
;12 RMSx
;13 SigmaY
;14 SigmaZ
;15 Ni (cm^-3)
;16 Frac O
;17 Frac He
;18 Frac H
;19 Ti
;20 Te
;21 pts



COMMON dmsp, dmsp_struct

; holder arrays are defined, with sizes based upon how many days of data


;--- if a single orbit is asked for, grab it from the first orbit.
stopday_=stopday
if keyword_set(orbit) ne 0 then stopday_=startday

for i=0,stopday_-startday do begin

  sc = strlowcase(sat) + '_rl'

  if year gt 1000 then year_=(year-1900) mod 100 else year_=year
  if year_ lt 1 then syear='00'
  if year_ lt 10 then syear='0' + strcompress(year_,/rem)
  if year_ ge 10 then syear=strcompress(year_,/rem)
  sday=strcompress(startday + i,/rem)
  if startday+i lt 100 then sday = '0' + sday 
  if startday+i lt 10 then sday  = '0' + sday

  ffilter=sc+syear+sday + '*.txt'
  pfilter='/home/immel/sci/dmsp/data_txt_files/'

;--- make sure you aren't adding empty strings to the file list.

  test=findfile(pfilter + ffilter)
  if test(0) ne '' then begin
    if defined(filelist) eq 0 then $
      filelist=findfile(pfilter+ffilter) else $
      filelist=[filelist, findfile(pfilter + ffilter)]
  endif

  if keyword_set(orbit) ne 0 then begin

    orb_limit=n_elements(filelist) -1 
    filelist=filelist(1> orbit < orb_limit)

  endif

endfor

holder=(1600 * n_elements(filelist))

dater=fltarr(22,holder)

counter=0

for i=0,n_elements(filelist)-1 do begin

;--- gotta get past the header
  startread=strarr(1)
  get_lun,unit
  openr,unit,filelist(i)
  print,'Reading ',filelist(i)
  header=1
  while header eq 1 do begin
    readf,unit,startread 
    headline=strsplit(startread,/extract)
;    print,headline(0)
    if strcompress(headline(0),/rem) eq 'Date' then header = 0
;    help,startread,headline
  endwhile

;-- NOW read all that data
  bla=fltarr(22)

  while not(eof(unit)) do begin
    readf,unit,bla
;    print,bla
    dater(*,counter)=bla
    counter=counter+1
  endwhile

  close,/all

endfor

dater=dater(*,0:counter-1)

dmsp_struct={date:reform(fix(dater(0,*) mod 1000)),$
             time:reform(dater(1,*)),$
             RR:reform(dater(2,*)),$
             II:reform(dater(3,*)),$
             alt:reform(dater(4,*)),$
             glat:reform(dater(5,*)),$
             glon:reform(dater(6,*)),$
             mlat:reform(dater(7,*)),$
             mlt:reform(dater(8,*)),$
             vx:reform(dater(9,*)),$
             vy:reform(dater(10,*)),$
             vz:reform(dater(11,*)),$
             rmsx:reform(dater(12,*)),$
             sigmay:reform(dater(13,*)),$
             sigmaz:reform(dater(14,*)),$
             Ni:reform(dater(15,*)),$
             frac_O:reform(dater(16,*)),$
             frac_He:reform(dater(17,*)),$
             frac_H:reform(dater(18,*)),$
             Ti:reform(dater(19,*)),$
             Te:reform(dater(20,*)),$
             pts:reform(dater(21,*))}


dmsp_struct_ret=dmsp_struct

;stop

end
