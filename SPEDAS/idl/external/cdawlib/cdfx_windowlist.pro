; Routines related to the CDFx window-list window.

;-----------------------------------------------------------------------------
; Register a window in our window-tracking list.

pro add_cdfxwindow, title, wid

common cdfxcom, CDFxwindows, CDFxprefs ; include the cdfx common

w = where(CDFxwindows.title eq '', wc)
if (wc eq 0) then w = 0
CDFxwindows.title[w(0)] = title
CDFxwindows.wid[w(0)]   = wid

end

;-----------------------------------------------------------------------------
; Remove a window from our window-tracking list.

pro remove_cdfxwindow, title=title, wid=wid

common cdfxcom, CDFxwindows, CDFxprefs ; include the cdfx common

if keyword_set(TITLE) then $
  w = where(CDFxwindows.title eq TITLE, wc) $
else $
  w = where(CDFxwindows.wid eq WID, wc)

if wc gt 0 then begin
  CDFxwindows.title[w[0]] = ''
  CDFxwindows.wid[w[0]] = 0
endif

end

;-----------------------------------------------------------------------------
; A shared cleanup handler for many different windows.

pro cdfx_cleanup_and_remove, wid

remove_cdfxwindow, wid=wid

end

;-----------------------------------------------------------------------------
; Event handler.

pro windowlist_event, event

if tag_names(event,/struct) eq 'WIDGET_LIST' then begin
  widget_control, event.id, get_uvalue=wids
  widget_control, wids(event.index), /show
endif

widget_control, event.top, /destroy

end

;-----------------------------------------------------------------------------
; Show the list of visible windows, and allow the user to select one to
; bring forward.

pro WindowList

common cdfxcom, CDFxwindows, CDFxprefs ; include the cdfx common

if XRegistered('WindowList') then return ; only one window list allowed

; Create list of realized window names
w = where(cdfxwindows.title ne '', wc)
if wc lt 1 then return

wlist = cdfxwindows.title[w]
wwids = cdfxwindows.wid[w]

base1 = widget_base(/column, title='Open Windows')
labl1 = widget_label(base1, value='Select Window')
list1 = widget_list(base1, value=wlist, Ysize=10, uvalue=wwids)
butn1 = widget_button(base1, value='Cancel')

widget_control, base1, /realize
xmanager, 'WindowList', base1

end

;-----------------------------------------------------------------------------
