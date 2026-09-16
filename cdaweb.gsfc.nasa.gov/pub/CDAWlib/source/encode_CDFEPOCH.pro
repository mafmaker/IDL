;$Author: kovalick $
;$Date: 1996/08/09 17:59:12 $
;$Header: /home/rumba/cdaweb/dev/control/RCS/encode_CDFEPOCH.pro,v 1.2 1996/08/09 17:59:12 kovalick Exp burley $
;$Locker: burley $
;$Revision: 1.2 $
;+------------------------------------------------------------------------
; NAME: ENCODE_CDFEPOCH
; PURPOSE: 
;	Convert a 'yyyy/mm/dd hh:mm:ss' string into CDF epoch time
; CALLING SEQUENCE:
;	e = encode_cdfepoch(instring)
; INPUTS:
;       instring = string in the form: 'yyyy/mm/dd hh:mm:ss'
; KEYWORD PARAMETERS:
; OUTPUTS:
;       e = CDF epoch timetag (i.e. DOUBLE, millisecs since 0 A.D.)
; AUTHOR:
;       Richard Burley, NASA/GSFC/Code 632.0, Feb 13, 1996
;       burley@nssdca.gsfc.nasa.gov    (301)286-2864
; MODIFICATION HISTORY:
;       8/20/96  : R. Burley     : Modify so that input parameter is not
;                                : changed by this function. 
;-------------------------------------------------------------------------
FUNCTION encode_CDFEPOCH, instring
; Convert the yyyy/mm/dd hh:mm:ss string into a CDF Epoch time
estr = strtrim(instring,2) ; trim any leading and trailing whitespace
; Define punctuation marks to be searched for
Punctuation = [44B,45B,46B,47B,58B,59B] ; (i.e. ",-./:;")
a=0 & reads,estr,a,FORMAT='(I)' ; read the year field from the string
s = strpos(estr,'/',0) & estr = strmid(estr,s+1,20) ; reposition after '/'
b=0 & reads,estr,b,FORMAT='(I)' ; read the month field form the string
s = strpos(estr,'/',0) & estr = strmid(estr,s+1,20) ; reposition after '/'
c=0 & reads,estr,c,FORMAT='(I)' ; read the day field from the string
s = strpos(estr,' ',0) & estr = strmid(estr,s+1,20) ; reposition after ' '
d=0 & reads,estr,d,FORMAT='(I)' ; read the hour field from the string
s = strpos(estr,':',0) & estr = strmid(estr,s+1,20) ; reposition after ':'
e=0 & reads,estr,e,FORMAT='(I)' ; read the minute field from the string
s = strpos(estr,':',0) & estr = strmid(estr,s+1,20) ; reposition after ':'
f=0 & reads,estr,f,FORMAT='(I)' ; read the sec field from the string
; Perform TBD validation
CDF_EPOCH,etime,a,b,c,d,e,f,/COMPUTE_EPOCH
return,etime
end

