function lorentz,x,x0,fwhm,A

; Lorentz function shape is controled by Gamma, the half width at halfmax.
; The amplitude(counts) is A.  X0 is the offset from Zero

;; !dpi = 3.141592653589793d0

Amp = A

gs = (fwhm/2d0) ; gamma

return, (Amp/!dpi) * gs / ( (x-x0)^2 + gs^2 )
end
