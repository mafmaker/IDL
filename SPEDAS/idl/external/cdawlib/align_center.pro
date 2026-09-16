;$Author: kenb $
;$Date: 2006-10-11 13:32:51 -0700 (Wed, 11 Oct 2006) $
;$Header: /home/rumba/cdaweb/dev/control/RCS/align_center.pro,v 1.3 2000/06/23 16:30:39 candey Exp $
;$Locker:  $
;$Revision: 8 $

pro align_center, X0, Xmin1, Xmax1

; Scheme for aligning center of box on (X, Y) position
; ####assumes first 3 points define whether log spaced
; 1995 April 10 original (or earlier)
; Robert.M.Candey@gsfc.nasa.gov 2000 June 23; changed "exp" to "10^"
; 2001 March 21  BC, added check for NANs and change to spline_interp for speed, robustness

Xmin1 = X0 & Xmax1 = X0
w0nan = where(X0 eq X0, w0nanc) ; find all real values
if w0nanc gt 0 then begin
   X = X0(w0nan)
   nX = n_elements(X)
   dx1 = abs(X(1)-X(0)) & dx2 = abs(X(2)-X(1))
   if (abs(dx1-dx2) lt 1.e-6 * min([dx1, dx2])) then begin ; evenly spaced X
      w = lindgen(nX)+1
      ;    Xs = spline(Xt,X,dindgen(nX+2)-1.) ; add outside points
      Xt = dindgen(nX)
      sCoef = spl_init(Xt,X) ; setup spline coefficients
      Xs = spl_interp(Xt,X,sCoef,dindgen(nX+2)-1.) ; add outside points
      ;  dx = (Xs(w)+Xs(w+1))/2. - (Xs(w-1)+Xs(w))/2. == (Xs(w+1) - Xs(w-1))/2.
      Xmin = (Xs(w-1)+Xs(w))/2.
      Xmax = (Xs(w)+Xs(w+1))/2.
   endif else begin ; assume log spacing
      wh = where(x le 0, wc)
      if (wc eq 0) then begin
         alogX = alog10(x)
      endif else begin
         alogX = X*0 ; all 0's
         wh = where(x gt 0, wc)
         if (wc gt 0) then alogX(wh) = alog10(X(wh))
      endelse
      ;    alogXs = spline(Xt,alogX,dindgen(nX+2)-1.) ; add outside points
      Xt = dindgen(nX)
      sCoef = spl_init(Xt,alogX) ; setup spline coefficients
      alogXs = spl_interp(Xt,alogX,sCoef,dindgen(nX+2)-1.) ; add outside points
      w = lindgen(nX)+1
      ;  dx = exp((alogXs(w)+alogXs(w+1))/2.) - exp((alogXs(w-1)+alogXs(w))/2.)
      Xmin = 10^((alogXs(w-1)+alogXs(w))/2.)
      Xmax = 10^((alogXs(w)+alogXs(w+1))/2.)
   endelse ; log spacing
   Xmin1(w0nan) = Xmin & Xmax1(w0nan) = Xmax
endif ; (w0nanc gt 0) else all NANs
return
end ; align_center
