pro read_crs, path

; read the cross section file from degrad

common crs, energy, de, ethr_n2, ethr_o2, ethr_o, c_n2, c_o2, c_o, $
	    exc_n2, exc_o2, exc_o, elastic_n2, elastic_o2, elastic_o, $
	    states_n2, states_o2, states_o, n_species, nstat_n2, nstat_o2, $
	    nstat_o, nmax

openr, unit, path, /get_lun

print, "Reading file ",path
; unformatted fortran written files seem to have two extra
; words (4 bytes each) per record: one at the beginning that
; contains the number of bytes in this record, and one at the
; end, also containing teh number of bytes of the record.  These
; two are read individually (as Long-integers), and printed out
; for comparison.  This is UNIX specific and won't work in a VMS
; environment!

l1=0L
l2=0L
 
nmax=0L
mmax=0L
n_species=0L
jsmax=0L
jspmax=0L
readu, unit, l1, nmax, mmax, n_species, jsmax, jspmax, l2
 
energy=fltarr(nmax)
readu, unit, l1, energy, l2
print, l1,l2, nmax*4
 
de=fltarr(nmax)
readu, unit, l1, de, l2
print, l1,l2, nmax*4
 
work=lonarr(2*n_species)
readu, unit, l1, work, l2
print, l1, l2, n_species*8
nstat_n2=work(0)
if n_species ge 2 then nstat_o2=work(1)
if n_species ge 3 then nstat_o=work(2)

work=fltarr(n_species,jsmax,jspmax)
readu, unit, l1, work, l2
print, l1, l2, n_species*jsmax*jspmax*4
ethr_n2=reform(work(0,*,0))
if n_species ge 2 then ethr_o2=reform(work(1,*,0))
if n_species ge 3 then ethr_o=reform(work(2,*,0))

work=fltarr(jspmax,n_species)
readu, unit, l1, work, l2
print, l1, l2, jspmax*n_species*4

work=bytarr(8*jsmax,n_species)
readu, unit, l1, work, l2
print, l1, l2, 8*jsmax*n_species
states_n2=string(work(*,0))
if n_species ge 2 then states_o2=string(work(*,1))
if n_species ge 3 then states_o=string(work(*,2))

work=fltarr(n_species, nmax)
readu, unit, l1, work, l2
print, l1, l2, n_species*nmax*4
elastic_n2=reform(work(0,*))
if n_species ge 2 then elastic_o2=reform(work(1,*))
if n_species ge 3 then elastic_o=reform(work(2,*))

readu, unit, l1, work, l2
print, l1, l2, n_species*nmax*4

work=fltarr(n_species,jsmax,nmax)
readu, unit, l1, work, l2
print, l1, l2, n_species*nmax*jsmax*4

readu, unit, l1, work, l2
print, l1, l2, n_species*nmax*jsmax*4
exc_n2=reform(work(0,0:nstat_n2-1,*))
if n_species ge 2 then exc_o2=reform(work(1,0:nstat_o2-1,*))
if n_species ge 3 then exc_o=reform(work(2,0:nstat_o-1,*))

c_n2=fltarr(nmax)
for n=0,nmax-1 do c_n2(n)=total(exc_n2(*,n))
c_o2=fltarr(nmax)
for n=0,nmax-1 do c_o2(n)=total(exc_o2(*,n))
c_o=fltarr(nmax)
for n=0,nmax-1 do c_o(n)=total(exc_o(*,n))

free_lun, unit
return
end
