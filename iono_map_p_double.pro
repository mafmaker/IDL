pro iono_map_p_double, date, time

mag_flag = 1
year = strmid(date, 0, 4)
;hour = '01'

; make hour an integer 
hour =  fix(strmid(date, 7, 2))
doy = strmid(date, 4, 3)
;minute = '18'
minute = '00'
stretcher = 120

xwin_flag= 0			;do things in x or in zbuffer and mpeg
ps_flag = 1

z_flag =  0
if xwin_flag lt 1 and ps_flag lt 1 then z_flag = 1

max_cts=25000.

gif_writer = 0
write_gifs_for_xanim_flag = 0   ;movie_frame_1.gif vs movie_frame_0001.gif
png_writer = 0
avg_flag=1
fix_flag = 0  ;fixes plot geographically, (otherwise in local time)

loadct, 1
stretch,0,stretcher


spawn_var='ls *'+strcompress(year+doy+'*.map')


if avg_flag gt 0 then spawn_var=spawn_var + '_avg'

spawn, spawn_var, filelist

counter = n_elements(filelist)







for i = 0, (counter-1) do begin
  
current_hour = strmid(filelist(i), 10, 2)
set_plot, 'ps'
  device, filename = 'iono_map'+strcompress(year, /rem)+strcompress(doy, /rem)+strcompress(current_hour, /rem)+$
  strcompress(minute,/rem)+'.ps', /color, /helvetica, /inches,/landscape, ysize = 4, xsize = 10, yoffset =10.5 $
, xoffset = 1.5, bits = 8
  

!p.position = [0, 0, 1, 1]

  black = bytarr(2, 2)
  real_tv, black, /nobytscl
  old_font = !p.font
  !p.font = 0

!p.position = [.01, .01, .385, .99]

  restore,filelist(i)
;  map_b=bytscl(mapim,min=0,max=max_cts) & print,max(mapim),'Max DC'

  maxcts = 6
  map_b=bytscl(mapim,min=0,max=maxcts, top = 254)

  filename = (filelist(i))
   bla=filename

 if strpos(bla,'/') ne -1 then begin
   name_path_extract,bla,a,b
   bla=a
 endif

 hh=float(strmid(bla,10,2))
 mm=float(strmid(bla,12,2))

 ut=hh + mm/60.
 



  local_time = -3
  slocal_time = 24 + local_time
  if slocal_time gt 24 then slocal_time = slocal_time - 24
  slocal_time = strcompress(slocal_time, /rem) + ':00'
  lon_3= -1 * ut * 15. + local_time * 15 ;for constant local time for any img
  if lon_3 lt 360 then lon_3 = lon_3 + 360.

  if fix_flag gt 0 then lon_3=-10

  maxlon=360. & minlon=0.
;  maxlat=180. & minlat=0.

  map_set,0,lon_3,0,/ortho,/noborder, /noerase             ;use advance 

  newpd=map_image(map_b,startx,starty,xsiz,ysiz,compress=1,$
        latmin=minlat-90.,latmax=maxlat-90.,lonmin=minlon,lonmax=maxlon,$
        /whole_map,scale=0.03, missing = 0)        ;0.84 gives > 300 dpi!!!


if mag_flag gt 0 then begin
   get_lun,unit
   alon = fltarr(361,181)
   alat = fltarr(361,181)
   apexfile='$FUVIEW_HOME/support/mlatlon.1997a.xdr'
   openr, unit, apexfile, /get_lun, /xdr
   readu, unit, alat
   readu, unit, alon
   close, /all
   free_lun, unit
   alat = shift(alat, 180, 0)
   alon = shift(alon, 180, 0)
   alat = congrid(alat, 3600, 1800, /interp)
   alon = congrid(alon, 3600, 1800, /interp)
   magmap = map_image(alat, startxmag, startymag, xsizmag, ysizmag, $
                      compress = 1, /whole_map)
   maglonmap = map_image(alon, startxmag, startymag, xsizmag, ysizmag, $
                      compress = 1, /whole_map)

