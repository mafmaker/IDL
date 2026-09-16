pro imzap7,fin,fout,crpix
;
; This routine is for cosmic ray removal from a single image when it 
;  is not possible to compare two or more images with minzap.  Adapted 
;  from minzap.pro (6/94) to remove cosmic rays from single WFPC2 
;  image: for each pixel, calculates median and deviation from median 
;  in 7 x 7 array, then for values more than n sigma from median it
;  replaces value with median of 7 x 7 array.
;
; Roughly 4-7 iterations of this .pro are needed to remove CR's, and
;  it also removes point source features - just for diffuse emission!
;  You should expect some residual CR's at the end... try handzap.pro
;  to get rid of these...also you can vary the threshold for replacing
;  values "n"...
;
;  Initial version    June 1994   JTC
;
;  - runs through 7 iterations, sigma = 2.6   at ST ScI  7/94  JTC
;
;  - add map of CR pixel locations, output "crpix", dimensions = 
;    dim's of fin, with values of zero for un-altered pixel locations
;    and original value for altered locations      7/95     JTC
;
if n_params(0) eq 0 then begin
 print,' imzap7,fin,fout,crpix'
 return
endif
;
print,' '
print,' *** Warning - this routine takes out point source features...***'
print,' '
;
;  force array to be floating point
;
f1 = float(fin)
fout = f1
crpix = f1*0.
;
sz = size(f1)
nx = sz(1)
ny = sz(2)
print,' image is ',nx,'    by ',ny
;
;  set minimum sigma for replacement of value
;
n = 3.0
;
;  get range of x,y in array to zap...
;
read,' enter xstart,xstop (range of x to clean) ',i1,i2
i1 = fix(i1) & i2 = fix(i2)
print,' xstart = ',i1,', xstop = ',i2
read,' enter ystart,ystop (range of y to clean) ',ii1,ii2
ii1 = fix(ii1) & ii2 = fix(ii2)
print,' ystart = ',ii1,', ystop = ',ii2
;
;  run 7 iterations in j loop
;
print," start at:  ",systime(0)
;
for j = 0,6 do begin
f1 = fout
;
;  double loop through array
;
 for i=i1,i2 do begin
  for ii=ii1,ii2 do begin
    farea = f1(i-3:i+3,ii-3:ii+3)
    med = median(farea)
    mean = total(farea)/49.
    sigma = sqrt(total((farea-med)^2)/49.)
    dif = f1(i,ii)-med
    if dif gt n*sigma then crpix(i,ii) = fout(i,ii)
    if dif gt n*sigma then fout(i,ii) = median(f1(i-3:i+3,ii-3:ii+3))
  endfor
 endfor
;
 print,' loop = ',j+1,'   is finished...',6-j,'  to go...'
endfor
;
print," finished at:  ",systime(0)
;return
end                                ;  imzap7
