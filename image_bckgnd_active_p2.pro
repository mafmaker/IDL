pro fill_array, array

;fill each point in the array with the value of its nearest good neighbor

sizer = size(array)

for i = 0, sizer(1)-1 do begin

  vector = array(i, *)
  badfinder = where(vector le 0 or finite(vector) ne 1, counter)
  goodfinder = where(vector gt 0 and finite(vector) eq 1, goodpix)
  if goodpix gt 0 then begin
    for j = 0, counter-1 do begin
      differ = abs(badfinder(j) -goodfinder)
      finder2 = where(differ eq min(differ))
      vector(badfinder(j)) = vector(goodfinder(finder2))
    endfor
    array(i, *) = vector
  endif

endfor

for i = 0, sizer(2)-1 do begin

  vector = array(*, i)
  badfinder = where(vector le 0 or finite(vector) ne 1, counter)
  goodfinder = where(vector gt 0 and finite(vector) eq 1, goodpix)
  if goodpix gt 0 then begin
    for j = 0, counter-1 do begin
      differ = abs(badfinder(j) -goodfinder)
      finder2 = where(differ eq min(differ))
      vector(badfinder(j)) = vector(goodfinder(finder2))
    endfor
    array(*, i) = vector
  endif

endfor

return
end

pro fill_array2, array

;--- this one will be a memory hog and a cpu hog. 

  sizer = size(array)

  badfinder = where(array le 0 or finite(array) ne 1, counter)
  goodfinder = where(array gt 0 and finite(array) eq 1, goodpix)

  dopix = fltarr(counter)
  dopix_x = badfinder mod sizer(1)
  dopix_y = badfinder / sizer(1)
  goodpix_x = goodfinder mod sizer(1)
  goodpix_y = goodfinder / sizer(1)

;--- calculate all distances simultaneously for each pixel
  for i = 0, counter-1 do begin
    dists = ((dopix_x(i)-goodpix_x)^2 + (dopix_y(i)-goodpix_x)^2);^0.5
    quickie = goodfinder(sort(dists))
    array(dopix_x(i), dopix_y(i)) = array((quickie(0)))
  endfor

return
end

  pro image_bckgnd_active_p2,imageinfo,bck,iteration,noflat=noflat,$
	bastille=bastille,nof107=nof107,raw=raw,bias=bias, active = active, $
        hyperactive = hyperactive, maglat = maglat, $
                            unflat = unflat,  fuview = fuview, $
                             stopper = stopper, pcap = pcap
;
;  Author : Thomas Immel, UCB
; License : BSD
;
;
; This program calculates a background dayglow image for 
; any particular wic or si13 image. as of 9-1-2000, there is no
; si model, but this should be designed with si in mind.
;
; For active modeling, this program EXPECTS an un-flatfielded
; array. If the flatfield has already been applied, then provide th
; keyword noflat. The keyword is something of a misnomer. To be clear:
;
; FLATFIELD RULES. Unflatfielded image is given (/noflat is not
; specified). The image HAS to be flatfielded for analysis. The
; returned background is a flat image.
;
; Flatfielded image (/noflat is specified). No flatfielding is
; necessary before binning. The returned background is still a flat image.
;
; I.E. the returned background is ALWAYS FLAT. UNLESS /unflat is
; specified in the call
;
; BIAS RULES.
;
; in bin_cts2.pro one will find:
;BIG_CT          DOUBLE    = Array[21, 110, 90]
;BIG_WT          INT       = Array[21, 110, 90]
;CT_ARR          DOUBLE    = Array[110, 90]
;WT_ARR          FLOAT     = Array[110, 90]
;
; in bias file (for WIC anyway) one will find bias_wic and surface 
; where surface is the fit to the whole thing
;
; the f107 corrections are found using correct_f107_wic or 
; correct_f107_si
;
; adapt to SI13 using imageinfo.src = '13LS' for that instrument
; 
; changes : 9-28-2000 - Choice to return 'flattened' image, selecting
;			noflat or flat keyword.
;	   10-11-2000 - Added iteration flag
;		      - changed correct_f107_wic to correct_f107_p
;			which has sc_flag (determined locally)
;		      - added s13 f107 corrections
;  6-18-01 added adjustment so that it never ASSUMES the size of any image,  
;  	since Harald may hand over a 2x SI image from calculate_grids 
;
;
;          Version 1.0
;
;          05-17-2002 - Going after an active correction scheme for
;                     - total removal, vs reference removal
;
;          06-28-2002 - if in doubt, set iteration to 0
;          active flag - removes as a function of solar zenith angle (SZA)
;          hyperactive flag - continues and removes as a function of ImageZA
;          08-29-2002 - actually indicated the author in the comments above
;          02-04-2003 - stopper keyword added.

