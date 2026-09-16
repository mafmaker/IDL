;The following two functions, Read_master_cdf and write_data_to_cdf are 
;intended to be used together.  The general purpose is to allow someone who might
;have data that's possibly stored in IDL save sets, to use the routines to 
;setup the "structure" of the cdf w/ a skeleton cdf. Then add their data to the
;cdf variables by simply setting the pointer variables and then write the data out
;to the desired cdf w/ the write_data_to_cdf routine.
;
;So a user's program might look like the following (w/o the comment characters):
;
;out_cdf = 'hk_test.cdf' 
;
;; Read the master cdf, copy its contents to our out_cdf and define a structure,
;; in this case "buf1" so that I may add the data to the variables.
;
;buf1 = read_master_cdf('hk_h0_vlf_00000000_v01.cdf',out_cdf)
;
;;buf1, would look like (a tag for each variable):
; EPOCH           STRUCT    -> <Anonymous> Array[1]
; E_FREQ          STRUCT    -> <Anonymous> Array[1]
; E_FREQ_DELTA    STRUCT    -> <Anonymous> Array[1]
;
;;help, /struct, buf1.epoch would reveal the structure for each variable
;  VARNAME         STRING    'e_spd'
;  DATA            POINTER   <PtrHeapVar1>
;
;
;Note: when needing to add character data to a string variable, you
;must blank fill your character arrays to match the variable size that
;you've defined in the cdf.  Here's an example:
;
;! Variable          Data      Number                 Record   Dimension
;! Name              Type     Elements  Dims  Sizes  Variance  Variances
;! --------          ----     --------  ----  -----  --------  ---------
;
;  "ask_names"
;                  CDF_CHAR       4       1     5       F         T
;
;  ! Attribute       Data
;  ! Name            Type       Value
;  ! --------        ----       -----
;
;    "FIELDNAM"    CDF_CHAR     { "ask_names" }
;    "FORMAT"      CDF_CHAR     { "A4" }
;    "VAR_TYPE"    CDF_CHAR     { "metadata" }
;    "VAR_NOTES"   CDF_CHAR     { "Names of stations with data in file" } .
;
;  ! NRV values follow...
;
;    [1] = { "    " }
;    [2] = { "    " }
;    [3] = { "    " }
;    [4] = { "    " }
;    [5] = { "    " }
;
;So, when defining the values to be loaded into the array elements, they
;must be, in this case, 4 characters long.  If they are shorter, w/o
;blank filling to 4 characters, they will not load.
;
;restore an IDL save set containing the data values for some variables
;restore, 'hk_vlf_74300.sav' 
;
;Epoch = double(num_rec)
;espd = fltarr(16,num_rec)
;bspd = fltarr(16,num_rec)
;bave = fltarr(num_rec)
;pos_mag = fltarr(3,num_rec)
;pos_gsm = fltarr(3,num_rec)
;seqno = indgen(num_rec)
;
;; copy values out of idl save set
;Epoch = arec.EPOCH
;espd = arec.spde
;bspd = arec.spdb
;bave = arec.BAVE
;pos_mag(0,*) = arec.RE
;pos_mag(1,*) = arec.MLAT
;pos_mag(2,*) = arec.MLT
;pos_gsm(0,*) = arec.XGSM
;pos_gsm(1,*) = arec.YGSM
;pos_gsm(2,*) = arec.ZGSM
;
;; Now set the buf1 structure data pointers for each variable to the appropriate
;; data arrays/values.
;
;*buf1.Epoch.data = epoch
;*buf1.E_SPD.data = espd
;*buf1.B_SPD.data = bspd
;*buf1.BAVE.data = bave
;*buf1.pos_mag.data = pos_mag
;*buf1.pos_GSM.data = pos_gsm
;*buf1.activity_index.data = seqno
;
;;write data in the above pointers back out to our new cdf
;
;stat2 = write_data_to_cdf(out_cdf, buf1)
;
;end
;
;
;
;Function: Read_master_cdf
;Purpose: To copy a "master" cdf and then read just the "data" and 
;"support_data" variables from it and create an IDL structure where each 
;structure tag is the name of a variable.  Each variable tag will then point 
;to a data pointer.  This structure is then returned to the user so that 
;they can fill each data pointer w/ the real data.  Once each pointer is 
;assigned real data, the user should call the write_data_to_cdf function 
;(below)
;
;Input arguments: 
;	master_cdf - name of the "skeleton/master" cdf which contains the
;		     cdf's metadata and variable "structure".
;	output_cdf - name of cdf file that will ultimately contain the metadata
;		     and data.
;Keywords: 
;	debug - set this if you want to see a few status messages
;
;Output:
;	final - an idl structure which looks like the following:
;
;Modification History:
;	Initial version written by Tami Kovalick, Raytheon ITSS 12/1/1999
;
;this function returns a structure

