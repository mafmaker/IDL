pro iridium_p,year,day,new_iridium,timeshift=timeshift,nointerp=nointerp,$
              stopper=stopper,debug=debug

;
;  Author : Thomas Immel
;  Licence : Berkeley Standard Distribution. Copyright UC Regents
; 

;  program to provide a simple day's worth of Iridium data,
;  interpolated to account for data gaps and the normal problem at 8
;  UT where the Iridium day turns over.
;
;  new iridium output are all net_db values interpolated to 15 minutes
;  exactly, with no smoothing at all. 
;
;  Timeshift shifts the time window for the data. Negative values
;  shift the window into the previous day by X hours. Positive values
;  shift the window toward the following day by X hours. This is done
;  to test delays
;
;  On 12-05-04, timeshifts were not working if greater than 24. Must
;  be a quick fix, but I don't see the problem currently
;
;   To really provide and index, it HAS to interpolate, but for bug
;   testing provide a no_interp switch

  year_ =year
  day_  =day  ;don't pass back changes in variables.
  hour_ =0
  timeshift_=0

  if keyword_set(debug) gt 0 then print,'Given ', day_,keyword_set(timeshift)
  if keyword_set(timeshift) gt 0 then print,timeshift
  if keyword_set(timeshift) gt 0 then timeshift_=timeshift

  if (timeshift_) lt 0 then begin

      day_=day_ -1 +fix(timeshift_/24)
      hour_= 24 + (timeshift_ mod 24)

  endif

  if (timeshift_) gt 0 then begin   
      day_ = day_ + fix(timeshift_/24)      
      hour_=  (timeshift_ mod 24) ;this likely does not work!!!
  endif     ; should not have to do an if then else. Same formula should work for positive and negative timeshifts

  if keyword_set(debug) gt 0 then print,year_,day_,hour_


  read_iridium_p2, [fix(year_), fix(day_), hour_,0,0],$
                  [fix(year_), fix(day_+1), hour_,0,0],iridium
  bad_data=where(iridium.net_db eq -1, baddy)
  good_data=where(iridium.net_db gt -1, goody)

  time_increment=.25
  time_steps= 24. / time_increment
  times=findgen(time_steps)* time_increment + (time_increment *0.5)


;--- this interpolation is flaky, it can produce 1-2 hour shifts in
;    the wrong time direction depending on if the data start off with
;    a gap or not. BUT, it is not overly destructive and I have to
;    concentrate on another problem now!!!

  if keyword_set(nointerp) gt 0 then new_iridium=iridium.net_db else begin

    time_4_interpolation=iridium.hour(good_data)

;--- put the shifted times on a 24 hour range starting at 0
    if keyword_set(timeshift) ne 0 then time_4_interpolation=((time_4_interpolation mod 24) - time_4_interpolation(0) + 24) mod 24  ;it works. ??? I don't think so!

    new_iridium=interpol(iridium.net_db(good_data),time_4_interpolation,$
                          times)   ;using good_data expecting the 0th data point to always be good in this scheme. Not really good here, the 0th element will not alway sbee 



  endelse


  if keyword_set(stopper) gt 0 then stop

return
end