;          Version 2.0
;
;          02-13-2003  - Version 2 release. Hyperactive is no longer
;                        the recommended method. Use /active and then
;                        call image_bckgnd_clock_correct. If that one
;                        crashes you need an updated version of fuv_ptg.pro!
;          02-21-2003 -  removed clock keyword
;                        added pcap keyword
;                        changed mlat_limit keyword to maglat
;          09-16-2003 -  Harald found what I should have noted clearly
;                        earlier, that this is a WIC centric code and
;                        will crash on SI-12, SI-13. It is MEANT TO
;                        WORK with image_bckgnd_clock_correct and wic
;                        imageinfo files. min_avg will come up undefined.
;
;

                 
;--- other keywords
;
;  added bastille flag to use base file from ~/neo/sci/fuv/bastille/quiet 
;  images
;  added nof107 flag to NOT perform flaky f107 corrections
;  added raw flag to use no fitted values.
;
;  The addition of iteration is a little tricky. 0 means there are
;  no f107 (or other future) corrections to make. The database used
;  to create the background is the raw s and d binned stuff.
;  Iteration=1 means use a normalized background (.idlf vs .idl) AND
;  make the proper corrections to images using (s13)comp_f107.idl
;
;  
;
;

;Print,'Making Background : Iteration= ' + strcompress(iteration) + $
;	'



;@degree_trig		;these must now be called in the calling routine
;@fuv_ptg
;@/home/immel/sci/fuv/model/correct_f107_p.pro
;@/home/immel/sci/fuv/model/get_f107_for_time_p.pro

fuview_flag =  0
flat_flag = 1
bastille_flag = 0	
f107_flag = 1
raw_flag = 0
mlat_limit = 60  ; limiting magnetic latitude for pixels
pcap_limit = 90
flat_bck_flag = 0

if keyword_set(noflat) eq 1 then flat_flag = 0
if keyword_set(raw) eq 1 then raw_flag = 1
if keyword_set(nof107) eq 1 then f107_flag = 0
if keyword_set(bastille) eq 1 then bastille_flag = 1
if keyword_set(maglat) eq 1 then mlat_limit = maglat
if keyword_set(fuview) gt 0 then fuview_flag = 1
if keyword_set(unflat) gt 0 then flat_bck_flag =  1
if keyword_set(pcap) gt 0 then pcap_limit = 80

image_size=size(imageinfo.image)
xsize=image_size(1)			;new 6-18-01
ysize=image_size(2)

if fuview_flag ne 1 then datafile_path = '$FUV_HOME/quiet/' else $
                         datafile_path = '$FUVIEW_HOME/support/'
if fuview_flag ne 1 then bias_path = '$FUV_HOME/flatfield/' else $
                         bias_path = '$FUVIEW_HOME/support/'


if imageinfo.src eq 'HWIC' then begin
  def_xsize=256
  def_ysize=256
  restore,datafile_path + 'fit_bin_cts2.idlf'  ;this is a small file
					       ;and restores AVG only
					       ;there is no option to
					       ;restore raw data here.
  sc_flag=0
  sizer = size(avg)
