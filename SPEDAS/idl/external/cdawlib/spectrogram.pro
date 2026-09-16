pro spectrogram, Z0, X0, Y0, X1, Y1, X2, Y2, $
        colorbar=colorbar, ctitle=ctitle, cscale=cscale, cCharSize=cCharSize, $
        logZ=logZ, logX=logX, logY=logY, $
        center=center, centerX=centerX, centerY=centerY, $ 
        fillValue=fillValue, Xfillval=Xfillval, Yfillval=Yfillval, $
        maxValue=maxValue, minValue=minValue, nResCol=nResCol, $
        noSkipGaps=noSkipGaps, noYSkipGaps=noYSkipGaps, $
        quick=quick, reduce=reduce, noclip=noclip, status=status, $
        _Extra=extra
;+
; NAME:
;       Spectrogram
;
; PURPOSE:
;       This function plots a color spectrogram of Z in contiguous or 
;       non-contiguous blocks with color Z(i,j) (data Z(i,j) is shown as a box
;       of size Xmin(i):Xmax(i) and Ymin(j):Ymax(j) with color Z(i,j))
;
; CATEGORY:
;       Graphics
;
; CALLING SEQUENCE:
;       SPECTROGRAM, Z, [X, Y]
;       SPECTROGRAM, Z, Xmin, Ymin, Xmax, Ymax
;       SPECTROGRAM, Z, Xcenter, Ycenter, Xminus, Yminus, Xplus, Yplus
;
; INPUTS:
;       Z:      2-dimensional data array; converted to float or double for NAN use
;
; OPTIONAL INPUTS:
;       X:      1-dimensional data array of size Z(*,0) or 2-dim of size Z(*,*)
;       Y:      1-dimensional data array of size Z(0,*) or 2-dim of size Z(*,*)
;
;       Xmin:   1- or 2- dim array of X values for left side of each data box
;       Ymin:   1- or 2- dim array of Y values for bottom side of each data box
;       Xmax:   1- or 2- dim array of X values for right side of each data box
;       Ymax:   1- or 2- dim array of Y values for top side of each data box
;
;       Xcenter:1- or 2- dim array of X values for center side of each data box
;       Ycenter:1- or 2- dim array of Y values for center side of each data box
;       Xminus: Xcenter-Xminus defines left side of each data box
;       Yminus: Ycenter-Yminus defines bottom side of each data box
;       Xplus:  Xcenter+Xplus defines right side of each data box
;       Yplus:  Ycenter+Yplus defines top side of each data box
;       (this allows gaps or overlaps in boxes; if not desired, use Z,X,Y case)
;
; KEYWORD PARAMETERS:
;       COLORBAR=colorbar:  Switch to create color bar on right
;       CSCALE=cScale:  scale for colorbar range [min, max]; sets /colorbar
;       CTITLE=cTitle:  String title for colorbar
;       CCHARSIZE=cCharSize:    Character size for axis on color bar
;       LOGZ=logZ:      Scale Z data and color scale logarithmically
;       LOGX=logX:      Scale Y axis logarithmically
;       LOGY=logY:      Scale Y axis logarithmically
;       CENTER=center:  Center boxes on (X,Y) location (only for 3 parameter 
;                               case: spectrogram, Z, X, Y, /center)
;       CENTERX=centerX:  Center boxes in X direction (only for 3 parameter
;                               case: spectrogram, Z, X, Y, /centerX)
;       CENTERY=centerY:  Center boxes in Y direction (only for 3 parameter
;                               case: spectrogram, Z, X, Y, /centerY)
;       FILLVALUE=fillValue: Z data with this value are ignored
;       YFILLVALUE=YfillValue: Y data with this value are ignored
;       XFILLVALUE=XfillValue: X data with this value are ignored
;       MAXVALUE=maxValue: Max value of data to plot; values above are ignored
;       MINVALUE=minValue: Min value of data to plot; values below are ignored
;           [probably better to use cScale so extremas are colored not ignored]
;       NRESCOL=nResCol: number of colors to reserve outside color table, def=2
;       NOSKIPGAPS=noSkipGaps: Turns off treating large delta X as missing data
;               and skip; not done anyway if Center option selected
;               #### Also assumes 1-dim X array
;       NOYSKIPGAPS=noYSkipGaps: Turns off treating large delta Y as missing data
;       QUICK=quick:    Allow quick and dirty plotting ignoring X and Y sizes
;                               (for X and Z plot devices only)
;       REDUCE=reduce: Reduce the number of X values to polyfill to not more 
;                         than twice the number of pixels across the plot, by
;                         sampling every so many values; for non-Postscript
;                         devices only; done for speed, alternative to /quick 
;       NOCLIP=noclip:  Polyfill bug in Z device; defaults to noclip=0
;       STATUS=status:  Return 0 if plot okay, else -1 for an error, 
;                         status variable must be predefined before call
;       _EXTRA=extra:   Any extra parameters to pass on to plot outline
;                         Add your own title, xtitle, ytitle
;                 May be able to over-ride plot location/size with position
;
; OUTPUTS:
;       No outputs.
;
; COMMON BLOCKS:
;       DEVICETYPEC: deviceType
;       Shared with DeviceOpen.pro to allow inverting grayscale Postscript
;
; SIDE EFFECTS:
;       Creates plot to screen or file.
;
; RESTRICTIONS:
;       Sets a specific X margin to allow for the colorbar.
;       Forces input arrays to float or double
;
; SUBROUTINES:
;       Calls colorbar.pro, findgaps.pro, align_center.pro
;
; PROCEDURE:
;       Uses plot,/nodata to setup the plot area and then uses polyfill to 
;       on each data value to color each small square of the spectrogram
;       A colorbar is plotted on the right if cscale is set.
;
; EXAMPLE:
;       Create a spectrogram plot of 2 dimensional data Z = dist(50)
;       spectrogram, dist(50), /colorbar
;       spectrogram,dist(50),findgen(50),findgen(50)+1,findgen(50),findgen(50)+1
;
; MODIFICATION HISTORY:
;       Written by:     Bobby Candey, NASA GSFC Code 632, 1993 August 27
;               Robert.M.Candey.1@gsfc.nasa.gov
;       1993 Nov 9      BC, removed timeaxis call and made more generic
;       1994 Sept 19    BC, update with documentation and higher level routine
;       1994 Nov 28     BC, added handling of 2-dim X and Y
;       1994 Dec 6      BC, merged routines and added center-minus-plus option
;       1995 April 10   BC, completed initial coding of version 5
;       1995 Jun 22     BC, added smaller font size for color bar axis
;       1995 July 26    BC, added cCharSize and reforming
;       1995 Oct 11     BC, added min/maxValue scaling to bytscl
;       1996 March 17   BC, added skip over time gaps and added fillValue
;       1996 March 18   BC, added /reduce for speed plotting
;       1996 March 25   BC, added noclip keyword for Z device bug with polyfill
;       1996 April 8    BC, added status keyword and plot a blank on all fill
;       1996 April 16   BC, moved Cscale to override min/maxValue
;       1996 April 17   BC, added colorBar switch to allow autoscale
;       1996 August 28  BC, added save for !p.multi so overplot works
;       2001 March 7    BC, added centerX/Y, XfillVal, and repaired Yfillval, etc.
;       2001 March 16   BC, repaired Yfillval, force all to float/double, added checks for NAN
;       2001 March 20   BC, added noYskipGaps, logX, and rearranged calling sequence for clarity
;       2001 March 30   BC, added nResCol in place of fixed 2 colors
;       2001 April 27   BC, added additional fillValue checks and updated alog10(Z) section
;       2001 August 9   BC, added logY tick sections
;-

