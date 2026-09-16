;TJK 10/25/2006 - removed timeslice_mystruct to its own file
;since it will now be called from read_myCDF in some cases.
;-----------------------------------------------------------------------------

pro cdfx_timeslice_Event, event

common cdfxcom, CDFxwindows, CDFxprefs ; include cdfx common

etype = widget_info(event.id,/type) ; get event type
child = widget_info(event.top,/child) ; get id of first child
widget_control,child,get_uvalue=info  ; get id's of all widgets

case etype of
    1 : begin ; button event
        case event.id of
          info.HELP   : print,'NOT YET HELPING'
          info.CANCEL                                     : begin
               remove_cdfxwindow,WID=event.id
               widget_control,event.top,/destroy
               end
          info.SAVE                                       : begin
               widget_control,info.slid1,get_value=v1
               widget_control,info.slid2,get_value=v2
               ; validate values on the sliders
               if v1 gt v2 then begin
                 print,'Start Time must be BEFORE Stop Time!' & return
               endif
               if (v1 eq 0)AND(v2 eq (n_elements(info.time)-1)) then begin
                 print,'No change to start and stop times' & return
               endif
               ; Perform the time subsetting
               widget_control,event.top,get_uvalue=a
               widget_control,/hourglass
               b = timeslice_mystruct(a,info.time(v1),info.time(v2))
               ; Create a new data object with the subsetted data
               cdfx_dataobject,b,GROUP=cdfxwindows.wid(0)
               ; Destroy the timeslice widget
               remove_cdfxwindow,WID=event.id
               widget_control,event.top,/destroy
               end
        endcase
        end

    2 : begin ; slider event
        if event.id eq info.slid1 then begin ; start time slider
          s = decode_cdfepoch(info.time(event.value))
          widget_control,info.labl1,set_value=s
        endif else begin ; stop time slider
          s = decode_cdfepoch(info.time(event.value))
          widget_control,info.labl2,set_value=s
        endelse
        end
    else : ; do nothing
endcase

end

;-----------------------------------------------------------------------------

; Provide a widget interface to subset the given structure by time
PRO cdfx_timeslice, a, GROUP=GROUP

; Point to the common block containing window information
COMMON cdfxcom, CDFxwindows, CDFxprefs ; include cdfx common

; Determine a variable that contains the timing information
atags = tag_names(a) & tvar = -1
for i=0,n_elements(atags)-1 do begin
  btags = tag_names(a.(i)) & w = where(btags eq 'CDFTYPE',wc)
  if (wc gt 0) then if (a.(i).CDFTYPE eq 'CDF_EPOCH') then tvar = i
endfor

if tvar eq -1 then begin
  ok = dialog_message(/error, $
    'cdfx_timeslice: Unable to locate time variable!')
  return
endif else ttags = tag_names(a.(tvar))

; Retrieve the timing data
ti = tagindex('HANDLE',ttags)
if ti ne -1 then handle_value,a.(tvar).HANDLE,d $
else begin
  ti = tagindex('DAT',ttags)
  if ti ne -1 then d = a.(tvar).DAT $
  else begin
    ok = dialog_message(/error, $
      'cdfx_timeslice:time var has no HANDLE or DAT tag!')
    return
  endelse
endelse

; Validate the dimensionality of the time data
ds = size(d)
nds = n_elements(ds)
if ds(0) ne 1 then begin
  ok = dialog_message(/error, 'timeslice:Epoch var is not an array!')
  return
endif

if ds(nds-2) ne 5 then begin
  ok = dialog_message(/error, 'timeslice:Epoch var is not DOUBLE float!')
  return
endif

nd = n_elements(d)

; Determine the letter of the object being sliced
child = widget_info(GROUP,/child) & widget_control,child,get_uvalue=info
letter = info.letter & wtitle = 'Time Filter: Object '+letter

; Prepare instructions
m0 = 'Adjust the start and stop sliders to modify the time range  '
m1 = 'of all of the variables in the Data Object.  Click the New '
m2 = 'Object button to create a new Data Object.  Click the CANCEL '
m3 = 'button to exit without changing the Data Object.                   '

; Create widget interface
base  = widget_base(/Column,Title=wtitle,/frame)
base0 = widget_base(base,/Column)
lab0a = widget_label(base0,value=m0)
lab0b = widget_label(base0,value=m1)
lab0c = widget_label(base0,value=m2)
lab0d = widget_label(base0,value=m3)
base1 = widget_base(base,/Row)
base2 = widget_base(base,/Row)
base3 = widget_base(base,/Row,/frame)
slid1 = widget_slider(base1,max=(nd-1),value=0,Title='Start Time',$
                      xsize=250,/drag)
labl1 = widget_label(base1,value=decode_cdfepoch(d(0)))
slid2 = widget_slider(base2,max=(nd-1),value=(nd-1),Title='Stop Time',$
                      xsize=250,/drag)
labl2 = widget_label(base2,value=decode_cdfepoch(d(nd-1)))
but3a = widget_button(base3,value='New Object')
but3b = widget_button(base3,value='Cancel')
but3c = widget_button(base3,value='Help')

; Register the main menu into the window list and save in the cdfx common
add_cdfxwindow,wtitle,base

; Save the widget id's and time data for use in the event handler
junk = {$
  slid1:slid1, labl1:labl1, slid2:slid2, labl2:labl2,$
  save:but3a, cancel:but3b, help:but3c, time:d}
child = widget_info(base,/child) ; get widget id of first child
widget_control, child, set_uvalue=junk ; save widget ids and time data

; Save the input structure in the base user value
widget_control, base, set_uvalue=a
a = 0

; Realize and manage the window
widget_control,base,/realize
Xmanager,'TimeSlice',base,Event='cdfx_timeslice_Event',$
         GROUP=GROUP,Cleanup='cdfx_cleanup_and_remove'
end

;-----------------------------------------------------------------------------
