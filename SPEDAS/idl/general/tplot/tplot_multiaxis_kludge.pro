;+
;Procedure:
;  tplot_multiaxis_kludge
;
;Purpose:
;  Apply workaround for simultaneous left/right y axes to
;  list of tplot variables.
;
;Calling Sequence:
;  tplot_multiaxis_kludge, names, [,/left] [,/right] [,/reset]
;
;Input:
;  names:  string array of tplot variables
;  left:  flag denoting left handed y axes
;  right:  flag denoting right handed y axes
;  reset:  flag to remove previous changes
;
;Output:
;  None, alters limits structure of tplot variables
;
;Notes:
;  -See tplot_multiaxis.pro
;  -Existing "ystyle" and "axis" elements of limits struct will be clobbered.
;
;
;$LastChangedBy: egrimes $
;$LastChangedDate: 2016-08-23 15:19:19 -0700 (Tue, 23 Aug 2016) $
;$LastChangedRevision: 21697 $
;$URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/spdsoft/trunk/general/tplot/tplot_multiaxis_kludge.pro $
;-
pro tplot_multiaxis_kludge, names, left=left, right=right, reset=reset

    compile_opt idl2, hidden


if undefined(names) then return


;clear previously added options
if keyword_set(reset) then begin
  for i=0, n_elements(names)-1 do begin
    options, names[i], 'axis'
    options, names[i], 'ystyle'
  endfor
  return
endif 


;init axis structure that will be passed through limits to mplot
base = {yaxis:0, ystyle:1}

if keyword_set(right) then begin
  base.yaxis=1
endif else if keyword_set(left) then begin
  base.yaxis=0
endif else begin
  return
endelse


for i=0, n_elements(names)-1 do begin

  if tnames(names[i]) eq '' then continue
  get_data, names[i], lim=lim, dlim=dlim
  
  ;use variable name as default y title
  axis = {ytitle: strjoin(strsplit(names[i],'_',/extract),'!c')}
  
  str_element, lim, 'colors', this_color, success=s
  if s then str_element, axis, 'color', this_color[0], /add

  ;copy & overwrite axis options from metadata into struct
  extract_tags, axis, dlim, /axis
  extract_tags, axis, lim, /axis
  extract_tags, axis, base  ;must be last!

  ;ysubtitle is ad hoc tplot feature so it must be grabbed separately
  str_element, dlim, 'ysubtitle', ysubtitle
  str_element, lim, 'ysubtitle', ysubtitle
  if ~undefined(ysubtitle) then axis.ytitle += '!c'+ysubtitle
  
  
  ;add options to limits struct
  extract_tags, lim, {ystyle:1+4, axis:axis}

  store_data, names[i], lim=lim

endfor


end