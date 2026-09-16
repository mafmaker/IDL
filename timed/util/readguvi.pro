;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; readguvi.pro - This file contains IDL functions to read netCDF data files
;               into IDL variables.
;
;  This file contains the following functions and procedures:
;     procedures:
;        read_ncdf - reads netCDF variables into IDL
;
;  History:
;  Date       Name          Action
;  ---------  ------------  ----------------------------------------------
;  06 Jun 97  S. Rupert     Created.
;  09 Jun 97  S. Rupert     Fully tested.
;  10 Jun 97  S. Rupert     Modified keyword usage.
;  03 Feb 98  S. Rupert     Added additional error checking, and warning to
;                           output script.
;  17 Feb 98  S. Rupert     Corrected validation routine to handle instance
;                           of name strating with a number and containing a
;                           dash.
;  17 Mar 02  D. Morrison   Changed routine to return data into a structure
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


pro readguvi, infile, data, attrib=attrib
; pro_description, infile
; This procedure reads the data in a given netCDFfile into an IDL data structure
; Inputs:           infile  - full path to netCDF file of interest
;                   attrib - includes extractions of all input file
;                             attributes in idl script
; Outputs:          data - structure into which data is returned
; Example:  read_ncdf, '/vol1/cids/netCDF.file', data, /attrib

; Establish that the correct data have been input.
if n_params() LT 1 then begin
   print, "Usage: readguvi, filename, guvi, attrib=attrib
   return
endif

; Ensure that the netCDF format is supported on the current platform.
if not(ncdf_exists()) then begin
   print, "The Network Common Data Format is not supported on this platform."
   return
endif

; Open the netcdf file for reading.
ncid = NCDF_OPEN(infile)
if (ncid EQ -1) then begin
   print, "The file "+infile+" could not be opened, please check the path."
   return
endif

; Retrieve general information about this netCDF file.
ncidinfo = NCDF_INQUIRE(ncid)

; Place the desired variables in local arrays.
for i=0, ncidinfo.Nvars-1 do begin
   vardata = NCDF_VARINQ(ncid, i)
   valid_varname = vardata.Name
   varname=valid_varname
   NCDF_VARGET, ncid, i, varname      ; Read in variable vardata.Name
   if i eq 0 then begin
 		data = create_struct(valid_varname,varname)
   		endif else begin
   		  data = create_struct(data, valid_varname,varname)
   		endelse
   if (keyword_set(attrib)) then begin
      for j=0, vardata.Natts-1 do begin
         att = NCDF_ATTNAME(ncid, i, j)
         attname = strcompress(valid_varname+"_"+strcompress(att,/REMOVE_ALL))
         valid_attname = attname
         NCDF_ATTGET, ncid, i,att,attname
         attname = STRING(attname)
   		 data = create_struct(data, valid_attname,attname)
      endfor
   endif
endfor

if (keyword_set(attrib)) then begin
  ; Read in the Global Attributes."
  for i=0, ncidinfo.Ngatts-1 do begin
     name = NCDF_ATTNAME(ncid, /GLOBAL, i)
     attname = validateName(name)
	 valid_attname = attname
     NCDF_ATTGET, ncid, /GLOBAL, name, attname
     attname = STRING(attname)
     data = create_struct(data, valid_attname, attname)
  endfor
 endif

NCDF_CLOSE, ncid      ; Close the NetCDF file"

; Return to the caller.
return

; End procedure.
end

