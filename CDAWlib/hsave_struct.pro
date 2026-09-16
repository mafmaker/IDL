;$Author: kovalick $
;$Date: 2010/07/09 14:33:43 $
;$Header: /home/cdaweb/dev/control/RCS/hsave_struct.pro,v 1.2 2010/07/09 14:33:43 kovalick Exp johnson $
;$Locker: johnson $
;$Revision: 1.2 $
; Utilize IDL's SAVE procedure to save the structure a into the given filename.
;If data is stored in handles, make .dat structure tags and extract
;the data from the handles and put into the .dat tags, then wipe out
;the .handle tags.
FUNCTION hsave_struct,a,fname, debug=debug, nosave=nosave

if (tagindex('HANDLE',tag_names(a.(0))) eq -1) then begin
  if (not(keyword_set(nosave)))then begin ;save the buffer to the save file
    ; data is stored directly in the structure
    SAVE,a,FILENAME=fname
    endif else begin ;return the structure as is, since the data is already in the .dat tags
      return, a
    endelse

endif else begin
  ; data is stored in handles.  Retrieve the data from the handles,
  ; create .dat and re-create the structure, then SAVE to file.
  tn = tag_names(a) & nt = n_elements(tn) & cmd = 'SAVE,'

  for i=0,nt-1 do begin ; retrieve each handle value
    order = 'handle_value,a.(i).HANDLE,data'
     status = EXECUTE(order)
     a.(0).handle = 0
     tmp = create_struct(a.(i),'dat',data)
     if (i eq 0) then data_buf = create_struct(a.(i).varname, tmp) else $
     data_buf = create_struct(data_buf, a.(i).varname, tmp)
   endfor

  if (not(keyword_set(nosave)))then begin ;save the buffer to the save file
    ; Add the filename keyword to save command
    cmd = cmd+"data_buf,FILENAME='"+fname+"'"
    if keyword_set(debug) then print, 'Saving data contents to ',fname
    status = execute(cmd) ; execute the save command
  endif else begin ;otherwise return the buffer to the calling program
    return, data_buf
  endelse

endelse
end

