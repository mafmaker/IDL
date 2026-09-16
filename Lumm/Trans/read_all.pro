pro read_all, subdir, path

; Driver to read all plotfiles from the transport code
; This code puts all data in common blocks and makes them
; so available to the subsequent plotting programs.

@common

if not keyword_set(path) then path='../output/'
if strmid(path, strlen(path)-1, 1) ne '/' then path=path+'/'

read_int, path+subdir
read_flx, path+subdir
read_exr, path+subdir
read_dep, path+subdir
read_atm, path+subdir
read_lbh, path+subdir

loadct, 5

return
end
