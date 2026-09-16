pro plot_loss

read_crs2, "~/trans/edeg/crs.l",e1,c1_n2,c1_o2,c1_o,e1_n2,e1_o2,e1_o
read_crs2, "~/trans/edeg/crs.new",e2,c2_n2,c2_o2,c2_o,e2_n2,e2_o2,e2_o

plot_oo, e1, c1_n2, yrange=[1e-19, 1e-14], title="N2", ytitle="Loss function (eV cm!e-2!n)", xtitle="Energy (eV)"
oplot, e2, c2_n2, line=2

; window, /free
plot_oo, e1, c1_o2, yrange=[1e-19, 1e-14], title="O2", ytitle="Loss function (eV cm!e-2!n)", xtitle="Energy (eV)"
oplot, e2, c2_o2, line=2

; window, /free
plot_oo, e1, c1_o, yrange=[1e-19, 1e-14], title="O", ytitle="Loss function (eV cm!e-2!n)", xtitle="Energy (eV)"
oplot, e2, c2_o, line=2

return
end
