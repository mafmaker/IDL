;$Author: mathews $
;$Date: 1997/02/04 16:02:06 $
;$Header: /home/rumba/cdaweb/dev/control/RCS/Pickdir.pro,v 1.4 1997/02/04 16:02:06 mathews Exp burley $
;$Locker: burley $
;$Revision: 1.4 $
;+
; NAME:
;       PICKDIR
;
; PURPOSE:
;       This function allows the user to interactively pick a directory.
;	A directory selection tool with a graphical user interface is created.
;       It is currently called from Xread_mycdf in order to allow a user
;       to change directories in order to find and read CDF files.
;
; CATEGORY:
;       Widgets.
;
; CALLING SEQUENCE:
;       Result = PICKDIR()
;
; KEYWORD PARAMETERS:
;
;       GROUP:  The widget ID of the widget that calls PICKDIR.  When this
;               ID is specified, a death of the caller results in the death of
;               the PICKDIR widget application.
;
;       PATH:   The initial path to select from.  If this keyword is
;               not set, the current directory is used.
;
;       FILTER: A string value for filtering the files in the file list.  This
;               keyword is used to reduce the number of files to choose from.
;               The user can modify the filter unless the FIX_FILTER keyword
;               is set.  Example filter values might be "*.pro" or "*.dat".
;
;       FIX_FILTER: When this keyword is set, only files that satisfy the
;               filter can be displayed.  The user has no ability to modify
;               the filter and the filter is not shown.
;
;       TITLE:  A scalar string to be used for the window title.  If it is
;               not specified, the default title is "Select Directory"
;
;       MUST_EXIST: When set, only directorys that actually exist can be selected.
;	VALID:	Special keyword to verify if a directory is valid
;		returns 1 if named variable is a valid directory
;		otherwise returns 0 if not.
;
; OUTPUTS:
;       PICKDIR returns a string that contains the name of the directory selected.
;       If no directory is selected, PICKDIR returns a null string.
;
; COMMON BLOCKS:
;       PICKDIR_C: COMMON block that maintains state for the widget.
;
; SIDE EFFECTS:
;       This function initiates the XMANAGER if it is not already running.
;
; RESTRICTIONS:
;       This routine is known to work on Suns (OPEN LOOK), MIPS, RS/6000,
;       DEC Ultrix, HP/700, VAX/VMS and SGI machines.
;
;       Only one instance of the PICKDIR widget can be running at one time.
;
;       PICKDIR does not recognize symbolic links to other files in UNIX.
;
; PROCEDURE:
;       Create and register the widget and then exit, returning the directory
;       that was picked.
;
; EXAMPLE:
;       Create a PICKDIR widget that lets users select only files with
;       the extensions 'pro' and 'dat'.  Use the 'Select File to Read' title
;       and store the name of the selected file in the variable F.  Enter:
;
;               F = PICKDIR(FILTER = '*.pro *.dat')
;
; AUTHOR:
;       Jason Mathews, NASA/GSFC/Code 633, Sept. 1994
;       mathews@nssdc.gsfc.nasa.gov
;
; MODIFICATION HISTORY:
;       Written by:	Jason Mathews, September, 1994
;                       Modified pickfile.pro (IDL V3.6) to select and
;                       return the directory path instead of a specific
;                       filename.  Fix Valid_Dir function when dir string
;                       contains space character in which the shell test
;                       has a fatal error.  Added VALID keyword to test
;                       if dir is valid returning TRUE or FALSE.
;       7/95 - RJB      for MacOs, strip the file name from the path+filename
;                       returned from OS_PICKFILE, and return the path.
;      12/97 - RJB      Replace obsolete OS_PICKFILE with DIALOG_PICKFILE
;-

FUNCTION valid_dir, dir
widget_control,/Hourglass
case !VERSION.OS of
'vms':      begin
            CD, current = here   ; get pwd
            ; VMS directories can be files, NAME.DIR, or paths DEVICE:[NAME.NAME].
            ; If the "[]" method is used, tack on a wildcard spec (*.*), otherwise
            ; the value of dir is a filename and it can remain the same.
            if(strpos(dir,']') gt -1)then dir = dir + "*.*"
            context = 0L
            resultant = STRING(BYTARR(256)+32B)
            ; See if either Name.dir file exists in the current directory or
            ; if a path specified see if there is any files in that dir.
            ; Use vms LIB$ routines via Call External
            result = CALL_EXTERNAL("LIBRTL", "LIB$FIND_FILE", dir, resultant,$
		                               context, here, 0L, 0L, 0L, $
		                               VALUE = [0, 0, 0, 0, 1, 1, 1])
            toss = CALL_EXTERNAL("LIBRTL", "LIB$FIND_FILE_END", context)
            return, (result EQ 65537)
            end
