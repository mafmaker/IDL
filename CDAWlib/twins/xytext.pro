pro Xytext, x, y, atext, _extra=extra, spacing=spacing,  $
            charsize=charsize, data=data, normal=normal, device=device
;; spacing positive: write lines upward. negative: write lines
;; downward.
common xytext_com, yline, xpos
if n_params() eq 1 then begin
    ;; continue from last position
    atext = x
endif else begin
    pos = convert_coord(x, y, data=data, normal=normal, device=$
                        device, /to_device) 
    yline = pos(1)
    xpos = pos(0)
endelse

text = string(atext)
if not keyword_set(spacing) then spacing = -1.5
if not keyword_set(charsize) then charsize = !p.charsize
if charsize ne 0 then spacing = charsize*spacing
line_height = spacing*!D.y_ch_size

for i = 0, n_elements(text)-1 do begin
    btext = byte(text(i)+string(10b))
    lines = [-1, where(btext eq 10B)]
    nl = n_elements(lines)-1
    for n = 0, nl-1 do begin
        ;; A nonempty line
        xyouts, xpos, yline,  $
          string(btext(lines(n)+1:lines(n+1))),  $
          _extra=extra, /device, charsize=charsize
        yline = yline+line_height
    endfor
endfor
return
end
