pro get_o1d, path, t_altitude, o1d

; Driver to get O1D plotfiles from the transport code
; This code puts all data in common blocks and makes them
; so available to the subsequent plotting programs.

@/home/lmp/Idl/Lumm/Trans/common

if n_elements(path) le 0 then $
   path = '~/Trans/Output/' + mk_path('~/Trans/Output')

read_exr, path, ''

; window, /free
loadct, 5

t_altitude=altitude             ; needs to be a different name
                                ; (altitude is in a common block...)
;t_ion=ion_n2(*,ion_states(0)-1)+ion_o2(*,ion_states(1)-1)+ $
;      ion_o(*,ion_states(2)-1)
; t_exr_n2=exr_n2
O1D=exr_o(*,1)

return
;stop
end

