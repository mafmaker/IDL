pro scan_index, titles, n_tn=n_tn, n_un=n_un, n_vn=n_vn, n_o2_=n_o2, $
   n_ox=n_ox, n_n4s=n_n4s, n_noz=n_noz, n_co1=n_co, n_co2=n_co2, $
   n_h2o=n_h2o, n_h2_=n_h2, n_hox=n_hox, n_op=n_op, n_ch4=n_ch4, $
   n_o21d=n_o21d, n_no2=n_no2, n_no1=n_no, n_o3=n_o3, n_o1=n_o1, $
   n_oh=n_oh, n_ho2=n_ho2, n_h1=n_h, n_n2d=n_n2d, n_ti=n_ti, n_te=n_te, $
   n_ne=n_ne, n_o2p=n_o2p, n_w=n_w, n_z=n_z, n_pot=n_pot, n_qj=n_qj, $
   n_qt=n_qt, n_qei=n_qei, n_qic=n_qic, n_qnc=n_qnc, n_qsrb=n_qsrb, $
   n_qsrc=n_qsrc, n_qo3=n_qo3, n_qa=n_qa, n_qeuv=n_qeuv, n_qo2=n_qo2, $
   n_qdh=n_qdh, n_qgw=n_qgw, n_qm=n_qm

; subroutine to scan title index to find and identify fields.
; returned parameters are indices to appropriate fields, if present.
; if not present, return -1

; by Chris Hackert, June 5, 2002

; added heating Q* to search list

n = n_elements(titles)

; version 3 type labels
n_tn = where(titles eq 'TN')
n_un = where(titles eq 'UN')
n_vn = where(titles eq 'VN')
n_o2 = where(titles eq 'O2')
n_ox = where(titles eq 'OX')
n_n4s = where(titles eq 'N4S')
n_noz = where(titles eq 'NOZ')
n_co = where(titles eq 'CO')
n_co2 = where(titles eq 'CO2')
n_h2o = where(titles eq 'H2O')
n_h2 = where(titles eq 'H2')
n_hox = where(titles eq 'HOX')
n_op = where(titles eq 'OP')
n_ch4 = where(titles eq 'CH4')
n_o21d = where(titles eq 'O21D')
n_no2 = where(titles eq 'NO2')
n_no = where(titles eq 'NO')
n_o3 = where(titles eq 'O3')
n_o1 = where(titles eq 'O1')
n_oh = where(titles eq 'OH')
n_ho2 = where(titles eq 'HO2')
n_h = where(titles eq 'H')
n_n2d = where(titles eq 'N2D')
n_ti = where(titles eq 'TI')
n_te = where(titles eq 'TE')
n_ne = where(titles eq 'NE')
n_o2p = where(titles eq 'O2P')
n_w = where(titles eq 'W')
n_z = where(titles eq 'Z')
n_pot = where(titles eq 'POTEN')
n_qj = where(titles eq 'QJ')
n_qt = where(titles eq 'QT')
n_qei = where(titles eq 'QEI')
n_qic = where(titles eq 'QIC')
n_qnc = where(titles eq 'QNC')
n_qo3 = where(titles eq 'QO3')
n_qsrb = where(titles eq 'QSRB')
n_qsrc = where(titles eq 'QSRC')
n_qa = where(titles eq 'QA')
n_qeuv = where(titles eq 'QEUV')
n_qo2 = where(titles eq 'QO2')
n_qdh = where(titles eq 'QDH')
n_qgw = where(titles eq 'QGW')
n_qm = where(titles eq 'QM')

; check for older style
if n_tn eq -1 then n_tn = where(titles eq 'TN (K)')
if n_ti eq -1 then n_ti = where(titles eq 'TI (K)')
if n_te eq -1 then n_te = where(titles eq 'TE (K)')
if n_w eq -1 then n_w = where(titles eq 'WN')
if n_pot eq -1 then n_pot = where(titles eq 'Phi')
if n_op eq -1 then n_op = where(titles eq 'O+ (M-3)')
if n_o2p eq -1 then n_o2p = where(titles eq 'O2+ (M-3)')
if n_ne eq -1 then n_ne = where(titles eq 'NE (M-3)')
if n_no eq -1 then n_no = where(titles eq '[NO]')

end
