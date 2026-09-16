pro Restore_Objects_Event, event

common cdfxcom, CDFxwindows, CDFxprefs ; include cdfx common

widget_control, event.top, get_uvalue=info
widget_control, info.list, get_value=bvals

case event.id of
  info.ALL     : begin
		bvals[*] = 1
                widget_control,info.LIST,set_value=bvals
                end

  info.NONE    : begin
		bvals[*] = 0
                widget_control,info.LIST,set_value=bvals
                end

  info.CANCEL  : widget_control,event.top,/DESTROY

  info.RESTORE : begin
                 for i=0,n_elements(bvals)-1 do begin
                   if bvals[i] eq 1 then begin
                     widget_control,/hourglass
                     a = restore_mystruct(info.fnames[i])
                     cdfx_dataobject,a,GROUP=cdfxwindows.wid[0]
                     a=0 ; free the memory
                   endif
                 endfor
                 widget_control,event.top,/DESTROY
                 end
  else :         ; do nothing
endcase
end

;-----------------------------------------------------------------------------

; Create a window to allow the user to restore saved data objects
PRO restore_dataobjects, GROUP=GROUP

fnames = cdfx_file_search('*.sav')
if fnames(0) eq '' then begin
  ok = dialog_message(/error, [$
    'No data objects found.  Cannot restore.', $
    '(CDFx objects are stored in .sav files in', $
    'the current working directory.)'])
  return
endif

bvals = lonarr(n_elements(fnames))  ; button state values
scroll = 0
ysize = 0
if n_elements(fnames) gt 10 then begin
  scroll=1 & ysize=20
endif

; Create the widget
base1 = widget_base(/Column,Title='Restore Data Objects',/frame)

if n_elements(fnames) le 15 then begin
  list1 = CW_BGROUP(base1,fnames,/NONEXCLUSIVE,SET_VALUE=bvals,/FRAME)
endif else begin
  list1 = CW_BGROUP(base1,fnames,/NONEXCLUSIVE,SCROLL=scroll,SET_VALUE=bvals,$
                    X_SCROLL_SIZE=200,Y_SCROLL_SIZE=200,/FRAME)
endelse

base2 = widget_base(base1,/Row)

; Register this data object into the main window list
add_cdfxwindow, 'Restore Objects', base1

; Save the widget id's of the buttons and list of this widget
info={LIST:list1, $
  ALL:     widget_button(base2, value='Select All'), $
  NONE:    widget_button(base2, value='Select None'), $
  RESTORE: widget_button(base2, value='Restore'), $
  CANCEL:  widget_button(base2, value='Cancel'), $
  FNAMES:  fnames}

; Realize the data object
widget_control, base1, /realize, set_uvalue=info
xmanager, 'Restore Objects', base1, Event='Restore_Objects_Event',$
         GROUP=GROUP, Cleanup='cdfx_cleanup_and_remove'
end

;-----------------------------------------------------------------------------

function cdfx_object_from_event, event

widget_control, /hourglass
widget_control, event.top, get_uvalue=a
child = widget_info(event.top, /child)
widget_control, child, get_uvalue=b
widget_control, b.list, get_uvalue=vnames
vname = str_sep(vnames(b.vnum), ' ')
vname = strtrim(vname[0], 2)

return, {orig:a, ti:tagindex(vname, tag_names(a)), $
  vname:vname, pruned:cdfx_prune_struct(a, vname)}
end

;-----------------------------------------------------------------------------

pro cdfx_DataObject_Event, event

common cdfxcom, CDFxwindows, CDFxprefs ; include cdfx common

