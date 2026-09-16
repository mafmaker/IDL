
pro cdfx_editvattrs_Event, event

wtype = widget_info(event.id,/NAME) ; get name of widget type

case wtype of
  'BUTTON': begin
            widget_control,event.id,get_value=bname
            case bname of
              'Edit'   : begin
                         child = widget_info(event.top,/child)
                         widget_control,child,get_uvalue=junk
                         widget_control,event.top,get_uvalue=a
                         widget_control,/hourglass
                         ti = tagindex(junk.vname,tag_names(a))
                         vi = junk.first_vattr + junk.list
                         b = a.(ti).(vi) & c=b
                         xvaredit,b
                         ; determine if attr value has been changed
                         nb = n_elements(b) & new = 0
                         if nb eq 1 then begin
                           if b ne c then new = 1
                         endif else begin
                           for i=0,nb-1 do if b(i) ne c(i) then new = 1
                         endelse
                         ; if attr has changed then process the new attribute
                         if new eq 1 then begin
                           a.(ti).(vi) = b
                           ; regenerate the list of attributes
                           vtags = tag_names(a.(ti)) & text = ''
                           for i=0,n_elements(vtags)-1 do begin
;TJK 12/7/2006 - replace call to gethelp w/ call to help
;because gethelp is obsolete and it doesn't support dcomplex datatype
;                             b = a.(ti).(i) & h = gethelp('b')
                             b = a.(ti).(i) & help, b, output=h
                             strput,h,vtags(i),0 & text = [text,h]
                           endfor
                           text=text((junk.first_vattr+1):(n_elements(vtags)-2))
                           widget_control,event.top,set_uvalue=a
                           widget_control,junk.listwid,set_value=text
                           widget_control,junk.cbut,sensitive=1
                           widget_control,junk.sbut,sensitive=1
                         endif
                         end
              'Cancel' : widget_control,event.top,/destroy
              'Save'   : begin
                         child = widget_info(event.top,/child)
                         widget_control,child,get_uvalue=junk
                         widget_control,event.top,get_uvalue=a
                         widget_control,junk.objectwid,set_uvalue=a
                         widget_control,event.top,/destroy
                         end
              'Help'   : print,'helping is TBD'
              else     : print,'ERROR>editvattrs: unknown button name!'
            endcase
            end
  'LIST'  : begin
            child = widget_info(event.top,/child)
            widget_control,child,get_uvalue=junk
            junk.list = event.index ; save current attribute index
            widget_control,junk.ebut,sensitive=1 ; sensitize edit button
            widget_control,child,set_uvalue=junk
            end
  else    : print,'ERROR>cdfx_editvattrs: unknown event type!'
endcase
end

;-----------------------------------------------------------------------------
; Display all variable attributes for the given variable in the given struct.
; Allow the user to modify the values of these attributes.

pro cdfx_editvattrs, a, vname, GROUP=GROUP

common cdfxcom, CDFxwindows, CDFxprefs ; include cdfx common

; Validate the input parameters
; Validation TBD

; Initialize
text1 = '' & text2 = ''

; Locate the variable given by 'vname' in the structure 'a'
atags = tag_names(a) & natags = n_elements(atags) & v = tagindex(vname,atags)
if (v eq -1) then begin
  ok = dialog_message(/error, $
    'editvattrs:named variable not in input structure')
  return
endif else vtags = tag_names(a.(v))

; Retrieve the data and determine its idl size information
ti = tagindex('HANDLE',vtags)
if (ti ne -1) then $
  handle_value, a.(v).HANDLE, d $
else begin
  ti = tagindex('DAT',vtags)
  if (ti ne -1) then d = a.(v).DAT $
  else begin
    ok = dialog_message(/error, $
      'editvattrs:variable has no .DAT or .HANDLE tag!')
    return
  endelse
endelse
ds = size(d) & nds = n_elements(ds)


; Capture type and dimensionality information
;TJK 12/7/2006, gethelp routine is obsolete AND it doesn't support
;the dcomplex data type, so replace gethelp call w/ one to help
;same fix throughout this file...
;h = gethelp('d') & h = strtrim(strmid(h(0),1,strlen(h(0))-1),2)

help, d, output=h & h = strtrim(strmid(h(0),1,strlen(h(0))-1),2)
s = str_sep(h(0),'=') & text1 = 'Variable name : ' + a.(v).VARNAME
text1 = [text1,('Variable type : ' + strtrim(s(0),2))]
text1 = [text1,('Dimensionality: ' + strtrim(s(1),2))]
d = 0L ; delete the data to same memory

; Construct another text array about the variable attributes
for i=0,n_elements(vtags)-1 do begin
;  b = a.(v).(i) & h = gethelp('b')
  b = a.(v).(i) & help, b, output=h 
  strput,h,vtags(i),0 & text2 = [text2,h]
endfor

; Slice out the variable attributes out of the text string array
fi = tagindex('FIELDNAM',vtags)
if (fi eq -1) then begin
  ok = dialog_message(/error, 'editvattrs:missing required vattr:FIELDNAM.')
  return
endif else text2 = text2((fi+1):(n_elements(vtags)-2))

; list width and height needed for good layout
twidth = max(strlen(text1)) & theight = n_elements(text1)
lwidth = max(strlen(text2)) & lheight = n_elements(text2)
if lheight gt 25 then lheight = 25
if lwidth  gt 80 then lwidth  = 80

; Create a widget to display the information
base  = widget_base(/Column,Title=('Variable Attributes: '+vname),$
                    /frame,uvalue=a)
base1 = widget_base(base,/Column)
base2 = widget_base(base,/Column)
base3 = widget_base(base,/Row,/frame)
text1 = widget_text(base1,value=text1,ysize=theight,xsize=twidth)
list2 = widget_list(base2,value=text2,ysize=lheight,xsize=lwidth,/frame)
but3a = widget_button(base3,value='Edit')
but3b = widget_button(base3,value='Cancel')
but3c = widget_button(base3,value='Save')
but3d = widget_button(base3,value='Help')

; Register the main menu into the window list and save in the cdfx common
add_cdfxwindow, ('Variable Attributes: ' + vname), base

; save required information in a structure in the first child widget
junk = {ebut:but3a,cbut:but3b,sbut:but3c,hbut:but3d,vname:vname,$
        list:-1L,first_vattr:fi,listwid:list2,objectwid:GROUP}
child = widget_info(base,/child) & widget_control,child,set_uvalue=junk
widget_control,but3a,sensitive=0 ; desensitize edit button
widget_control,but3b,sensitive=0 ; desensitize cancel button
widget_control,but3c,sensitive=0 ; desensitize save button

; Realize and manage the window
widget_control,base,/realize
Xmanager,'VarAttrs',base,Event='cdfx_editvattrs_Event',$
         GROUP=GROUP,Cleanup='cdfx_cleanup_and_remove'

end

;-----------------------------------------------------------------------------
