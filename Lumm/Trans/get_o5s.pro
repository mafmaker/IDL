pro get_o5s, path, t_altitude, o5s

; Driver to get O(o5s) profiles from the transport code

@common

if n_elements(path) le 0 then $
   path = '/mydisks/home/lmp/Trans/Output/' + mk_path('/mydisks/home/lmp/Trans/Output')

read_exr, path, ''

t_altitude=altitude             ; needs to be a different name
                                ; (altitude is in a common block...)
o5s=exr_o(*,3)

return
;stop
end