tnames = tag_names(event)
if tnames(3) eq 'VALUE' then begin ; must be from pull down menu
  case event.value of

    'Object Actions>.Save Object.as IDL save file' : begin
        child = widget_info(event.top,/child) ; get widget id of first child
        widget_control,child,get_uvalue=info
        widget_control,info.labl,get_value=olabel
        widget_control,/hourglass
        widget_control,event.top,get_uvalue=a
        olabel=strtrim(olabel,2)
        s = break_mystring(olabel,delimiter=' ')
        t = break_mystring(s(2),delimiter='/')
        u = s(0)+'_'+t(0)+t(1)+t(2)+'.sav'
        print,'Creating the save file:',u
        save_mystruct,a,u
        a = 0  ; free memory
        end

    'Object Actions>.Save Object.as a CDF file'    : begin
        child = widget_info(event.top,/child)
        widget_control,child,get_uvalue=info
        widget_control,info.labl,get_value=olabel
        widget_control,/hourglass
        widget_control,event.top,get_uvalue=a
        olabel=strtrim(olabel,2)
        s = break_mystring(olabel,delimiter=' ')
        t = break_mystring(s(2),delimiter='/')
        u = s(0)+'_'+t(0)+t(1)+t(2)+'.cdf'
        print,'Creating the cdf file:',u

;        s = cdfx_write_mycdf(a,u)  ;!!
	s = write_mycdf(a, filename=u) ; or [u] ??

        a = 0 ; free memory
        end

    'Object Actions>.List Object'                  : begin
        widget_control,event.top,get_uvalue=a
        print,'Generating list file...'
        widget_control,/hourglass
        s = list_mystruct(a,filename='cdfx.txt',/NOGATT,MAXRECS=950)
        if s ne -1 then xdisplayfile,'cdfx.txt'
        end

    'Object Actions>.Time Filter'                  : begin
        widget_control,/hourglass
        widget_control,event.top,get_uvalue=a
        cdfx_timeslice,a,GROUP=event.top
        end

    'Object Actions>.Plot Object.as an Xwindow'    : begin
        widget_control,/hourglass
        widget_control,event.top,get_uvalue=a
        s = plotmaster(a, xsize=600, /cdaweb, /auto, /slow, /smooth,$
          debug=CDFxprefs.debug)
        end

    'Object Actions>.Plot Object.as a GIF file': begin
        widget_control,/hourglass
        widget_control,event.top,get_uvalue=a
	cd,current=cwd
        if strupcase(!version.os_family) eq 'WINDOWS' then $
	    cwd=cwd+'\' else cwd=cwd+'/'
	print,'does this path work under windows? writing gif under: ',cwd
        s = plotmaster(a,xsize=600,/auto,/slow,/smooth,/GIF,/cdaweb,$
          outdir=cwd, debug=CDFxprefs.debug)
          ;outdir='./', debug=CDFxprefs.debug)
       ok = dialog_message(/info, 'GIF image saved.')
        end

    'Object Actions>.Close Object': begin
        if 'Yes' eq dialog_message(/question, $
            'Are you sure you want to close this object?') then begin
          widget_control, event.top, get_uvalue=a
          delete_myhandles, a ; free any handles
          child = widget_info(event.top, /child)
          widget_control, child, get_uvalue=info
          remove_cdfxwindow, title=('Data Object '+info.letter)
          widget_control, event.top, /destroy
        endif
        end

    'Variable Actions>.Show/Edit vattrs'           : begin
;        widget_control,/hourglass
;        widget_control,event.top,get_uvalue=a
;        child = widget_info(event.top,/child)
;        widget_control,child,get_uvalue=b
;        widget_control,b.list,get_uvalue=vnames
;        vname = str_sep(vnames(b.vnum),' ')
;        vname = strtrim(vname(0),2)

	a = cdfx_object_from_event(event)
        cdfx_editvattrs, a.orig, a.vname, group=event.top
        end

    'Variable Actions>.Compute Statistics'       : begin
