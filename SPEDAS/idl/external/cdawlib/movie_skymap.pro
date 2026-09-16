;+------------------------------------------------------------------------
; NAME: MOVIE_SKYMAP  
;
; PURPOSE: Produce gif/mpeg movie from TWINS images
;
; CALLING SEQUENCE:
;       out = movie_skymap(astruct,vname)
; INPUTS:
;       astruct = structure returned by the read_mycdf procedure.
;       vname   = name of the variable in the structure used to produce movie.
;
; KEYWORD PARAMETERS:
;       XSIZE     = x size of single frame
;       YSIZE     = y size of single frame
;       GIF      = name of gif file to send output to
;       REPORT    = name of report file to send output to
;       TSTART    = time of frame to begin imaging, default = first frame
;       TSTOP     = time of frame to stop imaging, default = last frame
;       COLORBAR = calls function to include colorbar w/ image
;       LIMIT = if set, limit the number of movie frames allowed -
;       this is the default for CDAWEB
;
; OUTPUTS:
;       out = status flag, 0=0k, -1 = problem occured.
; AUTHOR:
;       
;      Tami Kovalick, based on fuv_movie.pro
;
; MODIFICATION HISTORY:
;-------------------------------------------------------------------------
FUNCTION movie_skymap, astruct, vname, $
                      XSIZE=XSIZE, YSIZE=YSIZE, $
                      GIF=GIF, REPORT=REPORT,$
                      TSTART=TSTART,TSTOP=TSTOP,NONOISE=NONOISE,$
                      MOVIE_FRAME_RATE=MOVIE_FRAME_RATE, MOVIE_LOOP=MOVIE_LOOP, $
                      LIMIT=LIMIT, COLORBAR=COLORBAR, DEBUG=DEBUG


if keyword_set(COLORBAR) then COLORBAR=1L else COLORBAR=0L
if keyword_set(REPORT) then reportflag=1L else reportflag=0L
if keyword_set(XSIZE) then xs=XSIZE else xs=512
if keyword_set(YSIZE) then ys=YSIZE else ys=512

if COLORBAR then xco=80 else xco=0 ; will add or not 80 columns to window size

;by default want to limit the number of frames in a movie
;but if explicitly set to zero, then don't apply limits
if (n_elements(LIMIT) gt 0) then begin
  if keyword_set(LIMIT) then LIMIT = 1L else LIMIT = 0L
endif else LIMIT=1L

if n_elements(movie_frame_rate) eq 0 then movie_frame_rate = 3
if n_elements(movie_loop) eq 0 then movie_loop = 1 ; default is "on"

; Determine the field number associated with the variable 'vname'
w = where(tag_names(astruct) eq strupcase(vname),wc)
if (wc eq 0) then begin
   print,'ERROR=No variable with the name:',vname,' in param 1!' & return,-1
endif else vnum = w(0)
   
; Verify the type of the first parameter and retrieve the data
a = size(astruct.(vnum))
if (a(n_elements(a)-2) ne 8) then begin
   print,'ERROR= 1st parameter to plot_images not a structure' & return,-1
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

isize = size(idat)
; just in case we get a 1D array. I'm not sure there were any checks for this before.
if (isize(0) eq 1) then begin
   print, 'ERROR= 1D array found.  Need array to be 2D or 3D.'
   print, 'STATUS= 1D array found.  Need array to be 2D or 3D.'
   return, -1
endif
; if array is 2D we have 1 image, if 3D we can make movie:
if (isize(0) eq 2) then n_images=1 else n_images=isize(isize(0))

; Cannot produce movie out of a single frame:

if (n_images eq 1) then begin ; valid frame value
   print, 'ERROR= Single movie frame found'
   print, 'STATUS= Single movie frame; select longer time range.'
   return, -1
endif else begin ; produce thumbnails of all images
   ; if the number of frames exceeds 60 send a error message to the user to
   ; reselect smaller time
   ; TJK 12/19/2005 - change to 200 w/ new DELL rumba
;TJK 2/28/2006 - added check for LIMIT keyword - so that we can turn
;                this off for CDFX use and private use outside of CDAWeb.

   if(n_images gt 200 and LIMIT) then begin
      print, 'ERROR= Too many movie frames '
      print, 'STATUS= You have requested ',n_images,' frames.'
      print, 'STATUS= Movies are limited to 200 frames, select a shorter time range.'
      return, -1
   endif
   ;
   if keyword_set(GIF) then begin
      GIF1=GIF+"junk"
   endif

   if(reportflag eq 1) then printf,1,'MGIF=',GIF
   print,'MGIF=',GIF

   for j=0,n_images-1 do begin
      ; *** call plot_skymap:
      status=plot_skymap(astruct,vname,nonoise=nonoise, $
         frame=j+1,gif=gif1,colorbar=colorbar,/movie)

      if (status eq 0) then begin
        read_gif,gif1,image,r,g,b
        sz=size(image)

        write_mgif, GIF, image, r, g, b, delay=(100/movie_frame_rate), loop=movie_loop

      endif
   endfor

  write_mgif, GIF, /close

endelse
;   
return,0
end

