;+------------------------------------------------------------------------
; NAME: PLOT_WIND_MAP
; PURPOSE: To plot the map image data given in the input parameter astruct.
;          Can plot as "thumbnails" or single frames.
; CALLING SEQUENCE:
;       out = plot_map_images(astruct,vname) 
; INPUTS:
;       astruct = structure returned by the read_mycdf procedure.
;       vname   = name of the variable in the structure to plot
;
; KEYWORD PARAMETERS:
;       THUMBSIZE = size (pixels) of thumbnails
;       FRAME     = individual frame to plot
;       XSIZE     = x size of plotting window, single frame or thumbnails: 512 is default  
;   	YSIZE	  = for thumbnails:  calculated based on the number of images to plot.
;   	    	    for single frames: 512 is default
;       GIF       = name of gif file to send output to
;       REPORT    = name of report file to send output to
;       TSTART    = time of frame to begin mapping, default = first frame
;       TSTOP     = time of frame to stop mapping, default = last frame
;       CDAWEB    = being run in cdaweb context, nothing happens. yet.
;       DEBUG    = if set, turns on additional debug output.
;
; OUTPUTS:
;       out = status flag, 0=0k, -1 = problem occured.
; AUTHOR:
;       Rita Johnson 12/2004. Based on plot_map_images.pro
; MODIFICATION HISTORY:
;      
;-------------------------------------------------------------------------
FUNCTION plot_wind_map, astruct, vname, $
                      THUMBSIZE=THUMBSIZE, FRAME=FRAME, $
                      XSIZE=XSIZE, YSIZE=YSIZE,$
		      GIF=GIF, ps=ps, REPORT=REPORT,$
                      TSTART=TSTART,TSTOP=TSTOP,MYSCALE=MYSCALE,$ 
		      XY_STEP=XY_STEP, $
                      CDAWEB=CDAWEB,DEBUG=DEBUG

;print,'In plot_wind_map'

; Determine the field number associated with the variable 'vname'
w = where(tag_names(astruct) eq strupcase(vname))
if (w[0] eq -1) then begin
   print,'ERROR=No variable with the name:',vname,' in param 1!' & return,-1
endif else vnum = w[0]

if keyword_set(REPORT) then reportflag=1 else reportflag=0

; Verify the type of the first parameter and retrieve the data
a = size(astruct.(vnum))
if (a(n_elements(a)-2) ne 8) then begin
   print,'ERROR= 1st parameter to plot_wind_map not a structure' & return,-1
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

; Retrieve more data (latpass, lonpass)
;lat = tagindex('COMPONENT_2',tag_names(astruct.(vnum)))
;if (lat(0) ne -1) then lat=where(tag_names(astruct) eq strupcase(astruct.(vnum).component_2))
;lat=lat[0]
;;print,lat,tag_names(astruct),astruct.(vnum).component_2
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

; The DISPLAY_TYPE attribute may contain the THUMBSIZE  RTB
; The THUMBSIZE must be followed by the size in pixels of the images
wc=where(keywords eq 'THUMBSIZE')
if(wc[0] ne -1) then THUMBSIZE = fix(keywords(wc(0)+1))

;TJK 01/09/2004 - added map_proj into the syntax for the display_type
;Prompted by the arrival of TIMED data. Look for the value and then 
;set the appropriate projection name

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

;TJK 3/15/2004 - add the capability to switch the background from black to
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
   print, 'ERROR= GLAT variable missing from structure in map image' 
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
   print, 'ERROR= GLON variable missing from structure in map image'
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

; Determine the title for the window or gif file
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
;TJK 1/26/2006 removed for Rita the "sort" portion, it was putting our data in
;the wrong order (across data boundaries)
;indices=uniq(sedat,sort(sedat))
;indices=uniq(sedat)
; RCJ 01/27/2005  Changing this logic.
;        indices will be an array generated by hand and contain a group number: 
group=0
indices=[0]
for i=1L,n_elements(sedat)-1 do begin
   if sedat(i) ne sedat(i-1) then group=group+1
   indices=[indices,group]
endfor
;
;sedatpass=strarr(n_elements(edatpass))
;for i=0L,n_elements(sedatpass)-1 do sedatpass(i)=strmid(decode_cdfepoch(edatpass(i)),8,2)
;indicespass=uniq(sedatpass,sort(sedatpass))
;n_days=n_elements(indicespass)
;n_days=n_elements(indices)
n_days=n_elements(sedat(uniq(sedat)))
if (n_days eq 1) and (not keyword_set(frame)) then FRAME=1
;
idat_orig=idat
glat_orig=glat
glon_orig=glon
;latpass_orig=latpass
;lonpass_orig=lonpass