common deviceTypeC, deviceType, file;required for inverting grayscale Postscript
forward_function loglevels

if (n_params(0) lt 1) then $
        message, 'spectrogram, Z, [X, Y] or [Xmin, Ymin, Xmax, Ymax]'
if (n_elements(nResCol) le 0) then nResCol = 2
if (n_elements(status) gt 0) then doStatus = 1 else doStatus = 0
;if (n_elements(extra) le 0) then extra = {}
status = 0L
;if doStatus then begin
;  catch, error_status
;  if (error_status ne 0) then begin
;    message, 'General error: '+string(error_status)+': '+!err_string, /info
;    status = -1L & return
;  endif ; else return
;endif
if not keyword_set(logX) then logX = 0
if not keyword_set(logY) then logY = 0
if not keyword_set(logZ) then logZ = 0

Z = 1.*reform(Z0) ; remove extraneous dimensions
Zsize = size(Z)
if (Zsize(0) ne 2) then begin
   msgText = 'Requires 2-dimensional Z array'
   if doStatus then begin
      message, msgText, /info & status = -1L & return
   endif else message, msgText
endif

case n_params(0) of

   1: begin ; Z only
      Xmin = rebin(dindgen(Zsize(1)),Zsize(1),Zsize(2),/sample) & Xmax = Xmin + 1
      Ymin = rebin(dindgen(1,Zsize(2)),Zsize(1),Zsize(2),/sample) & Ymax = Ymin + 1
   end ; Z only
   
   3: begin ; Z, X, Y
      X0 = 1.*reform(X0) & Y0 = 1.*reform(Y0) ; remove extraneous dimensions
      Vsize = size(X0) 
      if not ((Vsize(Vsize(0)+2) eq Zsize(1)) or $
      ((Vsize(1) eq Zsize(1)) and (Vsize(2) eq Zsize(2)))) then begin
         msgText = 'X must be of same size as Z(*,0) or Z(*,*)'
         if doStatus then begin
            message, msgText, /info & status = -1L & return
         endif else message, msgText
      endif
      if not (Vsize(Vsize(0)+2) eq Zsize(1)) then Xmin = X0 else $
        Xmin = rebin(X0,Zsize(1),Zsize(2),/sample)
      Vsize = size(Y0)  
      if not ((Vsize(Vsize(0)+2) eq Zsize(2)) or $
      ((Vsize(1) eq Zsize(1)) and (Vsize(2) eq Zsize(2)))) then begin
         msgText = 'Y must be of same size as Z(0,*) or Z(*,*)'
         if doStatus then begin
            message, msgText, /info & status = -1L & return
         endif else message, msgText
      endif
      if not (Vsize(Vsize(0)+2) eq Zsize(2)) then Ymin = Y0 else $
        Ymin = rebin(reform(Y0,1,Zsize(2),/overwrite),Zsize(1),Zsize(2),/sample)


      ; added checks for fillVal, BC 2001Mar7
      if n_elements(Xfillval) gt 0 then begin
         wn = where(Xmin eq Xfillval[0], wnc)
         if wnc gt 0 then Xmin[wn] = !values.d_nan ; set to NAN
         ;    wn = where(Xmin ne Xmin, wnc) ; find NANs including XfillVal's
         wn = where(finite(Xmin), wnc) ; find non-NANs including XfillVal's
         if wnc le 0 then begin ; no valid Xmin data
            msgText = 'No valid Xmin data'
            if doStatus then begin
               message, msgText, /info & status = -1L & return
            endif else message, msgText
         endif ; wnc le 0
      endif ; Xfillval

      if n_elements(Yfillval) gt 0 then begin
         wn = where(Ymin eq Yfillval[0], wnc)
         if wnc gt 0 then Ymin[wn] = !values.d_nan ; set to NAN
         ;    wn = where(Ymin ne Ymin, wnc) ; find NANs including XfillVal's
         wn = where(finite(Ymin), wnc) ; find non-NANs including XfillVal's
         if wnc le 0 then begin ; no valid Ymin data
            msgText = 'No valid Ymin data'
            if doStatus then begin
               message, msgText, /info & status = -1L & return
            endif else message, msgText
         endif ; wnc le 0
      endif ; Yfillval

      ; create Xmax and Ymax from Xmin and Ymin
      if keyword_set(center) then begin
         centerX = 1 & centerY = 1
      endif
      if keyword_set(centerX) then begin
         ;align_center, X, Xmin, Xmax ; 1 dim case
         Xmax = Xmin
         for i = 0L, Zsize(2)-1 do begin
            align_center, Xmin(*,i), Xmint, Xmaxt
            Xmin(*,i) = Xmint & Xmax(*,i) = Xmaxt
         endfor ; i
      endif else begin ; shift min up to max array and add top value
         ; Scheme for aligning lower left corner of box on (X, Y) position
         ;Xmax = [X(1:*), X(nX-1)*2 - X(nX-2)] ; add deltaX to last item; 1 dim case
         Xmax = shift(Xmin,-1,0)        ; shift all elements in 1st dim to the left
         ; ####following assumes last 2 values in each row are real
         if logX then begin
            ;###  Xmax(Zsize(1)-1,*)=alog10(10^(Xmin(Zsize(1)-1,*))*2 - 10^(Xmin(Zsize(1)-2,*)))
            Xmax(Zsize(1)-1,*)=10^(alog10(Xmin(Zsize(1)-1,*))*2 - alog10(Xmin(Zsize(1)-2,*)))
         endif else begin
            Xmax(Zsize(1)-1,*) = Xmin(Zsize(1)-1,*)*2 - Xmin(Zsize(1)-2,*)
         endelse
         ; 2001 Mar 20 BC, new code for skipping NANs
         ; where Xmin has a real value and Xmax is NAN then set Xmax to next real Xmax up
         ; next real value may be much further up; ####do skipGaps to handle
         ; also does not have a value when NANs in last two positions?
         ;   w = where((Xmax ne Xmax) and (Xmin eq Xmin), wc)
         w = where((finite(Xmax) ne 1) and finite(Xmin), wc)
         if (wc gt 0) then $
         for i=0L,wc-1 do begin
            j = w[i] mod Zsize[1]
            k = long(w[i]/Zsize[1])
            ;  while (j lt (Zsize[1]-1)) and (Xmax[j,k] ne Xmax[j,k]) do j=j+1; skip to next
            while (j lt (Zsize[1]-1)) and (finite(Xmax[j,k]) ne 1) do j=j+1; skip to next
            Xmax[w[i]] = Xmax[j,k]
         endfor ; i
         if not keyword_set(noSkipGaps) then begin
            ;#### only uses first row of Xmin; assumes no fill data, no log spacing
            ;### really have to do this for every column
            for i = 0L, Zsize(2)-1 do begin
               gaps = findGaps(Xmin(*,i), 1.5, avg=avgDeltaX)
               if (gaps(0) lt 0) then nGaps = 0 else nGaps = n_elements(gaps)
               if (nGaps gt 0) then for k = 0L, nGaps-1 do $
                  Xmax(gaps(k),i) = Xmin(gaps(k),i) + avgDeltaX
            endfor ; i
         endif ; noSkipGaps
      endelse

      if keyword_set(centerY) then begin
         Ymax = Ymin
         for i = 0L, Zsize(1)-1 do begin
            align_center, Ymin(i,*), Ymint, Ymaxt
            Ymin(i,*) = Ymint & Ymax(i,*) = Ymaxt
         endfor ; i
      endif else begin ; shift min up to max array and add top value
         ; Scheme for aligning lower left corner of box on (X, Y) position
         Ymax = shift(Ymin,0,-1)        ; shift all elements in 2nd dim to the bottom
         ;print,transpose(ymax(1,*)),' ***' ;RCJ
         ; ####following assumes last 2 values in each row are real
         if logY then begin
         ;### Ymax(*,Zsize(2)-1)=alog10(10^(Ymin(*,Zsize(2)-1))*2 - 10^(Ymin(*,Zsize(2)-2)))
           Ymax(*,Zsize(2)-1)=10^(alog10(Ymin(*,Zsize(2)-1))*2 - alog10(Ymin(*,Zsize(2)-2)))
         ;print,transpose(ymax(1,*)) ;RCJ
         endif else begin
           Ymax(*,Zsize(2)-1) = Ymin(*,Zsize(2)-1)*2 - Ymin(*,Zsize(2)-2)
         endelse
         ; 2001 Mar 20 BC, new code for skipping NANs
         ; where Xmin has a real value and Xmax is NAN then set Xmax to next real Xmax up
         ; next real value may be much further up; ####do skipGaps to handle
         ; also does not have a value when NANs in last two positions?
         ;   w = where((Ymax ne Ymax) and (Ymin eq Ymin), wc)
         w = where((finite(Ymax) ne 1) and finite(Ymin), wc)
         if (wc gt 0) then $
         for i=0L,wc-1 do begin
            j = w[i] mod Zsize[1]
            k = long(w[i]/Zsize[1])
            ;  while (k lt (Zsize[2]-1)) and (Ymax[j,k] ne Ymax[j,k]) do k=k+1; skip to next
            while (k lt (Zsize[2]-1)) and (finite(Ymax[j,k]) ne 1) do k=k+1; skip to next
            Ymax[w[i]] = Ymax[j,k]
         endfor ; i
         if not keyword_set(noYSkipGaps) then begin
            ;#### only uses first col of Ymin; assumes no fill data, no log spacing
            ;### really have to do this for every column
            for i = 0L, Zsize(1)-1 do begin
               gaps = findGaps(Ymin(i,0), 1.5, avg=avgDeltaY)
               if (gaps(0) lt 0) then nGaps = 0 else nGaps = n_elements(gaps)
               if (nGaps gt 0) then for k = 0L, nGaps-1 do $
                  Ymax(i,gaps(k)) = Ymin(i,gaps(k)) + avgDeltaY
            endfor ; i
         endif ; noSkipGaps
      endelse

      ;      if not keyword_set(center) then begin
      ;         ; Scheme for aligning lower left corner of box on (X, Y) position
      ;         ;Xmax = [X(1:*), X(nX-1)*2 - X(nX-2)] ; add deltaX to last item; 1 dim case
      ;         Xmax = shift(Xmin,-1,0)        ; shift all elements in 1st dim to the left
      ;         Xmax(Zsize(1)-1,*) = Xmin(Zsize(1)-1,*)*2 - Xmin(Zsize(1)-2,*)
      ;         Ymax = shift(Ymin,0,-1)        ; shift all elements in 2nd dim to the bottom
      ;         Ymax(*,Zsize(2)-1) = Ymin(*,Zsize(2)-1)*2 - Ymin(*,Zsize(2)-2)
      ;         if not keyword_set(noSkipGaps) then begin
      ;            ;#### only uses first row of Xmin; assumes no fill data
      ;            gaps = findGaps(Xmin(*,0), 1.5, avg=avgDeltaX)
      ;            if (gaps(0) lt 0) then nGaps = 0 else nGaps = n_elements(gaps)
      ;            if (nGaps gt 0) then for k = 0L, nGaps-1 do $
      ;                Xmax(gaps(k),*) = Xmin(gaps(k),*) + avgDeltaX
      ;         endif ; noSkipGaps
      ;      endif else begin ; center box
      ;         ;align_center, X, Xmin, Xmax ; 1 dim case
      ;         Xmax = Xmin
      ;         for i = 0L, Zsize(2)-1 do begin
      ;            align_center, Xmin(*,i), Xmint, Xmaxt
      ;            Xmin(*,i) = Xmint & Xmax(*,i) = Xmaxt
      ;         endfor ; i
      ;         Ymax = Ymin
      ;         for i = 0L, Zsize(1)-1 do begin
      ;            align_center, Ymin(i,*), Ymint, Ymaxt
      ;            Ymin(i,*) = Ymint & Ymax(i,*) = Ymaxt
      ;         endfor ; i
      ;      endelse ; centering

   end ; Z, X, Y
   
   5: begin ; Z, Xmin, Ymin, Xmax, Ymax
      X0 = 1.*reform(X0) & Y0 = 1.*reform(Y0) ; remove extraneous dimensions
      X1 = 1.*reform(X1) & Y1 = 1.*reform(Y1) ; remove extraneous dimensions
      Vsize = size(X0)  
      if not ((Vsize(Vsize(0)+2) eq Zsize(1)) or $
      ((Vsize(1) eq Zsize(1)) and (Vsize(2) eq Zsize(2)))) then begin
         msgText = 'Xmin must be of same size as Z(*,0) or Z(*,*)'
         if doStatus then begin
            message, msgText, /info & status = -1L & return
         endif else message, msgText
      endif
      if not (Vsize(Vsize(0)+2) eq Zsize(1)) then Xmin = X0 else $
         Xmin = rebin(X0,Zsize(1),Zsize(2),/sample)
      Vsize = size(Y0)
      if not ((Vsize(Vsize(0)+2) eq Zsize(2)) or $
      ((Vsize(1) eq Zsize(1)) and (Vsize(2) eq Zsize(2)))) then begin
         msgText = 'Ymin must be of same size as Z(0,*) or Z(*,*)'
         if doStatus then begin
            message, msgText, /info & status = -1L & return
         endif else message, msgText
      endif
      if not (Vsize(Vsize(0)+2) eq Zsize(2)) then Ymin = Y0 else $
         Ymin = rebin(reform(Y0,1,Zsize(2),/overwrite),Zsize(1),Zsize(2),/sample)
      Vsize = size(X1)
      if not ((Vsize(Vsize(0)+2) eq Zsize(1)) or $
      ((Vsize(1) eq Zsize(1)) and (Vsize(2) eq Zsize(2)))) then begin
         msgText = 'Xmax must be of same size as Z(*,0) or Z(*,*)'
         if doStatus then begin
            message, msgText, /info & status = -1L & return
         endif else message, msgText
      endif
      if not (Vsize(Vsize(0)+2) eq Zsize(1)) then Xmax = X1 else $
         Xmax = rebin(X1,Zsize(1),Zsize(2),/sample)
      Vsize = size(Y1)
      if not ((Vsize(Vsize(0)+2) eq Zsize(2)) or $
      ((Vsize(1) eq Zsize(1)) and (Vsize(2) eq Zsize(2)))) then begin
         msgText = 'Ymax must be of same size as Z(0,*) or Z(*,*)'
         if doStatus then begin
            message, msgText, /info & status = -1L & return
         endif else message, msgText
      endif
      if not (Vsize(Vsize(0)+2) eq Zsize(2)) then Ymax = Y1 else $
         Ymax = rebin(reform(Y1,1,Zsize(2),/overwrite),Zsize(1),Zsize(2),/sample)
   end ; Z, Xmin, Ymin, Xmax, Ymax
   
   7: begin ; Z, Xcenter, Ycenter, Xminus, Yminus, Xplus, Yplus
      X0 = 1.*reform(X0) & Y0 = 1.*reform(Y0) ; remove extraneous dimensions
      X1 = 1.*reform(X1) & Y1 = 1.*reform(Y1) ; remove extraneous dimensions
      X2 = 1.*reform(X2) & Y2 = 1.*reform(Y2) ; remove extraneous dimensions
      Vsize = size(X0)  
      if not ((Vsize(Vsize(0)+2) eq Zsize(1)) or $
      ((Vsize(1) eq Zsize(1)) and (Vsize(2) eq Zsize(2)))) then begin
         msgText = 'Xcenter must be of same size as Z(*,0) or Z(*,*)'
         if doStatus then begin
            message, msgText, /info & status = -1L & return
         endif else message, msgText
      endif
      if not (Vsize(Vsize(0)+2) eq Zsize(1)) then Xcenter = X0 else $
         Xcenter = rebin(X0,Zsize(1),Zsize(2),/sample)
      Vsize = size(Y0)
      if not ((Vsize(Vsize(0)+2) eq Zsize(2)) or $
      ((Vsize(1) eq Zsize(1)) and (Vsize(2) eq Zsize(2)))) then begin
         msgText = 'Ycenter must be of same size as Z(0,*) or Z(*,*)'
         if doStatus then begin
            message, msgText, /info & status = -1L & return
         endif else message, msgText
      endif
      if not (Vsize(Vsize(0)+2) eq Zsize(2)) then Ycenter = Y0 else $
         Ycenter = rebin(reform(Y0,1,Zsize(2),/overwrite),Zsize(1),Zsize(2),/sample)
      Vsize = size(X1)
      if not ((Vsize(Vsize(0)+2) eq Zsize(1)) or $
      (Vsize(Vsize(0)+2) eq 1) or $ ; allow scalar
      ((Vsize(1) eq Zsize(1)) and (Vsize(2) eq Zsize(2)))) then begin
         msgText = 'Xminus must be of same size as Z(*,0) or Z(*,*)'
         if doStatus then begin
            message, msgText, /info & status = -1L & return
         endif else message, msgText
      endif
      if not (Vsize(Vsize(0)+2) eq Zsize(1)) then Xminus = X1 else $
         Xminus = rebin(X1,Zsize(1),Zsize(2),/sample)
      Vsize = size(Y1)
      if not ((Vsize(Vsize(0)+2) eq Zsize(2)) or $
      (Vsize(Vsize(0)+2) eq 1) or $ ; allow scalar
      ((Vsize(1) eq Zsize(1)) and (Vsize(2) eq Zsize(2)))) then begin
         msgText = 'Yminus must be of same size as Z(0,*) or Z(*,*)'
         if doStatus then begin
            message, msgText, /info & status = -1L & return
         endif else message, msgText
      endif
      if not (Vsize(Vsize(0)+2) eq Zsize(2)) then Yminus = Y1 else $
        Yminus = rebin(reform(Y1,1,Zsize(2),/overwrite),Zsize(1),Zsize(2),/sample)
      Vsize = size(X2)
      if not ((Vsize(Vsize(0)+2) eq Zsize(1)) or $
      (Vsize(Vsize(0)+2) eq 1) or $ ; allow scalar
      ((Vsize(1) eq Zsize(1)) and (Vsize(2) eq Zsize(2)))) then begin
         msgText = 'Xplus must be of same size as Z(*,0) or Z(*,*)'
         if doStatus then begin
            message, msgText, /info & status = -1L & return
         endif else message, msgText
      endif
      if not (Vsize(Vsize(0)+2) eq Zsize(1)) then Xplus = X2 else $
         Xplus = rebin(X2,Zsize(1),Zsize(2),/sample)
      Vsize = size(Y2)
      if not ((Vsize(Vsize(0)+2) eq Zsize(2)) or $
      (Vsize(Vsize(0)+2) eq 1) or $ ; allow scalar
      ((Vsize(1) eq Zsize(1)) and (Vsize(2) eq Zsize(2)))) then begin
         msgText = 'Yplus must be of same size as Z(0,*) or Z(*,*)'
         if doStatus then begin
            message, msgText, /info & status = -1L & return
         endif else message, msgText
      endif
      if not (Vsize(Vsize(0)+2) eq Zsize(2)) then Yplus = Y2 else $
         Yplus = rebin(reform(Y2,1,Zsize(2),/overwrite),Zsize(1),Zsize(2),/sample)
   
      ; remember X/Yminus and X/Yplus can be scalar as well as 2-dim arrays
      Xmin = Xcenter - Xminus & Xmax = Xcenter + Xplus
      Ymin = Ycenter - Yminus & Ymax = Ycenter + Yplus
   end ; Z, Xcenter, Ycenter, Xminus, Yminus, Xplus, Yplus
   
   else: begin
      msgText = 'Wrong number of arguments'
      if doStatus then begin
         message, msgText, /info & status = -1L & return
      endif else message, msgText
   end ; else
