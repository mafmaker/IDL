pro mk_msg_base, xoff, yoff, group=group

common msg_out_block, base, msg_but, msg_text, last, max_l, start_over

device, get_screen=xx
base = widget_base(/col, xoff=xoff*xx(0), yoff=yoff*xx(1), title='Messages')
msg_but = widget_text(base, value=msg_text, ysize=max_l, xsize=60)
widget_control, base, /real

return 
end



pro msg_out, in_text, group=group, xoffset=xoffset, yoffset=yoffset, $
             max_lines=max_lines, kill=kill

; this routine opens up a widget for text display and writes lines of 
; text to it.  If the widget already exists, it adds new lines of text
;
; use as
;        msg_out, text
;        with text: a string or string array 
;
; keywords:
;        xoffset, yoffset: offset on the screen (in normal units) from
;                          top left
;        group: groupleader
;        max_lines: maximum number of lines to be displayed (default:20)
;                   this has only an effect on the first call
;        kill: kill the widget and reset everything

common msg_out_block, base, msg_but, msg_text, last, max_l, start_over

; set variables and defaults
if keyword_set(xoffset) then xoff = xoffset else xoff = 0.6
if keyword_set(yoffset) then yoff = yoffset else yoff = 0.5
if n_elements(start_over) le 0 then start_over = 1
if start_over eq 1 then begin
   if keyword_set(max_lines) then max_l = max_lines else max_l = 20 
   msg_text = strarr(max_l)
   last = 0
   start_over = 0
   mk_msg_base, xoff, yoff, group=group
endif

; reset everything
if keyword_set(kill) then begin
   widget_control, base, /destroy
   start_over = 1
   return
endif

; how many lines do we need to add?  (keep the text in a local array)
if n_elements(in_text) gt max_l $
     then text = in_text(n_elements(in_text)-max_l:n_elements(in_text)-1) $
     else text = in_text
newlines = n_elements(text)

; is the window already full?  If so shift enough lines out
; of the array to make room for the new text
; add the new lines of test to the end of the array
if last+newlines le max_l-1 then begin
   msg_text(last:last+newlines-1) = text
   last = last+newlines
endif else begin
   mvlines = newlines - (max_l-last)
   msg_text(0:max_l-mvlines-1) =  msg_text(mvlines:max_l-1)
   msg_text(max_l-newlines:max_l-1) = text
   last = max_l
endelse

; display the updated array
widget_control, msg_but, set_value=msg_text

return
end
