pro read_crs, file

; read the cross section file from degrad

@common_c

msg_out, 'open crs_file '+file
openr, unit, file, /get_lun, /xdr

print, "Reading file ", file
headline = ''
readu, unit, headline
 
neng=0L                         ;number of energy levels
n_species=0L                    ;number of species
jsmax=0L                        ;maximum number of states
readu, unit, neng, n_species, jsmax
 
eng=fltarr(neng)                ;energy levels
readu, unit, eng
 
de=fltarr(neng)                 ;width of enegy cells
readu, unit, de
 
; number of states for each species 
; (nstat_n2(*,0): excitation, nstat_n2(*,1):ionization)
work=lonarr(n_species,2)
readu, unit, work
nstat_n2=reform(work(0,*))
if n_species ge 2 then nstat_o2=reform(work(1,*))
if n_species ge 3 then nstat_o=reform(work(2,*))

; thresholds (eV) for each state
work=fltarr(n_species,jsmax,2)
readu, unit, work
ethr_n2=reform(work(0,*,*))
if n_species ge 2 then ethr_o2=reform(work(1,*,*))
if n_species ge 3 then ethr_o=reform(work(2,*,*))

; titles (names) of each state
work=bytarr(8,n_species,jsmax,2)
readu, unit, work
states_n2=reform(string(work(*,0,*,*)))
if n_species ge 2 then states_o2=reform(string(work(*,1,*,*)))
if n_species ge 3 then states_o=reform(string(work(*,2,*,*)))

work=fltarr(neng, n_species)
readu, unit, work               ; elastic cross sections
elastic_n2=reform(work(*,0))
if n_species ge 2 then elastic_o2=reform(work(*,1))
if n_species ge 3 then elastic_o=reform(work(*,2))

readu, unit, work               ;total (modified) cross sections

work=fltarr(neng,n_species,jsmax,2)
readu, unit, work               ;modified individual cross sections

readu, unit, work               ;original individual cross sections
exc_n2=reform(work(*,0,0:nstat_n2(0)-1,0))
if n_species ge 2 then exc_o2=reform(work(*,1,0:nstat_o2(0)-1,0))
if n_species ge 3 then exc_o=reform(work(*,2,0:nstat_o(0)-1,0))
cion_n2=reform(work(*,0,0:nstat_n2(1)-1,1))
if n_species ge 2 then cion_o2=reform(work(*,1,0:nstat_o2(1)-1,1))
if n_species ge 3 then cion_o=reform(work(*,2,0:nstat_o(1)-1,1))

; total cross sections
c_n2=total(exc_n2, 2)+total(cion_n2, 2)
c_o2=total(exc_o2, 2)+total(cion_o2, 2)
c_o=total(exc_o, 2)+total(cion_o, 2)

free_lun, unit

return
end
