pro cbar,position,min_c,max_c,annotation,charsize,horiz=horiz,$
	numticks=numticks,noanno=noanno,swap=swap, color_ = color_,log=log
;
;  Sick to death of searching for this color bar and
;  pasting it into any code that needs it and missing
;  arrayx and then creating an array 16777216 elements long
;  et cetera.
;
;  Author: Thomas Immel
;  Date: 8-3-99
;  But now I am completely sick of trying to adjust the size of the
;  characters on the y axis of the axis I am adding to the color table
;  This is stupid!!@!
; --- version history
;     1.01 release
;     1.02 strcompress if horiz
;     1.03 xcharsize
;     1.04 numbers> 1000 in labels, numticks keyword
;     1.05 abs(numbers) lt 10e-3
;     1.06 NUMTICKS implemented
;     1.07 small ranges (eg -0.1,0,1) covered
;     1.08 no annotation keyword added               4-20-2000
;     1.09 swap keyword to label opposite side of cbar
;     1.10 add color keyword
;     1.11 add log keyword  - does not work yet. 
;     1.12 bugfix? reverse ticknames for horizontal bar  ---
print,'cbar - version 1.12'

xlog=0 & ylog=0
if keyword_set(log) gt 0 then begin & xlog=1 & ylog=1 & endif

if strupcase(!d.name) eq 'X' or strupcase(!d.name) eq 'Z' then $
  color = 255 else color = 0
if keyword_set(color_) gt 0 then color = color_



if keyword_set(horiz) eq 1 then horiz_flag = 1 else horiz_flag = 0 

        num_colors=!d.n_colors
        xaxisb=findgen(19)
        yaxisb=findgen(num_colors < 256)
        xbar=intarr(19)
        xbar(*)=1
        ybar=findgen(num_colors < 256)
        bar=xbar#ybar
        if !p.font eq -1 then $
        gtoreq='!9b!5' else $
        gtoreq='!9' + string(179b)+ '!X'
        old_pos=!p.position
        !p.position=position
       
        if horiz_flag eq 1 then begin
          bar=rotate(bar,3)
          xaxisb=yaxisb
          yaxisb=findgen(19)
        endif

        oplotscl,bar,255,0,xaxisb,yaxisb,' ', ' ',' '

stlab=[' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ']
blanks=stlab

;  yticklabr=[ '  -60','  -48','  -36','  -24','  -12','     0','   12',$
;        '   24','   36','   48',' !d !n'+ gtoreq+  '60']

;----------NEW YTICKLAB NEEDED-----------------------------------------
LABARY=FLTARR(11)
;FOR I=0,10 DO BEGIN
;  LABARY(I)= I/10. * (MAx_c-min_c) + min_c
;ENDFOR

tickstodo=11
if keyword_set(numticks) eq 1 then tickstodo=numticks


;if max_c lt 1000 and max_c gt 1e-3 then begin

if max_c lt 1000 and max_c gt 10 then begin	;1000-1

      print,'labels for max counts under 1000 and over 1' 

  labary=findgen(tickstodo)/(tickstodo-1)  *(MAx_c-min_c) + min_c 
  INTLAB=FIX(LABARY)
  STLAB=STRING(INTLAB)
  FOR I=0,tickstodo-1 DO BEGIN
    STLAB(I)=STLAB(I) + '  '
  ENDFOR
  STLAB(tickstodo-1)=STRCOMPRESS(gtoreq+STLAB(tickstodo-1),/REMOVE_ALL) + '  '

endif else begin			;infinity-1000...1-negative infinity

  if max_c le 10 and max_c gt 0.01 then begin	;decimal notation
						;1-0.01

    if keyword_set(numticks) ne 0 then tickstodo=numticks else tickstodo=7
    spacer=intarr(tickstodo)
    if max_c le 1e-3 then spacer(*)=1 else spacer(*)=0	
						;for really small #s
  

    labary=findgen(tickstodo)/(tickstodo-1) *(MAx_c-min_c) + min_c 
    morespace=where(labary lt 0,spacecount)
    print,spacer,morespace
    if spacecount ne 0 then spacer(morespace)=spacer(morespace)+1
    print,spacer,'spacer',spacecount
    print,labary

