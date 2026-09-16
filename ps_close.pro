pro ps_close
;
; Program to close postscript device and switch back to 'X'. 
; Not that we are not switching back to 'Mac' or 'Win' because
; that's fer sucks.
;

device,/close
set_plot,'x'


end