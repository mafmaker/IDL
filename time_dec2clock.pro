pro time_dec2clock,time,hr,min_,sec,msec,mkstr=mkstr, stopper = stopper, $
                   round = round, nudge = nudge
;
;  TIME_DECIMAL2CLOCK : Thomas Immel  10-22-99
;
;  sick and TIRED of converting back and forth all the time????
;  This will convert and will handle arrays transparently
;
;  input : time (decimal time)
;  output: hr min_ sec  (integer) and msec (floating point)
;
;  changes
;	02-28-2001 : added makestr keyword
;	04-16-2001 : does up to 1-D arrays with mkstr,(better than before)
;       03-15-2002 ; added nudge keyword, round keyword. IDL is really
;       stupid sometimes!

if keyword_set(nudge) eq 1 then   $
  time = double(time) + 0.001 ; add BS to get around stupid IDL rounding error
if keyword_set(round) then time = round(time*100)/100.

hr=fix(time)
work=(time-hr) * 60.
min_=fix(work)
work=(work-min_) *60.
sec=fix(work)
work=(work-sec) *1000.
msec=work               ;keep as floating point!!!

;stop

if keyword_set(mkstr) gt 0 then begin

  thing=size(time)
  if thing(0) lt 1 then begin

    shr=strcompress(hr,/rem) & if hr lt 10 then shr='0'+shr
    smin_=strcompress(min_,/rem) & if min_ lt 10 then smin_='0'+smin_
    ssec=strcompress(sec,/rem) & if sec lt 10 then ssec='0'+ssec
    smsec=strcompress(msec,/rem)

    hr=shr
    min_=smin_
    sec=ssec
    msec=smsec

  endif else begin
    shr=time & shr(*)=0 & shr=string(shr)
    smin_=shr
    ssec=shr
    smsec=shr
    for i=0,thing(1)-1 do begin

      hhh=strcompress(hr(i),/rem) & if hr(i) lt 10 then hhh='0'+hhh
      mmm=strcompress(min_(i),/rem) & if min_(i) lt 10 then mmm='0'+mmm


;	print,mmm

      sss=strcompress(sec(i),/rem) & if sec(i) lt 10 then sss='0'+sss
      msmsms=strcompress(msec(i),/rem)

      shr(i)=hhh
      smin_(i)=mmm
      ssec(i)=sss
      smsec(i)=msmsms

    endfor

;stop


    hr=shr
    min_=smin_
    sec=ssec
    msec=smsec
  endelse

endif

;help

if keyword_set(stopper) eq 1 then stop

return
end
