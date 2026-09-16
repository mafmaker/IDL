;
; cursor offsets.pro
;
;  program to interactively determine shifts in x sense between
;  calculated and actual geographic coordinates in a series of images
;
;  NEW ider on 9-25-2000 : flash not successive images, but
;  glat and the image, (with options to change the brightness scale)?
;
;
;

@fuv_ptg
@degree_trig

sc_flag = 0
print,'Select the spacecraft'
print,'0 - WIC,    2 - SI 13,    3 - SI 12'   
read, sc_flag

search_string='*'
spare=' '
print,'Enter any search constrains [e.g. *19803*]'
read,spare
if spare ne '' and strcompress(spare) ne ' ' then search_string=spare




impath=['','quiet/','new/','images/']
case sc_flag of
  0: begin
	sc='wic'
     end
  2: begin
	sc='s13'
     end
  3: begin
	sc='s12'
     end    
endcase

finder=0
checker=size(impath) & checker=checker(1)
i = 0
spawn,'pwd',current_dir
current_dir=current_dir(0) + '/'

while finder eq 0 and i lt checker do begin
  
  spawn,'ls ' + current_dir + sc + search_string + '.idl',filelist
  if filelist(0) ne '' and filelist(0) ne ' ' then finder = 1
  i = i + 1

endwhile


imgs=size(filelist) & imgs=imgs(1)
off2=0
off3=0

spare=''

for i=0,imgs-1 do print,i, ':', filelist(i)
print,'Enter number to begin at, or press return'
read,spare
if strcompress(spare) eq '' or strcompress(spare) eq ' ' $
	then startnum=0 else startnum=fix(spare)

;---there are a lot, for development cut out 2/3 or more


first_flag = 1		;this should be an option at startup
second_flag = 0

print,'Do you want to register images to Geographic coordinates or'
print,'register successive images?'
print,'Enter 1 for geographic, 2 for successive'
dummy=0
read,dummy
if dummy eq 1 then first_flag = 1
if dummy eq 1 then second_flag = 0
if dummy eq 2 then first_flag = 0
if dummy eq 2 then second_flag = 1

offset=0			;create variables
off2=88
register_start=0		;what is THIS for?
fillin_flag=0			;set to 1 to work non-existent files only


for i=startnum,imgs-1 do begin

  dotplace=strpos(filelist(i),'.')				;bla is just a spare
  savefile=strmid(filelist(i),0,dotplace) + '.off'		;silly word
  print,savefile
  restore,filelist(i)

  image_time,imageinfo.time,year,day,month,dom,hh,mm,ss
  flat_arr=get_flatfield(year,day,sc_flag)
  imageinfo.image=imageinfo.image * flat_arr



  spawn,'ls '+savefile,bla
  help,bla
  ;--- if the file exists and fillin_flag is on, skip it
  ;--- else, restore the variables and work as normal!!!

  if bla(0) ne '' then if fillin_flag eq 0 then $
			restore,savefile else goto,SKIPPY
  print,offset,off2	;restored existing file, need to NOT screw up
			; the values that have already been calculated

  if first_flag eq 1 then begin	;  CALCULATING OFFSET OF GEO FROM IMAGE

;--- if there is no offset file then start somethin up!


    if sc_flag eq 0 then begin	;do some resizing if si images are involved
;      img=imageinfo.image
;      glat=imageinfo.glat
      countmax=11000
    endif else begin
      countmax=70
    endelse
;    img=congrid(imageinfo.image,256,256)
;    glat=congrid(imageinfo.glat,256,256)

    img=congrid(imageinfo.image,512,512)
    glat=congrid(imageinfo.glat,512,512)

    if i eq 0 then window,0,xsize=900,ysize=550 else erase
    b=0
    tv_rdpix,tvrd(),glat,img,a,b




    off3=a-b
    offset=a-b
;---take care of possible resizing---
    if sc_flag gt 0 then offset=round(offset/4.) else offset=round(offset/2.)


    if offset gt 0 then $
    print,'Geographic _image_ must be shifted',offset,'pixels to the left' $
    else $
    print,'Geographic _image_ must be shifted',abs(offset),'pixels to the right'

	;save the single offset number, 
    save,filename=savefile,offset,off2	

;we are going to do without this for now
;goto, SKIP_REGISTER


  endif else begin		;SEQUENTIAL JITTER TO BE FIXED HERE


;  if second_flag eq 1 then begin


;--- second part gives absolute offset of images --- this really should
;--- NOT be necessary


	;;;--- if there was already an offset file, don't make another!
	;;;--- restore it and lets overlay some images!!!
	;;;--- this restoration should have been done earlier!!!

;    restore,savefile

;  endelse ;;;- OK, now we have the offset of geo from img, but 
	  ;;;- that is actually lame, I should blink the geographic
	  ;;;- and the images, but do the images for now.

    if register_start eq 0 then begin		;this happens once only

      if i eq 0 then begin

;--- commented out by TJI 3-29-2001
        if bla(0) ne '' then restore,savefile  else offset=0
	firstpos=offset
        baseim=imageinfo.image
        basegeo=imageinfo.glat
;--- commented out by TJI 3-29-2001
	off2=0        ;make sure there are not stale values in here


      endif else begin
        holder=imageinfo				;hold these for later
        offhold=offset					;hold these for later
        restore,filelist(i-1)
        baseim=imageinfo.image
        basegeo=imageinfo.glat
        bla2=strpos(filelist(i-1),'.')			;bla is just a spare
        restore,strmid(filelist(i-1),0,bla2) + '.off'	;get off2
        imageinfo=holder				;now set them back to 
        offset=offhold					;what they were
        print,'Picking up pieces, off2 is now ', off2
	print,'Need to shift baseim by that amount'
	baseim=shift(baseim,off2)
      endelse
    endif

      register_start = 1 



    b=off2						;off2 is lh offset of 
    tv_rdpix,tvrd(),baseim,imageinfo.image,a,b	     	;previous image
    print,a,b, a-b						
    off2=a-b

    baseim=shift(imageinfo.image,off2)
    basegeo=imageinfo.glat



    off2holder=off2
    if bla(0) ne '' then restore,savefile else offset = 0
    off2=off2holder
    save,filename=savefile,offset,off2
    print,'Offset: ', offset,' Offset2: ', off2, 'Saved in ', savefile

  SKIPPY:
;
  endelse

;  this endif goes with if bla(0) ne ''
;  endif  else print, 'Found offset file ' , savefile
;  That's only if first_flag is 1 you ass.


endfor


end