;        widget_control,/hourglass
;        widget_control,event.top,get_uvalue=a
;        child = widget_info(event.top,/child)
;        widget_control,child,get_uvalue=b
;        widget_control,b.list,get_uvalue=vnames
;        vname = str_sep(vnames(b.vnum),' ')
;        vname = strtrim(vname(0),2)
;        ti = tagindex(vname,tag_names(a))

	a = cdfx_object_from_event(event)
        cdfx_showstats, a.orig.(a.ti), group=event.top
        end

    'Variable Actions>.List Variable'        : begin
        a = cdfx_object_from_event(event)
	s = list_mystruct(a.pruned, /novatt, /norv, file=a.vname+'.list')
	resp = dialog_message(/info, $
          "Listing saved in file '" + a.vname + ".list'")
	end

    'Variable Actions>.Plot Variable'        : begin
        a = cdfx_object_from_event(event)
        sts = plotmaster(a.pruned, /smooth, /cdaweb, /auto)
        if sts ne 0 then $
          rsp = dialog_message(/error, 'Unable to plot variable!')
        end

    'Variable Actions>.XPlot Image Variable'        : begin
        a = cdfx_object_from_event(event)

        if stregex(a.vname, '.*IMAGE.*', /boolean, /fold) then $
          s = xplot_images(a.orig, a.vname) $
        else $
          rsp = dialog_message(/error, 'Only images can be sent to XPLOT.')
        end

    else : print,'UNKNOWN VALUE FOR PULLDOWN!'
  endcase
endif

if tnames(3) eq 'INDEX' then begin ; must be from variable list
  widget_control, event.id, get_uvalue=vnames
  s = size(vnames)

  if s(n_elements(s)-2) eq 7 then begin ; event is from the list
    child = widget_info(event.top,/child) ; get widget id of first child
    widget_control,child,get_uvalue=b ; get the widget ids from first child
    b.vnum = event.index ; record which variable is selected
    widget_control,child,set_uvalue=b ; set the updated widget ids
    widget_control,b.vmenu,/sensitive ; sensitize the variable functions

  endif else begin ; event is from the droplist
    widget_control,/hourglass
    widget_control,event.top,get_uvalue=a

    if (event.index eq 0) then $
      vnames = generate_varlist(a) $ ; DATA only
    else $
      vnames = generate_varlist(a, /ALL) ; ALL variables

    widget_control,event.id,get_uvalue=b
    widget_control,b,set_value=vnames
    widget_control,b,set_uvalue=vnames
    a=0 ; free up the memory
  endelse
endif

end

;-----------------------------------------------------------------------------

PRO cdfx_D0CBox, wid
  remove_cdfxwindow, WID=wid
  widget_control, wid, get_uvalue=a
  delete_myhandles, a ; free any handles
end

;-----------------------------------------------------------------------------

PRO cdfx_dataobject, a, GROUP=GROUP

COMMON cdfxcom, CDFxwindows, CDFxprefs ; include cdfx common

; Determine the letter to identify this object
letter = determine_dataobject_letter()

; Create a string array holding all of the global attributes in structure
atags = tag_names(a.(0)) & w=where(atags eq 'FIELDNAM') & gattrs='' & p='    '
for i=1,w(0)-1 do begin
  if (n_elements(a.(0).(i)) eq 1) then begin
    val = atags(i) + ': ' + string(a.(0).(i))
    if (gattrs(0) eq '') then gattrs = val else gattrs = [gattrs,val]
  endif else begin
    gattrs = [gattrs,(atags(i)+':')]
    for j=0,n_elements(a.(0).(i))-1 do gattrs = [gattrs,p+string(a.(0).(i)(j))]
  endelse
endfor

; Determine a variable that contains the timing information
atags = tag_names(a) & tvar = -1
for i=0,n_elements(atags)-1 do begin
  btags = tag_names(a.(i)) & w = where(btags eq 'CDFTYPE',wc)
  v = where(btags eq 'CDFRECVARY',vc) ;also check if record varies (because we
                                ;now have datasets w/ several
                                ;cdf_epoch variables, have to use the
                                ;one that varies by record (THEMIS))
  if (wc gt 0 and v gt 0) then $
    if (a.(i).CDFTYPE eq 'CDF_EPOCH' and (a.(i).CDFRECVARY eq 'VARY')) then tvar = i
  if (wc gt 0 and v gt 0) then $
    if (a.(i).CDFTYPE eq 'CDF_EPOCH16' and (a.(i).CDFRECVARY eq 'VARY')) then tvar = i