;--- this hack fixes the S=105-110 range= 0 problem 
  avg(104:*,*)=avg(103,*)##(fltarr(sizer(1)-104)+1)
  dumavg = avg(80:*, 0:70)
  min_avg = min(dumavg(where(dumavg gt 0)))  ;for application everywhere later
  avg =  avg >  min_avg  ;fix those stupid zeros now

;  stop

endif

if imageinfo.src eq '13LS' then begin
  def_xsize=128				;new 6-18-01
  def_ysize=128
  starter='fit_'
  if raw_flag eq 1 then starter=''		;if keyword 'raw' is set then
						;the raw data is restored
						;the same goes for SI12 below

  if bastille_flag eq 0 then $
	restore,datafile_path+starter+$
		's13_bin_cts2.idl' else $
	restore,datafile_path+starter+$
		'bastille_s13_bin_cts2.idl'   
  sc_flag = 2
  if raw_flag eq 1 then avg=ct_arr/wt_arr	;if keyword raw is set then
						;you have to calculate
						;avg quickly 
						;the same goes for SI12 below

endif						

if imageinfo.src eq '12LS' then begin
  def_xsize=128
  def_ysize=128
  starter='fit_'
  if raw_flag eq 1 then starter=''
  if bastille_flag eq 0 then $
	restore,datafile_path+starter+$
		's12_bin_cts2.idl' else $
	restore,datafile_path+starter+$
		'bastille_s13_bin_cts2.idl'   
  sc_flag = 3 &  if fuview_flag gt 0 then sc_flag =  1
  if raw_flag eq 1 then avg=ct_arr/wt_arr

endif


;---now get wic_bias background.

case imageinfo.src of				
  'HWIC' : restore,bias_path + 'wic_bias.idl' ;surface
   else  : begin
		surface=fltarr(128,128) & surface(*)=0
	   end
endcase

  if xsize ne def_xsize or ysize ne def_ysize then $
	surface=congrid(surface,xsize,ysize,/interp)


sza=imageinfo.sza
dza=imageinfo.dza

sza=fix(round(sza)) & dza=fix(round(dza))

bck=sza & bck(*)=0
doback=where(sza gt -1 and sza lt 110 and dza lt 80,count)
noback=where(sza eq -1 or sza ge 110 or dza gt 80,badoff)
dsk = where(sza gt -1, diskon)

bck(dsk) = min_avg

if count gt 0 then begin

;--- rebin dayglow on the fly to have something to compare directly to
;--- avg
  if keyword_set(active) gt 0 or keyword_set(hyperactive) gt 0 then begin

    sizer = size(avg)
    year_=imageinfo.time(0)/1000
    day_=imageinfo.time(0) - 1000*year_

;--- flatfield the image, since the data used for the avg array were 
;--- flatfielded, and had the background counting rate removed
    
    if flat_flag gt 0 or flat_bck_flag gt 0 then $
    if fuview_flag le 0 then flat_arr=get_flatfield(year_,day_,sc_flag) $
      else flat_arr = get_fuview_flatfield(year_, day_, sc_flag)

;      flat_arr=get_flatfield(year_,day_,sc_flag)
    if flat_flag gt 0 then begin
;    flatimg = (imageinfo.image-surface)*flat_arr
      flatimg = (imageinfo.image)*flat_arr 
    endif else flatimg = imageinfo.image

    binimg = avg-avg  ;create array same size as avg
;---this one peeks in the polar cap and isnt very safe
;    tobin = where(imageinfo.dza lt 70 and $
;                  (abs(imageinfo.mlat) lt 60 or abs(imageinfo.mlat) gt 75) $
;                  and imageinfo.sza lt 120, tobincount)

    tobin = where(imageinfo.dza lt 70 and $
                  (abs(imageinfo.mlat) lt mlat_limit $ 
                  or abs(imageinfo.mlat) gt pcap_limit) $
                  and imageinfo.sza lt 111, tobincount)
    if tobincount lt 1 then goto, GETOUT   ;abandon all attempts to fit dayglow
    binimg(imageinfo.sza(tobin), imageinfo.dza(tobin)) = flatimg(tobin)