'windows' : begin
            return,1 ; Hook into common dialogs for windows when this really works
            end
else:       begin
           ; Can't CD to a directory unless the user has execute permission.
           ; Use the unix command test to check this. Have to use sh5 on ultrix
           ; Test sets the shell status variable and echo prints it out. This is
           ; then captured by spawn and placed in result
           if (!version.os ne 'ultrix') then $
             spawn, ['test -d "'+dir +'" -a -x "'+dir+'" ; echo $?'], result, /sh $
           else $
             spawn, ['/bin/sh5 -c "test -d '+dir+' -a -x '+dir+' ";echo $?'], $
                     result, /sh
           return, (not fix(result(0)) )  ;convert result to int and NOT it.
           end
endcase
end




FUNCTION getfiles, filter
WIDGET_CONTROL, /HOUR
IF (!VERSION.OS EQ "vms") THEN BEGIN
  results = findfile(filter)
  IF (KEYWORD_SET(results)) THEN BEGIN
    endpath = STRPOS(results(0), "]", 0) + 1
    results = strmid(results, endpath, 100)
    dirs = WHERE(STRPOS(results, ".DIR", 0) EQ -1, found)
    IF (found GT 0) THEN BEGIN
      results = results(dirs)
      return, results
    ENDIF
  ENDIF
ENDIF ELSE IF !VERSION.OS EQ "windows" THEN BEGIN
  message,"Unsupported on this platform"
ENDIF ELSE BEGIN
  SPAWN, ["/bin/sh", "-c", "ls -laL " + filter + $
          " 2> /dev/null"], results, /NOSHELL     ;added -a to get all files
  IF(KEYWORD_SET(results)) THEN BEGIN
    firsts = STRUPCASE(STRMID(results, 0, 1))
    fileinds = (WHERE(((firsts EQ "F") OR (firsts EQ "-") OR $
                       (firsts EQ "l")), found))
    IF (found GT 0) THEN BEGIN
      results = results(fileinds)
      FOR i = 0, N_ELEMENTS(results) - 1 DO BEGIN
        spaceinds = WHERE(BYTE(results(i)) EQ 32)
        spaceindex = spaceinds(N_ELEMENTS(spaceinds) - 1)
        results(i) = STRMID(results(i), spaceindex + 1, 100)
      ENDFOR
      RETURN, results
    ENDIF
  ENDIF
ENDELSE
RETURN, ""
END


PRO Pickdir_ev, event
COMMON pickdir_c, pathtxt,filttxt,dirlist,filelist,ok,cancel,help,here,thedir,separator
WIDGET_CONTROL, filttxt, GET_VALUE = filt & filt = filt(0)
case event.id of
cancel:  begin
         thedir = ""
         WIDGET_CONTROL, event.top, /DESTROY
         end
filttxt: begin
         files = getfiles(filt)
         WIDGET_CONTROL, filelist, SET_VALUE = files
         WIDGET_CONTROL, filelist, SET_UVALUE = files
         end
dirlist: begin
         WIDGET_CONTROL, dirlist, GET_UVALUE = directories
         if (event.index GT N_ELEMENTS(directories) - 1) then return
         if (not valid_dir(directories(event.index))) then return
         if (!version.os EQ "vms") then begin
           ; Fixed logic error. If the users selects [-], the strpos/mid
           ; combo would return a null string. Added a check for [-],index=0
           if(event.index eq 0)then found=3 $ ; length of [-]
           else	found = STRPOS(directories(event.index), ".", 0)
           cd, STRMID(directories(event.index), 0, found)
           cd, CURRENT = here ; get pwd
         endif else if !version.os eq "windows" then begin
           message,"Unsupported on this platform"
         endif else begin
           cd, directories(event.index) & cd, CURRENT = here
           here = here + separator
         endelse
         WIDGET_CONTROL, pathtxt, SET_VALUE = here
         directories = getdirs() & files = getfiles(filt)
         WIDGET_CONTROL, filelist, SET_VALUE = files
         WIDGET_CONTROL, filelist, SET_UVALUE = files
         WIDGET_CONTROL, dirlist, SET_VALUE = directories
         WIDGET_CONTROL, dirlist, SET_UVALUE = directories
         end
