; This is an example program to be called from 
; the "Auto Command" feature (in the "Options" menu)
;
PRO xtplot_example
@xtplot_com
  pA = xtplot_pcsrA
  pB = xtplot_pcsrB
  
  print, xtplot_pcsrA, xtplot_pcsrB
  print, xtplot_vnameA
  print, xtplot_vnameB

  if strmatch(xtplot_vnameA, xtplot_vnameB) then begin
    if (pB eq 0 ) then begin
      msg = 'Please set two cursors, because this example program calculates a sum between two cursors.'
      result = dialog_message(msg,/center)
    endif else begin
      if pB lt pA then begin
        pAtmp = pA
        pA = pB
        pB = pAtmp
      endif
    endelse
    
    get_data, xtplot_vnameA, data=D
    sz = size(D.y)
    ndim = sz[0]
    case ndim of
      1:begin; scalar
        sum = total(D.y[pA:pB])
        tag = 'data'
        end
      2:begin; vector or spectrogram
        tag = (sz[2] eq 3) ? 'x-component': 'first element'
        sum = total(D.y[pA:pB, 0])
        end
      else:sum = !VALUES.F_NAN
    endcase
        
    print, '***************************************'
    print, 'sum of the '+tag+' between the two cursors are: ', sum
    print, '***************************************'
  endif
END