endcase

;##### remove "> 0." on next 30 lines for real Z < 0
;if (n_elements(minValue) gt 0) then minZ = minValue(0) else minZ = min(Z,/nan) > 0.
;if (n_elements(maxValue) gt 0) then maxZ = maxValue(0) else maxZ = max(Z,/nan) > 0.
if (n_elements(minValue) gt 0) then minZ = minValue(0) else minZ = min(Z,/nan)
if (n_elements(maxValue) gt 0) then maxZ = maxValue(0) else maxZ = max(Z,/nan)
if (n_elements(fillValue) gt 0) then begin
   fillZ = fillValue(0)
   wn = where(Z eq fillZ, wnc)
   if wnc gt 0 then Z[wn] = !values.d_nan ; set to NAN
   wn = where(finite(Z), wnc) ; find non-NANs including XfillVal's
   if (wnc gt 0) then begin
      if (n_elements(minValue) le 0) then minZ = min(Z(wn),/nan)
      if (n_elements(maxValue) le 0) then maxZ = max(Z(wn),/nan)
   endif
   ; RCJ 02/15/02 'minZ - 1' -> 'minZ - 1.' in case minZ is unsigned number.
endif else fillZ = minZ - 1.

;isBad = (Z lt minZ) or (Z gt maxZ) or (Z eq fillZ)
isBad = (Z lt minZ) or (Z gt maxZ) or (finite(Z) ne 1)
wBad = where(isBad, wBadc)
if (wBadc gt 0) then begin
   wGood = where(isBad ne 1, wGoodc)
   if (wGoodc le 0) then begin ; quit here
      msgText = 'No good values to display'
      if doStatus then begin
         ; RTB 11/96; check for ctitle first, BC 2001Mar7
         if n_elements(ctitle) gt 0 then parts=str_sep(ctitle,'!C') else parts=['']
         print,'ERROR= Instrument may be off '
         print, 'STATUS= No good values to display for ',parts(0)
         status=-1L
         return
         ;  plot, [0,1], [0,1], ytype=logY, /nodata, _Extra=extra
         ;  message, msgText, /info & status = -1L & return
      endif else message, msgText
   endif
   ;if (n_elements(minValue) eq 0) then minZ=min(Z(wGood),/nan) > 0.
   ;if (n_elements(maxValue) eq 0) then maxZ=max(Z(wGood),/nan) > 0.
   if (n_elements(minValue) le 0) then minZ=min(Z(wGood),/nan)
   if (n_elements(maxValue) le 0) then maxZ=max(Z(wGood),/nan)
   ; RCJ 02/15/02 'minZ - 1' -> 'minZ - 1.' in case minZ is unsigned number.
   if (n_elements(fillValue) le 0) then fillZ = minZ - 1.