if not keyword_set(myscale) then begin
   q=where(idat[0,*] ne astruct.(vnum).fillval)
   if q[0] eq -1 then myscale =0.0 else myscale=max(sqrt(idat[0,q]^2+idat[1,q]^2)) 
endif
;
; ******  Produce single frame; 
;
if keyword_set(FRAME) then begin ; produce plot of a single frame

   if ((FRAME ge 1)AND(FRAME le n_days)) then begin ; valid frame value
   j=frame-1
      ;q=where(sedat eq sedat(indices(j)))
      q=where(indices eq j)
      idat = idat_orig(*,q) ; grab the frame
      glat = glat_orig(q) ; grab the frame
      glon = glon_orig(q) ; grab the frame
      ;
      ;q=where(sedatpass eq sedatpass(indicespass(j)))
      ;latpass=latpass_orig[*,q]
      ;lonpass=lonpass_orig[*,q]
      ;
      ; Begin changes 12/11 RTB
      ; determine validmin and validmax values
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
         print, 'Image valid min and max: ',zvmin, ' ',zvmax 
         wmin = min(idat,MAX=wmax)
         print, 'Actual min and max of data',wmin,' ', wmax
      endif

     ; scale to maximize color spread
      idmax=max(idat) 
      idmin=min(idat) ; RTB 10/96
      if (idmax eq astruct.(vnum).fillval) and $
         (idmin eq astruct.(vnum).fillval) then begin
	 print,'ERROR= All values fillval: ',astruct.(vnum).fillval 
	 return,-1
      endif
      if keyword_set(DEBUG) then begin
         print, '!d.n_colors = ',!d.n_colors
         print, 'min and max after filtering = ',idmin, ' ', idmax
      endif

      if keyword_set(GIF) then begin
         ; RTB 9/96 Retrieve the Data set name from the Logical source or
         ;          the Logical file id
         atags=tag_names(astruct.(vnum))
         b = tagindex('LOGICAL_SOURCE',atags)
         b1 = tagindex('LOGICAL_FILE_ID',atags)
         b2 = tagindex('Logical_file_id',atags)
         if (b(0) ne -1) then psrce = strupcase(astruct.(vnum).LOGICAL_SOURCE)
         if (b1(0) ne -1) then $
            psrce = strupcase(strmid(astruct.(vnum).LOGICAL_FILE_ID,0,9))
         if (b2(0) ne -1) then $
            psrce = strupcase(strmid(astruct.(vnum).Logical_file_id,0,9))

         GIF=strmid(GIF,0,(strpos(GIF,'.gif')))+'_f000.gif'
         if(FRAME lt 100) then gifn='0'+strtrim(string(FRAME),2) 
         if(FRAME lt 10) then gifn='00'+strtrim(string(FRAME),2) 
         if(FRAME ge 100) then gifn=strtrim(string(FRAME),2)
         GIF=strmid(GIF,0,(strpos(GIF,'.gif')-3))+gifn+'.gif'
 
         deviceopen,6,fileOutput=GIF,sizeWindow=[xs,ys+30]
 	 if(white_background) then begin
	   mapcolor = foreground
	   erase ; erases background and makes it white 
	 endif

         ;print,'I_GIF=',GIF 
	 split=strsplit(gif,'/',/extract)
	 outdir='/'
	 for k=0L,n_elements(split)-2 do outdir=outdir+split[k]+'/'
	 print, 'GIF_OUTDIR=',outdir
	 print, 'LONG_GIF=',split[k]
         if (reportflag eq 1) then begin
            ;printf,1,'I_GIF=',GIF & close,1
            printf,1,'LONG_GIF=',outdir+split[k] & close,1
         endif
      endif	 
      if keyword_set(PS) then begin
         atags=tag_names(astruct.(vnum))
         b = tagindex('LOGICAL_SOURCE',atags)
         b1 = tagindex('LOGICAL_FILE_ID',atags)
         b2 = tagindex('Logical_file_id',atags)
         if (b(0) ne -1) then psrce = strupcase(astruct.(vnum).LOGICAL_SOURCE)
         if (b1(0) ne -1) then $
            psrce = strupcase(strmid(astruct.(vnum).LOGICAL_FILE_ID,0,9))
         if (b2(0) ne -1) then $
            psrce = strupcase(strmid(astruct.(vnum).Logical_file_id,0,9))

         ;This part creates the unique name for the individual images.
         ; If we took the input ps name we would override the thumbnail image.
         out_PS=strmid(PS,0,(strpos(PS,'.eps')))+'_f000.eps'
	 help,ps,out_ps
         if(FRAME lt 100) then psn='0'+strtrim(string(FRAME),2) 
         if(FRAME lt 10) then psn='00'+strtrim(string(FRAME),2) 
         if(FRAME ge 100) then psn=strtrim(string(FRAME),2)
         out_PS=strmid(out_PS,0,(strpos(out_PS,'.eps')-3))+psn+'.eps'
         deviceopen,1,fileOutput=out_ps,/portrait,sizeWindow=[xs,ys]
         if(reportflag eq 1) then printf,1,'PS=',out_ps
         print,'PS=',out_ps	 
      endif 
      if not(keyword_set(GIF) or keyword_set(ps)) then begin ; open the xwindow
         window,/FREE,XSIZE=xs,YSIZE=ys+30,TITLE=window_title
      endif
      ;endif else begin ; open the xwindow
      ;   window,/FREE,XSIZE=xs,YSIZE=ys+30,TITLE=window_title
      ;endelse

      xmargin=!x.margin
      
      ; have glat and glon.
      ; get zone and meri from idat:
      zone=transpose(idat[0,*])
      meri=transpose(idat[1,*])
      ;
      case map_proj of 
	 ; Option 6 not being used yet. 
         6: begin
            wc=where(keywords eq 'NORTH')
	    if wc[0] ne -1 then begin
	       map_set,/azimuthal,90.,180.,/continents,/isotropic,$
	          limit=[0,-180,90,180],color=200,/noborder
            endif
            wc=where(keywords eq 'SOUTH')
	    if wc[0] ne -1 then begin
	       map_set,/azimuthal,-90.,180.,/continents,/isotropic,$
	          limit=[-90,-180,0,180],color=200,/noborder
            endif
    	    end
         8: begin
	    map_set,/cylindrical,/continents,color=0,$
	         /isotropic;,/noborder,color=200
            map_grid,/label,latlab=-180.,lonlab=-90,color=0,$
                 ;latdel=20, londel=20, color=50
                 latdel=30, londel=45
	    end
      	 14: begin
	     map_set,/mercator,/continents,color=0,/isotropic,$
	         central_azimuth=90.,/noborder; color=200
    	     lats=[-80,-60,-40,-20,0,20,40,60,80]
	     latnames=['-80','-60','-40','','0','20','40','60','80'] 
             map_grid,/label,latlab=-180.,lonlab=-20,color=0,$
                 ;latdel=20, londel=20, color=50
                 ;latdel=20, londel=20, $
                 londel=20, $
		 lats=lats,latnames=latnames
	     end
         else: begin
	        print,' Do not recognize map projection. In plot_wind_map.'
	        return,-1
	     end
      endcase
	 
      map_proj_info,/current,name=idl_projection
      projection=proj_names(map_proj+1)
      ;if keyword_set(DEBUG) then print, 'Requested ',projection;proj_names(map_proj)
      
      ; cdaweb_velovect will overplot the wind plot on the map
      cdaweb_velovect,zone,meri,glon,glat,$
        ;latpass=latpass,lonpass=lonpass,$
        color=230, projection=idl_projection, error=error,$
	missing=astruct.(vnum).fillval,$
	;length=15, /normal, xy_step=xy_step, $ 
	; RCJ 03/21/2006  Changed from normal to device
	length=10000, /device, xy_step=xy_step, $ 
	myscale=myscale,myunit='m/s'

      if (error eq -1) then return,error
	 
      xyouts,.06,.06,/normal,astruct.(vnum).lablaxis,color=foreground

      project_subtitle,astruct.(vnum),window_title,/IMAGE,$
         ;TIMETAG=[edatpass(0),edatpass(n_elements(edatpass)-1)], TCOLOR=foreground
         ;TIMETAG=edat(indices(j)), TCOLOR=foreground
         TIMETAG=edat(q(0)), TCOLOR=foreground
	 
      ;xyouts, 0.02, 0.1, projection ,color=foreground,/normal

      if keyword_set(GIF) or keyword_set(ps) then deviceclose
   endif ; valid frame value