endif


if ps_flag lt 1 then erase

  tv,newpd,startx,starty,xsize=xsiz,ysize=ysiz

if mag_flag gt 0 then begin
;  tv,magmap,startxmag,startymag,xsize=xsizmag,ysize=ysizmag
  c_levels1 = [-35, -25, -15, -5, 5, 15,  25,  35]
  c_levels2 = [-30, -20, -10, 0, 10, 20, 30]
  c_labels2 = strcompress(c_levels2, /rem)

;  map_grid,latdel=30,londel=30,color=253,thick=1.
  map_continents, color = 253,mlinethick=2.5
  map_continents, color = 100, /countries,mlinethick=2
;  contour, magmap, xstyle = 5, ystyle = 5, /noerase, levels = c_levels1, $
;    c_linestyle = 2
  contour, magmap, xstyle = 5, ystyle = 5, /noerase, levels = c_levels2, $
    c_linestyle = 2, c_labels = c_labels2, c_charsize = 1.2,color=255

  contour, magmap, xstyle = 5, ystyle = 5, /noerase, levels = [0], $
    c_linestyle = 0, c_labels = c_labels2, charsize = 1.2, c_thick = [2],$
           color=255

  contour, maglonmap, xstyle = 5, ystyle = 5, /noerase, $
    c_linestyle = 2, levels = [-50, -25, 0, 25, 50],color=255
  

endif else begin
  map_grid,latdel=10,londel=10,color=253,glinethick=1.9
  map_continents, color = 253,mlinethick=2.5
  map_continents, color = 253, /countries,mlinethick=2.
endelse
        

;        if orbit_plot gt 0 then plots, [new_lons(bla(orbit_plot-1)), new_lons(bla(orbit_plot-1))],  [new_lats(bla(orbit_plot-1)), new_lats(bla(orbit_plot-1))],  psym = 8
;---END PLOT ROCSAT ORBIT

        time_integration = n_elements(avgmapname) * 2
        s_time_int = strcompress(time_integration, /rem)

        splitter = strpos(lab, '(')
;        newlab = strcompress(strmid(lab,0,23)) + '!C!C' +'TIME '+ strmid(filelist(i),10,2)+ ':'+ strmid(filelist(i), 12, 2)+' UT'
        annotate = 'IMAGE/FUV SI-13' + '!C' + '135.6 OI emissions' + '!C'+$
          s_time_int + ' minute integration' + '!C' + $
          'SSL, UC Berkeley' + '!C' + 'View from ' + slocal_time + ' LT'
   
;      xyouts, .35, .94, newlab, /norm, charsize = 1.7-.45*ps_flag-.3*z_flag, color = 254
        xyouts, .35, .14, annotate, /norm, charsize = 1.6 - .6*ps_flag-.5*z_flag, color = 254
        
;	cbar,[.89,.3,.91,.7],-.6,max_cts,'Response Units',1.1,numticks=5
;        loadct, 1
;	cbar,[.91,.3,.93,.7],0,maxcts/15.,'Brightness (kRayleigh)',1.1-.3*ps_flag -.05*z_flag,numticks=5, color = 253
        cbar, [.46, .3, .48, .7], 0,maxcts/15.,'Brightness (kRayleigh)',1.1-.3*ps_flag -.05*z_flag,numticks=5, color = 253

 


!p.position = [.51, .01, .885, .99]

  local_time = -21
  slocal_time = 24 + local_time
  if slocal_time gt 24 then slocal_time = slocal_time - 24
  slocal_time = strcompress(slocal_time, /rem) + ':00'
  lon_3= -1 * ut * 15. + local_time * 15 ;for constant local time for any img
  if lon_3 lt 360 then lon_3 = lon_3 + 360.
   
  if fix_flag gt 0 then lon_3=-10

  maxlon=360. & minlon=0.
;  maxlat=180. & minlat=0.

  map_set,0,lon_3,0,/ortho,/noborder, /noerase             ;use advance 

