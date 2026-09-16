;$author: $
;$Date: 2010-01-12 12:18:45 -0800 (Tue, 12 Jan 2010) $
;$Header: /home/cdaweb/dev/control/RCS/cdaweb_skymap.pro,v 1.2 2009/11/12 22:13:09 kovalick Exp kovalick $
;$Locker: kovalick $
;$Revision: 7092 $ 
;+------------------------------------------------------------------------
; NAME: CDAWeb_Skymap
; PURPOSE: This Skymap code was given to us by the TWINS project in
; order to properly produce mapped image plots of their TWINS images.
; 
; Modifications: TJK modified it slightly to allow a position to be
; defined, thus allowing it to be used from CDAWeb for making
; thumbnails and larger sized mapped images.  I also changed the name
; of the routine from skymap to cdaweb_skymap, so there's no confusion
; between the two.
;
; CALLING SEQUENCE: (sample call from below, making large images)
;       
;        cdaweb_skymap, image, sc_pos = sc_posv_re_eci_dat(*,(frame-1)), $
;          spin_axis=spin_axis_eci_dat(*,(frame-1)), sun_pos=sun_posv_eci_dat(*,(frame-1)), $
;          prime_meridian=prime_meridian_eci_dat(*,(frame-1)), lonmin=-88, lonmax=268,latmin=4, $
;          latmax=88, colorbar=0, grid = 1,  $
;          field=1, limb=1, sphere = 1, mag = mag, term=1, log=0, norotate=1, noerase=1,ctab=39, exobase=0

; INPUTS:
;       Required are: image, sc_pos, spin_axis, sun_pos, prime_meridian
;
; SEE DETAILS BELOW
;
;
pro cdaweb_skymap, image, $
            sc_pos = sc_pos, $
            spin_axis = spin_axis,  $
            prime_meridian=prime_meridian, $
            sun_pos = sun_pos, mag = mag, $
            sphere = sphere, $
            lonmin = lonmin, lonmax = lonmax, $
            latmin = latmin, latmax = latmax,  $
            annotation = annotation, $
            top_annotation = top_annotation, $
            min = min, max = max, $
            grid = grid,  $
            field = field, $
            limb = limb, $
            terminator = terminator,  $
            exobase = exobase, $
            colorbar = colorbar, $
            log = log,  $
            smooth = smooth, $
            norotate = norotate,   $
            xmargin = xmargin, ymargin = ymargin,  $
            title = title, subtitle = subtitle, $
            clip = clip, true = true, $
            square = square,  $
            pathlogo = pathlogo, $
            contour = contour, median = median,  $
            lee = lee, $
            closeup = closeup, xcloseup = xcloseup,  $
            top = top, noerase = noerase, $
            limit = limit, earth = earth,  $
            fullscreen = fullscreen, time = time,  $
            geogrid = geogrid, fill = fill, $
            landcolor = landcolor,  $
            seacolor = seacolor, gei = gei, $
            bartitle = bartitle,  $
            barlevels = barlevels, noimage = noimage,  $
            antiearthward = antiearthward, $
            cbarposition = cbarposition, $
            barcharsize = barcharsize, $
            barformat = barformat,wim=wim, $
            p0lat=p0lat,p0lon=p0lon, $
            rot=rot, $
            annosize=annosize, $
            line_thick=line_thick, $
            ps = ps, $
            ctab=ctab, $
            units = units, $
            sun_spot = sun_spot, $
            label_field_line = label_field_line, $
            position = position, $; TJK add position for support of CDAWeb thumbnails
            thumb=thumb ; TJK add to indicate this is for a small thumbnail plot
;+
; NAME: CDAWEB_SKYMAP.PRO
;
;
; PURPOSE: 

