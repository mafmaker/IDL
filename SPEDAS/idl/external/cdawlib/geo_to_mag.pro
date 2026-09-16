
;-----------------------------------------------------------------------------

pro geo_to_apex, geoglat, geoglon, apexlat, apexlon, interpolate=interp

; Transform geographic coordinates to apex magnetic coordinates.
; This requires a data file (supplied by Art Richmond) which contains
; the apex coordinates for all geographic coordinates on a 1x1 degree
; grid.  The routine works for all latitudes and longitudes, and the
; data file is valid only for the epoch 1997.

;    COMMON USER, con_path, apex_path, color_table_ndx, grid_color, con_color $
;               , glat_del, glon_del

; keep the data in a common block, i.e. read the file only once
common geo_to_apex_data, data

if n_elements(data) le 0 then begin
   file = '~/mlatlon.1997a.xdr'  ;!!
   alon = fltarr(361,181)
   alat = fltarr(361,181)
   openr, unit, file, /get_lun, /xdr
   readu, unit, alat
   readu, unit, alon
   free_lun, unit
endif

; the interpolation requires longitude 0 to 360
; note: interpolation causes problems at the alon=180 border....
if keyword_set(interp) then begin
   apexlat = interpolate(alat, ((geoglon+360) mod 360), geoglat + 90)
   apexlon = interpolate(alon, ((geoglon+360) mod 360), geoglat + 90)
endif else begin
   apexlat = alat(((geoglon+360) mod 360), geoglat + 90)
   apexlon = alon(((geoglon+360) mod 360), geoglat + 90)
endelse

end

;-----------------------------------------------------------------------------

pro UNUSED_geo_to_apex, geoglat, geoglon, apexlat, apexlon

; Transform geographic coordinates to apex magnetic coordinates.
; This requires a data file (supplied by Art Richmond) which contains
; the apex coordinates for all geographic coordinates on a 1x1 degree
; grid.  The routine works for all latitudes and longitudes, and the
; data file is valid only for the epoch 1997.

; keep the data in a common block, i.e. read the file only once
common geo_to_apex_data, data

if n_elements(data) le 0 then begin
   file = '~/mlatlon.1997a.xdr'  ;!!
   alon = fltarr(361,181)
   alat = fltarr(361,181)
   openr, unit, file, /get_lun, /xdr
   readu, unit, alat
   readu, unit, alon
   free_lun, unit
endif

; the interpolation requires longitude 0 to 360
; Map the line segment (-180,180) into a circle in the
; complex plane, perform the interpolation, map back to
; the original line segment
salon = sin(!DTOR*alon)
calon = cos(!DTOR*alon)
sapexlon = interpolate(salon, ((geoglon+360) mod 360), geoglat + 90)
capexlon = interpolate(calon, ((geoglon+360) mod 360), geoglat + 90)
apexlon = atan(sapexlon,capexlon)/!DTOR
apexlat = interpolate(alat, ((geoglon+360) mod 360), geoglat + 90)

; the interpolation requires longitude 0 to 360
;apexlat = interpolate(alat, ((geoglon+360) mod 360), geoglat + 90)
;apexlon = interpolate(alon, ((geoglon+360) mod 360), geoglat + 90)
; note: interpolation causes problems at the alon=180 border....
;apexlat = alat(((geoglon+360) mod 360), geoglat + 90)
;apexlon = alon(((geoglon+360) mod 360), geoglat + 90)

end

;-----------------------------------------------------------------------------

PRO geo_to_mag_cen, lat, lon, lat_mag, lon_mag, pole=pole

   ; From code supplied by Dirk Lummerzheim (f.k.a. geo_2_mag)
   ; Centered dipole model, used by 'studio.pro'

   if keyword_set(pole) then begin
      lat_p = pole(0)*!dtor
      lon_p = pole(1)*!dtor
   endif else begin
      lat_p=11*!dtor            ; geographic co-latitude of north pole
      lon_p=-70*!dtor           ; geographic longitude (east positive) of pole
   endelse

                                ;convert input values from degrees to radians
   lat_g=(90-lat)*!dtor         ; convert to co-latitude
   lon_g=lon*!dtor
   
                                ;convert to magnetic coords
   lat_mag=acos( cos(lat_p)*cos(lat_g) + $
                 sin(lat_p)*sin(lat_g)*cos(lon_g-lon_p) )
   lon_mag=asin( sin(lat_g)*sin(lon_g-lon_p)/ $
                 sin(lat_mag) )
   
                                ;check for bad values of lon
   i=where(finite(lon_mag) lt 1, ii)
   if ii gt 0 then lon_mag(i)=0
   
                                ;convert back from radians to degrees
   lon_mag=lon_mag/!dtor
   lat_mag=90-lat_mag/!dtor     ; convert from co-latitude
   
                                ;??
   lm=atan( tan(lat_p), cos(lon_g-lon_p) )
   i=where(lat_g gt lm, ii)
   if ii gt 0 then lon_mag(i)=180-lon_mag(i)
   
                                ;??
   lon_mag=360-((lon_mag + 180) mod 360)
   
                                ;shift into range -180 to +180
                                ;ndx=WHERE(lon_mag GT 180)
                                ;lon_mag(ndx) = lon_mag(ndx)-360.
end

;-----------------------------------------------------------------------------

pro geo_to_mag_ecc, geoglat, geoglon, mlat, mlon, epoch=epoch

; Eccentric dipole model

  glat = geoglat ; need these temps??
  glon = geoglon

  msz = size(glat)
  xdim = msz[1]
  ydim = msz[2]
  mlat = fltarr(xdim, ydim)
  mlon = fltarr(xdim, ydim)
  galt = 120.0+6378.16  ; UVI and VIS presumed emission height

  cdf_epoch, epoch, yr, mon, day, hour, min, sec, msec, /breakdown

  doy = fix(get_doy(day, mon, yr))
; ical, yr, doy, mon, day, /idoy
  doy = fix(doy)

  sod = 3600.*hour + 60.*min + sec + msec/1000.

  for li = 0, xdim-1 do begin
    for lj = 0, ydim-1 do begin
      if glat[li,lj] lt 90.1  and  glat[li,lj] gt -90.1  and $
        glon[li,lj] lt 180.1  and  glon[li,lj] gt -180.1 then begin 
         dum2 = float(glat(li,lj)) 
         dum3 = float(glon(li,lj)) 
         opos = eccmlt(yr, doy, sod, galt, dum2, dum3)
      endif else begin
         opos = [99999.0, 99999.0, 99999.0]
      endelse

      mlat[li,lj] = opos[1]
      mlon[li,lj] = opos[2] * 15.0
;     if mlat[li,lj] lt 40. then idat[li,lj] = 0  ??
    endfor
  endfor

end

;-----------------------------------------------------------------------------

pro geo_to_mag, glat, glon, mlat, mlon, $
  interpolate=interp, epoch=epoch, method=method

; INPUTS
;    glat         geographic latitude (2D array)
;    glon         geographic longitude (2D array, same dimensions)
;    interpolate  whether to interpolate (boolean)
;    epoch        CDF epoch of data (real)
;    method       conversion method to use (small integer code)

; OUTPUTS
;    mlat      magnetic latitude (2D array, same dims as glat & glon)
;    mlon      magnetic longitude (2D array, same dims again)

case method of
  1: geo_to_apex, glat, glon, mlat, mlon, interpolate=interp
  2: geo_to_mag_cen, glat, glon, mlat, mlon
  else: geo_to_mag_ecc, glat, glon, mlat, mlon, epoch=epoch
endcase

end

;-----------------------------------------------------------------------------
