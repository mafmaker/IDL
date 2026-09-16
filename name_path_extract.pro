pro name_path_extract,full,imfile,path,vms=vms,noroot=noroot

;
;  Author :  Thomas Immel
;  Date   :  11-3-98
;  Purpose : Extract filename and path from extended strings
;  Notes   : Untested on VMS!
;
;	     11-4-98 - Made vms_flag switchable by vms keyword
;	     11-9-98 - for filenames where the path does not start
;			with the root dir (/.), added /noroot keyword
;	     11-9-98 - Overly complex and needs a rewrite already!
;            3-6-18  - Fix ( vs [ problem for newest IDL
;
;--------------------------------------------------------------

if keyword_set(vms) then vms_flag = 1 else vms_flag=0
if keyword_set(noroot) then root_flag=0 else root_flag=1

  if VMS_flag then begin
    slength=strlen(full)
    bracket=strpos(full,']')
    path=strmid(imfile,0,bracket+1)
    imfile=strmid(imfile,bracket+1,slength-bracket-1)
    bracket=strpos(imfile,']')
  endif else begin
    directories=(strsplit(full,'/', /extract))
    dir_size=size(directories) & dir_size=dir_size[1]
    if dir_size eq 1 then begin
	path='.'
	imfile=directories
        goto,skip_path_compress
    endif 
    if dir_size eq 2 then begin
	imfile=directories[1]
	path=directories(0) + '/'
	if root_flag then path='/' + path
        goto, skip_path_compress
    endif else begin
      imfile=directories[dir_size-1]
      if root_flag then directories[*]='/' + directories[*] $
	else for jj=1,dir_size-1 do directories[jj]='/' + directories[jj]
  endelse
      path_arr=strcompress(directories[0:dir_size-2],/rem) 
                                ;ok except for dirs one level below /
      path=''
      for ii=0,dir_size-2 do path=path + path_arr[ii]
      path=path + '/'

SKIP_PATH_COMPRESS:

;stop

  endelse

return
end