;--- the image is binned. Compare with model. avg_ array is a tool
;--- now since we are going to do a fit, smooth binimg with a serious
;--- median filter 

;    binimg = median(binimg, 9)
;--- use slower but more versatile median_arr
    binimg = median_arr(binimg, 5, 0)   ;exclude zeroes!

    bad_range = where(binimg eq 0)
    good_range = where(binimg ne 0)
    rat_img = avg/binimg
    rat_img(bad_range) = 0
    avg_ = avg
    avg_(bad_range) = 0
    srat = total(binimg, 2)/total(avg_, 2)
    srat2d = binimg/avg_
    fill_array, srat2d
    killnan, srat, 0


;--- using avg/binimg ratios at every solar zenith angle, make corrections to
;--- recreate avg_ array
    
;    for i = 0, sizer(1)-1 do avg[i, *] = avg[i, *] * srat(i)

    avg = avg*srat2d
    
;--- reset min_avg

  dumavg = avg(80:*, 0:70)
  min_avg = min(dumavg(where(dumavg gt 0)))

;if keyword_set(stopper) then stop

    if keyword_set(hyperactive) gt 0 then begin

      avg = median(avg, 9)
      avg_ = avg
      avg_(bad_range) = 0

;--- adjust avg_ as well, as we will use this to do the dza variation
;    now. This is the array that has zeroes everywhere no data were
;    available in the image.
;    for i = 0, sizer(1)-1 do avg_(i, *) = avg_(i, *) * srat(i)





;--- now fit the residual differences (and correct for them!).

      ncoefs = 3
      coef_arr = fltarr(ncoefs, sizer(1)) ; array to hold all the coefficents
      coef_wt_arr = fltarr(sizer(1));array to hold the values of sigma
;      newcoef_arr = coef_arr
      asurf = fltarr(sizer(1), sizer(2))
      for i = 0, sizer(1)-1 do begin
        weights = avg_(i, *)
        finder = where(weights ne 0, countfind)
        if total(weights) ne 0 and countfind gt 5 then begin
          weights(where(weights ne 0)) = 1

;--- normalize weights to 1, and give pd=1 areas a weight of 0.01
          weights = weights/countfind + 0.01 ;(make sure they are 1 w/killnan)
;        plot, weights
;--- Make percent differences
          tofit = reform( (binimg(i, *)-avg_(i, *))/avg_(i, *) + 1   )

         killnan, tofit, 1
          coefs = polyfitw(indgen(sizer(2)),tofit, weights, ncoefs-1, $
                           a, b, c, d)
          coef_arr(*, i) = coefs
          coef_wt_arr(i) = c
          asurf(i, *) = a
;          print, c

;--- comment the following lines out if you are going to collect all
;    the coefficients and remake the "a" arrays from fits thereof
          avg[i, *] = avg[i, *]/ a
          avg_[i, *] = avg_[i, *] / a
        endif
      endfor   ;end loop through solar zenith angles



;--- I want a parabola, not just a linear fit. To keep the fit from
;    varying largely from bin to bin, I Need either larger
;    bins, or a sliding window over S for all the fits, or a table of
;    coefficents that then get fitted. hmmm...

;;;--- OK the table of fitted coefficents does not work, because
;;;--- we are trying to use fitted data away from the observations,
;;;    which does not work well at all. Need to open the window, or something.


;                         weights, 2, a, b, c)
;--- a is the fit, or indgen(90)^2*coefs(2) + indgen(90)*coefs(1) + coefs(0)
;        stop
;        print, coefs


;      for i = 0, 2 do begin
;        newcoefs = polyfitw(findgen(sizer(1)),coef_arr(i, *), $
;                            coef_wt_arr/max(coef_wt_arr), 1, a)
;        newcoef_arr(i, *) = a;
;
;      endfor

