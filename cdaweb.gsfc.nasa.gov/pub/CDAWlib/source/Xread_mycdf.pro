;$Author: kovalick $
;$Date: 1996/08/16 15:15:07 $
;$Header: /home/rumba/cdaweb/dev/control/RCS/Xread_mycdf.pro,v 1.3 1996/08/16 15:15:07 kovalick Exp kovalick $
;$Locker: kovalick $
;$Revision: 1.3 $
;This file contains the widget routines (written in IDL) that are used
;for the Xread_mycdf screen.  See the bottom of the file for how
;to call the function,

; Notes: Do not make original call with RECURSIVE keyword set
;        Files get appended to filelist.  If filelist is not
;        empty on original call, you might not get what you want
; IDL 4.0.1b BUG : The filter capability of findfile will not work if too
;                  many files exist within the directory.  Therefore, do
;                  the filtering external to the findfile call until
;                  this bug is fixed.

PRO pick_myVARIABLES_event,event
WIDGET_CONTROL,event.top,Get_UValue=info
case event.id of
  info.ALLwid    : begin
                   WIDGET_CONTROL,info.LISTwid,Get_Value=bvals
                   for i=0,n_elements(bvals)-1 do bvals(i)=1
                   WIDGET_CONTROL,info.LISTwid,Set_Value=bvals
                   end
  info.NONEwid   : begin
                   WIDGET_CONTROL,info.LISTwid,Get_Value=bvals
                   for i=0,n_elements(bvals)-1 do bvals(i)=0
                   WIDGET_CONTROL,info.LISTwid,Set_Value=bvals
                   end
  info.CANCELwid : begin
                   WIDGET_CONTROL,info.LISTwid,Get_Value=bvals
                   for i=0,n_elements(bvals)-1 do bvals(i)=0
                   HANDLE_VALUE,info.vlisthid,bvals,/SET
                   WIDGET_CONTROL,event.top,/DESTROY
                   end
  info.READwid   : begin
                   WIDGET_CONTROL,info.LISTwid,Get_Value=bvals
                   HANDLE_VALUE,info.vlisthid,bvals,/SET
                   WIDGET_CONTROL,event.top,/DESTROY
                   end
  else : ; do nothing
endcase
end


PRO pick_myVARIABLES, file, svnames
CDFid  = cdf_open(file) ; open the cdf file
cinfo  = cdf_inquire(CDFid) ; inquire about the cdf
vnames = get_allvarnames(CDFID=CDFid)
vlist  = strarr(n_elements(vnames))
mxvlen = max(strlen(vnames))

;nvars  = cinfo.nvars + cinfo.nzvars ; compute total number of variables
;vnames = strarr(nvars) & vlist = strarr(nvars); create string arrays
;for i=0,nvars-1 do begin
;  zflag = 0L & conseq_error_count = 0L
;  catch, error_status ; setup an error handler to catch z-variables
;  if (error_status ne 0) then begin
;    zflag = 1L & conseq_error_count = conseq_error_count + 1
;    if (conseq_error_count gt 1) then begin
;      print,'ERROR> While getting list of variable names' & return
;    endif
;  endif
;  vinfo = cdf_varinq(CDFid,i,ZVARIABLE=zflag)
;  vnames(i) = vinfo.NAME
;endfor

; Determine the attribute numbers of the 'FIELDNAM' and 'VAR_TYPE' vattrs
error_status = 0   ; initialize error flag
catch,error_status ; set up exception handler to handle missing 'FIELDNAM'
if (error_status ne 0) then fnanum = -1 $
else fnanum = cdf_attnum(CDFid,'FIELDNAM')
error_status = 0   ; initialize error flag
catch,error_status ; set up exception handler to handle missing 'VAR_TYPE'
if (error_status ne 0) then vtanum = -1 $
else vtanum = cdf_attnum(CDFid,'VAR_TYPE')

for i=0,n_elements(vnames)-1 do begin ; construct the list of variables name
  if (vtanum ne -1) then begin
    a = read_myATTRIBUTE(vnames(i),vtanum,CDFid)
    vtype = a.VAR_TYPE
  endif else vtype = '    '
  if (fnanum ne -1) then begin
    b = read_myATTRIBUTE(vnames(i),fnanum,CDFid)
    fname = b.FIELDNAM
  endif else fname = 'FIELDNAM attribute not present'
  pad1 = ' ' & for j=0,(mxvlen+4)-strlen(vnames(i)) do pad1 = pad1 + ' '
  pad2 = '   ' & if (strupcase(vtype) eq 'DATA') then pad2 = '       '
  vlist(i) = vnames(i) + pad1 + vtype + pad2 + fname
endfor
cdf_close,CDFid

