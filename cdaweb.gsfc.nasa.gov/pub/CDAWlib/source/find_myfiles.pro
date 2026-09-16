;$Author$
;$Date$
;$Header$
;$Locker$
;$Revision$
PRO find_myfiles, filter, path, filelist, RECURSIVE=RECURSIVE
if not keyword_set(RECURSIVE) then cd,current=cwd
Validate_myPATH, path & cd,path ; ensure path is valid for !OS
fnames = findfile()
w = where(strpos(strupcase(fnames),filter) ne -1,wc)
if (wc gt 0) then fnames = fnames(w)
if fnames(0) ne '' then begin
  fnames = path + fnames ; add path to filename
  listsize = size(filelist)
  if listsize(n_elements(listsize)-2) ne 0 then filelist = [filelist,fnames] $
  else filelist = fnames
endif
subdirs = getdirs() ; get list of all subdirectories
for i=1,n_elements(subdirs)-1 do begin
  oldpath = path & path = path+subdirs(i)
  find_myfiles,filter,path,filelist,/RECURSIVE
  path = oldpath ; reset for next subdirectory
endfor
if not keyword_set(RECURSIVE) then cd,cwd ; restore original directory
end


