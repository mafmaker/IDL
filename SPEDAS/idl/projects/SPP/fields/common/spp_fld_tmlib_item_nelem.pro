function spp_fld_tmlib_item_nelem, item_hash

  nelem = 1l

  if item_hash.HasKey('nblk') then $
    nelem = long((item_hash)['nblk'])

  if item_hash.HasKey('nelem') and nelem EQ 1l then $
    nelem = long((item_hash)['nelem'])
      
  return, nelem

end