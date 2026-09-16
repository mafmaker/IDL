pro image_bckgnd_clock_correct, imageinfo, bck, stopper = stopper, strict = strict, level = level, cycle = cycle, maglat = maglat, pcap = pcap
  
; Author : Thomas Immel, UCB
; Date   : 2-13-2003
; Program to make clock_angle corrections to background dayglow images
; using the actual differences between the bckgnd and image.
;
; Main problem is the gap left by excluding auroral latitudes. It
; would be easy to expand the whole array using
; median_arr(a,3,0,/fill), (which now works to do fills), but by doing
; this you propagate differences from low sza to high sza, where the
; count rates are much different. So compromise, expand the values
; slightly, then interpolate across the remaining gap. The filling
; procedure will hopefully eliminate issues from the
; inter/extrapolation that will occur at the edges outside of the main
; area of S/P points (sza, phase)
;
; keyword : level - basically indicates level of aggressiveness toward 
;                   extending differences into the polar cap. Default
;                   value is 0. Values beyond 4 only cause the cycle
;                   flag to be set to 1, with a max median range of 9.
;           cycle - Number of times to successively run the median
;                   filter over the S/P array. 0 (default)is fine. 1
;                   is plenty!
;          strict - Run no median filters at all, simply interpolate
;                   across the polar cap. Not recommended.
;         stopper - Stops before exiting procedure, debugging.
;
; 2-21-03  maglat - latitude  
;
; requires : fuv_ptg.pro  ; New version in fuview distribution as of 2-13-03
;

mag_limit = 60
pcap_flag =  0
level_flag =  3
cycle_flag =  0

if keyword_set(maglat) gt 0 then mag_limit = maglat

if keyword_set(level) gt 0 then begin
  if level lt 1 then level = 1
  level_flag = level_flag + 2*level
  if level_flag gt 9 then cycle_flag = 1
  if level_flag gt 9 then level_flag = 9
  print, 'image_bckgnd_clock_correct: smoothcycle=' + $
  ',mediansize='+strcompress(level_flag)
endif

if keyword_set(level) gt 0 then begin
  cycle_flag =  cycle
  print, 'image_bckgnd_clock_correct: smoothcycle='+strcompress(cycle_flag)
endif


fuv_ptg, imageinfo, imageinfo.time, 130.,  a, b, c, d, e, $
      clock = clock, /nocommon
clock = clock + 90

sza_size = 110
clock_size = 180
bin_arr = fltarr(sza_size, clock_size)

if keyword_set(pcap) le 0 then $
todo = where(imageinfo.sza lt 110 and imageinfo.sza gt 0 and $
           abs(imageinfo.mlat) lt mag_limit and imageinfo.dza lt 70, counter) $
else if keyword_set(pcap) eq 1 then $
todo = where(imageinfo.sza lt 110 and imageinfo.sza gt 0 and $
           (abs(imageinfo.mlat) lt mag_limit or abs(imageinfo.mlat) gt 80) $
             and imageinfo.dza lt 70, counter) $
else todo = where(imageinfo.sza lt 110 and imageinfo.sza gt 0 and $
           (abs(imageinfo.mlat) lt mag_limit or abs(imageinfo.mlat) gt pcap) $
             and imageinfo.dza lt 70, counter)

;--- to hack used to have mlat in it, but you don't want/need that!
tohack = where(imageinfo.sza lt 110 and imageinfo.sza gt 0 and $
               imageinfo.dza lt 70, hackcount)

diff = imageinfo.image-bck
bin_arr(imageinfo.sza(todo), clock(todo)) = diff(todo)


;bin_arr2 = bin_arr
;bin_arr2 = median_arr(bin_arr,7,0, /fill)
;bin_arr2 = median_arr(bin_arr2,7,0)

if keyword_set(strict) le 0 then begin

;  median_arr(bin_arr, 3, 0, /fill)

  for i = 0, cycle_flag do begin
    realcool=median_arr(median_arr(bin_arr,3,0,/fill),level_flag,0,/fill)
    bla=where(realcool ne 0 and bin_arr eq 0, gottacheck)
    if gottacheck gt 0 then bin_arr(bla)=realcool(bla)
  endfor
  bin_arr2 = smooth(bin_arr, 3, /edge)

endif else bin_arr2 = bin_arr ; 
;--- now do solar zenith angle interpolations
for s = 70, sza_size-1 do begin

  tofill = reform(bin_arr2(s, *))
  fixer = where(tofill eq 0, tofix) &  gooddat = where(tofill ne 0, touse)
  if tofix gt 0 and touse gt 0 then bin_arr2(s, fixer) = $
    interpol(tofill(gooddat), gooddat, fixer) 

endfor



bck(tohack) = bck(tohack) + bin_arr2(imageinfo.sza(tohack), clock(tohack))

if keyword_set(stopper) gt 0 then stop

return
end
