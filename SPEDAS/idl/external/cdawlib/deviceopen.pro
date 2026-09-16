;$Author: jimm $
;$Date: 2010-01-12 12:18:45 -0800 (Tue, 12 Jan 2010) $
;$Header: /home/cdaweb/dev/control/RCS/DeviceOpen.pro,v 1.8 2007/02/27 14:57:40 johnson Exp johnson $
;$Locker: johnson $
;$Revision: 7092 $
Pro DeviceOpen, device, portrait=portrait, fileOutput=fileOutput, $
	sizeWindow=sizeWindow, COLORTAB=COLORTAB
;Terri Martin and Robert Candey, 26 July 1993
; added more devices  25 Aug 1993 BC
; change to white on bottom, black on top   27 Aug 1993 BC
; Robert.M.Candey.1@gsfc.nasa.gov; 1995 June 22; added GIF
; R. Burley 04/19/96 added COLORTAB Keyword for use with GIF
; added Mac/Win and ION, RMC 2001 July 19

; This procedure sets the desired output device and parameters.

common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr
common deviceTypeC, deviceType, file
top = 255
bottom = 0
if (n_elements(device) le 0) then begin
  deviceType = 0
  ; print, 'Choose an output device:'
  ; print, '0    Local windows (X, Mac, Win) (color)'
  ; print, '1    Postscript file         (color)'
  ; print, '2    Postscript file         (grayscale)'
  ; print, '3    Postscript file         (black&white)'
  ; print, '4    Tektronix 4105 terminal (16 colors)'
  ; print, '5    Z buffer                (color)'
  ; print, '6    GIF image               (color)'
  ; print, '7    PNG image               (color)'
  ; print, '9    ION display             (color)'
  ; read, 'Output device number? ', deviceType
Read, 'Output device '+ $
  '(Local=0, PS color=1, PS gray=2, PS BW=3, Tek=4, Zbuf=5, GIF=6, PNG=7, ION=9)? ',deviceType   
endif else begin
  deviceType = device
endelse

Case deviceType of
  0: begin ; Local windows
  ; The pseudo setting for the device call only works for X
  ;   case strupcase(strtrim(strmid(!version.os_family,0,3),2)) of
  ;     'MAC': set_plot,'MAC'
  ;     'WIN': set_plot,'WIN'
  ;     else:  set_plot,'x'
  ;    endcase                   ;   endcase
  ;   device, pseudo=8, decomposed=0, retain=2
  ;new code below - TJK 9/15/2006
     case strupcase(strtrim(strmid(!version.os_family,0,3),2)) of
       'MAC': begin
                set_plot,'MAC'
                device, decomposed=0, retain=2
              end
       'WIN': begin
                set_plot,'WIN'
                device, decomposed=0, retain=2
              end
       else: begin
              set_plot,'x'
              device, pseudo=8, decomposed=0, retain=2
             end
     endcase
;TJK 3/27/03 - replace !d.n_colors and !d.table_size, because various display devices have many more
;colors than the size of the color table...
;     !p.background = !d.n_colors-1
     !p.background = !d.table_size-1
;     !p.color = !d.n_colors-2
     !p.color = 0
     loadct,13
;     restore,'goodcolor.xdr'
;     tvlct,red1,green1,blue1
     !p.thick = 1.0 & !x.thick = 1.0 & !y.thick = 1.0
;     !x.style = 1 & !y.style = 1
     !p.charthick = 1.0 & !p.charsize = 1.0
     !p.font = -1 ; 0 ; hardware font, -1 for Hershey character set
; ###
;     erase ; to clear screen first time
    End            
  1: begin ; color Postscript
     if (n_elements(fileOutput) le 0) then file='idl.ps' else file=fileOutput
     set_plot, 'ps'
     if keyword_set(portrait) then begin
       if (n_elements(sizewindow) ne 0) then begin
          device,/portrait,bits=8,font_size=12,$
	     /color,/encaps,$
	     YOFFSET=1.2,XSIZE=sizewindow[0]/1000.,ysize=sizewindow[1]/1000.,$
	     xoffset=0.25, file=file
       endif else begin
          device,/portrait,bits=8,font_size=12,$
	     /color,/encaps,/INCHES,$
		YOFFSET=1.2,XSIZE=8,ysize=8.6,xoffset=0.25, file=file
       endelse	
	;
     endif else begin
        device,/landscape,bits=8,font_size=12,/color,/INCHES,/encaps,$
		YOFFSET=9.8,XSIZE=8.6,ysize=8.1,xoffset=0.2, file=file
