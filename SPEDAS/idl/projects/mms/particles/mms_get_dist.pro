;+
;Procedure:
;  mms_get_dist
;
;
;Purpose:
;  Retrieve particle distribution structures/pointers from data loaded
;  into tplot. 
;
;
;Calling Sequence:
;  data = mms_get_dist( input_name [,trange=trange] [/times] [/structure] 
;                       [,probe=probe] [,species=species] 
;                       [,instrument=instrument] [,units=units] )
;
;
;Input:
;  input_name:  Name of tplot variable containing particle data (must be original name)
;  single_time: Return a single time nearest to the time specified by single_time (supersedes trange and index)
;  trange:  Optional two element time range
;  times:  Flag to return array of full distribution sample times
;  structure:  Flag to return structures instead of pointer to structures
;
;  probe: specify probe if not present or correct in input_name 
;  species:  specify particle species if not present or correct in input_name
;                e.g. 'hplus', 'i', 'e'
;  instrument:  specify instrument if not present or correct in input_name 
;                  'hpca' or 'fpi'
;  units:  (HPCA only) specify units of input data if not present or correct in input_name
;              e.g. 'flux', 'df_cm'  (note: 'df' is in km, 'df_cm' is in cm)
;
;
;Output:
;  return value:  Pointer to structure array or structure array if /structure used.
;                 Array of times if /times is used
;                 0 for any error case
;
;
;Notes:
;
;
;
;$LastChangedBy: egrimes $
;$LastChangedDate: 2016-12-05 11:22:40 -0800 (Mon, 05 Dec 2016) $
;$LastChangedRevision: 22435 $
;$URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/spdsoft/trunk/projects/mms/particles/mms_get_dist.pro $
;-

function mms_get_dist, tname, index, trange=trange, times=times, structure=structure, $
                       probe=probe, species=species, instrument=instrument, units=units, $
                       data_rate=data_rate, single_time = time_in

    compile_opt idl2, hidden


if undefined(instrument) then begin
  instrument = 'null'
  if stregex(tname, '^mms[1-4]_hpca_', /bool) then instrument = 'hpca'
  if stregex(tname, '^mms[1-4]_d[ei]s_', /bool) then instrument = 'fpi'
endif


case strlowcase(instrument) of
  'hpca': return, mms_get_hpca_dist(tname, index, trange=trange, times=times, structure=structure, probe=probe, species=species, units=units, single_time=time_in)
  'fpi': return, mms_get_fpi_dist(tname, index, trange=trange, times=times, structure=structure, probe=probe, species=species, single_time=time_in, data_rate=data_rate)
  'null': dprint, dlevel=1, 'Cannot determine instrument from variable name; please specify with INSTRUMENT keyword'
  else: dprint, dlevel=1, 'Unknown instrument: "'+instrument+'"'
endcase

return, 0

end