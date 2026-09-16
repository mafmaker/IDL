
function get_mydatasize, a, var

; Determine the variable number
s = size(var) & ns = n_elements(s) & atags = tag_names(a)
if s(ns-2) eq 7 then begin
  w = where(atags eq var,wc)
  if wc gt 0 then vnum = w(0) $
  else begin
    print,'ERROR>get_mydata:named variable not in structure!' & return,-1
  endelse
endif else vnum = var

; Retrieve the idl sizing information for the variable
vtags = tag_names(a.(vnum))
ti = tagindex('HANDLE',vtags) ; search for handle tag
if ti ne -1 then begin
  ti = tagindex('IDLSIZE',vtags) ; search for idlsize tag
  if ti ne -1 then isize = a.(vnum).IDLSIZE $
  else begin ; must retrieve data to get the size
    handle_value,a.(vnum).handle,d & isize = size(d)
  endelse
endif else begin ; search for dat tag
  ti = tagindex('DAT',vtags)
  if ti ne -1 then isize = size(a.(vnum).dat) $
  else begin
    print,'ERROR>get_mydata:variable has neither HANDLE nor DAT tag!'
    return,-1
  endelse
endelse

return, isize
end

;-----------------------------------------------------------------------------

pro cdfx_pre_xinteranimate_Event,event

common cdfxcom, CDFxwindows, CDFxprefs ; include cdfx common

wtype = widget_info(event.id, /type)
widget_control, event.top, get_uvalue=info

case wtype of
  1 : begin ; button event
      case event.id of
        info.proceed : begin
            widget_control, info.xwid, get_value=width
            widget_control, info.ywid, get_value=height
            width  = long(width)  & width  = width(0)
            height = long(height) & height = height(0)

            ; determine the name of the selected variable
            s = str_sep(info.vnames(info.vindex),':')
            for i=0,n_elements(s)-1 do s(i)=strtrim(s(i),2)
            w = where(cdfxwindows.title eq s(0),wc)

            if wc eq 0 then begin
              ok = dialog_message(/error, 'Data Object does not exist!')
              return
            endif else begin
              widget_control, cdfxwindows.wid(w(0)), get_uvalue=a
              widget_control, /hourglass

              ; extract the validmin and validmax values
              vnum = tagindex(s(1),tag_names(a))
              b = tagindex('VALIDMIN',tag_names(a.(vnum)))
              if (b(0) ne -1) then begin & c=size(a.(vnum).VALIDMIN)
                if (c(0) eq 0) then zvmin = a.(vnum).VALIDMIN $
                else begin
                  zvmin = 0 ; default for image data
                  print,'WARNING>Unable to determine validmin for ',s(1)
                endelse
              endif
              b = tagindex('VALIDMAX',tag_names(a.(vnum)))
              if (b(0) ne -1) then begin & c=size(a.(vnum).VALIDMAX)
                if (c(0) eq 0) then zvmax = a.(vnum).VALIDMAX $
                else begin
                  zvmax = 2000 ; guestimate
                  print,'WARNING>Unable to determine validmax for ',s(1)
                endelse
              endif

              print,'Retrieving the image data...'
              d = get_mydata(a,s(1)) ; extract the data from the structure

              ; Perform any requested data manipulations
              widget_control, info.valids, get_value=onoff
              if onoff eq 0 then begin
                print,'Performing validmin/max filtering...'
                w = where(((d lt zvmin)OR(d gt zvmax)),wc)
                if wc gt 0 then begin
                  print,'WARNING>filtering bad values from image data...'
                  d(w) = 0 & w = 0 ; set pixels to black and free space
                endif
              endif

              widget_control, info.noise, get_value=onoff
              if onoff eq 0 then begin
                print,'Performing noise reduction...'
                semiMinMax, d, zvmin, zvmax
                w = where(((d lt zvmin)OR(d gt zvmax)),wc)
                if wc gt 0 then begin
                  print,'WARNING>filtering values > 3-sigma from image data...'
                  d(w) = 0 & w = 0 ; set pixels to black and free space
                endif
              endif

              ;widget_control, info.maxcolor, get_value=onoff
              ;if onoff eq 0 then begin
                print,'Performing color enhancement...'
                d = bytscl(d,max=max(d),min=min(d),top=!d.n_colors-1)
              ;endif

              s = size(d) ; get the idl sizing info
              if width ne s(1)  or  height ne s(2) then begin
                print,'Resizing the image data...'
                d = congrid(d,width,height,s(3))
              endif

              widget_control, info.edges, get_value=onoff
              if onoff eq 0 then begin
                print,'Performing edge enhancement...'
                s = size(d)
                for i=0,s(3)-1 do d(*,*,i) = roberts(temporary(d(*,*,i)))
              endif

              ; Show the animation
              print,'Loading image data into animation frames...'
              xinteranimate, set=[width,height,s(3)]
              for i=0,s(3)-1 do $
                xinteranimate, frame=i, image=d(*,*,i)
              d = 0 ; delete the data now that it has been loaded
              xinteranimate, GROUP=info.group
              ; remove the current starter widget
              remove_cdfxwindow, WID=event.top
              widget_control, event.top, /destroy
            endelse
            end
        info.cancel  : begin
                       remove_cdfxwindow,WID=event.top
                       widget_control,event.top,/destroy
                       end
        info.help    : print,'not yet helping'
        else         : begin
                       print,'ERROR>cdfx_animator:unknown button event!'
                       ;stop
                       end
      endcase
      end
  3 : print,'nothing to do for text'
  6 : begin ; list widget
      ; Get the idl size information for the selected variable
      s = str_sep(info.vnames(event.index),':') ; get object name and varname
      for i=0,n_elements(s)-1 do s(i)=strtrim(s(i),2) ; trim blanks
      w = where(cdfxwindows.title eq s(0),wc)
      if wc eq 0 then begin
        print,'ERROR>Data Object containing variable does not exist!' & return
      endif else begin
        widget_control,cdfxwindows.wid(w(0)),get_uvalue=a
        isize = get_mydatasize(a,s(1)) ; get idl sizing information
        widget_control, info.xwid, set_value=string(isize(1))
        widget_control, info.ywid, set_value=string(isize(2))
        widget_control, info.xwid, sensitive=1
        widget_control, info.ywid, sensitive=1
      endelse

      info.vindex = event.index
      widget_control,info.proceed,sensitive=1
      widget_control,event.top,set_uvalue=info
      end

   else : x=0 ; do nothing