endfor


if (tvar ne -1) then begin ; Determine the start and stop time of the data
  d = get_mydata(a,tvar)
  start_time = decode_cdfepoch(min(d))
  stop_time  = decode_cdfepoch(max(d)) & d=0
endif

; Create label for this object from logical source and start/stop time
lsource = '' & atags = tag_names(a.(0)) ; get names of the epoch attributes
w = where(atags eq 'LOGICAL_SOURCE',wc)
if (wc gt 0) then lsource = lsource + a.(0).(w(0))
if (strlen(lsource) le 1) then begin ; construct lsource from other info
  s = '' & t = '' & d = ''
  w = where(atags eq 'SOURCE_NAME',wc)
  if (wc gt 0) then s = break_mystring(a.(0).(w(0)),delimiter='>')
  w = where(atags eq 'DATA_TYPE',wc)
  if (wc gt 0) then t = break_mystring(a.(0).(w(0)),delimiter='>')
  w = where(atags eq 'DESCRIPTOR',wc)
  if (wc gt 0) then d = break_mystring(a.(0).(w(0)),delimiter='>')
  lsource = s(0) + '_' + t(0) + '_' + d(0)
endif
olabel = '   ' + lsource + ' from ' + start_time + ' till ' + stop_time + '   '

; Create a list of variables and pertinent metadata
vnames = generate_varlist(a)

; Create the widget
base1 = widget_base(/Column,Title=('Data Object '+letter),/frame)
base2 = widget_base(base1,/Column)
base3 = widget_base(base1,/Row)
labl1 = widget_label(base2,value=olabel,/align_center)
text1 = widget_text(base2,value=gattrs,/scroll,ysize=10,xsize=40)
list1 = widget_list(base2,value=vnames,/frame,ysize=6,uvalue=vnames)
but1  = widget_droplist(base3,uvalue=list1,$
                        value=['Show data vars','Show all vars'])
junk1 =  {CW_PDMENU_S,flags:0,name:''}
puld1 = [{CW_PDMENU_S,1,'Object Actions>'},$
         {CW_PDMENU_S,1,'Save Object'},$
         {CW_PDMENU_S,0,'as IDL save file'},$
         {CW_PDMENU_S,2,'as a CDF file'},$
         {CW_PDMENU_S,1,'Plot Object'},$
         {CW_PDMENU_S,0,'as an Xwindow'},$
         {CW_PDMENU_S,2,'as a GIF file'},$
         {CW_PDMENU_S,0,'List Object'},$
         {CW_PDMENU_S,0,'Time Filter'},$
         {CW_PDMENU_S,2,'Close Object'}]
but2  =   CW_PDMENU(base3,puld1,/return_full_name)
puld2 = [{CW_PDMENU_S,1,'Variable Actions>'},$
         {CW_PDMENU_S,0,'Show/Edit vattrs'} ,$
         {CW_PDMENU_S,0,'Compute Statistics'} ,$
         {CW_PDMENU_S,0,'List Variable'},$
         {CW_PDMENU_S,0,'Plot Variable'},$
         {CW_PDMENU_S,2,'XPlot Image Variable'}]
but3  =   CW_PDMENU(base3,puld2,/return_full_name)

; Register this data object into the main window list
add_cdfxwindow,('Data Object '+letter),base1
; Save the widget id's of the buttons and list of this widget
junk = {labl:labl1,text:text1,list:list1,drop:but1,$
        omenu:but2,vmenu:but3,letter:letter,vnum:-1L}
child = widget_info(base1,/child) ; get widget id of first child
widget_control,child,set_uvalue=junk ; save widget ids in first child
widget_control,but3,sensitive=0 ; desensitize variable functions for now

; Save the structure into the base user value
widget_control,base1,set_uvalue=a & a=0

