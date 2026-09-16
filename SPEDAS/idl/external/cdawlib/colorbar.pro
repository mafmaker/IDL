;$Author: jimm $ 
;$Date: 2010-01-12 12:18:45 -0800 (Tue, 12 Jan 2010) $
;$Header: /home/cdaweb/dev/control/RCS/Colorbar.pro,v 1.20 2006/09/08 20:32:07 kovalick Exp kovalick $
;$Locker: kovalick $
;$Revision: 7092 $
Pro colorbar, scale, title, logZ=logZ, position=position, cCharSize=cCharSize,$
              fcolor=fcolor, reverse=reverse, image=image, nResCol=nResCol
;+ Terri Martin and Robert Candey
; 21 June 1993
; added ccharsize ; 1995 July 26
; added save on !x, !y, !p; 1995 Aug 2; BC
; reduced ncolors when not enough pixels; 1995 Sep 14 BC
; added !p.multi=0; 1996 Aug 28 BC
;
; Modified: July 30, 1997 by Tami Kovalick added the Reverse Keyword
;   so that you can reverse the colors in the colorbar.
;
; Modified: October 31, 1997 by T. Kovalick added the image keyword - 
; this keyword modifies the labeling for the color bar so it indicates
; that values in the image above the scale are assigned to the top color.
;
; 2001 Mar 30 BC, changed fcolor to default to !p.color
; 2001 March 30 BC, added nResCol in place of fixed 2 colors
;
; Purpose:
; This procedure creates a colorbar for the right side of a spectrogram
; and image...
;-
common deviceTypeC, deviceType,file; required for inverting grayscale Postscript
xsave = !x & ysave = !y & zsave = !z & psave = !p
!p.multi = 0

if (n_elements(position) ne 0) then positiont = position else $
  positiont = [!x.window(1)+0.01, !y.window(0), !x.window(1)+0.04, !y.window(1)]
;	positiont = [0.9, 0.1, 0.93, 0.9]
if not keyword_set(logZ) then logZ=0
if (n_elements(title) le 0) then title = ''
if (n_elements(nResCol) le 0) then nResCol = 2
;TJK 5/8/2003 - replace !d.n_colors w/ !d.table_size because we only need as many
;colors as those in the selected colorbar.
;nColors = !d.n_colors-nResCol ; reserve black and white at ends of colorscale
nColors = !d.table_size-nResCol ; reserve black and white at ends of colorscale
colors = bindgen(nColors) + 1B
if (n_elements(deviceType) ne 0) then if (deviceType eq 2) then $
;	colors = (!d.n_colors-1B) - colors ; invert grayscale for Postscript
	colors = (!d.table_size-1B) - colors ; invert grayscale for Postscript
;if not keyword_set(fcolor) then fcolor=0
if n_elements(fcolor) le 0 then fcolor=!p.color

fontsize = 1.0
if n_elements(cCharSize) le 0 then cCharSize = 0.
if cCharSize gt 0 then begin
  fontsize = cCharSize
endif else begin
; alternative if cCharSize is undefined or le 0
  if !p.charsize gt 0. then fontsize = !p.charsize
  if !y.charsize gt 0. then fontsize = !y.charsize * fontsize
  if (!p.multi(1)>!p.multi(2)) gt 2 then fontsize = fontsize/2.
endelse

plot, [0., 1.], [0., 1.], position = positiont, $
	/nodata, /noerase, xstyle = 4, ystyle = 1+4
;axis, yaxis = 1, ystyle = 1, yrange = scale, ytype=logZ, ycharsize=fontsize, $
;	ytitle = title, ticklen = -0.02*0.78/0.04 ; adjust for narrow window

if (abs(!x.window(1)-!x.window(0))*!d.x_size le 2) then begin
  message, 'Colorbar too narrow', /info
  !x = xsave & !y = ysave & !z = zsave & !p = psave ; restore original settings
  return
endif
colorStep = ceil(float(ncolors)/(abs(!y.window(1)-!y.window(0))*!d.y_size)) > 1L
; could require 2 pixels per color; colorStep = colorStep * 2L
nSteps = fix(nColors / colorStep) < nColors
;if (!d.name eq 'PS') 
if (!d.flags and 1L) then begin ; has scalable pixels (Postscript)
  colorStep = 1L
  nSteps = nColors
endif
;print,'colorStep = ', colorStep, ' nSteps = ', nSteps

if keyword_set(reverse) then colors = reverse(colors)

