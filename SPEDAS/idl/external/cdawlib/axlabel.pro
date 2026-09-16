;-------------------------------------------------------------
; $Id: axlabel.pro 8 2006-10-11 20:32:51Z kenb $
;+
; NAME:
;        AXLABEL
;
; PURPOSE:
;        Put previously calculated axis labels onto the screen
;        at proper position. This routine was designed to work 
;        together with LOGLEVELS to produce fancy log plots.
;        It involves several coordinate transformations in order
;        to be device independent and take into account the 
;        character size. The user can specify a label format
;        and use 'external' formatting functions similar to
;        the [XYZ]TICKFORMAT keyword of PLOT.
;
; CATEGORY:
;        Plotting
;
; CALLING SEQUENCE:
;        AXLABEL,Value [,/XAxis] [,keywords]
;
; INPUTS:
;        VALUE -> A vector with the values to be labelled on the 
;             axis.
;
; KEYWORD PARAMETERS:
;        /XAxis -> If set, the labels are placed on the X achis
;             rather than on the Y axis
;
;        /YAxis -> Place the labels on the Y axis (this is the default,
;             and this keyword is there for purely aesthetic reasons)
;
;        CHARSIZE -> The character size of the label
;
;        FORMAT -> An IDL format string (used as argument to the
;              STRING function) or the name of a function that returns
;              formatted labels. This function must accept three
;              arguments, the third of which is the current value
;              (see the online help to [XYZ]TICKFORMAT for more details).
;              AXLABEL always passes 0 to the first two arguments.
;
;        _EXTRA  keywords are passed on to XYOUTS (e.g. COLOR or
;              ORIENTATION). Note that the ALIGN keyword value is 
;              determined automatically.
;
; OUTPUTS:
;        Axis labels without fuss.
;
; SUBROUTINES:
;        None.
;
; REQUIREMENTS:
;        A DATA coordinate system must be established by a previous
;        PLOT command.
;
; NOTES:
;        AXLABEL currently operates only on the left and bottom axes.
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
;        mgs, 10 Sep 1999: VERSION 1.00
;
;-
; Copyright (C) 1999, Martin Schultz, Max-Planck-Institut f. Meteorologie
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to martin.schultz@dkrz.de
; with subject "IDL routine axlabel"
;-------------------------------------------------------------


pro axlabel,value,Charsize=Charsize,XAxis=XAxis,YAxis=YAxis,   $
       Format=Format,_EXTRA=e
 
 ; Lblv = LOGLEVELS([mind,maxd])
 ; PLOT,X,Y,/YLOG,YTICKFORMAT='(A1)'
 
   ; Error catching
   if (N_Elements(VALUE) eq 0) then begin
      message,'Must supply a label value to AXLABEL!'
   endif
 
   ; Set default for CHARSIZE and FORMAT
   if (n_elements(CHARSIZE) EQ 0) then $
      CHARSIZE = 1.
   if (n_elements(FORMAT) EQ 0) then $
      FORMAT = '(f8.1)'
 
   if (keyword_set(XAxis)) then begin
 
      ; Get y position for label
      ; Subtract one character size
      PY = !Y.Window[0] 
      PYOFF = CONVERT_COORD(1,!D.Y_CH_SIZE*CHARSIZE,/DEVICE,/TO_NORMAL)
      PY = PY - 1.05*PYOFF[1]
      PY = REPLICATE(PY,N_Elements(VALUE))
 
      ; Convert data values to normalized x coordinates
      PX =CONVERT_COORD(VALUE,REPLICATE(!Y.CRange[0],N_Elements(VALUE)), $
                         /DATA,/TO_NORMAL)
      PX = PX[0,*]
 
   endif else begin   ; Y axis label (default)
 
      ; Get x position for label
      PX = !X.Window[0] - 0.010
      PX = REPLICATE(PX,N_Elements(VALUE))
 
      ; Convert data values to normalized coordinates and
      ; subtract half the character size
      PYOFF = CONVERT_COORD(0,!D.Y_CH_SIZE*CHARSIZE,/DEVICE,/TO_NORMAL)
      PY =CONVERT_COORD(REPLICATE(!X.CRANGE[0],N_Elements(VALUE)),VALUE,  $
                         /DATA,/TO_NORMAL)
      PY = PY[1,*]-0.5*PYOFF[1]
   endelse
 
   ; Format VALUE according to format string. If this string
   ; does not begin with '(', it is assumed that the user has passed
   ; a formatting function as for [XYZ]TICKFORMAT
   ; However, only the third (NUMBER) argument of this function is used
   if (STRPOS(FORMAT,'(') ne 0) then begin
      ValS = STRARR(N_Elements(VALUE))
      for j=0,N_Elements(VALUE)-1 do $
         ValS[j] = CALL_FUNCTION(FORMAT,0,0,VALUE[j])
   endif else $      ; apply format string directly
      ValS = STRING(VALUE,format=FORMAT)
 
   ValS = STRTRIM(ValS,2)
 
   XYOUTS,PX,PY,ValS,/NORMAL,align=1.-0.5*keyword_set(XAxis),  $
      charsize=CHARSIZE,_EXTRA=e
 
   return
end