; Assemble the display of variables
base  = WIDGET_BASE(/COLUMN,Title='Select CDF Variables',/FRAME)
base1 = WIDGET_BASE(base,/COLUMN,/FRAME)
base2 = WIDGET_BASE(base,/ROW,/FRAME)
scroll=0 & ysize=0 ; initialize
if (n_elements(vlist) gt 10) then begin scroll=1 & ysize=20 & endif
bvals = lonarr(n_elements(vlist))
mxlen = max(strlen(vlist)) & if (mxlen gt 40) then mxlen=80
lab1v = strtrim(string(n_elements(vlist)),2) + ' Variables'
lst1a = CW_BGROUP(base1,vlist,/NONEXCLUSIVE,SCROLL=scroll,SET_VALUE=bvals,$
                  LABEL_TOP=lab1v,Y_Scroll_Size=(20*!D.y_ch_size),$
                  X_Scroll_Size=(mxlen * !D.x_ch_size))
but2a = WIDGET_BUTTON(base2,Value='Read Selected Variable(s)')
but2b = WIDGET_BUTTON(base2,Value='Select All')
but2c = WIDGET_BUTTON(base2,Value='Select None')
but2d = WIDGET_BUTTON(base2,Value='Cancel')
; Assemble information needed by event handler
vlisthid = HANDLE_CREATE()
info  = {LISTwid:lst1a,ALLwid:but2b,NONEwid:but2c,$
         READwid:but2a,CANCELwid:but2d,VLISThid:vlisthid}
WIDGET_CONTROL,base,Set_UValue=info
WIDGET_CONTROL,base,/REALIZE
Xmanager,'pick_myVARIABLES',base,/MODAL
; Determine the selected variable names
HANDLE_VALUE, vlisthid, bvals & HANDLE_FREE, vlisthid
w = where(bvals eq 1,wc)
if (wc gt 0) then svnames = vnames(w)
end


PRO Pick_myCDF_event,event
WIDGET_CONTROL,event.top,Get_UValue=info
case event.id of
info.CHANGEwid : begin ; user wants to change directories
                 path = PickDir(/MUST_EXIST)
                 if (path ne '') then begin ; user has selected new path
                   Validate_myPath,path
                   WIDGET_CONTROL,info.PATHwid,Set_Value=path
                   ; recreate list of cdf files using the new path
                   WIDGET_CONTROL,event.top,/DESTROY
                   pick_myCDF,cnames,vnames,PATH=path ; recreate CDF list
                   HANDLE_VALUE,info.VNAMEShid,vnames,/SET
                   HANDLE_VALUE,info.CNAMEShid,cnames,/SET
                 endif
                 end
info.PATHwid   : begin ; user wants to change to a specific directory
                 WIDGET_CONTROL,info.PATHwid,Get_Value=path
                 Validate_myPath,path(0)
                 ; recreate list of cdf files using the new path
                 WIDGET_CONTROL,event.top,/DESTROY
                 pick_myCDF,cnames,vnames,PATH=path(0) ; recreate CDF list
                 HANDLE_VALUE,info.VNAMEShid,vnames,/SET
                 HANDLE_VALUE,info.CNAMEShid,cnames,/SET
                 end
info.ALLwid    : begin ; select all files
                 WIDGET_CONTROL,info.LISTwid,Get_Value=bvals
                 for i=0,n_elements(bvals)-1 do bvals(i)=1
                 WIDGET_CONTROL,info.LISTwid,Set_Value=bvals
                 end
info.NONEwid   : begin ; UNselect all files
                 WIDGET_CONTROL,info.LISTwid,Get_Value=bvals
                 for i=0,n_elements(bvals)-1 do bvals(i)=0
                 WIDGET_CONTROL,info.LISTwid,Set_Value=bvals
                 end
info.OPENwid   : begin
                 WIDGET_CONTROL,/hourglass
                 WIDGET_CONTROL,info.LISTwid,Get_Value=bvals
                 WIDGET_CONTROL,info.PATHwid,Get_Value=path
                 w = where(bvals ne 0,wc)
                 if (wc eq 0) then return ; no cdf's selected
                 fnames = strarr(wc) & cnum = 1 & proceed = 1
                 fnames(0) = path(0) + info.files(w(0))
                 while (cnum lt wc)AND(proceed eq 1) do begin
                   ; Verify that the CDFs are structurally equivalent
                   if cnum eq 1 then begin ; special first case processing
                     print,'Verifying that selected CDFs are equivalent...'
                     cid1 = cdf_open(fnames(0))
                   endif
                   fnames(cnum) = path(0) + info.files(w(cnum))
                   cid2 = cdf_open(fnames(cnum)) ; open next cdf
                   e = Compare_myCDFs(cid1,cid2)
                   if e eq 0 then print,'Files ',fnames(0),' and ',$
                   fnames(cnum),' are NOT equivalent!'
                   cdf_close,cid2 ; close the cdf
                   if (e eq 1) then cnum=cnum+1 else proceed = 0
                 endwhile
                 if (proceed eq 1) then begin ; selected CDFs are equivalent
                   ; select the variables from the cdf
                   pick_myVARIABLES, fnames(0), vnames
                   HANDLE_VALUE,info.VNAMEShid,vnames,/SET
                   HANDLE_VALUE,info.CNAMEShid,fnames,/SET
                   WIDGET_CONTROL,event.top,/DESTROY
                 endif
                 end
