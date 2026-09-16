pro plotLabel, title, yaxis=yaxis, xaxis=xaxis, color=color, font=font, $
        charsize=charsize, thickness=thickness
; Robert.M.Candey.1@gsfc.nasa.gov, 1995 June 21
; 1995 July 26, BC  changed font sizing

; print label on Y axis or X axis; use instead of ytitle to get control over
;       font, font size and color
; main problem is lack of knowledge of how big tick labels are
; title:                text to print as title of an axis (required)
; yaxis=yaxis:          0 for left Y axis, 1 for right (default=0)
; xaxis=xaxis:          0 for bottom X axis, 1 for top (default=none)
; color=color:          text character color index (default=!p.color)
; charsize=charsize:    text character size (default=1.0)
; font=font:            text character font (default=-1 for Hershey fonts)
; thickness=thickness:  text character thickness (default=1.0)

if n_elements(color) eq 0 then color = !p.color
if n_elements(font) eq 0 then font = !p.font

ticklength = 0.0
tickLabelsize = 1.0
if n_elements(charsize) eq 0 then begin
   charsize = 1.0
   if !p.charsize gt 0 then charsize = !p.charsize
   if !p.charsize gt 0 then tickLabelsize = !p.charsize
   if !p.ticklen lt 0 then tickLength = !p.ticklen
   if n_elements(xaxis) ne 0 then begin ; x axis label
      if !x.charsize gt 0 then charsize = !x.charsize * charSize
      if !x.charsize gt 0 then tickLabelsize = !x.charsize * tickLabelsize
      if !x.ticklen lt 0 then tickLength = !x.ticklen ; override p.ticklen
   endif else begin ; y axis label
      if !y.charsize gt 0 then charsize = !y.charsize * charSize
      if !y.charsize gt 0 then tickLabelsize = !y.charsize * tickLabelsize
      if !y.ticklen lt 0 then tickLength = !y.ticklen ; override p.ticklen
   endelse
endif
;if n_elements(charsize) eq 0 then charsize = 1.0

if n_elements(thickness) eq 0 then $
   if !p.charthick gt 0 then thickness = !p.charthick else thickness = 1.0

if n_elements(xaxis) ne 0 then begin ; xaxis label
   Xmid = (!x.window(1) - !x.window(0)) / 2. + !x.window(0)
   if xaxis eq 1 then begin ; top label
      ticklabelLen = 0.5 < (!y.omargin(1) + !y.margin(1)) ; characters
      maxTside = (1.0 - (!d.x_ch_size * charsize * 1.1)/!d.y_size) < 1.0
      Tside = (!y.window(1) + ticklength + $
        (!d.y_ch_size * tickLabelsize * tickLabelLen)/!d.y_size ) < maxTside
      xyouts, Xmid, Tside, title, alignment=0.5, charsize=charsize, $
        orientation=0, font=font, color=color, /normal
   endif else begin ; bottom label
      ticklabelLen = 2.5 < (!y.omargin(0) + !y.margin(0)) ; characters
      ;    minBside = ((!d.x_ch_size * charsize * 1.1)/!d.y_size) > 0.0
      minBside = 0.01
      Bside = (!y.window(0) - ticklength - $
        (!d.y_ch_size * tickLabelsize * tickLabelLen)/!d.y_size ) > minBside
      xyouts, Xmid, Bside, title, alignment=0.5, charsize=charsize, $
         orientation=0, font=font, color=color, /normal
   endelse
endif else begin ; yaxis label
   Ymid = (!y.window(1) - !y.window(0)) / 2. + !y.window(0)
   if n_elements(yaxis) ne 0 then if yaxis eq 1 then begin ; right label
      ticklabelLen = 1.5 < (!x.omargin(1) + !x.margin(1)) ; characters
      maxRside = (1.0 - (!d.y_ch_size * charsize * 1.1)/!d.x_size) < 1.0
      Rside = (!x.window(1) + ticklength + $
        (!d.x_ch_size * tickLabelsize * tickLabelLen)/!d.x_size ) < maxRside
      xyouts, Rside, Ymid, title, alignment=0.5, charsize=charsize, $
         orientation=90, font=font, color=color, /normal
      ;       orientation=270, font=font, color=color, /normal
   endif else begin ; left label
      ticklabelLen = 6.5 < (!x.omargin(0) + !x.margin(0)) ; characters
      minLside = ((!d.y_ch_size * charsize * 1.1)/!d.x_size) > 0.0
      Lside = (!x.window(0) - ticklength - $
         (!d.x_ch_size * tickLabelsize * tickLabelLen)/!d.x_size ) > minLside
      xyouts, Lside, Ymid, title, alignment=0.5, charsize=charsize, $
         orientation=90, font=font, color=color, /normal
   endelse
endelse

return
end ; plotlabel