; Project a lat-lon matrix onto the sphere of the sky and draw the
; earth with field lines.
;
;
;
; CATEGORY:
;
;
; CALLING SEQUENCE:
; CDAWEB_SKYMAP, IMAGE
;
;
; INPUTS: IMAGE[nlon,nlat] - An image with a column corresponding to
; one latitude and row corresponding to longtitude of the map.
;
;
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
; 
; SC_POS - A three element array of the S/C postition in some
;          geocentric coordinate system.
;          
; SPIN_AXIS - Spin axis direction of the satellite in the same
;             geocentric coordinate system.
;
; PRIME_MERIDIAN - A 3 element vector that lies in the plane of the
;                    sphere pole and the zero reference angle of the
;                    sphere equator (the +x axis).  This has nothing
;                    to do with the prime meridian of the earth; it is
;                    just the most convenient description.
; 
; SUN_POS - The unit vector to the sun in the same system
;             
; MAG - Magnetic dipole direction in the same geocentric system.
;
; All vectors and positions must be expressed in the same geocentric
; coordinate system.
;
; SPHERE - Set 0 gives us the full sphere. Set to 1 gives us the
;          hemisphere lat and lon 0 deg in the center.
;
; LATMIN, LATMAX, LONMIN, LONMAX - Same as keywords to MAP_IMAGE.PRO
; 
; ANNOTATION - An array of strings containing information such as time 
;              and position, to be output together with the plot in
;              the assigned space.
;              
; MIN - The minimum number on the colorbar.
; 
; MAX - The max number of the color bar
;
; GRID - If set turns on lat-lon grid in S/C coordinates with the
;        'north pole' of the grid (+90 deg) being the spinaxis, and
;        lon being the spin angle.
;
; FIELD - Plots, dipole field lines L=4 and 8 for noon, dusk,
;         midnight, and dawn.
;
; LIMB - If set plots the Earth's limb.
;
; TERMINATOR - Turns on terminator line
;
; EXOBASE - If set plots the exobase line (dashed) at 300 km altitude.
;
; COLORBAR - If set plots a color bar.
;
; LOG - Turns on logarithmic scaling.
;
; SMOOTH - Applies a boxcar smoothing function to the mapped (output
;          of MAP_IMAGE) image. The purpose is to smooth the visible
;          image to aid the eye in interpreting the image as a 3D
;          structure and not make the eye unconciously map it to the
;          sphere. CAUTION!!: Localized features broadens. Care has to 
;          be taken when interpreting.
;
; NOROTATE - Turns off the fancy rotation that make some people
;            seasick. If set, spin axis (lat = +90 deg) always points
;            up (positive orbit normal down).
;
; XMARGIN, YMARGIN - Used in MAP_SET (Margin between map and image border)
;
; TITLE - Inserts title at top of SKYMAP Image
;
; SUBTITLE - Inserts subtitle under title at top of SKYMAP Image
;
; CLIP - All values GE than clip are set to 0.
;
; TRUE - Use TRUE Color representation
;
; SQUARE - Enable a square format window with minimum space for
;          annotation. Default is landscape. The effect of this
;          keyword is essentially to put the colorbar in the right
;          place (vertically) and annotation under the map. XMARGIN
;          and YMARGIN are used to set the position of the map.
;
; PATHLOGO - The absolut path to a GIF file containing an optional
;         pathlogo to be placed. Does not work just yet. Seems that
;         calling TVIMAGE the first time makes the position keyword
;         not work.
;
; CONTOUR -'contourimage' is the image that is smoothed and median filtered.
;          The CONTOUR procedure puts NLEVELS contours between min_value > 
;          min(data) and max_value < max(data).
;
; MEDIAN - Apply the MEDIAN filtering function with a
;           nearest-neighbor window. This is applied to the raw
;           pixelated image and not the mapped one. This can be used
;           together with the SMOOTH keyword but not the LEE
;           keyword. The purpose is to clean up statistical noise and
;           outliers. CAUTION!!: This function alters the appearance
;           of localized features such as the "low-altitude" ENA
;           emissions in the IMAGE/HENA data.
;
; LEE - Apply the LEE filter to the raw image. This can be used
;        together with the SMOOTH keyword but not the MEDIAN
;        keyword. Should do a better job than MEDIAN but one needs to
;        tweak the N and SIG arguments to the LEEFILT.PRO
;        function. EXPERIMENTAL!
;
; CLOSEUP - A shorcut of setting the LIMIT keyword to MAP_SET. This
;            gives you automatically 120 x 120 deg FOV. Equal to
;            setting LIMIT=[60,-60,-60,60]. Overrides SPHERE.
;
; XCLOSEUP -A shorcut of setting the LIMIT keyword to MAP_SET. This
;            gives you automatically 120 x 120 deg FOV. Equal to
;            setting LIMIT= [45, -45, -45, 45]. Overrides SPHERE.
;
; TOP - Same as for BYTSCL.PRO.
;
; NOERASE - If set, skymap doesn't erase the previous plot.
;            
; LIMIT - LAT, LON (in degrees)  [LATMIN, LONMIN, LATMAX, LONMAX]
;
; EARTH - Adds the Earth with landcolor, seacolor, maps out continents
;
; FULLSCREEN - Eliminates colorbar, annotation.  Entire screen filled
;              by IMAGE
;
; TIME - Stucture with Year, Doy, Hour, Min, Sec Used with keyword EARTH
;
; GEOGRID - Used with keyword EARTH
;
; FILL - Used with keyword EARTH
;
; LANDCOLOR - Used with keyword EARTH, indicates color of continents
;
; SEACOLOR - Used with keyword EARTH, indicates color of water
;
; GEI - Indicates sc_pos (plus other vectors) is in GEI coordinates Used with keyword EARTH
;
; BARTITLE - Annotation to appear on colorbar, typically Units
;
; BARLEVELS - Number of divisions in the colorbar.  (divisions + 1) annotations
;
; NOIMAGE - Indicates that no image should be made
;
; ANTIEARTHWARD - essentially sets
;                 p0lon=180 instead of 0 deg.
;
; CBARPOSITION - positions colorbar
;
; BARCHARSIZE - The character size of the color bar annotations. 
;
; BARFORMAT - Format of the Numbers used in the colorbar labeling
;
; WIM - Passes back the map_image(image) to the calling program
;
; P0LAT - center of the plot being p0lat, p0lon  in map coordinates
;
; P0LON - center of the plot being p0lat, p0lon  in map coordinates
;
; ROT - If not set, then  Rotate the map so that mag dipole axis always points
;       upwards.  If set use rot value to rotate the map.
;
; ANNOSIZE - Size of the text used in the annotation
;
; LINE_THICK - Thickness of lines used in images
;
; PS - Indicates whether we are making a postscript image or not
;      **Might go away
;
; CTAB - Indicates which colortable is used to make the image
;
; UNITS - **Will most likely be replaced by bartitle
;
; SUN_SPOT - Adds the A, Dot annotation on the plots
;
; LABEL_FIELD_LINE - Adds 0, 6, 12, 18 labels to the field lines
;
; OUTPUTS:
; 
;   The input image projected onto the sphere of the sky, using the
;   azimuthal projection with the 'north pole' of the sky sphere being
;   the spin axis. The coordinats of the map are the spin based
;   coordinates to represent what a spinning imager 'sees'.
;
;
;
; OPTIONAL OUTPUTS:
;
;
;
; COMMON BLOCKS:
;                None!
;
;
; SIDE EFFECTS:
;
; KNOWN PROBLEMS/BUGS: - Field-line plotting crashes at sc_pos_x=0???
;
;
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;   Set up the map by, setting 0 deg lat and lon as the
;   subsatellite point of the skysphere, i.e. the center of
;   the plot. The rotation (ROT argument to MAP_SET) is set
;   such that MAG will always point upward on the plot
;   window. Points a bit to the side for some positions but
;   gives a continuous pointing position of the earth, so
;   that it will work if one wants to do a movie. REFLECT_MAP 
;   is used to mirror turn the map since the map projections
;   in IDL are used to put data on the surface of a
;   sphere. We want to put data INSIDE a sphere.
;            
;   Field lines are plotted for fixed L-shell and MLT range.
;
; DEPENDENCIES (non-standard IDL routines):
; 
;   FIELD_LINE.PRO - To plot field_lines.
;   EARTH_BOUNDARY.PRO - To plot Earth's limb.
;   TERMINATOR_LINE.PRO - To plot terminator line.
;   SPHERE_BASIS.PRO
;   DOT.PRO
;   SPHERE2SPHERE.PRO
;   SPHERE_TO_XYZ.PRO
;   XYZ_TO_SPHERE.PRO
;   REFLECT_MAP.PRO
;   XYTEXT.PRO
;   COLORBAR.PRO
;            
; EXAMPLE:   
;   Following examples lets you view the earth as the
;   satellite passes it in a straight trajectory below the
;   southpole. 
;
;pro test
;  mag = [0, 0, 1]
;  sun_pos = [1, 0, 0]
;  spin_axis = [-1, 1, 0]
;  xs = transpose(interpol([6, -6], 50))
;  ys = xs
;  zs = transpose(replicate(-2, 50))
;  sc_pos = [[xs, ys, zs]]
;  for i = 0, 49 do begin 
;    SKYMAP, dist(10), sc_pos = reform(sc_pos(*, i)), spin_axis = spin_axis,  $
;      sun = sun_pos, sphere = 0, mag = mag
;    wait, .1
;  endfor
;end
;
;
; MODIFICATION HISTORY:
;
;       Jun 19 2007, Jillian Redfern, SWRI
;       - received new skymap.pro from Pontus Brandt
;         incorporating his changes into our version of skymap
;       Added in no_sun_spot, ps, line_thick, annosize, ctab  keywords
;       Added additional comments to the top of the program
;
;       Mar 22, 2005. Michael Muller, SwRI
;       - Commented out overplot of gridlines.
;
;       Dec 06, 2004. Michael Muller, SwRI
;       - originally created/tested Nov 07, 2002.
;       - Added code to make map of pixels
;         so can get values at any x,y grid
;         point. Also, overlay/plot the grid.
;
;       Thu Mar 4 09:32:56 2004, Pontus Brandt
;       <brandpc1@brandts-pc.jhuapl.edu>
;
;		- Added keyword PRIME_MERIDIAN for plotting the limb.
;
;       Thu Sep 25 15:18:24 2003, Pontus Brandt
;       <brandpc1@brandts-pc.jhuapl.edu>
;
;		- Bug: LATMIN=0 (and some other keywords too) caused
;                 latmin to be set to -90, since I used KEYWORD_SET
;                 routine. Changed to check set keyowrds with
;                 N_ELEMENTS instead.
;
;       Thu Sep 25 15:11:21 2003, Pontus Brandt
;       <brandpc1@brandts-pc.jhuapl.edu>
;
;		- Added keywords P0LAT and P0LON to generalize type of display for
;                 other instrumental geometries.
;
;       Tue Apr 17 14:21:16 2001, Pontus Brandt
;       <brandpc1@brandts-pc.jhuapl.edu>
;
;		- Added MLTs to the tip of each field line
;                 plotted. Removed "SUN" annotation.
;
;       Wed Mar 14 18:39:08 2001, Pontus Brandt
;       <brandpc1@brandts-pc.jhuapl.edu>
;
;		- Moved call to COLORBAR last and instead saved system 
;                 variables from the map coordinate system just after
;                 having created it. Restore them again just before
;                 exiting this procedure.
;
;       Wed Mar 14 14:40:12 2001, Pontus Brandt
;       <brandpc1@brandts-pc.jhuapl.edu>
;
;		- Added keyword CBARPOSITION to have an option to
;                 position the colorbar.
;
;       Fri Jan 12 12:55:15 2001, Pontus Brandt
;       <brandpc1@brandts-pc.jhuapl.edu>
;
;		- Added keyword ANTIEARTHWARD, which essentially sets
;                 p0lon=180 instead of 0 deg. Should carry with it the 
;                 right LIMIT, but somehow it looks weird for CLOSEUP
;                 and XCLOSEUP. Hemisphere and full sphere seems to be 
;                 fine.
;
;       Fri Jan 12 10:23:02 2001, Pontus Brandt
;       <brandpc1@brandts-pc.jhuapl.edu>
;
;		- Added keyword
;		  EARTH: gives outline of earth and continents.
;		  COLOREARTH: gives filled continents.
;		  Positioning and sizing of the earth is NOT solved
;		  yet, in other words, it doesnt work, but have to set 
;		  manually in the program! It is EXPERIMENTAL.
;
;       Wed Dec 6 12:48:36 2000, Pontus Brandt
;       <brandpc1@brandts-pc.jhuapl.edu>
;
;		- Adding keyword LIMIT in order to bring the setting
;                 of CLOSEUP and XCLOSEUP external to SKYMAP. Keeping
;                 old keywords CLOSEUP, XCLOSEUP, SPHERE just in case
;                 someone needs to use them.
;
;       Wed Oct 11 08:45:47 2000, Pontus Brandt
;       <brandpc1@brandts-pc.jhuapl.edu>
;
;		- Changed the plotting order to be able to save the
;                 data coordinate system established by MAP_SET. Put
;                 all plotting not using the data system, first. Still 
;                 problem with CONTOUR keyword. It is using the data
;                 system and shouldnt destroy it, but some how it gets 
;                 meesed up.
;
;       Thu Sep 28 13:42:27 2000, Pontus Brandt
;       <brandpc1@brandts-pc.jhuapl.edu>
;
;		- Added NOERASE keyword. The erasing should be done in 
;                 here, if any.
;
;       Wed Sep 27 14:05:57 2000, Pontus Brandt
;       <brandpc1@brandts-pc.jhuapl.edu>
;
;		- Added TOP keyword to be able to use only a specific
;                 region of the colortable.
;
;       Mon Sep 25 10:01:29 2000, Pontus Brandt
;       <brandpc1@brandts-pc.jhuapl.edu>
;
;		- Made filtering possible for 24-bit images.
;
;       Wed Sep 20 07:19:20 2000, Pontus Brandt
;       <brandpc1@brandts-pc.jhuapl.edu>
;
;		- Added check if field lines cannot be drawn.
;
;       Tue Sep 19 10:10:30 2000, Pontus Brandt
;       <brandpc1@brandts-pc.jhuapl.edu>
;
;		- Added MEDIAN and LEE keywords. Need to tweak their
;                 parameters a bit, especially LEE.
;               - Also, set BILINEAR=1 if SMOOTH is set. This soften
;                 the edges in the MAP_IMAGE function.
;
;       Wed Sep 6 12:01:07 2000, Pontus Brandt
;       <brandpc1@brandts-pc.jhuapl.edu>
;
;		- Added clip keyword. All values GE than clip
;                 are set to 0.
;
;       Wed Sep 6 10:00:31 2000, Pontus Brandt
;       <brandpc1@brandts-pc.jhuapl.edu>
;
;		- Fixed format codes for color bar and logscale.
;
;       Thu Jun 15 10:03:09 2000, Pontus Brandt
;       <brandpc1@brandts-pc.jhuapl.edu>
;
;		- Added keywords XMARGIN, YMARGIN, and TITLE.
;
;       Thu May 18 19:06:34 2000, Pontus Brandt
;       <brandpc1@brandts-pc.jhuapl.edu>
;
;		- Added some keywords for logscale and general looks.
;
;       Fri May 12 18:28:56 2000, Pontus Brandt
;       <brandpc1@brandts-pc.jhuapl.edu>
;
;		- Added keyword MAX for the colorbar.
;
;       Tue May 9 11:10:50 2000, Pontus Brandt
;       <brandpc1@brandts-pc.jhuapl.edu>
;
;		- Plotting position of Sun and magnetic north pole.
;
;       Mon May 8 18:07:00 2000, Pontus Brandt
;       <brandpc1@brandts-pc.jhuapl.edu>
;
;		- Added keyword ANNOTATION.
;
;       Sat Apr 15 16:58:21 2000, Pontus Brandt
;       <brandpc1@brandts-pc.jhuapl.edu>
;
;               - Included keywords latmin, latmax, lonmin, lonmax.
;
;       Fri Apr 14 13:14:47 2000, Pontus Brandt
;       <brandpc1@brandts-pc.jhuapl.edu>
;
;               - First version done with spin based map ;
;                 coordinates. Next step is to have an option for
;                 having ; the map coordinates in a geocentric
;                 coordinate system ; such as Solar Magnetic
;                 coordinates.
;
;-
DEBUG=0


