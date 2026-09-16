function spp_fld_select_server, server_string = server_string

  select_server_desc = [ $
    '0, LABEL, Select RFS server, CENTER', $
    '0, BUTTON, ' + $
    '128.32.147.120 - EM server (rflab.ssl.berkeley.edu)|' + $
    '128.32.147.149 - FM server (spffmdb.ssl.berkeley.edu)|' + $
    '192.168.0.202  - EM server (accessed from inside 214)|' + $
    '192.168.0.207  - FM server (accessed from inside 214),' + $
    'EXCLUSIVE,SET_VALUE=0, TAG=server_select', $
    '2, BUTTON, OK, QUIT, TAG=ok']

  server_form_str = cw_form(select_server_desc, /column)

  case server_form_str.server_select of
    0:server = 'rflab.ssl.berkeley.edu'
    1:server = 'spffmdb.ssl.berkeley.edu'
    2:server = '192.168.0.202'
    3:server = '192.168.0.207'
  endcase
  
  case server_form_str.server_select of
    0:server_string = 'rflab.ssl.berkeley.edu (EM server)'
    1:server_string = 'spffmdb.ssl.berkeley.edu (FM server)'
    2:server_string = '192.168.0.202 (EM server/LAN)'
    3:server_string = '192.168.0.207 (FM server/LAN)'
  endcase
  

  return, server

end