endif

doColorBar = 0
flipColorBar = 0 ; flip color bar if cScale is inverted
if (n_elements(cscale) ne 0) then begin
   doColorBar = 1
   ; check accuracy of cscale
   if n_elements(cscale) ne 2 then begin
      msgText = 'Error in cscale dimensions, no colorbar plotted'
      if doStatus then begin
         message, msgText, /info & status = -1L & return
      endif else message, msgText
   endif
   if logZ then begin ; check if cscale is less than 0 and minValue
      if (n_elements(minValue) ne 0) then minCscale = minValue(0) > 0 $
                                   else minCscale = 0
      wcs = where(cscale le minCscale, wcsc)
      if wcsc gt 0 then begin
         ws = where(Z gt minCscale, wsc)
         if wsc gt 0 then cscale(wcs) = min(Z(ws),/nan) else cscale(wcs) = minCscale
      endif ; bad cscale
   endif ; logZ
   doCheck = 0
   if doCheck then begin ; check for exceeding maxValue or less than minValue
      if (n_elements(maxValue) ne 0) then begin
         wcs = where(cscale gt maxValue(0), wcsc) ; #### could be "ge"
         if wcsc gt 0 then begin
            ws = where(Z le maxValue(0), wsc) ; #### could be "lt"
            if wsc gt 0 then cscale(wcs) = max(Z(ws),/nan) else cscale(wcs) = maxValue(0)
         endif
      endif
      if (n_elements(minValue) ne 0) then begin
         wcs = where(cscale lt minValue(0), wcsc) ; #### could be "le"
         if wcsc gt 0 then begin
            ws = where(Z ge minValue(0), wsc) ; #### could be "gt"
            if wsc gt 0 then cscale(wcs) = min(Z(ws),/nan) else cscale(wcs) = minValue(0)
         endif
      endif
   endif ; doCheck min/max Values in cscale
   minZ = min(cscale) & maxZ = max(cscale)
   if (cscale(0) gt cscale(1)) then flipColorBar = 1
   ; RCJ 02/15/02 'minZ - 1' -> 'minZ - 1.' in case minZ is unsigned number.
   if (n_elements(fillValue) le 0) then fillZ = minZ - 1.