pathtxt: begin
         WIDGET_CONTROL, pathtxt, GET_VALUE = newpath
         newpath = newpath(0)
         len = STRLEN(newpath) - 1
         IF STRPOS(newpath, '/', len) ne -1 then newpath = STRMID(newpath, 0, len)
         IF (valid_dir(newpath(0))) then begin        
           here = newpath(0) + separator & cd,here
           directories = getdirs() & files = getfiles(filt)
           WIDGET_CONTROL, filelist, SET_VALUE = files
           WIDGET_CONTROL, filelist, SET_UVALUE = files
           WIDGET_CONTROL, dirlist, SET_VALUE = directories
           WIDGET_CONTROL, dirlist, SET_UVALUE = directories
         endif else WIDGET_CONTROL, pathtxt, SET_VALUE = here
         end
ok:      begin
       	 WIDGET_CONTROL, pathtxt, GET_VALUE = temp
	       WIDGET_CONTROL, cancel, GET_UVALUE = existflag
	       if existflag then begin
           ON_IOERROR, print_error
	         OPENR, unit, temp(0), /GET_LUN & FREE_LUN, unit
	       endif
	       thedir = temp(0)
	       WIDGET_CONTROL, event.top, /DESTROY
	       return
	       print_error:
       	 WIDGET_CONTROL,pathtxt,SET_VALUE="!!! Invalid Directory Name !!!"
	       thedir = ""
         end
help:    begin
         XDISPLAYFILE, "", GROUP = event.top, TITLE = "Directory Selection Help", $
                           WIDTH = 50, HEIGHT = 12, $
         TEXT = ["    This selection widget lets you pick a ", $
                 "directory.  The directories are shown on the left.",$
			           "You can select a directory by clicking on it with",$
			           "the mouse.  Pressing the 'OK' button will accept",$
			           "the choice and the Cancel button will not.  To", $
			           "move into a subdirectory, click on its name in", $
			           "the directory list.  The path can also be modified", $
                 "to view files from a different directory.  The ", $
                 "full path name can also be typed directly into", $
                 "the Selection area.  The list of files, shown on",$
		           	"the right, can be modified by typing in a filter."]
		     end
else:
endcase
end

FUNCTION Pickdir, GROUP = GROUP, PATH = PATH, FILTER = FILTER, TITLE = TITLE, $
                  MUST_EXIST = MUST_EXIST, FIX_FILTER = FIX_FILTER, VALID=VALID
                  
COMMON pickdir_c,pathtxt,filttxt,dirlist,filelist,ok,cancel,help,here,thedir,separator
if n_elements(valid) ne 0 then return, valid_dir(valid)
if(XRegistered("Pickdir")) then return, 0

thedir = "" & existflag = 0 & cd, current=dirsave ; initialize local variables
case !VERSION.OS of
'vms'    : separator = '' ; VMS file separator
'windows': separator = '' ; Windows file separator
'MacOS'  : separator = "" ; Mac file separator
else     : separator = '/'; Unix and DOS file separator
endcase
if n_elements(PATH) eq 0 then begin
  PATH = dirsave + separator & here = PATH
