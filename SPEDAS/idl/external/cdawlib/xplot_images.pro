FUNCTION xanalyze_image,a,vname
i = get_mydata(a,vname) & isize = size(i)
window,/free,xsize=isize(1),ysize=isize(2)
wset,!d.window
tv,i
return,0
end

PRO cdfx_Xplotimages_Event,event
tnames = tag_names(event)
if tnames(3) eq 'VALUE' then begin ; process button/pulldown event
  case event.value of
    'Operations>.Analyze Selected Frame' : begin
      widget_control,/hourglass
      widget_control,event.top,get_uvalue=info ; retrieve widget info
      widget_control,info.draw,get_uvalue=s    ; retrieve display layout info
      if info.frame ne -1 then begin
        frametime = s.tdat(info.frame)         ; determine time of frame
        widget_control,info.base1,get_uvalue=a ; retrieve data structure
        b = timeslice_mystruct(a,frametime,frametime) ; subset the structure
        status = xanalyze_image(b,info.vname)
      endif
      end
    'Operations>.Annotate Thumbnail Plot' : begin
      widget_control,event.top,get_uvalue=info
      widget_control,/hourglass
      annotate
      end
  else : print,'Unknown value for xplot_images button!'
  endcase
endif
if tnames(3) eq 'TYPE' then begin ; process draw event
  if event.type eq 1 then  begin  ; user has clicked in the drawing
    widget_control,event.top,get_uvalue=info ; retrieve widget info
    widget_control,info.draw,get_uvalue=s    ; retrieve display layout info
    icol = fix(event.x / s.tsizes(0))        ; compute column number
    if icol le s.ncols then begin            ; user has clicked within images
      irow = fix((s.ysize-event.y) / (s.tsizes(1)+s.timetag_height))
      if irow le s.nrows then begin          ; user has clicked within images
        frame = (irow*s.ncols)+icol          ; compute frame number
        if frame le s.nimages-1 then begin   ; valid frame number computed
          widget_control,info.lab1b,set_value=strtrim(string(frame),2)
          info.previousframe = info.frame & info.frame=frame
          widget_control,event.top,set_uvalue=info
        endif
      endif
    endif
  endif
endif
end

PRO cdfx_Xplotimages_CBox,wid
  print,'CBox closing does nothing yet'
end


FUNCTION xplot_images, a,vname,$
                       THUMBSIZE=THUMBSIZE,TSTART=TSTART,TSTOP=TSTOP,$
                       XSIZE=XSIZE,NONOISE=NONOISE,COLORBAR=COLORBAR,$
                       DEBUG=DEBUG

; Evaluate the input structure and determine the plotting space required
s = evaluate_image_struct(a,vname,THUMBSIZE=THUMBSIZE,TSTART=TSTART,$
                          TSTOP=TSTOP,XSIZE=XSIZE,COLORBAR=COLORBAR)
i = size(s) & if i(n_elements(i)-2) ne 8 then return,-1
if keyword_set(DEBUG) then help,/struct,s
tn = tag_names(a.(s.vnum))


; Determine the titles for the window and colorbar
w = where(tn eq 'SOURCE_NAME',wc)
if wc ne 0 then wtitle = a.(s.vnum).SOURCE_NAME else wtitle = ''
w = where(tn eq 'DESCRIPTOR',wc)
if wc ne 0 then wtitle = wtitle + '  ' + a.(s.vnum).DESCRIPTOR
w = where(tn eq 'UNITS',wc)
if wc ne 0 then ctitle = a.(s.vnum).UNITS else ctitle = ''


; Retrieve the image data and time data from the structure for manipulation
w = where(tn eq 'DAT',wc)
if wc ne 0 then idat = a.(s.vnum).DAT else handle_value,a.(s.vnum).HANDLE,idat
w = where(tag_names(a.(s.tnum)) eq 'DAT',wc)
if wc ne 0 then tdat = a.(s.tnum).DAT else handle_value,a.(s.tnum).HANDLE,tdat

; Perform time filtering if required
if ((s.firstframe ne 0)or(s.lastframe ne s.nimages)) then begin
  idat = idat(*,*,s.firstframe:s.lastframe-1)
  tdat = tdat(s.firstframe:s.lastframe-1)
endif

