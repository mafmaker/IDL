;+
; NAME:
;   SPP_FLD_CDF_PUT_DATA
;
; PURPOSE:
;   Stores SPP/FIELDS data in a created CDF file.
;
; CALLING SEQUENCE:
;   spp_fld_cdf_put_data, fileid, data, close = close
;
; INPUTS:
;   FILEID: The file ID of the destination CDF file.
;   DATA: A single IDL hash which contains items to be put into the 
;     CDF file.  The items themselves are hashes.  Each data item is itself
;     an IDL hash which contains:
;       - the parsed information from the corresponding XML file definition
;         of the data item
;       - the set of CDF attributes which will be stored as metadata in the
;         CDF file
;       - the data itself, as an IDL list.  The list is converted into an
;         array before being stored in the CDF file.
;     Items which do not have defined CDF attributes are not stored in the
;     CDF file.
;   CLOSE: Set to 1 to close the CDF after putting in the data.
;
; OUTPUTS:
;   No explicit outputs are returned.  After completion, the data in the
;   input IDL hash is stored in the specified CDF file.
;
; EXAMPLE:
;   See call in SPP_FLD_MAKE_CDF_L1.
;
; CREATED BY:
;   pulupa
;
; $LastChangedBy: pulupalap $
; $LastChangedDate: 2017-01-11 16:14:34 -0800 (Wed, 11 Jan 2017) $
; $LastChangedRevision: 22579 $
; $URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/spdsoft/trunk/projects/SPP/fields/common/spp_fld_cdf_put_data.pro $
;-
pro spp_fld_cdf_put_data, fileid, data, close = close

  foreach data_item, data, item_name do begin

    null_ind = data_item['data'].Where(!NULL, count = null_count, $
      complement = non_null_ind, ncomplement = non_null_count)

    if data_item.HasKey('cdf_att') then begin

      cdf_atts = data_item['cdf_att']

      ; Check for null records.  If null records exist, then create
      ; a sparse CDF variable.  If no non-null records exist, then
      ; create a non-sparse variable.

      ; TODO: enable selective addition for sparse CDFs

      cdf_sparse = (null_count NE 0)

      if non_null_count GT 0 then begin

        if data_item.HasKey('convert_routine') then begin

          raw_data_array = data_item['data'].ToArray()
          data_array = call_function(data_item['convert_routine'], raw_data_array)

        endif else begin

          data_array = (data_item['data'].ToArray())

        endelse

        data_dim = size(data_array, /dim)
        data_ndim = n_elements(data_dim) - 1

        dprint, 'Data Type: ', size(data_array, /tname), dlevel = 3
        dprint, 'Data Dimensions: ', data_dim, dlevel = 3
        dprint, 'Number of CDF dimensions: ', data_ndim, dlevel = 3

      end

      if cdf_atts.HasKey('DATA_TYPE') then begin

        cdf_data_type = cdf_atts['DATA_TYPE']

      endif else begin

        cdf_data_type = 'CDF_FLOAT'

      endelse

      if non_null_count GT 0 then begin
        if data_ndim GT 0 then begin

          cdf_data_dims = data_dim[1:*]
          cdf_data_vary = intarr(data_ndim) + 1
          varid = cdf_varcreate(fileid, item_name, cdf_data_vary, $
            dim = cdf_data_dims, /REC_VARY, /ZVARIABLE, $
            _EXTRA = CREATE_STRUCT(cdf_data_type,1))

          ; TODO: this works for simple 2D spectra but for higher dimensions
          ; might need something different
          data_array = transpose(data_array)

        endif else begin

          varid = cdf_varcreate(fileid, item_name, /REC_VARY, /ZVARIABLE, $
            _EXTRA = CREATE_STRUCT(cdf_data_type,1))

        endelse

      endif else begin

        nelem = spp_fld_tmlib_item_nelem(data_item)

        fillval = spp_fld_tmlib_item_fillval(data_item)

        fill_arr = make_array(nelem, value = fillval)

        cdf_data_dims = [nelem]
        cdf_data_vary = [1]

        n_records = n_elements(data_item['data'])

        varid = cdf_varcreate(fileid, item_name, cdf_data_vary, $
          dim = cdf_data_dims, /REC_VARY, /ZVARIABLE, $
          _EXTRA = CREATE_STRUCT(cdf_data_type,1))

      endelse

      dprint, '', dlevel = 3
      dprint, 'Variable ', varid, item_name, $
        format = '(A, I6, A20)', dlevel = 3
      dprint, 'CDF Attributes: ', dlevel = 3

      foreach cdf_att, cdf_atts, cdf_attname do begin

        ;if cdf_attname NE 'DEPEND_0' then begin

        cdf_attput, fileid, cdf_attname, varid, cdf_att, /zvariable

        dprint, cdf_attname, cdf_att, dlevel = 3, $
          format = '(A20, " ", A40)'

        if cdf_attname EQ 'VAR_SPARSERECORDS' then begin

          if cdf_att EQ 'PAD_MISSING' then begin
            cdf_control, fileid, var = item_name, SET_SPARSERECORDS = 'PAD_SPARSERECORDS'
          endif

        endif

        ;end

      endforeach

      if non_null_count GT 0 then begin

        cdf_varput, fileid, item_name, data_array

      endif else begin

        print, 'No non-null records for ', item_name

        ; Get the number of elements in the data item

        ; TODO: fix this kludge

        ;cdf_varput, fileid, item_name, fill_arr, rec_start = n_records - 1

        ;stop

      endelse

    endif else begin

      if data_item.HasKey('cdf_att') EQ 0 then $
        print, 'CDF attributes not defined for ', item_name

    endelse

  endforeach

  if keyword_set(close) then cdf_close, fileid

end