; Realize the data object
widget_control,base1,/realize
Xmanager,'DataObject',base1,Event='cdfx_DataObject_Event',$
         GROUP=GROUP,Cleanup='cdfx_D0CBox'
end

;-----------------------------------------------------------------------------

pro cdfx_save_all_data_objects

common cdfxcom, CDFxwindows, CDFxprefs ; include cdfx common

w = where(strpos(CDFxwindows.title, 'Data Object') ne -1, wc)
if wc lt 1 then begin
  resp = dialog_message(/info, 'No data objects to save!')
  return
end

for i=0, wc-1 do begin
  child = widget_info(CDFxwindows.wid(w[i]), /child)
  widget_control, child, get_uvalue=info
  widget_control, info.labl, get_value=olabel
  widget_control, /hourglass
  widget_control, CDFxwindows.wid(w[i]), get_uvalue=a

  olabel = strtrim(olabel, 2)
  s = break_mystring(olabel, delimiter=' ')
  t = break_mystring(s(2), delimiter='/')
  u = s(0)+'_'+t(0)+t(1)+t(2)+'.sav'

;  print, 'Creating the save file:', u
  save_mystruct, a, u
  a = 0  ; free memory
endfor

resp = dialog_message(/info, 'Saved ' + strtrim(string(wc),2) + ' object(s).')

end

;-----------------------------------------------------------------------------

pro cdfx_shutdown

common cdfxcom, CDFxwindows, CDFxprefs ; include cdfx common

; Free any data held in handles before destroying the objects
w = where(strpos(cdfxwindows.title,'Data Object') ne -1,wc)
for i=0, wc-1 do begin
  widget_control, cdfxwindows.wid(w(i)), get_uvalue=a
  delete_myhandles, a
endfor

cd,current=cwd
CDFXprefs.cdf_path=cwd

if strupcase(!version.os_family) eq 'WINDOWS' then begin $
   cd,current=cwd
   save,filename=cwd+'\.cdfx', CDFxprefs
endif else save, filename='~/.cdfx', CDFxprefs

remove_cdfxwindow, title='Main Menu'  ;need??

end

;-----------------------------------------------------------------------------

pro cdfx_MMenu_Event, event

common cdfxcom, CDFxwindows, CDFxprefs ; include cdfx common

tnames = tag_names(event)
if tnames(3) eq 'VALUE' then begin ; must be from pull down menu
  case event.value of
    'Open a new Window >.Image Animator Window'   : begin
        widget_control,/hourglass
        cdfx_pre_xinteranimate, GROUP=event.top
        end

;   'Open a new Window >.Time Series Plot Window' : print,'NOT YET IMPLEMENTED'
;   'Open a new Window >.Spectrogram Plot Window' : print,'NOT YET IMPLEMENTED'
;   'Open a new Window >.Radar Plot Window'       : print,'NOT YET IMPLEMENTED'
;   'Open a new Window >.Data Manipulator Window' : print,'NOT YET IMPLEMENTED'

    'Modify Preferences>.Font Preferences'        : begin
        s = XFONT()
        if (s ne '') then widget_control,default_font=s
        end
    'Modify Preferences>.Color Table Preferences' : xloadct

;   'Modify Preferences>.Data Object Preferences' : print,'NOT YET IMPLEMENTED'
;   'Modify Preferences>.Time Series Preferences' : print,'NOT YET IMPLEMENTED'
;   'Modify Preferences>.Spectrogram Preferences' : print,'NOT YET IMPLEMENTED'
;   'Modify Preferences>.Image Preferences'       : print,'NOT YET IMPLEMENTED'
;   'Modify Preferences>.Listing Preferences'     : print,'NOT YET IMPLEMENTED'

    else : print,'UNKNOWN VALUE FOR PULLDOWN!'
  endcase
endif else begin ; must be a regular button or the draw widget
  if tnames(3) eq 'TYPE' then begin ; must be the draw widget
    if event.press ne 0 then begin
