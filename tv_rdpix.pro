; $Id: rdpix.pro,v 1.4 1998/01/15 18:43:38 scottm Exp $
;
; Copyright (c) 1989-1998, Research Systems, Inc.  All rights reserved.
;       Unauthorized reproduction prohibited.

Pro tv_Rdpix, Image,im1,im2,X0,homex 	;Read the value of the pixel under the cursor
			;Display x,y and the pixel value under the cursor
;+
; NAME:
;	RDPIX
;
; PURPOSE:
;	Interactively display the X position, Y position, and pixel value 
;	of the cursor.
;
; CATEGORY:
;	Image display.
;
; CALLING SEQUENCE:
;	RDPIX, Image ,im1,im2,a,b
;
; INPUTS:
;	Image:	simple tvrd() of working area will do
;	im1, im2 : images to be overlain
;	homex can be provided to shift the original im1
; OPTIONAL INPUT PARAMETERS:
;  b : can be specified as something other than zero such that the 
;      initial image position is shifted to the left or right
; OUTPUTS:
;	Note that the outputs are in the opposite order of the inputs
;       X0 - the lhs of im2
;       homex - the lhs of im1
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	The X, Y, and value of the pixel under the cursor are continuously 
;	displayed.
;
; RESTRICTIONS:
;	None.
;
; PROCEDURE:
;	Instructions are printed and the pixel values are printed as the 
;	cursor is moved over the image.
;
;	Press the left or center mouse button to create a new line of output,
;	saving the previous line. Hold that button to repeatedly show
;	im1 and im2 over one another, in order to drag the image to 
; 	the best place. Do this as many times as necessary.
;
;	Press the right mouse button to exit the procedure.
;	The xposition at that time is NOT passed back, only the last
;  	position of the cursor when buttons 0 or one were lifted.
;       No images are shown with the right button. Nothing is calculated.
;   
;
; MODIFICATION HISTORY:
;	DMS, Dec, 1987.
;	Rob Montgomery (rob@hao.ucar.edu), 9/21/92;
;		Correct indices for case of !order = 1
;	renamed tv_rdpix.pro by TJI at SSL, UCB
;       flashes overlay of two images
;
;-

startoff=100 + homex		;initial position from x=0

max1=max(im1) < 22000.
max2=max(im2) < 22000.
				;can give initial offset of im1
tv,bytscl(im1,min=0,max=(max1/2.)),startoff,0
ims=size(im2)

on_error,2              ;Return to caller if an error occurs
print,'Press left or center mouse button for new output line."
print,'... right mouse button to exit.'
s = size(image)
if s[0] ne 2 then message, 'Image parameter not 2d.'
s[1] = s[1]-1		;To n-1
s[2] = s[2]-1
!err=0
;if n_elements(x0) le 0 then x0 = 0
;if n_elements(y0) le 0 then y0 = 0
x0=0 & y0=0

if s[s[0]+1] ge 4 then form = 'F' else form = 'I'
cr = string("15b)	;this codes a newline
form="($,'x=',i4,', y=',i4,', value=',"+form+",a)"

;---added by tji

counter = 0 

while !err ne 4 do begin

	;---homex is USELESS, but this huge while loop works for now.
	if counter eq 0 then homex = 0
	CURSOR,x,y,0,/dev
	while homex eq 0 do begin
	if x gt 128 and x lt !d.x_size-128 then begin
	
		homex=x
		print,homex , 'Starting x- position'
;--- grab current image and save it
		first=tvrd()
	 	buffer=first
	endif
	CURSOR,x,y,0,/dev
	endwhile


;	if counter mod 100 eq 0 then begin

;	endif

	if (!err and 3) ne 0 then begin	;New line?
	   print,form="($,a)",string("12b)
	   while (!err ne 0) do begin 
		counter=counter+1
		wait,.1 	
;		print,'have to click 0 to get out of this';
;		CURSOR,max_x,y,0,/dev 
		CURSOR,x,y,0,/dev 
		max_x=x
		buffer=first
		lay=bytscl(im2,min=0,max=max2/2.)	;lay means overlay
		indices=indgen((ims(2)-2)/2)*2 + counter mod 2
		buffer(x:x+ims(1)-1,indices)=lay(*,indices)
		tvscl,buffer
	   endwhile
	endif

	x = x-x0 & y = y - y0
	if (x le s[1]) and (y le s[2]) and (x ge 0) and (y ge 0) then begin
	   if (!order eq 1) then yy = s[2] - y else yy = y
	   print,form = form, x,y,Image[x,yy],cr
	endif
	counter=counter+1
;	print,counter
endwhile
print,form="(/)"
	x0=max_x	;the lhs of im2
	homex=startoff	;the lhs of im1
	erase
return
end