endif else begin

; ******  Produce thumbnail plots; 
   ;
   ;if(n_elements(THUMBSIZE) gt 0) then tsize = THUMBSIZE else tsize = 166
   if(n_elements(THUMBSIZE) gt 0) then begin
      case map_proj of
      8:begin
         x_tsize = THUMBSIZE
         y_tsize = THUMBSIZE-70 
         end
      14:begin
         x_tsize = THUMBSIZE
         y_tsize = THUMBSIZE-30 
         end
      else:begin
         x_tsize = THUMBSIZE
         y_tsize = THUMBSIZE-70
         end
      endcase   	  
   endif else begin
      x_tsize=150
      y_tsize=150
   endelse
   
   nimages=n_days
   
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
   else begin
      no_data_avail = 0
   endelse

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
         print, 'Image valid min and max: ',zvmin, ' ',zvmax 
         wmin = min(idat,MAX=wmax)
         print, 'Actual min and max of data',wmin,' ', wmax
      endif

      ; calculate number of columns and rows of images
      ;ncols = xs / x_tsize & nrows = (nimages / ncols) + 1
      ncols = round(xs/x_tsize)  
      if ((nimages mod ncols) eq 0) then nrows=nimages/ncols $
         else nrows=(nimages/ncols) + 1
      label_space = 0 ; TJK added constant for label spacing
      boxsize = y_tsize+label_space;TJK added for allowing time labels for each image.
      ys = (nrows*boxsize) +50

      if keyword_set(GIF) then begin
         deviceopen,6,fileOutput=GIF,sizeWindow=[xs,ys];+30]
 	 if(white_background) then begin
	   mapcolor = foreground
	   erase ; erases background and makes it white 
	 endif
         ;if (no_data_avail eq 0) then begin
            if(reportflag eq 1) then printf,1,'IMAGE=',GIF
            print,'IMAGE=',GIF
         ;endif else begin
            ;if(reportflag eq 1) then printf,1,'I_GIF=',GIF
            ;print,'I_GIF=',GIF
         ;endelse
      endif
      if keyword_set(PS) then begin
         deviceopen,1,fileOutput=ps,/portrait,sizeWindow=[xs,ys]
         ;if(reportflag eq 1) then printf,1,'I_PS=',out_ps
         if(reportflag eq 1) then printf,1,'PS=',ps
         ;print,'I_PS=',ps
         print,'PS=',ps
      endif	 
      if (not keyword_set(GIF) and not keyword_set(ps)) then begin
          window,/FREE,XSIZE=xs,YSIZE=ys,TITLE=window_title
      endif
      ;endif else begin ; open the xwindow
      ;   window,/FREE,XSIZE=xs,YSIZE=ys,TITLE=window_title
      ;endelse
      xmargin=!x.margin

      ; generate the thumbnail plots
      irow=0
      icol=0
      for j=0L,nimages-1 do begin
         if(icol eq ncols) then begin
            icol=0 
            irow=irow+1
         endif
         ;xpos=icol*tsize
         ;ypos=ys-(irow*tsize);+30)
         ;if (irow gt 0) then $
	    ;ypos = ypos-(label_space*irow) ;TJK modify position for labels

         ; Scale images  RTB 3/98
         xthb=x_tsize
         ythb=y_tsize+label_space
         xsp=float(xthb)/float(xs+80)  ; size of x frame in normalized units
         ysp=float(ythb)/float(ys+30)  ; size of y frame in normalized units
         yi= 1.0 - 10.0/ys             ; initial y point in normalized units
         x0i=0.0095                    ; initial x point in normalized units
         y0i=yi-ysp         ;y0i=0.65
         x1i=0.0095+xsp             ;x1i=.10
         y1i=yi
         ; Set new positions for each column and row
	 ;print,'xsp = ',xsp,tsize,label_space
         x0=x0i+icol*xsp+.01 ; 0.01 to separate the graphs a bit   
         y0=y0i-irow*ysp   
         x1=x1i+icol*xsp  
         y1=y1i-irow*ysp   
         position=[x0,y0,x1,y1]
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
	   ; Option 6 not being used yet. 
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
	      position=position,/noerase; color=200
	      ;tlat=-90 ; tlat: title lat. This is to date the map 
	      ;tlon=-150 ; tlon: title lon
	      end
      	   14: begin
	       map_set,/mercator,/continents,color=0,/isotropic, $
	       central_azimuth=90.,position=position,/noerase; color=200
	       ;tlat=5
	       ;tlon=-100
	       end  
           else: begin
	        print,' Do not recognize map projection. In plot_wind_map.'
	        return,-1
	       end
           endcase
         
         map_proj_info,/current,name=idl_projection
	 projection=proj_names(map_proj+1)
         ;if keyword_set(DEBUG) then print, 'Requested ',projection;proj_names(map_proj)

         ; cdaweb_velovect will overplot the wind plot on the map
         cdaweb_velovect,zone,meri,glon,glat,$
	    ;latpass=latpass,lonpass=lonpass,color=0,$
            color=230, projection=idl_projection, position=position, $
	    missing=astruct.(vnum).fillval, error=error, $
	    ;length=2, /normal, /clip, xy_step=xy_step, $ 
	    ; RCJ 03/21/2006 Changed from normal to device
	    length=2500, /device, /clip, xy_step=xy_step, $ 
	    myscale=myscale,myunit='m/s',/nolabels
       
         if (error eq -1) then return,error
	 
         ;xyouts,tlon,tlat, $
            ;strmid(decode_cdfepoch(edatpass(indicespass(j))),0,10)
            ;strmid(decode_cdfepoch(edat(indices(j))),0,10)
         xyouts,x0,y0, $
            ;strmid(decode_cdfepoch(edat(indices(j))),0,10),/normal
            strmid(decode_cdfepoch(edat(q(0))),0,10),/normal
      
         !x.margin=xmargin
         icol=icol+1
      endfor
      
      xyouts,.06,.06,/normal,astruct.(vnum).lablaxis,color=foreground

      project_subtitle,astruct.(vnum),window_title,/IMAGE,$
      ;TIMETAG=[edatpass(0),edatpass(indicespass(j-1))], TCOLOR=foreground
      ;TIMETAG=[edat(0),edat(indices(j-1))], TCOLOR=foreground
      TIMETAG=[edat(0),edat(q(0))], TCOLOR=foreground

      ;xyouts, 0.02, 0.1, projection ,color=foreground,/normal
      ;xyouts, 0.02, y0-y0*.2, projection ,color=foreground,/normal

      ; done with the image
      ; RCJ  If we are at this point in the code that's because no_data_avail *is* =0
      ;if ((reportflag eq 1)AND(no_data_avail eq 0)) then begin
      if (reportflag eq 1) then begin
         PRINTF,1,'VARNAME=',astruct.(vnum).varname 
         PRINTF,1,'NUMFRAMES=',nimages
         PRINTF,1,'NUMROWS=',nrows & PRINTF,1,'NUMCOLS=',ncols
         PRINT,1,'THUMB_HEIGHT=',y_tsize+label_space
         PRINT,1,'THUMB_WIDTH=',x_tsize
         PRINTF,1,'START_REC=',start_frame
         PRINTF,1,'WIND_MAP_IMAGE=1'
         PRINTF,1,'MYSCALE=',myscale
         PRINTF,1,'XY_STEP=',xy_step
      endif
      ; RCJ  If we are at this point in the code that's because no_data_avail *is* =0
      ;if (no_data_avail eq 0) then begin
         PRINT,'VARNAME=',astruct.(vnum).varname
         PRINT,'NUMFRAMES=',nimages
         PRINT,'NUMROWS=',nrows & PRINT,'NUMCOLS=',ncols
         PRINT,'THUMB_HEIGHT=',y_tsize+label_space
         PRINT,'THUMB_WIDTH=',x_tsize
         PRINT,'START_REC=',start_frame
         PRINT,'WIND_MAP_IMAGE=1'
         PRINT,'MYSCALE=',myscale
         PRINT,'XY_STEP=',xy_step
      ;endif
      
      ;if ((keyword_set(CDAWEB))AND(no_data_avail eq 0)) then begin
      if (keyword_set(CDAWEB)) then begin
         if keyword_set(gif) then fname = GIF + '.sav' 
         if keyword_set(ps) then fname = ps + '.sav' 
	 save_mystruct,astruct,fname
      endif

      if keyword_set(GIF) or keyword_set(ps) then deviceclose
   
   endif else begin ; no_data_avail=0
      ; no data available - write message to gif file and exit
      print,'STATUS=No data in specified time period.'
      if keyword_set(GIF) then begin
         xyouts,xs/2,ys/2,/device,alignment=0.5,color=foreground,$
            'NO DATA IN SPECIFIED TIME PERIOD'
         deviceclose
      endif else begin
         xyouts,xs/2,ys/2,/device,alignment=0.5,'NO DATA IN SPECIFIED TIME PERIOD'
      endelse
   endelse
endelse
; blank image (Try to clear)
if keyword_set(GIF) or keyword_set(ps) then device,/close

return,0
end

