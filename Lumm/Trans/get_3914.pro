pro get_3914, t_altitude, N2_3914, N2p_B, i3914, path

; Driver to get N2(1N) profiles from the transport code

@common

if n_elements(path) le 0 then $
   path = '~/New_trans/output/' + mk_path('~/New_trans/output')

read_exr, path, ''

t_altitude=altitude             ; needs to be a different name
                                ; (altitude is in a common block...)
N2p_B = ion_n2(*,2)
N2_3914 = N2p_B*6.48e-7         ; in R
i3914 = (-1e5)*trap(n2_3914, altitude)  ; in R (note: trap gets negative
                                ; value since the arrays are in
                                ; decending order)
  
return
;stop
end

