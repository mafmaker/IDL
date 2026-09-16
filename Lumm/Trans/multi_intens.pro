pro multi_intens, path, e_path

; Driver to read all plotfiles from the transport code
; This code puts all data in common blocks and makes them
; so available to the subsequent plotting programs.

@common
@common_w

; define the various structures that are needed by the read routines
flx_param={emax:0., fmin:0.}
ionr_param={npowers:0, yrange:[0.,0.]}
flx_cont_param={npowers:0, yrange:[0.,0.], xrange:[0.,0.], $
                up:0, energyflux:0, total:0, photo:0}
engdep_param={npowers:0, yrange:[0.,0.], only_total:0}
intensity_param={alt:0, erange:[0.,0.], irange:[0.,0.]}
spectrum_param={emin:0., emax:0., fmin:0., fmax:0., count:0}

;read_all, e_path, path
read_int, path+e_path

!p.multi=[0,4,8]
n1=35
n2=190
n3=5
m=0          ; select altitude level
;for n=n1,n2,n3 do begin 
;    plot, -reverse(angle), intens_dn(m,n,*), xr=[-1,1], $
;      tit='Energy='+string(energy(n)), /ylog, $
;      yr=[max(intens_dn(m,n,*))/10., max(intens_dn(m,n,*))]  
;    oplot, angle, intens_up(m,n,*) 
;endfor

Re=6370.
zm=altitude(m)
z1=1500.
mu_1=sqrt(1-(1-angle^2)*((Re+zm)/(Re+z1))^3)
for n=n1,n2,n3 do begin 
    plot, 180-reverse(acos(-mu_1)/!dtor), intens_dn(m,n,*), xr=[0,180], $
      xsty=1, tit='Energy='+string(energy(n)), /ylog, $
      yr=[max(intens_dn(m,n,*))/10., max(intens_dn(m,n,*))]  
    oplot, 180-acos(mu_1)/!dtor, intens_up(m,n,*) 
endfor
xyouts, .985, .5, 'Altitude='+string(z1)+' km', align=.5, $
  orient=-90., /norm

; return
stop
end
