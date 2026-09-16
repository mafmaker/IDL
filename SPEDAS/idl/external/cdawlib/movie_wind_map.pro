;+------------------------------------------------------------------------
; NAME: movie_wind_map
; PURPOSE: To plot a sequence of mapped images into a movie file.
; CALLING SEQUENCE:
;       out = movie_wind_map(astruct,vname)
; INPUTS:
;       astruct = structure returned by the read_mycdf procedure.
;       vname   = name of the variable in the structure to plot
;
; KEYWORD PARAMETERS:
;       XSIZE     = x size of single frame
;       YSIZE     = y size of single frame
;       LIMIT     = Limit to the number of frames
;       REPORT    = name of report file to send output to
;       TSTART    = time of frame to begin imaging, default = first frame
;       TSTOP     = time of frame to stop imaging, default = last frame
;       MGIF      = filename of animated gif output (won't do gif AND mpeg)
;       MPEG      = filename of mpeg output (won't do gif AND mpeg)
;       CDAWEB    = being run in cdaweb context
;       DEBUG    = if set, turns on additional debug output.
;
; OUTPUTS:
;       out = status flag, 0=0k, -1 = problem occured.
; AUTHOR:
;       Rita Johnson, 12/2004. Based on movie_map_images.pro
; MODIFICATION HISTORY:
;      
;-------------------------------------------------------------------------

FUNCTION movie_wind_map, astruct, vname, $
                      XSIZE=XSIZE, YSIZE=YSIZE, limit=limit,$
		      REPORT=REPORT,$
                      TSTART=TSTART,TSTOP=TSTOP,MYSCALE=MYSCALE,$
		      XY_STEP=XY_STEP, MGIF=MGIF, MPEG=MPEG,$ 
                      MOVIE_FRAME_RATE=MOVIE_FRAME_RATE, MOVIE_LOOP=MOVIE_LOOP, $
                      CDAWEB=CDAWEB,DEBUG=DEBUG

; Determine the field number associated with the variable 'vname'
w = where(tag_names(astruct) eq strupcase(vname))
if (w[0] eq -1) then begin
   print,'ERROR=No variable with the name:',vname,' in param 1!' & return,-1
endif else vnum = w[0]

if keyword_set(REPORT) then reportflag=1 else reportflag=0
if keyword_set(CDAWEB) then limit=1L
if (not keyword_set(mgif) and not keyword_set(mpeg)) then mgif='my_movie.gif'

if n_elements(movie_frame_rate) eq 0 then movie_frame_rate = 3
if n_elements(movie_loop) eq 0 then movie_loop = 1 ; default is "on"

; Verify the type of the first parameter and retrieve the data
a = size(astruct.(vnum))
if (a(n_elements(a)-2) ne 8) then begin
   print,'ERROR= 1st parameter to movie_wind_map not a structure' & return,-1
endif else begin
   a = tagindex('DAT',tag_names(astruct.(vnum)))
   if (a(0) ne -1) then idat = astruct.(vnum).DAT $
   else begin
      a = tagindex('HANDLE',tag_names(astruct.(vnum)))
      if (a(0) ne -1) then handle_value,astruct.(vnum).HANDLE,idat $
      else begin
         print,'ERROR= 1st parameter does not have DAT or HANDLE tag' & return,-1
      endelse
   endelse
endelse

; Retrieve more data (latpass, lonpass, etc as needed)
;lat = tagindex('COMPONENT_2',tag_names(astruct.(vnum)))
;if (lat(0) ne -1) then lat=where(tag_names(astruct) eq strupcase(astruct.(vnum).component_2))
;lat=lat[0]
;lat1 = tagindex('DAT',tag_names(astruct.(lat)))
;if (lat1(0) ne -1) then latpass = astruct.(lat).DAT $
;else begin
;   lat1 = tagindex('HANDLE',tag_names(astruct.(lat)))
;   if (lat1(0) ne -1) then handle_value,astruct.(lat).HANDLE,latpass $
;   else begin
;      print,'ERROR= Latpass does not have DAT or HANDLE tag' & return,-1
;   endelse
;endelse

;lon = tagindex('COMPONENT_3',tag_names(astruct.(vnum)))
;if (lon(0) ne -1) then lon=where(tag_names(astruct) eq strupcase(astruct.(vnum).component_3))
;lon=lon[0]
;lon1 = tagindex('DAT',tag_names(astruct.(lon)))
;if (lon1(0) ne -1) then lonpass = astruct.(lon).DAT $
;else begin
;   lon1 = tagindex('HANDLE',tag_names(astruct.(lon)))
;   if (lon1(0) ne -1) then handle_value,astruct.(lon).HANDLE,lonpass $
;   else begin
;      print,'ERROR= Lonpass does not have DAT or HANDLE tag' & return,-1
;   endelse
;endelse

; Get pass epochs.
;elon = tagindex('DEPEND_0',tag_names(astruct.(lon)))
;if (elon(0) ne -1) then elon=where(tag_names(astruct) eq strupcase(astruct.(lon).depend_0))
;elon=elon[0]
;elon1 = tagindex('DAT',tag_names(astruct.(elon)))
;if (elon1(0) ne -1) then edatpass = astruct.(elon).DAT $
;else begin
;   elon1 = tagindex('HANDLE',tag_names(astruct.(elon)))
;   if (elon1(0) ne -1) then handle_value,astruct.(elon).HANDLE,edatpass $
;   else begin
;      print,'ERROR= Edatpass does not have DAT or HANDLE tag' & return,-1
;   endelse
;endelse

; Find & Parse DISPLAY_TYPE FOR ancillary map image variables (lat & lon)
a = tagindex('DISPLAY_TYPE',tag_names(astruct.(vnum)))
if(a(0) ne -1) then display= astruct.(vnum).DISPLAY_TYPE $
else begin
   print, 'ERROR= No DISPLAY_TYPE attribute for variable'
endelse

; Parse DISPLAY_TYPE
ipts=parse_display_type(display)
keywords=str_sep(display,'>')  ; keyword 1 or greater 

wc=where(keywords eq 'MAP_PROJ')
if(wc[0] ne -1) then map_proj = fix(keywords(wc(0)+1)) else $
                    map_proj = 8 ;default map projection 
proj_names =["", "stereographic projection","orthographic projection","lambertconic projection",$
	     "lambertazimuthal projection", "gnomic projection", "azimuthal equidistant projection",$
	     "satellite projection", "cylindrical equidistant projection", "mercator projection", $
	     "molleweide projection",  "sinusoidal projection", "aitoff projection", "hammeraitoff projection", $
	     "albers equal area conic projection", "transverse mercator projection", $
	     "miller cylindrical projection", "robinson projection", "lambertconic ellipsoid projection", $
	     "goodes homolosine projection"]

; Based on the projection, set xs and ys. 512 is default
if keyword_set(XSIZE) then xs=XSIZE else begin
   xs=512 
   ; Overwrite xs depending on the projection:
   if (map_proj eq 8) then xs=512 
   if (map_proj eq 14) then xs=512 
endelse  
if keyword_set(YSIZE) then ys=YSIZE else begin
   ys=512 
   ; Overwrite ys depending on the projection:
   ; RCJ.  It's useless to set this for the thumbnail page, ys is
   ;       redefined based on boxsize and number of rows
   if (map_proj eq 8) then ys=350
   if (map_proj eq 14) then ys=512
endelse


tip = tagindex('PROJECT',tag_names(astruct.(vnum)))
if (tip ne -1) then project=astruct.(vnum).project else project = ' '

if (project eq 'TIMED') then white_background = 1

; switch the background from black to
;white.  Also have to switch for foreground color (one to be used for 
;labeling and axes, etc.)
if keyword_set(WHITE_BACKGROUND) then begin
   foreground = 2 
   white_background = 1
endif else begin
   foreground = !d.n_colors-1 
   white_background = 0
endelse


; Assign latitude variable 
a = tagindex(strtrim(ipts(0),2),tag_names(astruct))
if(a(0) ne -1) then begin
   a1=tagindex('DAT',tag_names(astruct.(a(0)))) 
   if(a1(0) ne -1) then glat = astruct.(a(0)).DAT $
   else begin
      a2 = tagindex('HANDLE',tag_names(astruct.(a(0))))
      if (a2(0) ne -1) then handle_value,astruct.(a(0)).HANDLE,glat $
      else begin
         print,'ERROR= 2nd parameter does not have DAT or HANDLE tag' 
         return,-1
      endelse
   endelse
endif else begin
   print, 'ERROR= GLAT variable missing from structure in movie_wind_map' 
   return, -1
endelse

; Assign longitude variable
a = tagindex(strtrim(ipts(1),2),tag_names(astruct))
if(a(0) ne -1) then begin
   a1=tagindex('DAT',tag_names(astruct.(a(0))))
   if(a1(0) ne -1) then glon = astruct.(a(0)).DAT $
   else begin
      a2 = tagindex('HANDLE',tag_names(astruct.(a(0))))
      if (a2(0) ne -1) then handle_value,astruct.(a(0)).HANDLE,glon $
      else begin
         print,'ERROR= 3rd parameter does not have DAT or HANDLE tag'
         return,-1
      endelse
   endelse
endif else begin
   print, 'ERROR= GLON variable missing from structure in movie_wind_map'
   return, -1
endelse

; Determine which variable in the structure is the 'Epoch' data and retrieve it
b = astruct.(vnum).DEPEND_0  
c = tagindex(b(0),tag_names(astruct))
d = tagindex('DAT',tag_names(astruct.(c)))
if (d(0) ne -1) then edat = astruct.(c).DAT $
else begin
   d = tagindex('HANDLE',tag_names(astruct.(c)))
   if (d(0) ne -1) then handle_value,astruct.(c).HANDLE,edat $
   else begin
      print,'ERROR= Time parameter does not have DAT or HANDLE tag' & return,-1
   endelse
endelse

; Determine title for plot:
a = tagindex('SOURCE_NAME',tag_names(astruct.(vnum)))
;if (a(0) ne -1) then b = astruct.(vnum).SOURCE_NAME else b = ''
if (a(0) ne -1) then b = astruct.(vnum).SOURCE_NAME+', ' else b = ''

a = tagindex('DESCRIPTOR',tag_names(astruct.(vnum)))
;if (a(0) ne -1) then b = b + '  ' + astruct.(vnum).DESCRIPTOR
if (a(0) ne -1) then b = b + astruct.(vnum).DESCRIPTOR+', '

a = tagindex('DATA_TYPE',tag_names(astruct.(vnum)))
if (a(0) ne -1) then begin
   type=strsplit(astruct.(vnum).DATA_TYPE,'>',/extract)
   if n_elements(type) eq 2 then b=b+type[1]+', '
   ;b = b + '  ' + astruct.(vnum).DATA_TYPE
   ;d_type = strupcase(str_sep((astruct.(vnum).DATA_TYPE),'>'))
endif

a = tagindex('FIELDNAM',tag_names(astruct.(vnum)))
;if (a(0) ne -1) then window_title=(b = b + ' ' + astruct.(vnum).FIELDNAM)
if (a(0) ne -1) then window_title=(b = b + astruct.(vnum).FIELDNAM)


sedat=strarr(n_elements(edat))
for i=0L,n_elements(sedat)-1 do sedat(i)=strmid(decode_cdfepoch(edat(i)),8,2)
;indices=uniq(sedat,sort(sedat))
; RCJ 01/30/2006   indices have to be an array generated by hand because we have to
;  separate the days in groups - if not, for long requests, the data from a given
;  month/day will be plotted together w/ the data for the next_month/same_day:
group=0
indices=[0]
for i=1L,n_elements(sedat)-1 do begin
   if sedat(i) ne sedat(i-1) then group=group+1
   indices=[indices,group]
endfor
;
;sedatpass=strarr(n_elements(edatpass))
;for i=0,n_elements(sedatpass)-1 do sedatpass(i)=strmid(decode_cdfepoch(edatpass(i)),8,2)
;indicespass=uniq(sedatpass,sort(sedatpass))
;
;n_days=n_elements(indicespass)
;n_days=n_elements(indices)
n_days=n_elements(sedat(uniq(sedat)))
;if (n_days eq 1) then FRAME=1
;
idat_orig=idat
glat_orig=glat
glon_orig=glon
;latpass_orig=latpass
;lonpass_orig=lonpass
;
if not keyword_set(myscale) then begin
   q=where(idat[0,*] ne astruct.(vnum).fillval)
   if q[0] eq -1 then myscale =0.0 else myscale=max(sqrt(idat[0,q]^2+idat[1,q]^2)) 
endif
;
nimages=n_days
;
; ******  Single frame doesn't make movie; 
;
if (nimages eq 1) then begin 
   print, 'ERROR= Single movie frame found'
   print, 'STATUS= Single movie frame; select longer time range.'
   return, -1
endif else begin

; ******  Produce movie; 
;TJK 1/26/2006 - increase limit to 200 (new rumba)

   if((nimages gt 200) and keyword_set(limit)) then begin
      print, 'ERROR= Too many movie frames '
      print, 'STATUS= Movies limited to 200 frames; select a shorter time range.'
      return, -1
   endif

   ; screen out frames which are outside time range, if any
   if NOT keyword_set(TSTART) then start_frame = 0 $
   else begin
      w = where(edat ge TSTART,wc)
      if wc eq 0 then begin
         print,'ERROR=No image frames after requested start time.' & return,-1
      endif else start_frame = w(0)
   endelse
   if NOT keyword_set(TSTOP) then stop_frame = nimages $
   else begin
      w = where(edat le TSTOP,wc)
      if wc eq 0 then begin
         print,'ERROR=No image frames before requested stop time.' & return,-1
      endif else stop_frame = w(wc-1)
   endelse
   if (start_frame gt stop_frame) then no_data_avail = 1 $
      else no_data_avail = 0


   ; Perform data filtering and color enhancement it any data exists
   if (no_data_avail eq 0) then begin
      ;
      a = tagindex('VALIDMIN',tag_names(astruct.(vnum)))
      if (a(0) ne -1) then begin & b=size(astruct.(vnum).VALIDMIN)
         if (b(0) eq 0) then zvmin = astruct.(vnum).VALIDMIN $
         else begin
            zvmin = 0 ; default for image data
            print,'WARNING=Unable to determine validmin for ',vname
         endelse
      endif
      a = tagindex('VALIDMAX',tag_names(astruct.(vnum)))
      if (a(0) ne -1) then begin & b=size(astruct.(vnum).VALIDMAX)
         if (b(0) eq 0) then zvmax = astruct.(vnum).VALIDMAX $
         else begin
            zvmax = 2000 ; guesstimate
            print,'WARNING=Unable to determine validmax for ',vname
         endelse
      endif
      if keyword_set(DEBUG) then begin
         print, 'Map valid min and max: ',zvmin, ' ',zvmax 
         wmin = min(idat,MAX=wmax)
         print, 'Actual min and max of data',wmin,' ', wmax
      endif

      if keyword_set(mpeg) then begin 
         mpegID=mpeg_open([xs,ys])
         ; option 6 is for gifs but also works for mpegs:
         deviceopen,6,fileOutput=mpeg+"junk",sizeWindow=[xs,ys]
      endif else begin
         deviceopen,6,fileOutput=mgif+"junk",sizeWindow=[xs,ys]
      endelse
   
      if(white_background) then begin
         mapcolor = foreground
	 erase ; erases background and makes it white 
      endif
      
      if keyword_set(mpeg) then begin
         if(reportflag eq 1) then printf,1,'MPEG=',mpeg
         print,'MPEG=',mpeg
      endif else begin ; if it's not mpeg then it's gif:
         if(reportflag eq 1) then printf,1,'MGIF=',mgif
         print,'MGIF=',mgif
      endelse

      ; loop thru the images and generate movie
      for j=0L,nimages-1 do begin
         if(white_background) then begin
           erase ;make the background white for each frame in the movie
         endif
         ;
         ;q=where(sedat eq sedat(indices(j)))
	 q=where(indices eq j)
         idat = idat_orig(*,q) ; grab the frame
         glat = glat_orig(q) ; grab the frame
         glon = glon_orig(q) ; grab the frame
         ;
         ;q=where(sedatpass eq sedatpass(indicespass(j)))
         ;latpass=latpass_orig[*,q]
         ;lonpass=lonpass_orig[*,q]

         zone=transpose(idat[0,*])
         meri=transpose(idat[1,*])

         case map_proj of 
	 ; 6 is not being used. yet.
         6: begin
            wc=where(keywords eq 'NORTH')
	    if wc[0] ne -1 then begin
	       map_set,/azimuthal,90.,180.,/continents,/isotropic,$
	          limit=[0,-180,90,180],color=200,/noborder
	       ;tlat=5
	       ;tlon=-100
            endif
            wc=where(keywords eq 'SOUTH')
	    if wc[0] ne -1 then begin
	       map_set,/azimuthal,-90.,180.,/continents,/isotropic,$
	          limit=[-90,-180,0,180],color=200,/noborder
	       ;tlat=-5
	       ;tlon=-100
            endif
    	    end
         8: begin
	      map_set,/cylindrical,/continents,/isotropic,color=0,$
	      /noerase; color=200
	      ;tlat=-90 ; tlat: title lat. This is to date the map 
	      ;tlon=-150 ; tlon: title lon
              map_grid,/label,latlab=-180.,lonlab=-90,color=0,$
                 ;latdel=20, londel=20, color=50
                 latdel=30, londel=45
	    end
      	 14: begin
	       map_set,/mercator,/continents,color=0,/isotropic, $
	       central_azimuth=90.,/noerase; color=200
	       ;tlat=5
	       ;tlon=-100
    	       lats=[-80,-60,-40,-20,0,20,40,60,80]
	       latnames=['-80','-60','-40','','0','20','40','60','80'] 
               map_grid,/label,latlab=-180.,lonlab=-20,color=0,$
                 ;latdel=20, londel=20, color=50
                 ;latdel=30, londel=45
		 londel=20,lats=lats,latnames=latnames
	     end  
         else: begin
	        print,' Do not recognize map projection. In movie_wind_map.'
	        return,-1
	     end
        endcase

        map_proj_info,/current,name=idl_projection
	projection=proj_names(map_proj+1)
        ;if keyword_set(DEBUG) then print, 'Requested ',projection ;proj_names(map_proj)

        ; cdaweb_velovect will overplot the wind plot on the map
        cdaweb_velovect,zone,meri,glon,glat, $
	  ;latpass=latpass,lonpass=lonpass,$
          color=230, projection=idl_projection, $
	  missing=astruct.(vnum).fillval, error=error, $
	  ;length=15, /normal, xy_step=xy_step, $ 
	  ; RCJ 03/21/2006  Changed from normal to device
	  length=3500, /device, xy_step=xy_step, $ 
	  myscale=myscale,myunit='m/s';,/nolabels
       
        if (error eq -1) then return,error
	 
        ;xyouts,tlon,tlat, $
         ;;strmid(decode_cdfepoch(edatpass(indicespass(j))),0,10)
         ;strmid(decode_cdfepoch(edat(indices(j))),0,10)
            
        xyouts,.06,.06,/normal,astruct.(vnum).lablaxis,color=foreground

        project_subtitle,astruct.(vnum),window_title,/IMAGE,$
        ;TIMETAG=[edatpass(0),edatpass(n_elements(edatpass)-1)], TCOLOR=foreground
        ;TIMETAG=edat(indices(j)), TCOLOR=foreground
        TIMETAG=edat(q[0]), TCOLOR=foreground

        ;xyouts, 0.06, 0.08, projection ,color=foreground,/normal

        image=tvrd()
        if j eq 0 then tvlct, r,g,b, /get  ; do this just once
        ; tvrd images into a array, then write to mpeg or animated
	;     gif file and save
	if keyword_set(mpeg) then begin
           ii=bytarr(3,xs,ys)
           ii(0,*,*)=r[image]
           ii(1,*,*)=g[image]
           ii(2,*,*)=b[image]
           mpeg_put, mpegID, IMAGE=ii, FRAME=j, ORDER=1
	endif else begin
           write_mgif, MGIF, image, r, g, b, delay=(100/movie_frame_rate),$
             loop=movie_loop
	   device, /close
	endelse
      endfor

      if keyword_set(mpeg) then begin
         mpeg_save, mpegID, FILENAME=mpeg
         mpeg_close, mpegID
      endif else begin 
         write_mgif, MGIF, /close
      endelse
      
      if keyword_set(mgif) or keyword_set(mpeg) then deviceclose
      
   endif else begin ; no_data_avail=0
      ; no data available 
      print,'STATUS=No data in specified time period.'
         xyouts,xs/2,ys/2,/device,alignment=0.5,color=foreground,$
            'NO DATA IN SPECIFIED TIME PERIOD'
      deviceclose	    
   endelse
endelse
if keyword_set(mgif) or keyword_set(mpeg) then device,/close
return,0
end