if not keyword_set(sc_pos) then sc_pos = [0, 3, 0] ;TWINS Specific
if not keyword_set(spin_axis) then spin_axis = [0, -1, 0]
if not keyword_set(prime_meridian) then prime_meridian = -sc_pos
if not keyword_set(sun_pos) then sun_pos = [1, 0, 0]
if not keyword_set(mag) then mag = [0, 0, 1]

if not keyword_set(sphere) then sphere = 0

if not keyword_set(lonmin) then lonmin = -90 ;TWINS Specific
if not keyword_set(lonmax) then lonmax = 270 ;TWINS Specific
if not n_elements(latmin) then latmin = 2 ;TWINS Specific
if not n_elements(latmax) then latmax = 90 ;TWINS Specific

if not keyword_set(min) then min = min(image)
if not keyword_set(max) then max = max(image)

if keyword_set(smooth) then bilinear = 1 else bilinear = 0

if not keyword_set(xmargin) then  xmargin = 1
if not keyword_set(ymargin) then ymargin = [10,1]

if not keyword_set(title)  then title = ''
if not keyword_set(subtitle)  then subtitle = ''
if not keyword_set(clip) then clip = max(image)+10.
if not keyword_set(true) then true = 0
if not keyword_set(square) then square = 0
if not keyword_set(contour) then contour = 0
if n_elements(top) eq 0 then top = !d.table_size-4
if not keyword_set(noerase) then erase

