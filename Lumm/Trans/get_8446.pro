pro get_8446, t_altitude, O_8446, O2_8446, i8446, path

; Driver to get OI(8446) profiles from the transport code

@/home/lmp/Idl/Lumm/Trans/common

if n_elements(path) le 0 then $
   path = '~/Trans/Output/' + mk_path('~/Trans/Output')

read_exr, path, ''

t_altitude=altitude             ; needs to be a different name
                                ; (altitude is in a common block...)
O2_8446 = exr_o2(*,8)*0.75e-6
O_8446 = exr_o(*,4)*0.75e-6        ; in R
i8446 = (-1e5)*trap(o2_8446+o_8446, altitude)  ; in R (note: trap gets negative
                                ; value since the arrays are in
                                ; decending order)
  
return
;stop
end