endif else begin; colorBar without cscale
   if keyword_set(colorbar) then begin
      doColorBar = 1
      cscale = [minZ, maxZ]
   endif
endelse

minZ1 = minZ & maxZ1 = maxZ
Ztemp = Z
;TJK following seems to be irrelevant, removed 9/30/99
;if (Zsize(Zsize(0)+1) ne 1) then begin ; not Byte array

if logZ then begin
   ;;   ztype = size(z, /type)
   ;   ;if integer or byte data then convert to float
   ;;   ;so we don't loose precision. TJK 3/9/99, 9/30/99 (extended for byte)
   ;;   if (ztype eq 1 or ztype eq 2 or ztype eq 12) then begin 
   ;;      Zt = float(Zt) & Z = Zt           
   ;;   endif
   wh = where((Ztemp le 0) or (finite(Ztemp) ne 1), wc)
   if (wc eq 0) then begin ;no 0's found in the data, convert whole array
      Ztemp = alog10(Ztemp)
   endif else begin ;some zero's found
      ;      Zt = Z*0 ; all 0's
      ;      wh = where(Z gt 0, wc)
      Ztemp[wh] = !values.d_nan ; set to NAN
      wh = where(finite(Ztemp), wc)
      if (wc gt 0) then Ztemp(wh) = alog10(Ztemp(wh))
   endelse
   
   if (minZ le 0.) then minZ1 = 0. else minZ1 = alog10(minZ)
   if (maxZ le 0.) then maxZ1 = 0. else maxZ1 = alog10(maxZ)