if keyword_set(fullscreen) then begin 
    annotation = 0
    top_annotation = 0
    colorbar = 0
    xmargin = 0
    ymargin = 0
endif 
if (not(keyword_set(bartitle)) and not(keyword_set(units))) then bartitle = 'FLUX (cm!E2!N sr s)!E-1!N'
if keyword_set(units) and not(keyword_set(bartitle)) then begin
    if keyword_set(log) then begin
        extra = 'LOG(' 
        extra_end = ') '
    endif else begin
        extra = ''
        extra_end = ' '
    endelse
    case units of
        1: begin
            bartitle =  'FLUX ' + $
              extra + '(cm!E2!N sr s)!E-1!N' + $
              extra_end         ;integral number flux
        end
        2: begin
            bartitle = 'E FLUX ' + $
              extra + '(eV cm!E2!N sr s)!E-1!N' + $
              extra_end         ; differential number flux
        end
        4: begin
            bartitle = extra +'DEGREES FROM SUN' + $
               extra_end 
        end
        5: begin
            bartitle =extra + 'COUNTS' + $
              extra_end 
        end
        10: begin
            bartitle = '!3Fractional Error !7D!3F/F'
        end
        else: begin
            bartitle = 'E FLUX ' + $
              extra + '(eV cm!E2!N sr s)!E-1!N' + $
              extra_end         ; differential number flux
        end
    endcase

endif

