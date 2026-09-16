pro read_flx, path, e_path

; read the PLOTFLX file from trans

@common 

on_ioerror, error

test=0L & nmax=0L & mmax=0L

if not keyword_set(e_path) then e_path=""
msg_out, "Reading file PLOTFLXxdr"
;dummi=widget_message("Reading file PLOTFLX", /info)
openr, unit, path+"/PLOTFLXxdr"+e_path, /get_lun, /xdr

l1=0L
readu, unit, l1
messag=string(replicate(32B,l1))
readu, unit, messag

readu, unit, l1
crs_file=string(replicate(32B,l1))
readu, unit, crs_file

readu, unit, nmax, mmax, test

energy=fltarr(nmax)
readu, unit, energy

altitude=fltarr(mmax)
readu, unit, altitude
altitude=altitude*1e-5

flux_down=fltarr(nmax, mmax)
flux_up=fltarr(nmax, mmax)
readu, unit, flux_down
readu, unit, flux_up
if test eq 1 then begin 
    flux_extra=fltarr(nmax, mmax)
    readu, unit, flux_extra
    msg_out, "extra data..."
endif

free_lun, unit

error = check_math(0,1)
;fmin = mmin([flux_up, flux_down, flux_extra], above=0)
fmin = machar()
fmin = fmin.xmin
flux_up = (flux_up > fmin)
flux_down = (flux_down > fmin)
flux_extra = (flux_extra > fmin)
error = check_math(0,0)

return

error: prnt_error, !err_string
return

end