info.QUITwid   : WIDGET_CONTROL,event.top,/DESTROY
info.LISTwid   : ; do nothing
else           : ; do nothing
endcase
end


PRO pick_myCDF,cnames,vnames,PATH=path
cd,current=cwd  ; Get the current directory and remember it
filter = '*.cdf' ; search for the cdf extension
if keyword_set(PATH) then begin
  cd, path & files = findfile()
  w = where(strpos(strupcase(files),'.CDF') ne -1,wc)
  if (wc gt 0) then files = files(w)
endif else begin
  path=cwd & files = findfile() & Validate_myPATH,path
  w = where(strpos(strupcase(files),'.CDF') ne -1,wc)
  if (wc gt 0) then files = files(w)
endelse

; layout widget structure
base  = WIDGET_BASE(/COLUMN,TITLE='Select your CDFs',/FRAME)
base1 = WIDGET_BASE(base,/ROW,/FRAME) ; base for path information
base2 = WIDGET_BASE(base,/COLUMN,/FRAME) ; base for file list
lab1a = WIDGET_LABEL(base1,VALUE='Current path:')
txt1a = WIDGET_TEXT(base1,VALUE=path,XSIZE=strlen(cwd)+10,/EDITABLE)
but1a = WIDGET_BUTTON(base1,VALUE='Change path')
if (files(0) eq '') then begin
  lab2a = WIDGET_LABEL(base2,VALUE='No files in current directory')
  but3d = WIDGET_BUTTON(base2,VALUE='QUIT')
  lst2a = 0L & but3a = 0L & but3b = 0L & but3c = 0L
endif else begin
  scroll=0 & ysize=0 ; initialize
  if (n_elements(files) gt 10) then begin & scroll=1 & ysize=20 & endif 
  lab2v = strtrim(string(n_elements(files)),2) + ' Files'
  bvals = lonarr(n_elements(files))
  lst2a = CW_BGROUP(base2,files,/NONEXCLUSIVE,SCROLL=scroll,SET_VALUE=bvals,$
                    LABEL_TOP=lab2v,Y_Scroll_Size=(20*!D.y_ch_size),$
                    X_Scroll_Size=(40*!D.x_ch_size),/FRAME)
  base3 = WIDGET_BASE(base,/ROW,/FRAME)
  but3a = WIDGET_BUTTON(base3,Value='Open selected CDF(s)')
  but3b = WIDGET_BUTTON(base3,Value='Select All')
  but3c = WIDGET_BUTTON(base3,Value='Select None')
  but3d = WIDGET_BUTTON(base3,Value='Quit')
endelse

; Save info needed for the event handler and realize
VNAMEShid = HANDLE_CREATE() & CNAMEShid = HANDLE_CREATE()
info = {PATHwid:txt1a, LISTwid:lst2a, CHANGEwid:but1a, OPENwid:but3a,$
        ALLwid:but3b, NONEwid:but3c, QUITwid:but3d,files:files,filter:filter,$ 
        VNAMEShid:VNAMEShid,CNAMEShid:CNAMEShid}

WIDGET_CONTROL,base,Set_UValue=info
WIDGET_CONTROL,base,/REALIZE
XManager,'Pick_myCDF',base,/MODAL

; Recover the anonymous structure containing the data and metadata
HANDLE_VALUE,info.VNAMEShid,vnames & HANDLE_FREE,VNAMEShid
HANDLE_VALUE,info.CNAMEShid,cnames & HANDLE_FREE,CNAMEShid
cd,cwd ; Restore directory to what it was when you began
end


FUNCTION Xread_mycdf,NODATASTRUCT=NODATASTRUCT,DEBUG=DEBUG
; Display list of cdf's within the current directory
pick_mycdf,cnames,vnames
; determine if user selected cdf and variables or quit
a = size(cnames) & b = size(vnames)
if (a(n_elements(a)-2) eq 0)OR(b(n_elements(b)-2) eq 0) then return,-1 $
else begin
  if keyword_set(DEBUG) then begin
    for i=0,n_elements(vnames)-1 do print,'VarName=',vnames(i)
    for i=0,n_elements(cnames)-1 do print,'CDFName=',cnames(i)
  endif else print,'STAND BY: Now reading the CDF file(s)'
  if keyword_set(DEBUG) then df = 1 else df = 0
  widget_control,/hourglass
  if NOT keyword_set(NODATASTRUCT) then a = read_mycdf(vnames,cnames,DEBUG=df) $
  else a = read_mycdf(vnames,cnames,/NODATASTRUCT,DEBUG=df)
endelse
return,a
end
