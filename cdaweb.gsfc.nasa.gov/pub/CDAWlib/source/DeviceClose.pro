;$Author: baldwin $
;$Date: 1996/11/08 20:39:12 $
;$Header: /home/rumba/cdaweb/dev/control/RCS/DeviceClose.pro,v 1.3 1996/11/08 20:39:12 baldwin Exp baldwin $
;$Locker: baldwin $
;$Revision: 1.3 $
Pro DeviceClose,command=command
; 25 Aug 1993 Bobby Candey, Code 632
; Robert.M.Candey.1@gsfc.nasa.gov; 1995 June 22; added GIF

; This procedure closes the print file and submits it to the printer

common deviceTypeC, deviceType, file
;  '(X=0, PS color=1, PS gray=2, PS BW=3, Tek=4, Zbuf=5, GIF=6)? ',deviceType   
if n_elements(deviceType) le 0 then message,'No deviceType defined'
Case deviceType of
  0: begin ; X windows
    End            
  5: begin ; Z buffer
     xscale = !x.s
     yscale = !y.s
     device,/close   ;RTB added 11/96
    End            

  6: begin ; GIF image file output
     xscale = !x.s
     yscale = !y.s
     bytemap = tvrd() ; get bitmap from Z device
;     save,xscale,yscale,bytemap,file='bytemap.dat'
    tvlct, r,g,b, /get ; get colortable actually used
    write_gif, file, bytemap, r,g,b
;    print,' byte map stored in file: ', file ; 'bytemap.dat'
;If you transfer the GIF image to a Macintosh, use Fetch and set its Suffix
;Mapping Custom option to assign the filetype 'GIFf' and use binary transfer.
    End            

  1: begin ; color Postscript
     device,/close
    if keyword_set(command)  then spawn, command
;     spawn, 'print/queue=NCFCP2_PS idl.ps/del'
     print, 'IDL.PS is available for printing to a color Postscript printer'
    End
  2: begin ; grayscale Postscript
     device,/close
    if keyword_set(command)  then spawn, command
;     spawn, 'print/queue=NCFLP1_PS idl.ps/del/notify'
     print, 'IDL.PS is available for printing to a Postscript printer'
    End
  3: begin ; Black and white Postscript
     device,/close
    if keyword_set(command)  then spawn, command
;     spawn, 'print/queue=NCFLP1_PS idl.ps/del/notify'
;     print, 'IDL.PS is available for printing to a Postscript printer'
    End
  4: begin ; Tektronix 4105
    End
  Else: MESSAGE,'INCORRECT OUTPUT DEVICE!!!'
endcase
return
END ; deviceClose