if not keyword_set(barlevels) then barlevels = 2

if not keyword_set(p0lat) then p0lat = 90 ;TWINS Specific
if not keyword_set(p0lon) then p0lon = 0 ;TWINS Specific
if not keyword_set(line_thick)  then line_thick = 2.0
if not keyword_set(ps)   then ps   = 0
if not keyword_set(ctab) then ctab = 0 ;grayscale
if not keyword_set(annosize) then annosize = 1.0



if n_elements(sc_pos) ne 3 then begin 
    print, '%SKY.PRO: SC_POS must have three elements'
    return
endif
if sqrt(total(sc_pos^2)) le 1 then begin 
    print, '%SKY.PRO: SC_POS is below the surface'
    return
endif
if n_params() lt 1 then begin 
    print, 'Must have 1 argument'
    return
endif
s = size(image)
if s(0) lt 2 or s(0) gt 3 then begin 
    print, '%SKYMAP:Argument must have 2 or 3 dimensions'
    return
endif

;; Check for mismatching keywords
if keyword_set(lee) and keyword_set(median) then begin 
    print, '%SKYMAP.PRO: Cannot do Lee and Median filtering together.'
    return
endif 
if keyword_set(contour) and keyword_set(true) then begin 
    print, '%SKYMAP.PRO: Keywords CONTOUR and TRUE not allowed...yet'
    contour = 0
endif 

;; Annotation

;for CDAWeb, want background to be black which is 0 w/ C.T. 13
;for CDAWeb, want foreground to be white which is 255 w/ C.T. 13

!p.color = 255
!p.background = 0

if keyword_set(annotation) then begin 
    cs = PlotCharSize()
    if (ps EQ 1) then tvimage, (intarr(255,255)+1)*255
    if (ps EQ 1) then !p.color = 0
    if (ps EQ 1) then !p.background = 255
    if keyword_set(square) then begin  
        xyouts, .02, .95, strcompress(string("!5"+title)),  $
          align = 0, /normal, charsize = 1.5, color=!p.color
        xyouts, .02, .9, strcompress(string("!5"+subtitle)) $
          , align = 0,  $
          /normal, charsize = 1, color=!p.color
    endif else begin 
        xytext, .05, cs.y*annosize*6.5, annotation, /normal, spacing = -1.2, charsize = $
          annosize, charthick = line_thick, color=!p.color
                                ;  xytext, .6, .7, annotation, /normal, spacing = -1.5, charsize = 1.2
        xyouts, .28, .9, string("!5"+title), align = .5, /normal, charsize = annosize, color=!p.color
        xyouts, .28, .86, string("!5"+subtitle), align = .5,  $
          /normal, charsize = annosize*0.75, color=!p.color
    endelse
endif

;Top Annotation
if keyword_set(top_annotation) then begin 
    xyouts, .985, .05, top_annotation, /normal, charsize = $
      annosize*0.75, color=!p.color, orientation=90
endif



;; Set up the map
;; Rotate the map so that mag dipole axis always points
;; upwards. Sign of rotation is given by vector product between spin 
;; and mag. If the vector product points towards the observer (the
;; same hemisphere) the longitudes go upward in the same direction
;; as the dipole, but if it is negative the longitudes go down and
;; so does the dipole.
dd = sqrt(total(prime_meridian^2)*total(mag^2))
if n_elements(rot) eq 0 then begin  
    if dd ne 0 then $
      rot = acos(total(prime_meridian*mag)/dd)/!dtor  $
    else begin 
        print, '%SKYMAP.PRO: WARNING: Spinaxis or Mag = 0!'
        rot = 0
    endelse
    v = crossp(prime_meridian, mag)
    if total(v^2) ne 0 then $
      rot = total(v*(-sc_pos))/ $
      sqrt(total(v^2)*total(sc_pos^2))*rot $
    else rot = rot
endif

;If we don't want to rotate, set rot to be 0
if keyword_set(norotate) then rot = 0

if keyword_set(limit) then $
  limit = limit else $
  if keyword_set(xcloseup) then $
  limit = [0, -45, 45, 45] else $
  if keyword_set(closeup) then $
  limit = [0, -60, 60, 60] else $
  if keyword_set(sphere) then $
  limit = [0, -180, 90, 180] $ ;; Hemisphere ;TWINS Specific
else $
  limit = [0, -180, 90, 180] ;; Hemisphere ;TWINS Specific



;; Preliminary for a cartwheel orbit with the center of the plot being
;; nadir, i.e. lat, lon = 0, 0 in map coordinates
;; (DEFINITION)...unless ANTIEARTHWARD keyword is set.
if n_elements(p0lat) eq 0 and n_elements(p0lon) eq 0 then begin  
    if keyword_set(antiearthward) then begin 
        p0lat = 0
        p0lon = 180
        limit = limit*[1, -1, 1, -1] ;; reverse longitudes
    endif else begin 
        p0lat = 0
        p0lon = 0
    endelse 
endif

if n_elements(p0lat) ne 0 and n_elements(p0lon) eq 0 then begin 
    p0lon=0
endif  


;TJK 10/15/2009 - added this code to accept a position w/in a window
;                 so that we can make thumbnails... hopefully
if keyword_set(thumb) then begin
;Have to switch to normalized coordinates - that's what this code uses 
;vs. device
    x_loc = [position[0],position[2]]
    y_loc = [position[1],position[3]]
    n_loc = convert_coord(x_loc,y_loc,/device, /to_normal)
;convert_cord returns, x,y,z, x2,y2,z2 - we're ignoring the z's
    position=[n_loc[0],n_loc[1],n_loc[3],n_loc[4]]
;    print, 'position values in normalized coord',n_loc
;    print, 'the following values should be between 0 and 1',position
    map_set, p0lat, p0lon, rot, /azimuth, /iso, $
      limit = limit, /noborder, /noerase,$ 
      position=position ;TJK added used of position for thumbnails
      ;TJK removed xmargin = xmargin, ymargin = ymargin,$

