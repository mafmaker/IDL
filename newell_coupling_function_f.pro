function newell_coupling_function_f,imfbx,imfby,imfbz,swvel

; Code that implements Newell's coupling function
; Newell's coupling function comes from a 2006 paper
;    A Nearly Universal Solar-Wind Magnetosphere Coupling Function
; Inferred from Ten Magnetospheric State Variables
; P. T. Newell, T. Sotirelis, K. Liou, and C.-I. Meng
; The Johns Hopkins University Applied Physics Laboratory
; Laurel, Maryland, 20723
; F. J. Rich
; Space Vehicles Directorate, Air Force Research Laboratory
; Hanscom Air Force Base
; Bedford, Massachusetts 01731
;

  
   clock_angle=imf_clock_angle_f(imfby,imfbz)
   bT=sqrt(imfbx^2+imfby^2+imfbz^2)

   sw_power=4./3.
   bT_power=2./3.
   clock_angle_sin_power=8./3.
   
   ncf = swvel^(sw_power) * $
         bt^(bT_power) * $
         sin(clock_angle/2.)^(clock_angle_sin_power)

  return,ncf

  end