Function read_master_cdf, master_cdf, output_cdf, debug=debug

;1st make a copy of the master into the requested output cdf
cmd = strarr(3)
cmd(0) = "cp"
cmd(1) = master_cdf
cmd(2) = output_cdf
spawn, cmd, /noshell
;
; now change the protection so that updates can be made to the new cdf
; HAL 8/1/2000
;
cmd(0) = "chmod"
cmd(1) = "+w"
cmd(2) = output_cdf
spawn, cmd, /noshell


;set the quiet flag so that various non relevant CDF warning messages are
;not displayed.
!quiet = 1

;now work on the output_cdf

;get the list of data variables from the cdf

;TJK 11/7/2006 - change this to just get all the variables in one call
;data_vars = get_allvarnames(cname=output_cdf, var_type='data')
;meta_vars = get_allvarnames(cname=output_cdf, var_type='support_data')
all_vars = get_allvarnames(cname=output_cdf)

if keyword_set(debug) then print, 'Setting up an IDL structure for the following variables ',all_vars

num_vars = n_elements(all_vars)

for d = 0, num_vars-1 do begin
  meta = create_struct('varname', all_vars(d)) 
  ptr = create_struct('data',ptr_new(/allocate_heap))
  d_struct = create_struct(meta, ptr)
  if (d eq 0) then  final = create_struct(all_vars(d),d_struct)
  if (d gt 0) then begin
    d_struct = create_struct(all_vars(d),d_struct)
    final = create_struct(final, d_struct)
  endif
endfor


return, final
end

function write_data_to_cdf, output_cdf, a_struct, debug=debug

;Purpose: To take a structure produced by read_master_cdf and insert the "data"
;arrays into their associated CDF variables.  The routine also defines the 
;global attribute logical_file_id for the output_cdf to be the filename 
;specified with any directory and .cdf extensions stripped off.
;
;Note: the data pointers for each of the variables need to be filled in by
;the calling program.
;
;Written by TJK 11/12/1999

num_vars = n_tags(a_struct)

if (num_vars gt 0) then begin
  cdf_id = cdf_open(output_cdf)
  ;need to determine the logical_file_id which is just the filename
  ;not including any directory/pathname and not including the .cdf extension.

  logical_file_id = output_cdf
  period = rstrpos(logical_file_id, '.') ;find position of last '.'
  if (period gt -1) then logical_file_id = strmid(output_cdf,0,period)

  slash = rstrpos(logical_file_id, '/') ;find position of last '/'
  if (slash gt -1) then logical_file_id = strmid(logical_file_id,slash+1)
  
;  if (cdf_id gt 0) then begin ; cdf_id can be negative when file is successfully opened
    if keyword_set(debug) then print, 'Successfully opened CDF ',output_cdf

    ; need to change the logical_file_id global attribute here... check for
    ; existance first
    attexst = cdf_attexists(cdf_id,'Logical_file_id')
    if (attexst) then begin
      attid = cdf_attnum(cdf_id, 'Logical_file_id')
      cdf_attput, cdf_id, attid, 0L, logical_file_id
      if keyword_set(debug) then print, 'Changed logical_file_id attribute to ',logical_file_id
    endif

    ; Set the Generation_date global attribute value here...
    attexst = cdf_attexists(cdf_id,'Generation_date')
    if (attexst) then begin
      attid = cdf_attnum(cdf_id, 'Generation_date')
      today = systime()
      cdf_attput, cdf_id, attid, 0L, today
      if keyword_set(debug) then print, 'Set Generation_date attribute value to ',today
    endif

    for i = 0, num_vars - 1 do begin
	  ;test to make sure some data is actually in the data pointer
	  if (size(*a_struct.(i).data,/type) gt 0) then begin
	    cdf_varput, cdf_id, a_struct.(i).varname, *a_struct.(i).data
            
	  if keyword_set(debug) then  print, 'data put in cdf var, ',a_struct.(i).varname
	  endif else begin
		if keyword_set(debug) then print, 'No data found in pointer for ',a_struct.(i).varname
	  endelse
    endfor
;  endif else print, 'Could not open CDF ',output_cdf
  cdf_close, cdf_id

endif else begin
	print, 'No variables in structure. ' 
	help, /struct, a_struct
endelse

for i = 0, num_vars - 1 do begin
  if (ptr_valid(a_struct.(i).data)) then begin
	if keyword_set(debug) then print, 'Freeing pointer for ',a_struct.(i).varname
	ptr_free, a_struct.(i).data
	if (ptr_valid(a_struct.(i).data) and keyword_set(debug)) then print, 'Pointer not deleted.'
  endif
endfor

!quiet = 0; turn messages back on
return, 1
end