;!!    print,'CDFx Version 1.0     Date: 5/22/96'
    endif
  endif else begin ; must be a regular button
    child = widget_info(event.top, /child)
    widget_control, child, get_uvalue=button_ids

    case event.id of
      button_ids.but1 : begin ; Read CDF files
                        widget_control,/hourglass

;                        a = xread_mycdf(/nodatastruct,debug=CDFxprefs.debug)
                        a = cdfx_opencdfs(gleader=button_ids.base01)

                        ; verify that 'a' is a structure
                        b = size(a) & c = b(n_elements(b)-2)
                        if (c eq 8) then begin
                          ;print,'Generating data object...'
                          widget_control,/hourglass
                          cdfx_dataobject, a, GROUP=event.top
                          a = 0 ; delete structure
                        endif
                        end

      button_ids.but2 : begin
                        widget_control,/hourglass
                        restore_dataobjects,GROUP=event.top
                        end

      button_ids.but3 : begin
                        widget_control,/hourglass
                        WindowList
                        end

      button_ids.butm:		help, /memory
      button_ids.bSaveObjects:	cdfx_save_all_data_objects
      button_ids.bShowPrefs:    cdfx_show_preferences

      button_ids.bAnimate:	begin
				widget_control,/hourglass
				cdfx_pre_xinteranimate, group=event.top
				end

      button_ids.bQuit: begin
	if dialog_message(/question,$
          'Are you sure you want to quit?') eq 'Yes' then begin
	  cdfx_shutdown
	  widget_control, event.top, /destroy
	endif
	end

      else : print,'UNKNOWN BUTTON!'
    endcase
  endelse
endelse

end

;-----------------------------------------------------------------------------

pro cdfx_MMenuCBox, wid

cdfx_shutdown

end

;-----------------------------------------------------------------------------

pro cdfx, debug=debug

; Create the common block containing window information
common cdfxcom, CDFxwindows, CDFxprefs

if xregistered('CDFx Main Menu') ne 0 then begin
  print, 'CDFx main menu already exists!'
  ; dialog_message??
  return
endif

device, decomposed = 0
;device, true_color = 24

loadct, 5
;widget_control, default_font='6x10'

; Initialize globals.

CDFxwindows = { title:strarr(50), wid:lonarr(50) } ;is 50 enough??
cd,current=cwd
if strupcase(!version.os_family) eq 'WINDOWS' then $
   ;CDFxprefs = {version:1,debug:0,masters_path:cwd} else $
   ;CDFxprefs = {version:1,debug:0,masters_path:'/home/cdaweb/data/0MASTERS' }
   CDFxprefs1 = {version:1,debug:0,masters_path:cwd,cdf_path:cwd} else $
   CDFxprefs1 ={version:1,debug:0,masters_path:'/home/cdaweb/data/0MASTERS', $
                cdf_path:cwd+'/' }

; ?? Use defsysv, '!CDFX', ___

; Restore preferences, if the save file exists.

if strupcase(!version.os_family) eq 'WINDOWS' then $
   ;fname = file_search('~/.cdfx')
   fname = file_search(cwd+'\.cdfx') else fname = file_search('~/.cdfx')
if (size(fname))[0] ne 0 then begin
   restore, fname[0]
   ; RCJ 01/26/2007 restored CDFxprefs, now compare to CDFxprefs.  This is
   ; an issue if we change the program and add elements to CDFxprefs...
   if n_elements(tag_names(CDFxprefs1)) ne n_elements(tag_names(CDFxprefs)) then begin
      print,'Please delete file '+fname[0]+' then restart IDL and CDFX'
      exit
   endif 
endif 
CDFxprefs=CDFxprefs1

; Create the main menu
base01 = widget_base(/Column,Title='CDFx',/frame,/base_align_center)
drw1  = widget_draw(base01,xsize=131,ysize=126,/frame, retain=2)
lbl = widget_label(base01, value = 'v0.525')

