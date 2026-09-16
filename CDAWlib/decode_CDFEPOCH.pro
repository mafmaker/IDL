;$Author: johnson $
;$Date: 2012/11/15 21:02:44 $
;$Header: /home/cdaweb/dev/control/RCS/decode_CDFEPOCH.pro,v 1.5 2012/11/15 21:02:44 johnson Exp johnson $
;$Locker: johnson $
;$Revision: 1.5 $
;+------------------------------------------------------------------------
; NAME: DECODE_CDFEPOCH
; PURPOSE: 
;	Create a yyyy/mm/dd hh:mm:ss string given a CDF Epoch time
; CALLING SEQUENCE:
;       out = decode_cdfepoch(e)
; INPUTS:
;       e = CDF Epoch timetag (i.e. DOUBLE, millisecs from 0 A.D.)
; KEYWORD PARAMETERS:
; OUTPUTS: out = string in the format 'yyyy/mm/dd hh:mm:ss'
; AUTHOR:
;       Richard Burley, NASA/GSFC/Code 632.0, Feb 13, 1996
;       burley@nssdca.gsfc.nasa.gov    (301)286-2864
; MODIFICATION HISTORY:
;
;   RCJ Mar/2012 Keywords tt2000 and epoch16 were added
;-------------------------------------------------------------------------
FUNCTION decode_CDFEPOCH, etime, TT2000=TT2000, EPOCH16=EPOCH16, incl_mmm=incl_mmm
; Create a yyyy/mm/dd hh:mm:ss string given a CDF Epoch time
;
; CDF_EPOCH:  dd-mm-yyyy hh:mm:ss   or    dd-mm-yyyy hh:mm:ss.mmm  if incl_mmm is set
; CDF_EPOCH16:  dd-mm-yyyy hh:mm:ss.mmm.uuu.nnn.ppp
; CDF_TIME_TT200: yyyy-mm-ddThh:mm:ss.mmmuuunnn
;
;
case 1 of
   keyword_set(tt2000): begin
      CDF_TT2000,etime,Yr,Mo,Day,Hr,Min,Sec,Mil,usec,nsec,/BREAKDOWN_EPOCH, /tointeger
      ;print,Yr,Mo,Day,Hr,Min,Sec,Mil,usec,nsec
      estr1 = strtrim(string(Yr ,FORMAT='(I4.4)'),2) + '-'
      estr1 = estr1 + strtrim(string(Mo ,FORMAT='(I2.2)'),2) + '-'
      estr1 = estr1 + strtrim(string(Day,FORMAT='(I2.2)'),2) + 'T'
      estr1 = estr1 + strtrim(string(Hr ,FORMAT='(I2.2)'),2) + ':'
      estr1 = estr1 + strtrim(string(Min,FORMAT='(I2.2)'),2) + ':'
      estr1 = estr1 + strtrim(string(Sec,FORMAT='(I2.2)'),2) + '.' 
      estr1 = estr1 + strtrim(string(Mil,FORMAT='(I3.3)'),2) 
      estr1 = estr1 + strtrim(string(usec,FORMAT='(I3.3)'),2) 
      estr1 = estr1 + strtrim(string(nsec,FORMAT='(I3.3)'),2)
   end
   keyword_set(epoch16): begin
      CDF_EPOCH16,etime,Yr,Mo,Day,Hr,Min,Sec,Mil,usec,nsec,psec,/BREAKDOWN_EPOCH 
         estr1 =         strtrim(string(Yr ,FORMAT='(I4.4)'),2) + '/'
         estr1 = estr1 + strtrim(string(Mo ,FORMAT='(I2.2)'),2) + '/'
         estr1 = estr1 + strtrim(string(Day,FORMAT='(I2.2)'),2) + ' '
         estr1 = estr1 + strtrim(string(Hr ,FORMAT='(I2.2)'),2) + ':'
         estr1 = estr1 + strtrim(string(Min,FORMAT='(I2.2)'),2) + ':'
         estr1 = estr1 + strtrim(string(Sec,FORMAT='(I2.2)'),2) + '.'
         estr1 = estr1 + strtrim(string(mil,FORMAT='(I2.2)'),2) + '.'
         estr1 = estr1 + strtrim(string(usec,FORMAT='(I2.2)'),2) + '.'
         estr1 = estr1 + strtrim(string(nsec,FORMAT='(I2.2)'),2) + '.'
         estr1 = estr1 + strtrim(string(psec,FORMAT='(I2.2)'),2) 
   end
   else: begin
         CDF_EPOCH,etime,Yr,Mo,Day,Hr,Min,Sec,Mil,/BREAKDOWN_EPOCH
         estr1 =         strtrim(string(Yr ,FORMAT='(I4.4)'),2) + '/'
         estr1 = estr1 + strtrim(string(Mo ,FORMAT='(I2.2)'),2) + '/'
         estr1 = estr1 + strtrim(string(Day,FORMAT='(I2.2)'),2) + ' '
         estr1 = estr1 + strtrim(string(Hr ,FORMAT='(I2.2)'),2) + ':'
         estr1 = estr1 + strtrim(string(Min,FORMAT='(I2.2)'),2) + ':'
         estr1 = estr1 + strtrim(string(Sec,FORMAT='(I2.2)'),2)
	 if keyword_set(incl_mmm) then $
         estr1 = estr1 + '.' + strtrim(string(Mil,FORMAT='(I3.3)'),2)
   end	 
endcase


;print,'estr1 = ',estr1
return,estr1
end