endif

Zt = bytscl(Ztemp, min=minZ1, max=maxZ1, top=!d.n_colors-nResCol-1, /nan)+1B
; reserve black and white at ends of colorscale

;TJK took out following line 9/30/99 
;endif

if (wBadc gt 0) then Zt(wBad) = 0B ; minZ1

if (n_elements(deviceType) ne 0) then if (deviceType eq 2) then $
   Zt = (!d.n_colors-1B) - Zt ; invert grayscale for Postscript
if flipColorBar then Zt = (!d.n_colors-1B) - Zt ; invert for inverted cscale

xmargin = !x.margin
;ymargin = !y.margin

if doColorBar then if (!x.omargin(1)+!x.margin(1)) lt 14 then !x.margin(1) = 14

;pPosition = !p.position ; save for later
;w = where(pPosition eq 0, wc)
;if (n_elements(position) ne 0) then positiont = position else $
;    if (wc ne 4) then positiont = pPosition else $
;       positiont = [0.1, 0.1, 0.88, 0.9]

;set up x- & y_ ranges to plot axis...

Xminmax = [min([Xmin,Xmax], max=maxt,/nan), maxt]
Yminmax = [min([Ymin,Ymax], max=maxt,/nan), maxt]

;Check for Y-fill values and screen prior to drawing axis...
;CGallap, 9/97, updated BC 2001Mar7
if n_elements(Xfillval) gt 0 then begin
   wn = where(Xmin eq Xfillval[0], wnc)
   if wnc gt 0 then Xmin[wn] = !values.d_nan ; set to NAN
   wn = where(finite(Xmin), wnc) ; find non-NANs including fillVal's
   if wnc le 0 then begin
      msgText = 'No valid Xmin data'
      if doStatus then begin
         message, msgText, /info & status = -1L & return
      endif else message, msgText
   endif ; wnc le 0
   wx = where(Xmax eq Xfillval[0], wxc)
   if wxc gt 0 then Xmax[wx] = !values.d_nan ; set to NAN
   wx = where(finite(Xmax), wxc) ; find non-NANs including fillVal's
   if wxc le 0 then begin ; no valid Xmax data
      msgText = 'No valid Xmax data'
      if doStatus then begin
         message, msgText, /info & status = -1L & return
      endif else message, msgText
   endif ; wxc le 0
   Xminmax = [min([Xmin[wn],Xmax[wx]], max=maxt,/nan), maxt]