;      sza_arr = findgen(sizer(1))
;      for i = 0, sizer(1)-1 do begin
;         aa = newcoef_arr(2, *)*sza_arr^2 + $
;              newcoef_arr(1, *)*sza_arr + newcoef_arr(2, *)
;         avg(i, *) = avg(i, *)* aa
;          avg_(i, *) = avg_(i, *) * aa
;      endfor

;--- reset min_avg
;      min_avg = min(avg(where(avg gt 0)))   ;for application everywhere later
;      avg =  avg >  min_avg

      dumavg = avg(80:*, 0:70)
      min_avg = min(dumavg(where(dumavg gt 0)))  
;      avg =  avg >  min_avg  

    endif           ;end hyperactive section

  endif             ;end active section

  bck(dsk) = min_avg
  for i=0L,count-1L do bck(doback(i))=avg[sza(doback(i)),dza(doback(i))]

  bad_pix=where(bck(doback) eq 0,baddiez)	;do no background 

    ;stop


;--- now do CLOCK ANGLE CORRECTION!


;--- skip f107 correction if active correction is on...
  if keyword_set(active) gt 0 or keyword_set(hyperactive) gt 0 $
    then goto, DONE_ACTIVE



;--- is this next line right? I am adding this a second time later!

;  bck=bck + surface		;add the slightly temperature dependent
				; bias background for wic.

;---now get f107 correction array

  if iteration gt 0 and f107_flag gt 0 then begin

    case imageinfo.src of 
  'HWIC': begin 
		get_f107_for_time_p,imageinfo.time,f107
		spare=imageinfo
		correct_f107_p,spare,f107,iteration,sc_flag,/correct	
					;spare will have the correction
					;array since we provide the /correct
		bck=bck+spare
		
		print,'Added f107 corrections to wic background' 
	  end
  '13LS' : begin
		get_f107_for_time_p,imageinfo.time,f107
		spare=imageinfo
		correct_f107_p,spare,f107,iteration,sc_flag,/correct	
					;spare will have the correction
					;array since we provide the /correct
		bck=bck+spare
		print,'Added f107 corrections to s13 background' 
	   end


  else: print,'No f107 correction is yet available'
    endcase
  endif


;--- now FLAT FIELD the BACKGROUND IMAGE, so that it looks like an un
;--- flatfielded image


  if flat_flag eq 1 then begin

    year_=imageinfo.time(0)/1000
    day_=imageinfo.time(0) - 1000*year_

;--- all you have to say is this:

    if fuview_flag le 0 then flat_arr=get_flatfield(year_,day_,sc_flag) $
      else flat_arr = get_fuview_flatfield(year_, day_, sc_flag)

    if xsize ne def_xsize or ysize ne def_ysize then $
	flat_arr=congrid(flat_arr,xsize,ysize,/interp)    
    
;    finite    
 
    bck=bck*(1./flat_arr)

  endif

  if baddiez gt 0 then bck(doback(bad_pix))=0		
				;make sure any bad values are set to zop

  if badoff gt 0 then bck(noback)=0

;--- as I noted before, how does this fit with the previous bck
;    addition? 
;    Above, I just added surface to the whole background. This may be stupid!



  if keyword_set(bias) gt 0 then begin
	if imageinfo.src eq 'HWIC' and badoff gt 0 $
	then bck(noback)=surface(noback)

	if imageinfo.src eq 'HWIC' and baddiez gt 0 $
	then bck(doback(bad_pix))=surface(doback(bad_pix))

  endif

;--- I would ALWAYS set uncalculated background values to 
;--- the bias value (for WIC), except that
;--- a lot of my software expects that 0 background means it was not
;--- calculated. If you want bias values everywhere, use the /bias flag

;stop




if flat_bck_flag gt 0 then bck = bck/flat_arr
killnan, bck, 0


DONE_ACTIVE:   ; the following may still be pertinent to active removal


endif else begin 
  GETOUT:
  print,'No good pixels for background calculation'

endelse


if keyword_set(stopper) gt 0 then stop


  
return
end