;       device,/landscape,bits=8,font_size=12,/color,/INCHES,$
;		YOFFSET=10.25,XSIZE=10,ysize=7.5,xoffset=0.5, file=file
;       device,/landscape,bits=8,font_size=12,/color,/INCHES,$
;		YOFFSET=9.50,xsize=8,ysize=8,xoffset=.75, file=file
     endelse
     !p.background = !d.n_colors-1
;     !p.color = !d.n_colors-2
     !p.color = 0
     loadct,13
;     restore,'goodcolor.xdr'
;     tvlct,red1,green1,blue1
     !p.thick = 3.0 & !x.thick = 3.0 & !y.thick = 3.0
;     !x.style = 1 & !y.style = 1
     !p.charthick = 3.0 & !p.charsize = 1.0
     !p.font = -1 ; hardware font, -1 for Hershey character set
    End
  2: begin ; grayscale Postscript
     if (n_elements(fileOutput) le 0) then file='idl.ps' else file=fileOutput
     set_plot, 'ps'
     if keyword_set(portrait) then begin
       device,/portrait,bits=4,font_size=12,/INCHES,$
		YOFFSET=1.2,XSIZE=8,ysize=8.6,xoffset=0.25, file=file
;       device,/portrait,bits=4,font_size=12,/INCHES,$
;		YOFFSET=0.25,XSIZE=8,ysize=10.5,xoffset=0.25, file=file
     endif else begin
       device,/landscape,bits=4,font_size=12,/INCHES,$
		YOFFSET=10.75,XSIZE=10.5,ysize=8,xoffset=0.25, file=file
     endelse
     !p.background = !d.n_colors-1
     !p.color = 0
;     !p.background = 0
;     !p.color = !d.n_colors-1
;     loadct,0
;     r_curr = (!d.n_colors-1) - bindgen(!d.n_colors) ; inverted gray scale
;;     r_curr = bindgen(!d.n_colors) ; gray scale
;;     g_curr = r_curr & b_curr = r_curr
;;     tvlct, r_curr, g_curr, b_curr
print, "Don't forget to invert your data (!d.n_colors-1-bytscl(data)) for grayscale"
     !p.thick = 3.0 & !x.thick = 3.0 & !y.thick = 3.0
;     !x.style = 1 & !y.style = 1
     !p.charthick = 3.0 & !p.charsize = 1.0
     !p.font = -1 ; hardware font, -1 for Hershey character set
    End
  3: begin ; Black and white Postscript
     if (n_elements(fileOutput) le 0) then file='idl.ps' else file=fileOutput
     set_plot, 'ps'
     if keyword_set(portrait) then begin
       device,/portrait,font_size=12,/INCHES,$
		YOFFSET=1.2,XSIZE=8,ysize=8.6,xoffset=0.25, file=file
     endif else begin
       device,/landscape,font_size=12,/INCHES,$
		YOFFSET=10.5,XSIZE=10,ysize=7.5,xoffset=0.5, file=file
     endelse
;     !p.background = 1
;     !p.color = 0
     !p.thick = 3.0 & !x.thick = 3.0 & !y.thick = 3.0
;     !x.style = 1 & !y.style = 1
     !p.charthick = 3.0 & !p.charsize = 1.0
     !p.font = -1 ; hardware font, -1 for Hershey character set
    End
  4: begin ; Tektronix 4105
     set_plot, 'tek'
     device,color=16, /tek4100
     !p.background = 0
     !p.color = 1
;?###     loadct,12 ; 16 color table
     !p.thick = 1.0 & !x.thick = 1.0 & !y.thick = 1.0
;     !x.style = 1 & !y.style = 1
     !p.charthick = 1.0 & !p.charsize = 1.0
     !p.font = -1 ; 0 ; hardware font, -1 for Hershey character set
    End
  5: begin ; Z buffered output
     if (n_elements(sizeWindow) le 0) then sizeWindow=[640,512]
     set_plot,'z'
     device,set_resolution=sizeWindow,set_colors=240,set_char=[6,11], $
	z_buffering=0
     !p.background = !d.n_colors-1
