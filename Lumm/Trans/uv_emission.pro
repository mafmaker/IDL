pro uv_emission

; plot the UV part of emission spectrum and the 
; brightness of these emissions at satellite altitude

@common 

if !d.flags/256 then begin
   device, get_screen_size=screensize
   window, /free, xs=screensize(0)/2*w_scale, ys=screensize(1)*w_scale
endif else $
   device, xsize=13, ysize=24, yoffset=2, xoffset=4.2

p_save=!p.multi
!p.multi=[0,1,2]

plot, wavelength(0:104), emission(0:104), /nodata, $
      title="LBH emission and brightness", $
      xtitle="Wavelength (nm)", $
      ytitle="Intensity (cm!e-2!ns!e-1!n)"

for i=0,104 do polyfill, $
    [wavelength(i)-0.25, wavelength(i)-0.25, $
      wavelength(i)+0.25, wavelength(i)+0.25], $
    [0.,emission(i),emission(i), 0.], col=150

for i=0,104 do polyfill, $
    [wavelength(i)-0.25, wavelength(i)-0.25, $
      wavelength(i)+0.25, wavelength(i)+0.25], $
    [0.,brightness(i),brightness(i), 0.]

plot, wavelength(105:115), emission(105:115), /nodata, $
      title="NI and OI emission and brightness", $
      xtitle="Wavelength (nm)", ytitle="Intensity (cm!e-2!ns!e-1!n)", $
      xrange=[min(wavelength(105:115)-0.25),max(wavelength(105:115)+0.25)], $
      yrange=[0., max([max(brightness),max(emission)])]

for i=105,113 do polyfill, $
    [wavelength(i)-0.4, wavelength(i)-0.4, wavelength(i), wavelength(i)], $
    [0.,emission(i),emission(i), 0.], col=150
    
for i=105,113 do polyfill, $
    [wavelength(i), wavelength(i), wavelength(i)+0.4, wavelength(i)+0.4], $
    [0.,brightness(i),brightness(i), 0.]
    
for i=114,115 do polyfill, $
    [wavelength(i)-0.4, wavelength(i)-0.4, wavelength(i), wavelength(i)], $
    [0.,emission(i),emission(i), 0.], col=150
    
for i=114,115 do polyfill, $
    [wavelength(i), wavelength(i), wavelength(i)+0.4, wavelength(i)+0.4], $
    [0.,brightness(i),brightness(i), 0.]
    
!p.multi=p_save

return
end