endif ; Xfillval

if n_elements(Yfillval) gt 0 then begin
   wn = where(Ymin eq Yfillval[0], wnc)
   if wnc gt 0 then Ymin[wn] = !values.d_nan ; set to NAN
   wn = where(finite(Ymin), wnc) ; find non-NANs including fillVal's
   if wnc le 0 then begin ; no valid Ymin data
      msgText = 'No valid Ymin data'
      if doStatus then begin
         message, msgText, /info & status = -1L & return
      endif else message, msgText
   endif ; wnc le 0
   wx = where(Ymax eq Yfillval[0], wxc)
   if wxc gt 0 then Ymax[wx] = !values.d_nan ; set to NAN
   wx = where(finite(Ymax), wxc) ; find non-NANs including fillVal's
   if wxc le 0 then begin ; no valid Ymax data
      msgText = 'No valid Ymax data'
      if doStatus then begin
         message, msgText, /info & status = -1L & return
      endif else message, msgText
   endif ; wxc le 0
   Yminmax = [min([Ymin[wn],Ymax[wx]], max=maxt,/nan), maxt]
endif ; Yfillval

;if keyword_set(Yfillval) then begin
;   w = where(Ymin ne Yfillval, wc)
;   y = where(Ymax ne Yfillval, yc)
;   if (wc eq yc) then if (wc ne 0) then Yminmax(0) = min([Ymin(w), Ymax(y)],$
;        max=maxt) $
;   else Yminmax(0) = min([Ymin, Ymax], max=maxt)
;CAK  Replaced lines above with lines below.
;    wmin = where(Ymin ne Yfillval, i)  &  if (i eq 0) then wmin = [0]
;    wmax = where(Ymax ne Yfillval, i)  &  if (i eq 0) then wmax = [0]
;    Yminmax[0] = min([Ymin[wmin], Ymax[wmax]])
;endif

; make any changes here also to plot command below polyfill
; rtb added 12/98
;!p.charsize = 1.0

pmulti = !p.multi ; save so overwrite plot command will work

; if ymin has values < 0 then make logY=0 because shouldn't try to plot log of negative numbers:
q=where(ymin lt 0)
if (q(0) ne -1) then logY = 0 

;
; in order to have more tickmark labels when plotting in log scale,
; I removed the ytitle from the extra structure, then called loglevels
; (see further down) to create new tickmark labels.
; RCJ 09/19/00 <- at this date axlabel.pro was also called but in 08/2001 we added Bobby's
; modifications and removed the call to axlabel.
; check for extra.ytitle, BC 2001Mar7
; removed section, BC 2001Aug9
if logY and (n_elements(extra) gt 0) then begin
   extra_names = tag_names(extra)
   w = where(strupcase(extra_names) eq 'YTITLE', wc)
   if wc gt 0 then begin
      hold_ytitle=extra.(w[0])
      extra.(w[0])=' '
      plot, Xminmax, Yminmax, ytype=logY, /nodata, _Extra=extra, ytickformat='(a1)'
   endif else plot, Xminmax, Yminmax, ytype=logY, /nodata, _Extra=extra
endif else plot, Xminmax, Yminmax, ytype=logY, /nodata, _Extra=extra

if logY then crange = 10^!y.crange 

px=!x.window*!d.x_size
py=!y.window*!d.y_size
xWinsize=px(1)-px(0)
yWinsize=py(1)-py(0)

if keyword_set(quick) and ((!d.name eq 'X') or (!d.name eq 'Z') or $
(!d.name eq 'WIN') or (!d.name eq 'MAC') or (!d.name eq 'SUN')) then begin
   ; quick and dirty plotting
   tv,congrid(Zt,xWinsize,yWinsize),px(0),py(0)
endif else begin
   skipX = 1L & avgDeltaX = 1
   ; RCJ 11/02/2007  Changing this condition. It's causing data to disappear 
   ;                 in gif plotting of tha_l2_sst data.
   ;if keyword_set(reduce) and not (!d.flags and 1L) then begin 
   if keyword_set(reduce) then begin 
      ; not scalable pixels (Postscript)
      gaps = findGaps(Xmin(*,0), 1.1, avg=avgDeltaX)
      ; #### uses only first row of Xmin and assumes no fill data in Xmin
      skipX = long((!x.crange(1)-!x.crange(0)) / avgDeltaX / xWinsize) $ ; -1?
                > 1L < (Zsize(1)/2)
   endif ; reduce
   if (n_elements(noclip) gt 0) then noclip = noclip(0) else noclip = 0

   for i = 0L, Zsize(1)-1, skipX do begin
      for j = 0L, Zsize(2)-1 do begin
         doPixel = 1 ; plot all data (no maximum value limit or below limit)
         ;##### why not use minZ, maxZ?
         if (n_elements(maxValue) ne 0) then if (Z(i,j) gt maxValue(0)) then doPixel=0
         if (n_elements(minValue) ne 0) then if (Z(i,j) lt minValue(0)) then doPixel=0
         ;bc         if (n_elements(fillValue) ne 0) then if (Z(i,j) eq fillZ) then doPixel=0

         ;if (Ymin(i,j) lt 0) then doPixel=0
         ;TJK changed 'le' to 'eq' 2/16/2001      if (n_elements(Yfillval) ne 0) then if (Ymin(i,j) le Yfillval) then doPixel=0
         ;CAK change to below on 3/2/2001      if (n_elements(Yfillval) ne 0) then if (Ymin(i,j) eq Yfillval) then doPixel=0
         ;CAK Added test against Ymax values equalling Yfillval.  For at least the IM_k1_RPI data, fill data
         ;    is occuring in different cells, so both the ymin and ymax array points must both be checked, otherwise
         ;    fill data gets through and throws everything off...
         ; updated with [0] as well and added Xfillval, BC
         ;         if (n_elements(Xfillval) gt 0) then doPixel = (Xmin[i,j] ne Xfillval[0] and Xmax[i,j] ne Xfillval[0])
         ;         if (n_elements(Yfillval) gt 0) then doPixel = (Ymin[i,j] ne Yfillval[0] and Ymax[i,j] ne Yfillval[0])
         ;bc         if (n_elements(Xfillval) gt 0) then $
         ;bc             if (Xmin[i,j] eq Xfillval[0]) or (Xmax[i,j] eq Xfillval[0]) then doPixel=0
         ;bc         if (n_elements(Yfillval) gt 0) then $
         ;bc             if (Ymin[i,j] eq Yfillval[0]) or (Ymax[i,j] eq Yfillval[0]) then doPixel=0
         ; check for NAN values
         ;         if (Z(i,j) ne Z(i,j)) or (Xmin[i,j] ne Xmin[i,j]) or (Xmax[i,j] ne Xmax[i,j]) or $
         ;             (Ymin[i,j] ne Ymin[i,j]) or (Ymax[i,j] ne Ymax[i,j]) then doPixel=0
         ; ##### statement below may replace all checks above
         if (finite(Ztemp[i,j]) ne 1) or (finite(Xmin[i,j]) ne 1) or (finite(Xmax[i,j]) ne 1) or $
             (finite(Ymin[i,j]) ne 1) or (finite(Ymax[i,j]) ne 1) then doPixel=0

         if (doPixel) then begin
            ;don't assume that the y-axis starts with 0...
            x = [0,1,1,0] * ((Xmax(i,j)+(skipX-1L)*avgDeltaX) - Xmin(i,j)) + Xmin(i,j)
            y = [Ymin(i,j), Ymin(i,j), Ymax(i,j), Ymax(i,j)]
            polyfill, x, y, color = Zt(i,j), noclip=noclip
            ; #### problem when right on clip boundary? use noclip=1 for Z device
         endif
      endfor ; j
   endfor ; i