;stop

    stlab=strcompress(labary,/rem)
    for i=0,tickstodo-1 do begin
	stlab(i)=strmid(stlab(i),0,3+spacer(i)) 
			;make e+00 notation fit
			;spacer takes into account minus signs
    endfor

    print,'decimal'
    print,stlab

    stlab=stlab+'  '
    STLAB(tickstodo-1)=STRCOMPRESS(gtoreq+STLAB(tickstodo-1),/REMOVE_ALL) + '  '

  endif else begin		;scientific notation only
				;infinity to 1000 ... 
				;0.01 to negative infinity

    if max_c lt 1e3 then begin	; do 0.01 to negative infinity
      print,'labels for max counts under 1000' 
      if keyword_set(numticks) ne 0 then tickstodo=numticks else tickstodo=7
      spacer=intarr(tickstodo)
      if max_c le 1e-3 then spacer(*)=1 else spacer(*)=0	
						;for really small #s
      labary=findgen(tickstodo)/(tickstodo-1) *(MAx_c-min_c) + min_c 

      stlab=strcompress(labary)
      for i=0,numticks-1 do begin
	  stlab(i)=strmid(stlab(i),0,4+spacer(i))+ $
		  strmid(stlab(i),9,4+spacer(i))
			  ;make e+00 notation fit
			  ;spacer takes into account minus signs
      endfor
      print,stlab
      stlab=stlab+'  '
      STLAB(tickstodo-1)=STRCOMPRESS(gtoreq+STLAB(tickstodo-1),/REMOVE_ALL) + '  '
    endif else begin	; to infinity to 1000
      print,'labels for max counts over 1000' 
     
      if keyword_set(numticks) ne 0 then tickstodo=numticks else tickstodo=7
      spacer=intarr(tickstodo)
;      if max_c le 1e-3 then spacer(*)=1 else spacer(*)=0	
						;for really small #s
      labary=findgen(tickstodo)/(tickstodo-1) *(MAx_c-min_c) + min_c 

      stlab=strcompress(long(labary))
;      for i=0,numticks-1 do begin
;	  stlab(i)=
		  ;strmid(stlab(i),0,4+spacer(i))+ $
		  ;strmid(stlab(i),9,4+spacer(i))
	          ;make e+00 notation fit
		  ;spacer takes into account minus signs
;      endfor
      print,stlab
      stlab=stlab+'  '
      STLAB(tickstodo-1)=STRCOMPRESS(gtoreq+STLAB(tickstodo-1),/REMOVE_ALL) + '  '
;      print,'These ticks are not being done right!'
;      stop
    endelse
  endelse

endelse

if horiz_flag eq 1 then stlab=strcompress(stlab,/rem)

;print,labary
;print,stlab

if keyword_set(noanno) then stlab(*)=' '		;blow it all away!!!

;--------------------GOOD!!!-----------------------------------------------

if horiz_flag eq 0 then begin
  yticks=tickstodo-1 & xticks = 1
  ytitle=annotation & xtitle=' '
  ytickname=stlab & xtickname=blanks
  if keyword_set(swap) then ytickname=strcompress(ytickname,/rem)
  yticklen=0.04 & xticklen=0.000000001

endif else begin
  xticks=tickstodo-1 & yticks = 1
  xtitle=annotation & ytitle=' '
;  xtickname=reverse(stlab) & ytickname=blanks
  xtickname=stlab & ytickname=blanks
  if keyword_set(swap) then xtickname=strcompress(xtickname,/rem)
  xticklen=0.04 & yticklen=0.000000001
endelse

;oldsize=!y.charsize
;!y.charsize=4

yaxis=1
xaxis=1

if keyword_set(swap) eq 1 then begin
  yaxis=0
  xaxis=0
endif

  axis,yaxis=yaxis,yticks=yticks,yminor=0,yrange=[-60,60],$
     ytickname=blanks,/ystyle,ycharsize=charsize*1.1, color = color,ylog=ylog
  axis,yaxis=abs(yaxis-1),yticks=yticks,yminor=0,yrange=[-60,60],$
     ytickname=ytickname,/ystyle,ycharsize=charsize*1.1,ytitle=ytitle, $
    color = color,ylog=ylog
  axis,xaxis=abs(xaxis-1),xticks=xticks,xminor=0,xticklen=xticklen,$
     xtickname=xtickname,/xstyle,xtitle=xtitle,xcharsize=charsize, $
    color = color,xlog=xlog
  axis,xaxis=xaxis,xticks=1,xminor=0,xticklen=xticklen,xtickname=blanks,$
	/xstyle,xcharsize=charsize, color = color,xlog=xlog
 
  xsize=!p.position(2)-!p.position(0)
  ysize=!p.position(3)-!p.position(1)
;  xyouts,!p.position(2)-xsize*1.1,!p.position(3)+ysize/30.,'PD (%)',/norm,$
;	charsize=charsize

;!y.charsize=oldsize


!p.position=old_pos


return
end





