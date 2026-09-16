
pro cdfx_showstats_Event, event

;print, 'No events for showstats'

end

;-----------------------------------------------------------------------------
; Compute and display pertinent statistical information about the variable
; contained in the structure a, in a non-editable text widget.

pro cdfx_showstats, a, GROUP=GROUP

common cdfxcom, CDFxwindows, CDFxprefs ; include cdfx common

; Initialize
text = ''

; Verify that a is a record varying structure
as = size(a) & nas = n_elements(as)
if (as(nas-2) ne 8) then begin
  ok = dialog_message(/error, 'showstats:input parameter is not a structure.')
  return
endif else atags = tag_names(a)

ti = tagindex('VAR_TYPE',atags)
if (ti ne -1) then begin
  if strupcase(a.VAR_TYPE eq 'METADATA') then begin
    ok = dialog_message(/error, $
      'Can only produce stats for record-varying variables!')
    return
  endif
endif


; Retrieve the data and determine its idl size information
ti = tagindex('HANDLE',atags)
if (ti ne -1) then handle_value,a.HANDLE,d $
else begin
  ti = tagindex('DAT',atags)
  if (ti ne -1) then d = a.DAT $
  else begin
    ok = dialog_message(/error, $
      'showstats:variable has no .DAT or .HANDLE tag!')
    return
  endelse
endelse
d = reform(d) & ds = size(d) & nds = n_elements(ds)

; Verify that the data is not character data
if ds[nds-2] eq 7 then begin
  ok = dialog_message(/error, 'showstats:no status for character data.')
  return
endif

; Capture type and dimensionality information
;TJK 12/7/2006 - replace call to gethelp w/ call to help because
;it is obsolete and doesn't support dcomplex.
;h = gethelp('d') & h = strtrim(strmid(h(0),1,strlen(h(0))-1),2)
help, d, output=h & h = strtrim(strmid(h(0),1,strlen(h(0))-1),2)
s = str_sep(h(0),'=') & text = 'Variable name : ' + a.VARNAME
text = [text,('Variable type : ' + strtrim(s(0),2))]
text = [text,('Dimensionality: ' + strtrim(s(1),2))]

; Determine the fill value if one exists
ti = tagindex('FILLVAL',tag_names(a))
if (ti ne -1) then fill = a.FILLVAL else fill = 'n/a'
s = 'fill value=' + string(fill)
text = [text,' '] & text = [text,s]

; Compute statistics
if ds(0) eq 1 then begin ; variable is record-varying scalar
  w = where(d eq fill,fc) & w = where(d ne fill,wc)
  if (wc ne 0) then d = d(w) ; filter out fill values
  dmin = min(d) & dmax = max(d)
  davg = total(d)/n_elements(d)
  text = [text,('fill count= ' + string(fc))]
  text = [text,('minimum   = ' + string(dmin))]
  text = [text,('maximum   = ' + string(dmax))]
  text = [text,('average   = ' + string(davg))]
endif

if ds(0) eq 2 then begin ; variable is record-varying vector
  w = where(d eq fill,fc) & w = where(d ne fill,wc)
  if (wc ne 0) then e = d(w) ; filter out fill values
  dmin = min(e) & dmax = max(e)
  davg = total(e)/n_elements(e) & e=0
  text = [text,('fill count= ' + strtrim(string(fc),2))]
  text = [text,('minimum   = ' + strtrim(string(dmin),2))]
  text = [text,('maximum   = ' + strtrim(string(dmax),2))]
  text = [text,('average   = ' + strtrim(string(davg),2))]
  text = [text,' '] & text = [text,' Element by Element Checking:']
  ; get stats for each element of vector
  for i=0,ds(1)-1 do begin
    e = d(i,*) & w = where(e eq fill,fc)
    w = where(e ne fill,wc) & if (wc ne 0) then e = e(w) ; filter out fills
    dmin = min(e) & dmax = max(e) & davg = total(e)/n_elements(e) & e=0
    text = [text,('Element ' + strtrim(string(i+1),2))]
    text = [text,('   fill count= ' + strtrim(string(fc),2))]
    text = [text,('   minimum   = ' + strtrim(string(dmin),2))]
    text = [text,('   maximum   = ' + strtrim(string(dmax),2))]
    text = [text,('   average   = ' + strtrim(string(davg),2))]
  endfor
endif

if ds(0) ge 3 then begin ; variable is record-varying image
  ok = dialog_message(/error, $
    'Cannot produce stats for 3D+ variables!')
  return
endif

; Create a widget to display the text
net = n_elements(text)
base1 = widget_base(/Column,Title='Variable Stats',/frame)

if net le 30 then $
  txt1 = widget_text(base1,value=text,ysize=net,xsize=max(strlen(text)))$
else $
  txt1 = widget_text(base1,value=text,ysize=30,xsize=max(strlen(text)),/scroll)


; Register the main menu into the window list and save in the cdfx common
add_cdfxwindow,'Variable Stats',base1

; Realize and manage the window
widget_control,base1,/realize
Xmanager,'VarStats', base1, Event='cdfx_showstats_Event',$
         GROUP=GROUP, Cleanup='cdfx_cleanup_and_remove'
end

;-----------------------------------------------------------------------------
