;
FUNCTION fuv_trim3,x 
  RETURN,STRTRIM(STRING(x,FORMAT='(I3.3)'),2)
END
;
FUNCTION fuv_trim2,x 
  RETURN,STRTRIM(STRING(x,FORMAT='(I2.2)'),2)
END
;
;+-------------------------------------------------------------------------
; NAME: FUV_READ_EPOCH
; PURPOSE: 
;       Convert a string into a string array given a delimiting character 
; CALLING SEQUENCE:
;       fuv_read_epoch,epoch,year,month,day,hour,minute,second,millisecond, $
;              ut,doy,file_stub=file_stub
; INPUTS:
;       epoch - value is the number of milliseconds since 01-Jan-0000 00:00:00.000
; KEYWORD PARAMETERS:
;       file_stub - I have no idea what this is for. RCJ
; OUTPUTS:
;       year, month, day, hour, minute, second, millisecond corresponding to the epoch
;	ut - hours (decimal format) of the day
;	doy - day of year
; AUTHOR:
;       Rick Burley 
; MODIFICATION HISTORY:
;       RCJ 03/2001 - Added the functions fuv_trim2 and 3 to this routine. 
;-------------------------------------------------------------------------

PRO fuv_read_epoch,epoch,year,month,day,hour,minute,second,millisecond $
              ,ut,doy,file_stub=file_stub

   CDF_EPOCH,epoch,year,month,day,hour,minute $
            ,second,millisecond,/BREAKDOWN_EPOCH

   ut=hour + minute/60. +second/3600. + millisecond/(3600.*1000)
   doy=get_doy(day,month,year)
   file_stub=fuv_trim3(doy)+'_'+fuv_trim2(hour)+fuv_trim2(minute)+fuv_trim2(second)

END