endif else begin ;regular large plots
;    print, 'thumb is NOT set in cdaweb_skymap'
;TJK have to clear out the !p.position and !p.region values, otherwise
;the position/size of the plot carries over from the previous
;requested plot, e.g. orbit plot...
    !p.position=[0,0,0,0]
    !p.region=[0,0,0,0]
;print, 'clear out !p.position = ',!p.position
;print,  'clear out !p.region = ',!p.region

    map_set, p0lat, p0lon, rot, /azimuth, /iso, $
      limit = limit, xmargin = xmargin, ymargin = ymargin,  $
      /noborder, /noerase
endelse

reflect_map

box = 10

;; Filter the raw image
if keyword_set(median) then begin 
    if keyword_set(true) then begin 
        if (n_elements(image(0, *, 0)) mod 2 eq 0) and $
          (n_elements(image(0, 0, *)) mod 2 eq 0) then even = 1
        image(0, *, *) = median(reform(image(0, *, *)), 3, even = even) 
        image(1, *, *) = median(reform(image(1, *, *)), 3, even = even) 
        image(2, *, *) = median(reform(image(2, *, *)), 3, even = even) 
    endif else begin 
        if (n_elements(image(*, 0)) mod 2 eq 0) and $
          (n_elements(image(0, *)) mod 2 eq 0) then even = 1
        image = median(image, 3, even = even) 
    endelse 
endif 
if keyword_set(lee) then begin 
    n = 2
    sig = .4
    if keyword_set(true) then begin  
        image(0, *, *) = leefilt(reform(image(0, *, *)), n, sig) 
        image(1, *, *) = leefilt(reform(image(1, *, *)), n, sig)
        image(2, *, *) = leefilt(reform(image(2, *, *)), n, sig)
    endif else $
      image = leefilt(image, n, sig)
endif 

;; Warp and display image
;; For 24-bit images
if keyword_set(true) then begin 
    r = map_image(reform(image(0, *, *)), sx, sy, xsize, ysize,  $
                  latmin = latmin, latmax = latmax,  $
                  lonmin = lonmin, lonmax = lonmax, /compress)
    g = map_image(reform(image(1, *, *)), sx, sy, xsize, ysize,  $
                  latmin = latmin, latmax = latmax,  $
                  lonmin = lonmin, lonmax = lonmax, /compress)
    b = map_image(reform(image(2, *, *)), sx, sy, xsize, ysize,  $
                  latmin = latmin, latmax = latmax,  $
                  lonmin = lonmin, lonmax = lonmax, /compress)
    wim = bytarr(3, n_elements(r(*, 0)), n_elements(r(0, *)) )
    wim(0, *, *) = r
    wim(1, *, *) = g
    wim(2, *, *) = b

endif else begin 
    
    ;; Save the image to contour for later
    if (n_elements(image(*, 0)) mod 2 eq 0) and $
      (n_elements(image(0, *)) mod 2 eq 0) then even = 1

    contourimage = median(image, 3, even = even) 
    contourimage = map_image(contourimage, sx, sy, xsize, ysize,  $
                             latmin = latmin, latmax = latmax,  $
                             lonmin = lonmin, lonmax = lonmax, /compress,  $
                             /bilinear)
    contourimage = smooth(contourimage, box, /edge, /nan)
    if keyword_set(log) then contourimage = alog10(contourimage+1e-6)
    
    wim = map_image(image, sx, sy, xsize, ysize,  $
                    latmin = latmin, latmax = latmax,  $
                    lonmin = lonmin, lonmax = lonmax, /compress,  $
                    bilinear = bilinear, missing = 0) ;!p.background)
endelse 

if min(image) lt 0 then print, '% SKYMAP: WARNING: Found pixels < 0.'

;; Top clip image
ind = where(wim ge clip, cts)
if cts gt 0 then wim(ind) = 0

if keyword_set(log) then begin
    enamax = alog10(max > 1e-1)
    enamin = alog10(min > 1e-2)
    if keyword_set(units) then begin
        if (units eq 2) then begin
            enamax = alog10(max > 1e-3)
            enamin = alog10(min > 1e-4)
        endif
    endif
    wim = alog10(wim+0.000001)
endif else begin 
    enamin=min
    enamax=max
endelse

if enamin ge enamax then begin
    if (keyword_set(log)) then $
      enamin = enamax-1.5           $
    else begin
        enatmp = enamin
        enamin = enamax
        enamax = enatmp
        if (enamin eq enamax) then begin
            enamin=0
            enamax = ((enamin+.001) > enamax)
        endif
    endelse
endif

;bad = where(wim le 0b,cts)
;if cts gt 0 then wim(bad) = !p.background


if keyword_set(smooth) then begin 
    if smooth gt 1 then box = smooth $
    else box = 10
    wim = smooth(TEMPORARY(wim), box, /edge, /nan)
endif 

;; We bytscale WIM here, so that the IMAGE matrix always contains the
;; data values
byteimage = bytscl(TEMPORARY(wim), min = enamin, max = enamax, top = top)
ind = where(byteimage eq 0B, cts)
if cts gt 0 then byteimage(ind) = !p.background
if not keyword_set(noimage) then $ 
  tv, byteimage, sx, sy,  $
  xsize = xsize, ysize = ysize, true = true


if keyword_set(grid) then map_grid, /label, glinethick = 1,  $
  charsize=annosize*0.75, glinestyle = 1

;; Save map coordinate system here. Restore it before exiting this
;; procedure. Then we can plot whatever we want (colorbars,
;; contours, etc.)
draw_st = {p:!p, x:!x, y:!y, z:!z, map:!map}



