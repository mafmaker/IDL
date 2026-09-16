pro read_exr, path, e_path

; read the PLOTEXR file from trans

;common grid, energy, altitude, angle, mu_weight
;common header, messag, crs_file, nmax, mmax, kmax, jmax, ex_states, ion_states
;common excitation, exr_n2, exr_o2, exr_o, ion_n2, ion_o2, ion_o
@/home/lmp/Idl/Lumm/Trans/common

on_ioerror, error

if not keyword_set(e_path) then e_path=""
msg_out, "Reading file "+path+"/PLOTEXRxdr"+e_path
openr, unit, path+"/PLOTEXRxdr"+e_path, /get_lun, /xdr

l1=0L
readu, unit, l1
messag=string(replicate(32B,l1))
readu, unit, messag

readu, unit, l1
crs_file=string(replicate(32B,l1))
readu, unit, crs_file

jmax=0L
mmax=0L
readu, unit, jmax, mmax

altitude=fltarr(mmax)
readu, unit, altitude
altitude=altitude*1e-5

ex_states=lonarr(jmax)
readu, unit, ex_states

if jmax ge 1 then begin 
   exr_n2=fltarr(mmax, ex_states(0))
   readu, unit, exr_n2
endif

if jmax ge 2 then begin 
   exr_o2=fltarr(mmax, ex_states(1))
   readu, unit, exr_o2
endif

if jmax ge 3 then begin 
   exr_o=fltarr(mmax, ex_states(2))
   readu, unit, exr_o
endif

if jmax ge 4 then begin 
   exr_co=fltarr(mmax, ex_states(3))
   readu, unit, exr_o
endif

if jmax ge 5 then begin 
   exr_co2=fltarr(mmax, ex_states(4))
   readu, unit, exr_o
endif

ion_states=lonarr(jmax)
readu, unit, ion_states

if jmax ge 1 then begin 
   ion_n2=fltarr(mmax, ion_states(0))
   readu, unit, ion_n2
endif

if jmax ge 2 then begin 
   ion_o2=fltarr(mmax, ion_states(1))
   readu, unit, ion_o2
endif

if jmax ge 3 then begin 
   ion_o=fltarr(mmax, ion_states(2))
   readu, unit, ion_o
endif

if jmax ge 4 then begin 
   ion_co=fltarr(mmax, ion_states(3))
   readu, unit, ion_o
endif

if jmax ge 5 then begin 
   ion_co2=fltarr(mmax, ion_states(4))
   readu, unit, ion_o
endif

free_lun, unit

return

error: msg_out, !err_string     ;prnt_error, !err_string
return

end