;boost brightness by factor of 2 on dawn side
  maxcts = 6
  mapim = 2*mapim
  map_b=bytscl(mapim,min=0,max=maxcts, top = 254)


  newpd=map_image(map_b,startx,starty,xsiz,ysiz,compress=1,$
        latmin=minlat-90.,latmax=maxlat-90.,lonmin=minlon,lonmax=maxlon,$
        /whole_map,scale=0.03, missing = 0)        ;0.84 gives > 300 dpi!!!


if mag_flag gt 0 then begin
   get_lun,unit
   alon = fltarr(361,181)
   alat = fltarr(361,181)
   apexfile='$FUVIEW_HOME/support/mlatlon.1997a.xdr'
   openr, unit, apexfile, /get_lun, /xdr
   readu, unit, alat
   readu, unit, alon
   close, /all
   free_lun, unit
   alat = shift(alat, 180, 0)
   alon = shift(alon, 180, 0)
   alat = congrid(alat, 3600, 1800, /interp)
   alon = congrid(alon, 3600, 1800, /interp)
   magmap = map_image(alat, startxmag, startymag, xsizmag, ysizmag, $
                      compress = 1, /whole_map)
   maglonmap = map_image(alon, startxmag, startymag, xsizmag, ysizmag, $
                      compress = 1, /whole_map)

endif


if ps_flag lt 1 then erase

  tv,newpd,startx,starty,xsize=xsiz,ysize=ysiz

if mag_flag gt 0 then begin
;  tv,magmap,startxmag,startymag,xsize=xsizmag,ysize=ysizmag
  c_levels1 = [-35, -25, -15, -5, 5, 15,  25,  35]
  c_levels2 = [-30, -20, -10, 0, 10, 20, 30]
  c_labels2 = strcompress(c_levels2, /rem)

;  map_grid,latdel=30,londel=30,color=253,thick=1.
  map_continents, color = 253,mlinethick=2.5
  map_continents, color = 100, /countries,mlinethick=2.
;  contour, magmap, xstyle = 5, ystyle = 5, /noerase, levels = c_levels1, $
;    c_linestyle = 2
  contour, magmap, xstyle = 5, ystyle = 5, /noerase, levels = c_levels2, $
    c_linestyle = 2, c_labels = c_labels2, c_charsize = 1.2,color=255

  contour, magmap, xstyle = 5, ystyle = 5, /noerase, levels = [0], $
    c_linestyle = 0, c_labels = c_labels2, charsize = 1.2, c_thick = [2],$
           color=255

  contour, maglonmap, xstyle = 5, ystyle = 5, /noerase, $
    c_linestyle = 2, levels = [-50, -25, 0, 25, 50],color=255
  

endif else begin
  map_grid,latdel=10,londel=10,color=253,glinethick=1.9
  map_continents, color = 253,mlinethick=2.5
  map_continents, color = 253, /countries,mlinethick=2.
endelse
        
    annotate = 'IMAGE/FUV SI-13' + '!C' + '135.6 OI emissions' + '!C'+$
          s_time_int + ' minute integration' + '!C' + $
          'SSL, UC Berkeley' + '!C' + 'View from ' + slocal_time + ' LT'

     xyouts, .843, .14, annotate, /norm, charsize = 1.6 - .6*ps_flag-.5*z_flag, color = 254


;boost conversion factor by 2 to compensate for brightening
  cbar, [.96, .3, .98, .7], 0,maxcts/(15.*2),'Brightness (kRayleigh)',1.1-.3*ps_flag -.05*z_flag,numticks=5, color = 253

       newlab = strcompress(strmid(lab,0,23)) + '!C!C' +'TIME '+ strmid(filelist(i),10,2)+ ':'+ strmid(filelist(i), 12, 2)+' UT'

            xyouts, .35, .94, newlab, /norm, charsize = 1.7-.45*ps_flag-.3*z_flag, color = 254

if ps_flag gt 0 then begin

  !p.font = old_font
  ps_close


endif


endfor
end