;     !p.color = !d.n_colors-2
     !p.color = 0
     loadct,13
;     restore,'goodcolor.xdr'
;     tvlct,red1,green1,blue1
     !p.thick = 1.0 & !x.thick = 1.0 & !y.thick = 1.0
;     !x.style = 1 & !y.style = 1
     !p.charthick = 1.0 & !p.charsize = 1.0
     !p.font = -1 ; 0 ; hardware font, -1 for Hershey character set
    End            
  6: begin ; GIF image file output
     if (n_elements(sizeWindow) le 0) then sizeWindow=[640,512]
     if (n_elements(fileOutput) le 0) then file='idl.gif' else file=fileOutput
     set_plot,'z'
     device,set_resolution=sizeWindow,set_colors=240,set_char=[6,11], $
	z_buffering=0
     !p.background = !d.n_colors-1
;     !p.color = !d.n_colors-2
     !p.color = 0
     if keyword_set(COLORTAB) then loadct,COLORTAB else loadct,13
;     restore,'goodcolor.xdr'
;     tvlct,red1,green1,blue1
     !p.thick = 1.0 & !x.thick = 1.0 & !y.thick = 1.0
;     !x.style = 1 & !y.style = 1
     !p.charthick = 1.0 & !p.charsize = 1.0
     !p.font = -1 ; 0 ; hardware font, -1 for Hershey character set
    End            
  7: begin ; PNG image file output
     if (n_elements(sizeWindow) le 0) then sizeWindow=[640,512]
     if (n_elements(fileOutput) le 0) then file='idl.png' else file=fileOutput
     set_plot,'z'
     device,set_resolution=sizeWindow,set_colors=240,set_char=[6,11], $
	z_buffering=0
     !p.background = !d.n_colors-1
;     !p.color = !d.n_colors-2
     !p.color = 0
     if keyword_set(COLORTAB) then loadct,COLORTAB else loadct,13
;     restore,'goodcolor.xdr'
;     tvlct,red1,green1,blue1
     !p.thick = 1.0 & !x.thick = 1.0 & !y.thick = 1.0
;     !x.style = 1 & !y.style = 1
     !p.charthick = 1.0 & !p.charsize = 1.0
     !p.font = -1 ; 0 ; hardware font, -1 for Hershey character set
    End            
  9: begin ; ION
     set_plot,'ION'
     !p.background = !d.n_colors-1
;     !p.color = !d.n_colors-2
     !p.color = 0
     loadct,13
;     restore,'goodcolor.xdr'
;     tvlct,red1,green1,blue1
     !p.thick = 1.0 & !x.thick = 1.0 & !y.thick = 1.0
;     !x.style = 1 & !y.style = 1
     !p.charthick = 1.0 & !p.charsize = 1.0
     !p.font = -1 ; 0 ; hardware font, -1 for Hershey character set
    End            
  Else: MESSAGE,'INCORRECT OUTPUT DEVICE!!!'
endcase

;  '(X=0, PS color=1, PS gray=2, PS BW=3, Tek=4, Zbuf=5, GIF=6)? ',deviceType   
;w = where([0, 1, 2, 5, 6, 7, 9] eq deviceType, wc) 
;if (wc gt 0) then begin
if (deviceType ne 3) and (deviceType ne 4) then begin
 ; munge color table to ensure black and white color
;  r_curr(!d.n_colors-2) = bottom & g_curr(!d.n_colors-2) = bottom
;  b_curr(!d.n_colors-2) = bottom
  r_curr(0) = bottom & g_curr(0) = bottom & b_curr(0) = bottom
  ; background
;TJK 3/27/03 - replace !d.n_colors and !d.table_size, because various display devices have many more
;colors than the size of the color table...

;  r_curr(!d.n_colors-1) = top & g_curr(!d.n_colors-1) = top
;  b_curr(!d.n_colors-1) = top
  r_curr(!d.table_size-1) = top & g_curr(!d.table_size-1) = top
  b_curr(!d.table_size-1) = top
  tvlct, r_curr, g_curr, b_curr
endif
return
END ; deviceOpen
