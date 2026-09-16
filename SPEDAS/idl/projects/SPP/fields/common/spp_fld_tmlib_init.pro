pro spp_fld_tmlib_init, server = server

  if not keyword_set(server) then server = 'spffmdb.ssl.berkeley.edu'

  defsysv, '!TMLIB', exists = exists

  if not keyword_set(exists) then begin

    defsysv, '!TMLIB', {server:server}

  endif else begin

    !TMLIB.server = server

  end

  printdat, !tmlib, /values, varname = '!tmlib'

end