endcase

end

;-----------------------------------------------------------------------------

pro cdfx_pre_xinteranimate, GROUP=GROUP

common cdfxcom, CDFxwindows, CDFxprefs ; include cdfx common

if xregistered('ImageAnimator') then begin
  print,'WARNING:Only 1 Image Animator setup allowed at a time.' & return
endif

; Assemble a list of variables which can be displayed via xinteranimate
numvars = 0L ; initialize
w = where(strpos(cdfxwindows.title,'Data Object') ne -1,wc)

for i=0,wc-1 do begin ; examine every data object
  widget_control,cdfxwindows.wid(w(i)),get_uvalue=a
  vnames = tag_names(a) & nvnames = n_elements(vnames)
  for j=0,nvnames-1 do begin ; examine each variable
    ; Retrieve the sizing information for the variable
    isize = get_mydatasize(a,j)
    if isize(0) eq 3 then begin ; data dimensionality ok for xinteranimate
      s = cdfxwindows.title(w(i)) + ' : ' + vnames(j)
      if numvars eq 0 then text = s else text = [text,s]
      numvars = numvars + 1 ; increment variable counter
    endif
  endfor
endfor

; If no variables can be displayed via xinteranimate inform user and exit
if numvars eq 0 then begin
  ok = dialog_message(/error, [$
    'No Data Objects contain variables ',$
    'which can be displayed via xinteranimate.',$
    'Click OK to continue.'])
  return
endif

; Construct a widget interface
base1 = widget_base(/Column,Title='Image Animation')
lab1a = widget_label(base1,value='Select variable to display')
list1 = widget_list(base1,/frame,value=text,ysize=5)
lab1b = widget_label(base1,value='Display sizing:')
base2 = widget_base(base1,Row=2)
lab2x = widget_label(base2,value='Image Width  ')
txt2x = widget_text(base2,value= ' 100',/editable)
lab2y = widget_label(base2,value='Image Height ')
txt2y = widget_text(base2,value= ' 100',/editable)
base3 = widget_base(base1,/Column,/frame)
lab3a = widget_label(base3,value='Data Manipulation Options')
but3a = CW_BGROUP(base3,['On','Off'],label_left='Valid min/max filter:',$
                  /row,/exclusive,set_value=0)
but3b = CW_BGROUP(base3,['On','Off'],label_left='Noise Reduction     :',$
                  /row,/exclusive,set_value=1)
;but3c = CW_BGROUP(base3,['On','Off'],label_left='Color Enhancement   :',$
;                  /row,/exclusive,set_value=1)
but3d = CW_BGROUP(base3,['On','Off'],label_left='Edge Enhancement    :',$
                  /row,/exclusive,set_value=1)
base4 = widget_base(base1,/Row,/frame)
but4a = widget_button(base4,value='PROCEED')
but4b = widget_button(base4,value='Cancel')
but4c = widget_button(base4,value='Help')

; desensitize some widgets at start
widget_control,but4a,sensitive=0
widget_control,txt2x,sensitive=0
widget_control,txt2y,sensitive=0

; assemble structure of needed information and save in top uvalue
info = {vnames:text,vindex:-1L,xwid:txt2x,ywid:txt2y,$
        valids:but3a,noise:but3b, $
        ;maxcolor:but3c, $
        edges:but3d,$
        proceed:but4a,cancel:but4b,help:but4c,group:GROUP}

; Register this window into the common block
add_cdfxwindow, 'Image Animation', base1

; Realize the widget
widget_control, base1, set_uvalue=info
widget_control, base1, /realize
Xmanager,'ImageAnimator',base1,Event='cdfx_pre_xinteranimate_Event',$
         GROUP=GROUP,Cleanup='cdfx_cleanup_and_remove'

; If only a single variable exists, then set automatically select it
widget_control, list1, set_list_select=0
e = {ID:list1, TOP:base1, HANDLER:base1, INDEX:0L, CLICKS:1L}
widget_control, list1, send_event=e

end

;-----------------------------------------------------------------------------
