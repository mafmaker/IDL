function get_datasets, dataset_list, db, no_string=no_string
;searches for the specified dataset abreviated string, e.g. 'AC_' in the specified db file
;returns an array of dataset names that meet the criteria
if (n_elements(dataset_list) gt 0 and n_elements(db) gt 0) then begin
  for i = 0, n_elements(dataset_list)-1 do begin
     cmd = strarr(3)
     cmd(0) = "grep"
     cmd(1) = 'DATASET>'+dataset_list(i)
     cmd(2) = db
     spawn, cmd, /noshell, long_datasets
;print, 'DEBUG datasets found = ',long_datasets
     if (n_elements(long_datasets) ge 0) then begin
          if (n_elements(datasets_tmp) eq 0) then datasets_tmp = long_datasets else $
              datasets_tmp = [temporary(datasets_tmp),long_datasets]
     endif
  endfor
  if (n_elements(datasets_tmp) gt 0) then begin
     datasets = strmid(datasets_tmp,8)
     return, datasets
  endif else return, 'NO_DATASETS'
endif else begin
     print, 'please provide a valid DATASET abbreviation, e.g AC_ and/or a valid metadbase filename'
     return, 'NO_DATASETS'
 endelse
end