endif else begin

  ;; When on a Dos platform the argument to CD cannot end in a '\' unless
  ;; it is a root directory of a drive (ie C:\). Because of this, check
  ;; If we must remove the last character of PATH. -KDB 2/4/94
  IF((!version.os eq 'windows')and  $
       (Strpos(path,'\', Strlen(PATH)-1)ne -1))THEN  BEGIN
         IF(strlen(path) gt 3)THEN  $ ; Root dirs are 3 chars long.
             path = Strmid( path, 0, Strlen(path)-1)
  ENDIF
  IF(STRPOS(PATH, separator,STRLEN(PATH)- 1) EQ -1)AND(PATH NE separator)THEN $
    PATH = PATH + separator
  CD, PATH & here = PATH
  
endelse

auto_exit = 0
if keyword_set(MUST_EXIST) then existflag = 0 else existflag = 0
if keyword_set(FIX_FILTER) then mapfilter = 0 else mapfilter = 1
if NOT keyword_set(TITLE) then TITLE="Please Select a Directory"

case !VERSION.OS of
'windows': begin ; Windows pickdir does NOT support NOCOMFIRM or FIX_FILTER
           ; default FILTER needs to be forced to *.* if none set
           if keyword_set(FILTER) then filt=FILTER else filt = "*.*"
           if n_elements(GROUP) eq 0 then GROUP=0
           junk = DIALOG_PICKFILE(GROUP=GROUP,FILTER=filt,TITLE=TITLE, $
                                  MUST_EXIST=existflag,GET_PATH=here)
           end
'MacOS'   :begin; Mac Standard File dialog pickdir does NOT support FIX_FILTER
          ; default FILTER is set to "*" if none set
          if keyword_set(FILTER) then filt = FILTER else filt = "*"
          if n_elements(GROUP) eq 0 then GROUP=0
          if keyword_set(WRITE) then wr=1 else wr=0
          if keyword_set(PATH) then pth=PATH else cd, current=pth
          junk = DIALOG_PICKFILE(GROUP=GROUP,FILTER=filt,TITLE=TITLE, $
                                 MUST_EXIST=existflag,FIX_FILTER=mapfilter, $
                                 GET_PATH=here,WRITE=wr,PATH=pth)
          thedir = junk & i=0 ; strip the filename, if any, from the junk
          while (i ne -1) do begin 
            i=strpos(junk,':',i) & if (i ne -1) then begin j=i & i=i+1 & endif
          endwhile
          if (thedir ne '') then thedir = strmid(junk,0,j+1)
          return,thedir
          end
ELSE:     begin ; Widget pickdir for the rest of IDL
          if keyword_set(FILTER) THEN filt = FILTER else filt = ""
          directories = getdirs() & files = getfiles(filt)
          version = widget_info(/VERSION)
          IF (version.style eq 'Motif') THEN osfrm = 0 ELSE osfrm = 1
          Pickdirbase = WIDGET_BASE(TITLE = TITLE, /COLUMN)
          filtbase =    WIDGET_BASE(Pickdirbase, /ROW, MAP = mapfilter)
          filtlbl =     WIDGET_LABEL(filtbase, VALUE = "Filter:")
          filttxt =     WIDGET_TEXT(filtbase, VAL = filt, /EDIT, XS = 10, FR = osfrm)
          selections =  WIDGET_BASE(Pickdirbase, /ROW, SPACE = 30)
          dirs =        WIDGET_BASE(selections, /COLUMN, /FRAME)
          lbl =         WIDGET_LABEL(dirs, VALUE = "Subdirectories          ")
          dirlist =     WIDGET_LIST(dirs,VALUE=directories,YSIZE=8,UVALUE=directories)
          fls =         WIDGET_BASE(selections, /COLUMN, /FRAME)
          lbl =         WIDGET_LABEL(fls, VALUE = "Files                   ")
          filelist =    WIDGET_TEXT(fls, VALUE = files, YSIZE = 8, /SCROLL)
          widebase =    WIDGET_BASE(Pickdirbase,/ROW)
          label =       WIDGET_LABEL(widebase,VALUE="Selection:")
          pathtxt =     WIDGET_TEXT(widebase,VAL=here,/EDIT,FR=osfrm,XS=42)
          rowbase =     WIDGET_BASE(Pickdirbase, SPACE = 20, /ROW)
          ok =          WIDGET_BUTTON(rowbase,VALUE="     Ok     ",UVALUE=auto_exit)
          cancel =      WIDGET_BUTTON(rowbase,VALUE="   Cancel   ",UVALUE=existflag)
          help =  WIDGET_BUTTON(rowbase, VALUE = "    Help    ")
          WIDGET_CONTROL, Pickdirbase, /REALIZE
          XManager, "Pickdir", Pickdirbase, EVENT_HANDLER = "Pickdir_ev", $
                     GROUP_LEADER = GROUP, /MODAL
          end
endcase
cd, dirsave
return, thedir
end