if keyword_set(limb) then begin  
; Earth boundary with spin axis in geocentric coordinates pointing to
; the +z direction in viewing sphere.
    eb = earth_boundary(sc_pos, spin_axis, $
                        prime_meridian = prime_meridian, /deg, $
                        earth = earth)

    plots, eb(2, *), eb(1, *), thick = line_thick, /data;, linestyle=1
endif

if keyword_set(exobase) then begin  
; Exosphere base at 300km
    eb = earth_boundary(sc_pos, spin_axis,  $
                        prime_meridian = prime_meridian, /deg,  $
                        radius = 1.+300./6378.)
    plots, eb(2, *), eb(1, *)   ;, linestyle = 5
endif

if keyword_set(terminator) then begin  
                                ; Terminator
    w = terminator_line({c:{axis:spin_axis, phase:prime_meridian, sun:sun_pos},  $
                         p:sc_pos*6378.}, num = 10)


    if n_elements(w) ge 2 then begin
        if annosize ge 4. then $
          plots, w(2, *), w(1, *),  $
          noclip = 0, psym=2 $
        else $
          plots, w(2, *), w(1, *),  $
          noclip = 0, linestyle=1
    endif
endif

if keyword_set(sun_spot) then begin

    if keyword_set(annotation) then begin  
        ;; Get Sun and Mag Pole in instrumental coordinates
        ;; First, define the axis of the instrumental cooridnate system in
        ;; whatever geocentric system you've defined spin_axis, sun, sc_pos,
        ;; and mag in. 
        z = spin_axis/norm(spin_axis)
        x = prime_meridian
        x = x/norm(x)
        y = crossp(z, x)

        ;; And, second, convert sun and mag to the instrumental coordinate system.
        p = sphere2sphere(xyz_to_sphere([[sun_pos], [mag]], /degree),  $
                          diag([1, 1, 1]), [[x], [y], [z]], /degree)

        npts = 20
        x = cos(interpol([0, 2*!pi], npts))
        y = sin(interpol([0, 2*!pi], npts))
        usersym, x, y, /fill
        plots, p[2, 0], p[1, 0], psym = 8, /data, symsize = 2
        xyouts, (p(2, 0)+180.) mod  360., -p(1, 0),  $
          align = .5, 'A', charsize = 1
    endif                       ;annotation
endif                           ;sunspot

;NO WORKING, SWRI Doesn't have a copy of all needed programs
;  if keyword_set(earth) then begin 
;      ;; Calculate angular extent of earth. Ofcourse the earth is NOT
;      ;; warped onto the existing map. We assume the region where earth is 
;      ;; plotted is rectangular enough for it to look real. in other
;      ;; words, if the earth is small enough it can be approximated by a
;      ;; circle.
;      alpha = atan(1., sqrt(total(sc_pos^2)))/!dtor
;      x0 = alpha
;      y0 = x0
;      x1 = -alpha
;      y1 = x1
;      position = [x0, y0, x1, y1]
;      ;; p0lat and p0lon is the footprint on the earth in GEOGRAPHIC
;      ;; coordinates. Thus, take the SM lat and lon and convert to GEO.
;      if not keyword_set(gei) then begin  
;          pos = gei2sm(sc_pos, time.year, time.doy, time.hour,  $
;                       time.min, time.sec, /inv)
;      endif else pos = sc_pos
;      date = doy2date(time.doy, time.year, /num)
;      posgeo = gei2geo(pos,  $
;                       [time.hour+time.min/60., date[2], date[1], time.year])
;      posgeo_sphere = xyz2sphere(posgeo, /deg)
;      p0lat = posgeo_sphere(1)
;      p0lon = posgeo_sphere(2)
;      ;; Calculate the rotation by first calculate the rotation to line
;      ;; up with spin axis. The vgeo=Geonorth-(p0lat,p0lon)_geo vector is
;      ;; pointing down on the screen for rot=0.
;      ;; Rotation between spinaxis and vgeo
;      if not keyword_set(gei) then begin 
;          spin = gei2sm(spin_axis, time.year, time.doy, time.hour,  $
;                        time.min, time.sec, /inv)
;      endif else spin = spin_axis
;      spingeo = gei2geo(spin,  $
;                        [time.hour+time.min/60., date[2], date[1], time.year])
;      spingeo_sphere = xyz2sphere(spingeo, /deg)
;      rot = spingeo_sphere(2)-p0lon
;      rot = 172.
;      earth, rot = rot, p0lat = p0lat, p0lon = p0lon, position = position,  $
;        data=1, geogrid = geogrid, fill = fill, landcolor = landcolor,  $
;        seacolor = seacolor       ;, /pole, /foot
;  endif 

if keyword_set(field) then begin  
;; Field lines
;  Red(color=254)=noon=12LocalTime. Yellow(90)=dusk=18LT.
    st = {gei: sc_pos*6378., mag_gei: mag, sun_gei: sun_pos,  $
          axis_gei: spin_axis, prime_gei: prime_meridian}
    l = [4, 8]

    flon = [0, 90, 180, 270]
;TJK add code to save off the colortable before these fieldlines and
;others are drawn and then restore them at the bottom. Using a
;different colortable than original, so purple is a different #.
    tvlct, orig_r,orig_g,orig_b, /get
;    purple = 253
    purple = 195
    tvlct, 180, 120, 200, purple
    for i = 0, n_elements(l)-1 do $
      for j = 0, n_elements(flon)-1 do begin 
;        if flon[j] eq 0 then ccolor = 254 $
        if flon[j] eq 0 then ccolor = 230 $ ;230 is red in CDAWeb
        else if flon[j] eq 90 then ccolor = purple else ccolor=!p.color
        line = field_line(st, l(i), flon(j))
        if size(line, /n_dim) eq 2 then begin 
            plots, line(2, *), line(1, *),  thick = line_thick, color=ccolor 
                                ;if (flon[j] eq 90 ) then plots, line(2, *), line(1, *),  linestyle=1, thick = line_thick, color= !p.color
                                ;if (flon[j] eq 0 ) then plots, line(2, *), line(1, *),  linestyle=1, thick = line_thick, color= !p.color
        endif else begin 
            print, '%SKYMAP: Cannot draw field line. Function returns', line
        endelse 
    endfor

    if keyword_set(label_field_line) then begin

