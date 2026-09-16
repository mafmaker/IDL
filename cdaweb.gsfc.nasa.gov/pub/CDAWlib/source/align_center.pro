;$Author: kovalick $
;$Date: 1996/08/09 15:57:39 $
;$Header: /home/rumba/cdaweb/dev/control/RCS/align_center.pro,v 1.2 1996/08/09 15:57:39 kovalick Exp candey $
;$Locker: candey $
;$Revision: 1.2 $
pro align_center, X, Xmin, Xmax
  ; Scheme for aligning center of box on (X, Y) position
; Robert.M.Candey@gsfc.nasa.gov 2000 June 23; changed "exp" to "10^"
  nX = n_elements(X)
  dx1 = abs(X(1)-X(0)) & dx2 = abs(X(2)-X(1))
  if (abs(dx1-dx2) lt 1.e-6 * min([dx1, dx2])) then begin ; evenly spaced X
    w = lindgen(nX)+1
    Xs = spline(dindgen(nX),X,dindgen(nX+2)-1.) ; add outside points
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
    alogXs = spline(dindgen(nX),alogX,dindgen(nX+2)-1.) ; add outside points
    w = lindgen(nX)+1
  ;  dx = exp((alogXs(w)+alogXs(w+1))/2.) - exp((alogXs(w-1)+alogXs(w))/2.)
    Xmin = 10^((alogXs(w-1)+alogXs(w))/2.)
    Xmax = 10^((alogXs(w)+alogXs(w+1))/2.)
  endelse ; log spacing
return
end ; align_center