but1  = widget_button(base01,value='Read CDF files')
but3  = widget_button(base01,value='Window List')
but2  = widget_button(base01,value='Restore Data Objects')

bSaveObjects	= widget_button(base01, value='Save Data Objects')
bAnimate	= widget_button(base01, value='Animate Images')
bShowPrefs      = widget_button(base01, value='Preferences')
bQuit		= widget_button(base01, value='Quit')

if keyword_set(debug) then begin
  CDFxprefs.debug = 1
  butm = widget_button(base01, value='IDL Memory')
endif else $
  butm = -1L

base2 = widget_base(base01,/Column,/BASE_ALIGN_CENTER)
junk1 =  {CW_PDMENU_S, flags:0, name:''}

;puld1 = [{CW_PDMENU_S,1,'Open a new Window >'},$
;         {CW_PDMENU_S,0,'Image Animator Window'}]
;but4  =   CW_PDMENU(base2,puld1,/return_full_name)

;!!      {CW_PDMENU_S,0,'Time Series Plot Window'},$
;        {CW_PDMENU_S,0,'Spectrogram Plot Window'},$
;        {CW_PDMENU_S,0,'Radar Plot Window'},$
;        {CW_PDMENU_S,2,'Data Manipulator Window'},$


;puld2 = [{CW_PDMENU_S,1,'Modify Preferences>'},$
;         {CW_PDMENU_S,0,'Font Preferences'},$
;         {CW_PDMENU_S,0,'Color Table Preferences'}]
;but5  =   CW_PDMENU(base2,puld2,/return_full_name)


;!!      {CW_PDMENU_S,0,'Data Object Preferences'},$
;        {CW_PDMENU_S,0,'Time Series Preferences'},$
;        {CW_PDMENU_S,0,'Spectrogram Preferences'},$
;        {CW_PDMENU_S,0,'Image Preferences'},$
;         {CW_PDMENU_S,0,'Listing Preferences'}]

;puld3 = [{CW_PDMENU_S,1,'Shut Down>'},$
;         {CW_PDMENU_S,0,'...and Save all Data Objects'},$
;         {CW_PDMENU_S,2,'...and Destroy all Data Objects'}]
;but6  =   CW_PDMENU(base2,puld3,/return_full_name)


; Register the main menu into the window list and save in the cdfx common
add_cdfxwindow, 'Main Menu', base01

; Save the widget id's of the buttons in the first child uvalue
button_ids = { $
  base01:base01, drw1:drw1, but1:but1, but2:but2, but3:but3, butm:butm, $
 ;but4:but4, $
  bAnimate:bAnimate, $
  bSaveObjects:bSaveObjects, $
  bShowPrefs:bShowPrefs, $
  bQuit:bQuit }
child = widget_info(base01, /child)
widget_control, child, set_uvalue=button_ids

; Realize the main menu
widget_control, base01, /realize
widget_control, get_value=index, drw1
wset, index

; Try to locate the CDFx logo image.
pathDirs = strjoin(strsplit(!path, ':', /extract), ',')
logoFiles = cdfx_file_search('{' + pathDirs + '}/cdfxlogo.png')

;print, logoFiles
;print, pathDirs 

; If logo found, draw it.
if (size(logoFiles))[0] gt 0 then begin
  catch, error_status
  if error_status eq 0 then begin
;     read_gif, logoFiles[0], logo, r, g, b
    logo = read_png(logoFiles[0], r, g, b)
    if !version.release lt '6.0' then $
      logo = reverse(logo, 2)
    tvlct, r, g, b
    tv, logo
  endif
endif else begin
   r=findgen(100) & theta=r/5
   plot,r,theta,/polar,xsty=4,ysty=4
   xyouts,.2,.1,/normal,color=200,'CDFx',charsize=3
endelse


; Manage the window
xmanager, 'MMenu', base01, event='cdfx_MMenu_Event', cleanup='cdfx_MMenuCBox'

end

;-----------------------------------------------------------------------------
