function prank,array,percentile,histo=histo,top=top,binres=binres
;+
; ROUTINE:    prank
;
; PURPOSE:    compute the value in ARRAY which is at a given 
;             percentile ranking within ARRAY.  For example,
;             median_of_array=prank(array,50)
;
; USEAGE:     result=prank(array,percentile)
;
; INPUT:
;   array     an array of values, any type but string or complex
; percentile  percentile rank 
;
; KEYWORD INPUT:
;   top       if set, percentile ranking is reversed so that a percentile
;             ranking of 0 is the max value and a percentile ranking of 
;             100 is the bottom value.
;
;   binres    histogram bin resolution as a percentage of the total dynamic
;             range (default = 1).  If the input array is of type byte
;             then the default bin resolution is 1 unit.
;
;   histo     histogram of ARRAY, use this optional input to save time
;             when PRANK is to be called many times. to retrieve the
;             histogram on the first call, set this keyword to a named
;             variable with an initial value of undefined or zero.
;
; OUTPUT:     result=prank(array,percentile)
;             result=value within array which is at the specified percentile
;             rank
;
; PROCEDURE:
;             1. compute histogram of ARRAY
;             2. sum up histogram from bottom (or top if TOP is set)
;                until the specified percentile value is reached
;             3. return the value 
;             
; EXAMPLE:    plot a random variable ignoring values in the top and 
;             bottom 1% percentiles:
; 
;             histo=0
;             array=randomn(iseed,200)
;             r1=prank(array,1,histo=histo) 
;             r2=prank(array,1,/top,histo=histo)
;             plot,array,yrange=[r1,r2]
;
; AUTHOR:     Paul Ricchiazzi     ESRG/UCSB    sep93
;-
;
nn=n_elements(array)
qmax=max(array,min=qmin) & totrng=qmax-qmin

sz=size(array)
if keyword_set(binres) eq 0 then binres=1.
if sz(n_elements(sz)-2) eq 1 then begin
  binsiz=1 
  factor=1
endif else begin
  binsiz=.01*binres*totrng
  factor=binres*100./totrng
endelse
if keyword_set(histo) eq 0 then histo=histogram(factor*array)
if keyword_set(top) then h=reverse(histo) else h=histo
nh=n_elements(h)
hsum=0.
pern=.01*percentile*nn

case 1 of
  pern ge nn: fj=nh-1
  pern le  0: fj=0.
  else: begin
    j=-1
    repeat begin & j=j+1 & hsum=hsum+h(j) & endrep until hsum ge pern 
    fj=j-(hsum-pern)/h(j)
  end
endcase

if keyword_set(top) then return,qmax-fj*binsiz else return,qmin+fj*binsiz

end


