
function imf_clock_angle_f,imfby,imfbz

;-- code to calculate clock angle of IMF with zero degrees being exact BZ south
;  From the Newell et al 2006 JGR paper entitled
;  A Nearly Universal Solar-Wind Magnetosphere Coupling Function
;  Inferred from Ten Magnetospheric State Variables

; Here the IMF clock angle is defined by θc =
; arctan(By/Bz).
;--- that means that positive bz clock angles are near zero, strong by angles are around 90 degrees, and strongly southward bz is 180.
  
  
  
  clock_angle=atan(abs(imfby),imfbz)

return,clock_angle
end
