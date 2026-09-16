pro get_7320, t_altitude, O_7320, i7320, path

; Driver to get OII(7320) profiles from the transport code
; taking into account quenching by N2 and O

@/home/lmp/Idl/Lumm/Trans/common

if n_elements(path) le 0 then $
   path = '~/Trans/Output/' + mk_path('~/Trans/Output')

read_exr, path, ''
if n_elements(N2) le 0 then read_atm, path

t_altitude=altitude             ; needs to be a different name
                                ; (altitude is in a common block...)

ex2p = 0.18
a7320 = 9.23e-2 
a2p = 0.218                     ;0.171+0.047 for 7320 and 2470
gama1 = 1.e-10 
gama2 = 5.2e-11
ionrate = total(ion_O,2)
O_7320 = a7320*ex2p*ionrate/(a2p+gama1*N2+gama2*O)*1.e-6 ; in R 
i7320 = (-1e5)*trap(O_7320, altitude)  ; in R (note: trap gets negative
                                ; values since the arrays are in
                                ; decending order)
  
return
end

