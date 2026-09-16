; Implementation of the CDFx Preferences dialog box.

;-----------------------------------------------------------------------------

pro cdfx_show_preferences_event, event

common cdfxcom, CDFxwindows, CDFxprefs ; include the cdfx common

widget_control, event.top, get_uvalue=wids
case event.id of

  wids.LoadCT:	xloadct
  wids.Cancel:	widget_control, event.top, /destroy

  wids.Save:	begin
		widget_control, wids.MasDir, get_value=v
		CDFxprefs.masters_path = v
		widget_control, event.top, /destroy
		end

  else:	; do nothing
endcase

end

;-----------------------------------------------------------------------------

pro cdfx_show_preferences

common cdfxcom, CDFxwindows, CDFxprefs ; include the cdfx common

base = widget_base(/column, title='CDFx Preferences')
row1 = widget_base(base, /row)
blct = widget_button(base, value='Load Color Table')
w    = widget_label(row1, value='Master file directory:')
rowb = widget_base(base, /row, /align_right, /frame)

wids = { $
  MasDir: widget_text(row1, /editable, xsize=30, ysize=1, $
            value=CDFxprefs.masters_path),$
  LoadCT: blct,$
  Save:   widget_button(rowb, value='Save'), $
  Cancel: widget_button(rowb, value='Cancel') }

widget_control, base, /realize, set_uvalue=wids
xmanager, 'cdfx_show_preferences', base

end

;-----------------------------------------------------------------------------
