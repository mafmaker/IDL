pro key_set,bla,_extra=e

  if keyword_set(maxcts) eq 1 then bla=1 else bla=0

end

pro star_fit2d,image,coef_arr,fwhm=fwhm,verbose=verbose,actual=actual,_extra=e

;
; test_star.pro
; 
;  author: Thomas Immel
;  date  : 7-7-2000
;
;
; For Automatic star finding and profiling in any image
; `
;  INPUT is just an image. WIC works for now and, besides the star
;	threshold question SI13 should as well
;  OUTPUT is the coef_arr, with the 7 gaussian coefficents from 
;	  gauss2dfit for each star identified.
;
;  If the print_out flag is switched to one there is a
;  SCREEN OUTPUT in format: '(f8.1,2x,4(f8.3,2x),a20)' and goes as
;  peak height minus background, xposition in array, yposition, 
;					xwidth, ywidth
;
;  OPTIONS, /fwhm makes it report the gaussian width times 1.41421 or
;		the full width half max.
;
;  notes - if provided location of earth-pixels, could lower max count
;	 - discrimination. Also void stars which are in limb glow.
;
;	 - must know somehow whether wic, SI 12, SI 13 max counts 
;
;        - /fwhm cause full-width half max to be reported, as opposed
;	  to gaussian width.
;
;  version notes - 1.0 7-07-2000
;  		   1.2 7-25-2000 
; 		changes-
;		-fixed coef_arr so that correct array positions were passed
;		-added verbose
;		-added actual, such that the actual peaks in brightness are 
;		-  returned, not the peak position of the fit.
;		adding - _extra so that peak star brightness can be defined
;			 using maxcts. Any other variable name will not work!
;
;
;wic_june5_2101.idl   wic_june8_2015.idl
;wic_june8_0603.idl   wic_may25_1355.idl
;
;



print_out = 0		;if print out eq 1 then print formatted output
if keyword_set(verbose) eq 1 then print_out = 1


helper=size(image) & xsize=helper(1) & ysize=helper(2)
if xsize gt 150 then maxcts=2000 else maxcts=1000	;SI guess 1000

;key_set,bla,_extra=e				;NICE HACK. THIS SHOULD
;						;not be necessary!!!
;if bla eq 1 then maxcts=e.maxcts		;but it should F**NG WORK
;print,bla,maxcts

if n_elements(e) ne 0 then maxcts=e.maxcts
print,maxcts

edge_size=5

second=deriv(deriv(image)) * (-1)		;-2nd deriv finds stars
subsec=second(edge_size:xsize-edge_size,$
		edge_size:ysize-edge_size)      ;edge effect if Earth there.
subimg=image(edge_size:xsize-edge_size,$
		edge_size:ysize-edge_size)	;
subsec_size=size(subsec)			;continue on without edges


finder=where(subsec gt maxcts,found)
if found le 0 then goto,nostars
findery=finder/subsec_size(1)			;x and y positions of 
finderx=finder mod subsec_size(1)		;'star' pixels

tester=subsec & tester(*)=0			
tester(finderx,findery)=1

;----now find star groups, where pixels are bunched up

groupen=0
nomore=0
work_find=finder				;going to whittle this down
work_findx=finderx				;going to whittle this down
work_findy=findery				;going to whittle this down
group_indices=fltarr(400,20)			;up to 20 groups, 400 pixels
group_indices(*)=-1				;per group

;---find star groups!

while nomore eq 0 do begin

  scratchx=work_findx-work_findx(0)
  scratchy=work_findy-work_findy(0)

  a_group=where(abs(scratchx lt 15) and abs(scratchy lt 15),ingroup) 
  not_group=where(abs(scratchx ge 15) or abs(scratchy ge 15),notingroup)

  group_indices(0:ingroup-1,groupen)=work_find(a_group)
  groupen=groupen+1

  ;---whittle pixels down

  if notingroup eq 0 then nomore=1 else begin
    work_findx=work_findx(not_group) &  work_findy=work_findy(not_group)
    work_find=work_find(not_group)
  endelse

endwhile

;---find greatest brightness in star groups

bright_loc=lonarr(groupen)    ;for brightest pixel/center of each star group
bright_locx=bright_loc
bright_locy=bright_loc

for i=0, groupen-1 do begin
  this_group=group_indices(*,i)
  ingroup=where(this_group ne -1)    ;indices of good indices
  brightest_pix=where(this_group(ingroup) eq max(this_group(ingroup)))
  bright_loc(i)=this_group(ingroup(brightest_pix))
endfor

bright_locy=bright_loc/subsec_size(1)
bright_locx=bright_loc mod subsec_size(1)

;---get back to uncropped image coordinates, using 2d images.
;---its easier this way!!!

;;;bright_locx=bright_loc/

scratch=subimg & scratch(*)=0
bigscratch=image & bigscratch(*)=0
scratch(bright_loc)=1
bigscratch(5:xsize-5,5:ysize-5)=scratch		;edge effect if Earth there.

starpos=where(bigscratch ne 0)		;brightest points in image
starposy=starpos/xsize
starposx=starpos mod xsize

;--- define XxY boxes about each star position 
;--- (l)eft, (r)ight, (t)op, (b)ottom

X=15
Y=15
starl=(starposx-X)> 0
starr=(starposx+X)< (xsize-1)
start=(starposy+Y)< (ysize-1)
starb=(starposy-Y)> 0 


!p.multi=[0,2,2,0]
coef_arr=fltarr(7,groupen)
if groupen le 0 then coef_arr=-1	;you will never get this far if
					;groupen is 0, the goto statement
					;will force you to the end.

;xpos=fltarr(groupen)

for i=0,groupen-1 do begin

  subarr=image(starl(i):starr(i),starb(i):start(i))
  fit = GAUSS2DFIT( subarr, coef)
  coef_arr(*,i)=coef
  xwid=coef(2)
  ywid=coef(3)
  if keyword_set(fwhm) then begin	;fwhm is NOT the width returned
	xwid=1.41421 * xwid
	ywid=1.41421 * ywid
  endif
  posx=coef(4)
  posy=coef(5)
  bigposx=starl(i)+posx
  bigposy=starb(i)+posy
  coef_arr(4,i)=bigposx
  coef_arr(5,i)=bigposy

;---sometimes you simply want the actual brightest locations.

  if keyword_set(actual) then begin  
	coef_arr(4,i)=bright_locx(i)+edge_size
	coef_arr(5,i)=bright_locy(i)+edge_size
  endif


  format='(f8.1,2x,4(f8.3,2x),a20)'		;a20 for optional text
						;not added yet.
  if print_out eq 1 then $
	print,format=format,coef(1),bigposx,bigposy,xwid,ywid
endfor

goto, ending

NOSTARS:		;go here if no points meet the star criteria
coef_arr=-1


ENDING:			;go here to not set coef_arr to -1

return

end
