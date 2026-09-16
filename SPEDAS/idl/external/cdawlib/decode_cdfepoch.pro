;$Author: kenb $
;$Date: 2006-10-11 13:32:51 -0700 (Wed, 11 Oct 2006) $
;$Header: /home/rumba/cdaweb/dev/control/RCS/decode_CDFEPOCH.pro,v 1.1 1996/08/09 14:06:31 kovalick Exp kovalick $
;$Locker: kovalick $
;$Revision: 8 $
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
;-------------------------------------------------------------------------
FUNCTION decode_CDFEPOCH, etime
; Create a yyyy/mm/dd hh:mm:ss string given a CDF Epoch time
CDF_EPOCH,etime,Yr,Mo,Day,Hr,Min,Sec,Mil,/BREAKDOWN_EPOCH
estr1 =         strtrim(string(Yr ,FORMAT='(I4.4)'),2) + '/'
estr1 = estr1 + strtrim(string(Mo ,FORMAT='(I2.2)'),2) + '/'
estr1 = estr1 + strtrim(string(Day,FORMAT='(I2.2)'),2) + ' '
estr1 = estr1 + strtrim(string(Hr ,FORMAT='(I2.2)'),2) + ':'
estr1 = estr1 + strtrim(string(Min,FORMAT='(I2.2)'),2) + ':'
estr1 = estr1 + strtrim(string(Sec,FORMAT='(I2.2)'),2)
return,estr1
end