;;     Put MLT on the tips of each field line.
        mltname = ['12', '18', '00', '06']
        for i = 0, n_elements(flon)-1 do begin 
            line = field_line(st, l[n_elements(l)-1], flon[i])
            if size(line, /n_dim) eq 2 then begin 
                r = line[2, *]^2+line[1, *]^2
                ind = where(r eq max(r))
                phi =  line[2, ind[0]]
                phi = 1.1*phi
                theta = line[1, ind[0]]
                theta = 1.1*theta
                xyouts, phi, theta, mltname[i],  $
                  charsize = annosize
            endif 
        endfor 
    endif
    
endif

;  ;mam Jun21,2005.
;  ;This lanl field lines/satellite
;  ;section is not used (lanl=0 is set).
;  ;* It also has a bug! *
;  ;The part:
;  ;  lanl_mltlon = lanl_lon
;  ;  for kk = 0, n_elements(lanl_lon) - 1 do begin
;  ;      if (lanl_lon[kk] le 0) then $
;  ;         lanl_mltlon[kk] = ut - lanl_lon[kk]/15. $
;  ;      else $
;  ;         lanl_mltlon[kk] = ut - lanl_lon[kk]/15.
;  ;      lanl_mltlon[kk] =  lanl_mltlon[kk] * 15.
;  ;  endfor
;  ;can be rewritten lanl_mltlon = ut*15 - lanl_lon
;  ;It is unknown what the exact equation is or
;  ;if the intent was to use the if() and then
;  ;have one branch a + and the other a -.
;  ;
;  lanl = 0
;  if (lanl) then begin
;     ;; Field lines
;     ;if (!d.name eq 'PS') then loadct,0,/silent
;     st = {gei: sc_pos*6378., mag_gei: mag, sun_gei: sun,  $
;           axis_gei: spin_axis, prime_gei: -sc_pos}
;     l = [6.6]
;     lanl_lon = [-165.1,8.5,69.5,-38.1,103.4]
;     lanl_mltlon = lanl_lon
;     for kk = 0, n_elements(lanl_lon) - 1 do begin
;         if (lanl_lon[kk] le 0) then $
;            lanl_mltlon[kk] = ut - lanl_lon[kk]/15. $
;        else $
;            lanl_mltlon[kk] = ut - lanl_lon[kk]/15.
;         lanl_mltlon[kk] =  lanl_mltlon[kk] * 15.
;     endfor
;     for i = 0, n_elements(l)-1 do $
;       for j = 0, n_elements(lanl_mltlon)-1 do begin
;          line = field_line(st, l(i), lanl_mltlon(j))
;          plots, line(2, *), line(1, *), thick = line_thick, color=254
;       endfor
;   endif


if keyword_set(contour) then begin 
    ;; Contour
    position = [sx, sy, sx+xsize, sy+ysize]
    ;; 'contourimage' is the image that is smoothed and median filtered.
    ;; The CONTOUR procedure puts NLEVELS contours between min_value > 
    ;; min(data) and max_value < max(data).
    contour, contourimage, /follow, nlevels = 9,  $
      /noerase, xstyle = -1, ystyle = -1, position = position, dev=1,  $
      c_charsize = 1.8, min_value = enamin, max_value = enamax, c_thick = 2
endif


if keyword_set(colorbar) then begin  
;; Color bar
    if enamin ge enamax then begin 
        print, '% SKYMAP: Keyword MIN must be less than MAX!'
        enamin = 0
    endif
    if keyword_set(square) then begin 
        position = [0.92, 0.25, 0.95, 0.75]
        vertical = 1
    endif else begin 
        ;; Default
        position = [0.92, 0.05, 0.95, 0.35]
        vertical = 1
    endelse 
    

    if keyword_set(cbarposition) then $
      position = cbarposition
    if not keyword_set(barcharsize) then barcharsize = 1.
    if not keyword_set(barformat) then begin
        barformat='(f5.2)'

        if (enamax ge .001 and enamax lt 1) then barformat='(f6.3)'
        if (enamax ge 1 and enamax lt 10) then barformat='(f6.3)'
        if (enamax ge 10 and enamax lt 100) then barformat='(f6.2)'
        if (enamax ge 100 and enamax lt 1000) then barformat='(f7.2)'
        if (enamax ge 1000 and enamax lt 10000) then barformat='(f6.1)'
        if (enamax ge 10000 and enamax lt 100000) then barformat='(f7.1)'
        if (enamax ge 100000 and enamax lt 1000000) then barformat='(f8.1)'

        if (enamin ge .0001) then begin
            if (enamin ge .001  and enamin lt .01 ) then barformat='(f5.3)'
            if (enamin ge .0001 and enamin lt .001) then barformat='(f6.4)'
        endif

        if (enamax ge 1000000) then barformat='(e7.1)'
    endif

    if (DEBUB) then print,'  ***### min,max',min,max

    twinscolorbar, position = position, vertical = vertical, $
      minrange = enamin, maxrange = enamax, format = barformat, title = bartitle,  $
      ncolors = top, ps = (!d.name eq 'PS'), color = !p.color,  $
      divisions = barlevels > 4, charsize = annosize*.7, minor=0
endif

;; Restore coordinate system variables
!p = draw_st.p
!x = draw_st.x
!y = draw_st.y
!z = draw_st.z
!map = draw_st.map

;TJK restore the color table prior to the use of purple
    tvlct, orig_r,orig_g,orig_b
return
end                             ;pro skymap
