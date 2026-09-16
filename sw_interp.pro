
pro sw_interp,data,time,flag

;
;  program : sw_interp
;  author  : T Immel, UCB
;  purpose : take an array of data, and times and interpolate at points
;	   : where the data are equal to the value of 'flag'
;
;  data and time should be the same size.
;
;
;


if keyword_set(read) eq 1 then begin

;--- emergency read of sw data
  spawn,'ls swp/AC*',filelist
  close,5
  openr,5,filelist(0)
  spare=' '
  bla='                                                                     '
  while spare ne 'dd-mm' do readf,5,format='(a5)',spare
  counter=0

;--- count how many times to read this thing.
  while not(eof(5)) do begin
    readf,5,format='(a68)',bla
    bla=strcompress(bla)
    newbla=strsplit(bla(0),/extract)
    print,newbla(2),newbla(3)
    counter=counter + 1
  endwhile

  close,5
  openr,5,filelist(0)

  sw_data=fltarr(2,counter)
  time=indgen(counter)
  bla='                                                                     '
  spare=' '
;--- load the data
  while spare ne 'dd-mm' do readf,5,format='(a5)',spare
  for i=0,counter-1 do begin
    readf,5,format='(a68)',bla
    bla=strcompress(bla)
    newbla=strsplit(bla(0),/extract)
    sw_data(0,i)=float(newbla(2))
    sw_data(1,i)=float(newbla(3))

  endfor
  data=reform(sw_data(0,*))
  flag = -999.9

endif else begin 	;--- not instructed to read the data, assume it
			;--- is provided in call.



  bad_dat=where(data eq flag,badct)
  good_dat=where(data ne flag,goodct)

  if badct eq 0 then print,'Data does not need interpolation' else begin
    if goodct lt 2 then begin
	print,'All data are bad, cannot interpolate'
	data(*)=-1
        goto, ALL_BAD
    endif

    fill_dat=interpol(data(good_dat),time(good_dat),time(bad_dat))

    new_dat=data
    new_dat(bad_dat)=fill_dat

;--- copy first good datum back to t=0

    initval=data(good_dat(0))
    init_pos=good_dat(0)
    new_dat(0:init_pos)=initval

    data=new_dat

  endelse	;--- new loop 3-30-2001
endelse


;stop

ALL_BAD:

return

end