endelse

; replot so the box gets put back over the filled area
pmulti2 = !p.multi

; rtb added 12/98
;!p.charsize=1.0

!p.multi = pmulti ; restore from before first plot command
if logY then begin
   lblv=loglevels(crange)
   ; do not plot labels lt or gt crange. They tend to go over labels of other graphs.
   if (n_elements(lblv) ge 3) then begin
;TJK 6/27/2007 - check min being in the max position, which is legal
;                and means the user wants the axis values from highest
;                to lowest, etc.
      if (crange(0) lt crange(1)) then begin
        if lblv(0) lt crange(0) then lblv=lblv[1:*]
        if lblv(n_elements(lblv)-1) gt crange(1) then lblv=lblv[0:n_elements(lblv)-2]
      endif else begin ; crange values have been deliberately switched to plot the data upsidedown
        if lblv(0) gt crange(0) then lblv=lblv[1:*]
        if lblv(n_elements(lblv)-1) lt crange(1) then lblv=lblv[0:n_elements(lblv)-2]
      endelse
   endif   

   extra.ytitle=hold_ytitle
   plot,Xminmax, Yminmax, _Extra=extra, ytype=logY, /nodata, /noerase,$
      yticks=n_elements(lblv)-1,ytickv=lblv 
   ;   lblv=loglevels(Yminmax) <- this is not correct! We really want crange so we are still within
   ;      specified validmin/max.  RCJ
   ;   RCJ. Ugly hack: 
   ;   if n_elements(lblv) ge 3 then begin
   ;      ; try to delete labels that are overlaping with labels from other graphs. RCJ 11/00
   ;;      if lblv(0) le yminmax(0) then lblv=lblv[1:*]
   ;      if lblv(0) lt crange(0) then lblv=lblv[1:*]
   ;;      if yminmax(1) lt $
   ;;         (lblv(n_elements(lblv)-1)+(lblv(n_elements(lblv)-1)-lblv(n_elements(lblv)-2))/2) then $
   ;      if crange(1) lt $
   ;         (lblv(n_elements(lblv)-1)+(lblv(n_elements(lblv)-1)-lblv(n_elements(lblv)-2))/2) then $
   ;         lblv=lblv[0:n_elements(lblv)-2]
   ;   endif
   ;   if max(yminmax) ge 1000000 then fmt='(e7.0)' else fmt='(f7.0)'
   ;   axlabel,lblv,format=fmt
   ; BC 2001Mar7 call plotlabel
   ;   if (n_elements(extra.position) gt 0) and (n_elements(extra.device) gt 0) then begin
   ;      xyouts,extra.position(0)-60,extra.position(1)+50,hold_ytitle,device=extra.device, $
   ;         charsize=extra.charsize, orientation=90, alignment=0.5
   ;   endif else plotlabel, hold_ytitle, /yaxis
   ;;;;;if n_elements(hold_ytitle) gt 0 then plotlabel, hold_ytitle, yaxis=0
   ;   plotlabel, ytitle, yaxis=0
endif else begin
   plot,Xminmax, Yminmax, _Extra=extra, ytype=logY, /nodata, /noerase
endelse

!p.multi = pmulti2 ; restore from after first plot command

if doColorBar then begin
   if (n_elements(ctitle) le 0) then ctitle = ''
   if (n_elements(cCharSize) le 0) then cCharSize = 0.
   xwindow = !x.window
   offset = 0.01
   colorbar, cscale, ctitle, logZ=logZ, cCharSize=cCharSize, nResCol=nResCol, $
        position=[!x.window(1)+offset,      !y.window(0),$
                  !x.window(1)+offset+0.03, !y.window(1)]
   !x.window = xwindow
endif ; colorbar

;!p.Position = pPosition ; restore
!x.margin = xmargin
;!y.margin = ymargin

; mask valid for idl5.3 but we run 5.2 on the web and this keyword is not allowed yet. RCJ
;c=check_math(mask=128) ; clear illegal floating point operand errors from where statements
c=check_math() ; clear illegal floating point operand errors from where statements

return
end ; spectrogram