for i = 0L, nSteps-1 do begin
  polyfill, [0.,1.,1.,0.], (i+[0.,0.,1.,1.])/nSteps, $
	color=colors(i*colorStep), noclip=0
endfor ; i
;for i = 0L, nColors-1, colorStep do begin
;  polyfill, [0.,1.,1.,0.], (i+[0.,0.,1.,1.])/nSteps, color=colors(i), noclip=0
;endfor ; i

; replot so the box gets put back over the filled area
plot, [0., 1.], [0., 1.], position = positiont, $
	/nodata, /noerase, xstyle = 4, ystyle = 1+4
; adjust for narrow window


  axis, yaxis = 1, ystyle = 1+4, yrange = scale, ytype=logZ, $
  ycharsize=fontsize,color=fcolor,ytickname=replicate(' ',30),ytick_get=yticks

if (keyword_set(IMAGE)) then begin ;adjust top axis label to be ">= number"
  ;get the tick labels for the color axis - this is a really klugy way
  ;to get the ytick labels back from idl.
;TJK 10/21/2005
; moved this above to get yticks for IMAGES AND other types of plots
;  axis, yaxis = 1, ystyle = 1+4, yrange = scale, ytype=logZ, $
;  ycharsize=fontsize,color=fcolor,ytickname=replicate(' ',30),ytick_get=yticks

  ydim = size(yticks)
  
  ;yticks = fix(yticks) ;convert to integers
  ;ychar_ticks = string(yticks)
  
  ; RCJ 12/11/00 replace 2 lines above with the following 'if' statement: 
  ; remove decimal if not needed:
  q=where(yticks-long(yticks) ne 0)
  if (q(0) eq -1) then begin
     yticks=long(yticks) ; turn them into integers
     ychar_ticks = string(yticks)
  endif else begin
     ; RCJ 06/23/2003 Originally we only had the 'f20.1' line, but for numbers
     ; of the order of 10^-4 we needed the 'e' format. This may/may not be
     ; the best setup, depending on tests.
     if (yticks[n_elements(yticks)-1]-yticks[0] le 1) then $
        ychar_ticks = string(yticks,format='(e20.1)') else $
        ychar_ticks = string(yticks,format='(f20.1)')
  endelse
  
  ychar_ticks = strtrim(ychar_ticks,2) ;trim off the blank spaced
   
  ychar_ticks(ydim(1)-1) = '>='+ychar_ticks(ydim(1)-1)
  axis, yaxis = 1, ystyle = 1, yrange = scale, ytype=logZ,ycharsize=fontsize,$
      color=fcolor,ytitle = title, ticklen = -0.02*0.78/0.04, $
      ytickname=ychar_ticks

endif else begin

; For yrange lt 9 the log axis shows too few labeled tick marks. 
; Force it to have 4 labeled tick marks by setting yticks=3.  RCJ 09/01
;TJK 10/24/2005 - change the logic to look at the number of 
; tick marks IDL has chosen based on the scale, vs. the range of the
; scale.  Otherwise, plots that have small scale, but need the regular
; log scaling don't come out right, e.g. timed_l1b_saber
;
;   if logZ and scale[1]-scale[0] lt 9 then begin   


    if (logZ and (n_elements(yticks) lt 3)) then begin
      print, 'DEBUG - Colorbar LogZ and demanding 3 ticks instead of IDL default of ',n_elements(yticks),' in this case'
;TJK 3/22/2006 - changed ystyle from 1 to 2 to let IDL choose more
;                reasonable log scale labels, vs. forcing the actual min/max
;      axis, yaxis = 1, ystyle = 1, ytype=logZ, ycharsize=fontsize, $
      axis, yaxis = 1, ystyle = 2, ytype=logZ, ycharsize=fontsize, $
         color=fcolor,ytitle = title, ticklen = -0.02*0.78/0.04,$
         yrange=scale 
;TJK 9/8/2006 removed yticks=3 - don't force the number of ticks either (caused IDL to select
;strange min/max numbers w/ small ranges, e.g. 0.025-2.1 

   endif else begin
      axis, yaxis = 1, ystyle = 1,  ytype=logZ, ycharsize=fontsize, $
         color=fcolor,ytitle = title, ticklen = -0.02*0.78/0.04,$
         yrange=scale 
   endelse
endelse

!x = xsave & !y = ysave & !z = zsave & !p = psave ; restore original settings
return
end ; colorbar
