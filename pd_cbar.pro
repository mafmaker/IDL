pro pd_cbar,position,charsize
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

print,'pd_cbar - version 1.01'



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
        oplotscl,bar,255,0,xaxisb,yaxisb,' ', ' ',' '

stlab=[' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ']


  yticklabr=[ '  -60','  -48','  -36','  -24','  -12','     0','   12',$
        '   24','   36','   48',' !d !n'+ gtoreq+  '60']

;oldsize=!y.charsize
;!y.charsize=4

  axis,yaxis=1,yticks=10,yminor=0,yrange=[-60,60],$
     ytickname=yticklabr,/ystyle,ycharsize=charsize*1.1
  axis,yaxis=0,yticks=10,yminor=0,yrange=[-60,60],$
     ytickname=STLAB,/ystyle,ycharsize=charsize*1.1
  axis,xaxis=0,xticks=1,xminor=0,xticklen=0.000000001,xtickname=stlab,/xstyle
  axis,xaxis=1,xticks=1,xminor=0,xticklen=0.000000001,xtickname=stlab,/xstyle
 
  xsize=!p.position(2)-!p.position(0)
  ysize=!p.position(3)-!p.position(1)
  xyouts,!p.position(2)-xsize*1.1,!p.position(3)+ysize/30.,'PD (%)',/norm,$
	charsize=charsize

;!y.charsize=oldsize


!p.position=old_pos


return
end





