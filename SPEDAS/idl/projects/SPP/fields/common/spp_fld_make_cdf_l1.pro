pro spp_fld_make_cdf_l1, apid_name, $
  fileid = fileid, $
  varformat = varformat, $
  trange = trange, $
  filename = filename

  if not keyword_set(apid_name) then return ; TODO: Better checking and error reporting

  spp_fld_cdf_timespan, trange = trange, success = ts_success, $
    filename_timestring = filename_timestring

  if ts_success NE 1 then return ; TODO: error reporting here

  data = spp_fld_load_tmlib_data(apid_name, $
    varformat = varformat, success = dat_success, $
    cdf_att = cdf_att, times = times, idl_att = idl_att)

  if dat_success NE 1 then return ; TODO: error reporting here

  ;
  ; Create the CDF file
  ;

  spp_fld_cdf_create, 1, 0, cdf_att, filename_timestring, $
    filename = filename, fileid = fileid

  spp_fld_cdf_put_metadata, fileid, filename, cdf_att

  spp_fld_cdf_put_time, fileid, times.ToArray()
  
  spp_fld_cdf_put_depend, fileid, idl_att = idl_att

  spp_fld_cdf_put_data, fileid, data, /close

end