; Determine validmin and validmax values
vmin = 0 & vmax = 10000 ; defaults
w = where(tn eq 'VALIDMIN',wc)
if wc ne 0 then begin & i = size(a.(s.vnum).VALIDMIN)
  if i(0) eq 0 then vmin = a.(s.vnum).VALIDMIN
endif
w = where(tn eq 'VALIDMAX',wc)
if wc ne 0 then begin & i = size(a.(s.vnum).VALIDMAX)
  if i(0) eq 0 then vmax = a.(s.vnum).VALIDMAX
endif

; Perform data validmin/max filtering to maximize color spread
w = where(idat lt vmin,wc) & if wc gt 0 then idat(w) = 0       ; 'black'
w = where(idat gt vmax,wc) & if wc gt 0 then idat(w) = vmax-1  ; 'red'

; Rebin the data to the thumbnail size
if s.nimages eq 1 then idat = congrid(idat,s.tsizes(0),s.tsizes(1)) $
else idat = congrid(idat,s.tsizes(0),s.tsizes(1),s.nimages)

; Filter data values outside 3-sigma for better color spread
if keyword_set(NONOISE) then begin
  ;semiminmax,idat,smin,smax
  ; RCJ 05/05/2006  Replaced call to semiminmax w/ call to three_sigma
  sigminmax=three_sigma(idat)
  smin=sigminmax.(0)
  smax=sigminmax.(1)
  w = where(idat lt smin,wc) & if wc gt 0 then idat(w) = smin   ; 'black'
  w = where(idat gt smax,wc) & if wc gt 0 then idat(w) = smax-1 ; 'red'
endif

; Bytescale to maximize the color spread
idmax = max(idat) & idmin = min(idat)
idat  = bytscl(idat,min=idmin,max=idmax,top=!d.n_colors-8)

; Generate the Widget display
base = widget_base(title=wtitle,/column)
draw = widget_draw(base,xsize=s.xsize,ysize=s.ysize,/frame,retain=2,uvalue=s,$
                   x_scroll_size=512,y_scroll_size=512,/button_events)
base1= widget_base(base,/row,/frame,uvalue=a)
lab1a= widget_label(base1,value='Selected Frame= ')
lab1b= widget_label(base1,value='-1')
junk1=  {CW_PDMENU_S,flags:0,name:''}
puld1= [{CW_PDMENU_S,1,'Operations>'},$
        {CW_PDMENU_S,0,'Analyze Selected Frame'},$
        {CW_PDMENU_S,2,'Annotate Thumbnail Plot'}]
but1a=   CW_PDMENU(base1,puld1,/return_full_name)
info = {vname:vname,draw:draw,base1:base1,$
        lab1b:lab1b,frame:-1,previousframe:-1}
widget_control,base,set_uvalue=info
widget_control,base,/realize
widget_control,draw,get_value=windowid


; Draw the plot in the newly created draw widget
wset,windowid & irow=0 & icol=0
xpos = 0 & ypos = s.ysize - s.title_height - s.tsizes(1)
if keyword_set(COLORBAR) then begin
  !x.margin = 14 & plot,[0,1],[0,1],/noerase,/nodata,xstyle=4,ystyle=4
endif
for j=0,s.nimages-1 do begin
  tv,idat(*,*,j),xpos,ypos,/device
  tdate = decode_cdfepoch(tdat(j))
  shortdate = strmid(tdate,10,strlen(tdate))
  xyouts,xpos,ypos-s.timetag_height+1,shortdate,color=!d.n_colors-1,/device
  ; recompute positions for next thumbnail
  xpos = xpos + s.tsizes(0) & icol = icol + 1  
  if icol eq s.ncols then begin
    icol=0 & xpos=0 & ypos = ypos - (s.tsizes(1) + s.timetag_height)
  endif
endfor


; Draw the colorbar if requested
if keyword_set(COLORBAR) then begin
  if n_elements(cCharSize) eq 0 then cCharSize=0
  cscale = [idmin,idmax] & xwindow= !x.window & offset = 0.01
  colorbar,cscale,ctitle,logZ=0,cCharSize=cCharSize,$
           position=[!x.window(1)+offset,     !y.window(0),$
                     !x.window(1)+offset+0.03,!y.window(1)],$
           fcolor=244,/image
  !x.window=xwindow
endif ; colorbar

; Start the Xmanager
Xmanager,'Xplotimages',base,Event='cdfx_Xplotimages_Event',$
         Cleanup='cdfx_Xplotimages_CBox'

return,0
end


