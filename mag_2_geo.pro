PRO mag_2_geo, lat_mag, lon_mag, lat, lon, pole=pole
;convert from geomagnetic to geocentric coordinates
;modified from Art Richmond's original code in GM2GC.f
;Nov. 7, 2001 by G. Lu

   if keyword_set(pole) then begin
      lat_p = pole(0)*!dtor
      lon_p = pole(1)*!dtor
   endif else begin
      lat_p=10.44*!dtor            ; co-latitude of north geomagnetic pole
      lon_p=-71.59*!dtor           ; longitude (east positive) of geomagnetic pole
   endelse

                                ;convert input values from degrees to radians
   lat_m=(90-lat_mag)*!dtor         ; convert to co-latitude
   lon_m=lon_mag*!dtor
   
                                ;convert to geocentric coords
   stm = sin(lat_m)
   ctm = cos(lat_m) 
   ctc = cos(lat_p) * ctm - sin(lat_p) * stm * cos(lon_m)
;  ctc = min(ctc, 1.)
;  ctc = max(ctc, -1.)
   lat=acos(ctc)
   lon=atan(sin(lat_p)*stm*sin(lon_m),ctm-cos(lat_p)*ctc)

                                ;convert back from radians to degrees
   lon=(lon + lon_p)/!dtor
   lat=90-lat/!dtor     ; convert from co-latitude
   
end
