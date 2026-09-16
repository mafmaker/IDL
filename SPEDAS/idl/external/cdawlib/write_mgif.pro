pro write_mgif, FILE, IMG, R, G, B, CLOSE=close, loop=loop, delay=delay

;+
; NAME:
;	WRITE_MGIF
;
; PURPOSE:
;	Write an IDL image and color table vectors to a
;	GIF (graphics interchange format) file.
;
; CATEGORY:
;
; CALLING SEQUENCE:
;
; INPUTS:
;	Image:	The 2D array to be output.
;
; OPTIONAL INPUT PARAMETERS:
;      R, G, B:	The Red, Green, and Blue color vectors to be written
;		with Image.
; Keyword Inputs:
;	CLOSE = if set, closes any open file if the MULTIPLE images
;		per file mode was used.  If this keyword is present,
;		nothing is written, and all other parameters are ignored.
;
; OUTPUTS:
;	Writes files containing multiple images.
;	Each call to WRITE_GIF writes the next image,
;	with the file remaining open between calls.  The File
;	parameter is ignored, but must be supplied,
;	after the first call.  When writing
;	the 2nd and subsequent images, R, G, and B are ignored.
;	All images written to a file must be the same size.

;	If R, G, B values are not provided, the last color table
;	established using LOADCT is saved. The table is padded to
;	256 entries. If LOADCT has never been called, we call it with
;	the gray scale entry.

; COMMON BLOCKS:
;	COLORS

; SIDE EFFECTS:
;	If R, G, and B aren't supplied and LOADCT hasn't been called yet,
;	this routine uses LOADCT to load the B/W tables.

; COMMON BLOCKS:
;	WRITE_GIF_COMMON.

; RESTRICTIONS:
;	This routine only writes 8-bit deep GIF files of the standard
;	type: (non-interlaced, global colormap, 1 image, no local colormap)
;
;	The Graphics Interchange Format(c) is the Copyright property
;	of CompuServ Incorporated.  GIF(sm) is a Service Mark property of
;	CompuServ Incorporated.
;
; MODIFICATION HISTORY:
;	Written 9 June 1992, JWG.
;	Added MULTIPLE and CLOSE, Aug, 1996.
;
;   Updated 9 December 1999, Eduardo Iturrate
;   If MULTIPLE GIF is created, it will loop 65535 times 
;     (the available maximum).
;
;-
;

common WRITE_MGIF_COMMON, unit, width, height, position
common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr

; Check the arguments
ON_ERROR, 2			;Return to caller if error
n_params = N_PARAMS();

;; Fix case where passing through undefined r,g,b variables
;; SJL - 2/99
if (n_params eq 5) and (N_ELEMENTS(r) eq 0) then n_params = 2

if n_elements(unit) le 0 then unit = -1
if n_elements(delay) le 0 then delay = 0

if KEYWORD_SET(close) then begin
  if unit ge 0 then FREE_LUN, unit
  unit = -1
  return
endif

if (n_params NE 2) and (n_params NE 5) then $
  message, "usage: WRITE_MGIF, file, image, [r, g, b]"

; Is the image a 2-D array of bytes?

img_size = SIZE(img)
IF img_size[0] NE 2 OR img_size[3] NE 1 THEN	$
	message, 'Image must be a byte matrix.'

if unit ge 0 then begin
  if width ne img_size[1] or height ne img_size[2] then $
	message,'Image size incompatible'
  point_lun, unit, position-1	;Back up before terminator mark

endif else begin		;First call
  width = img_size[1]
  height = img_size[2]

; If any color vectors are supplied, do they have right attributes ?
  IF (n_params EQ 2) THEN BEGIN
	IF (n_elements(r_curr) EQ 0) THEN LOADCT, 0	; Load B/W tables
	r	= r_curr
	g	= g_curr
	b	= b_curr
  ENDIF

  r_size = SIZE(r)
  g_size = SIZE(g)
  b_size = SIZE(b)
  IF ((r_size[0] + g_size[0] + b_size[0]) NE 3) THEN $
	message, "R, G, & B must all be 1D vectors."
  IF ((r_size[1] NE g_size[1]) OR (r_size[1] NE b_size[1]) ) THEN $
	message, "R, G, & B must all have the same length."

  ;	Pad color arrays

  clrmap = BYTARR(3,256)

  tbl_size		= r_size[1]-1
  clrmap[0,0:tbl_size]	= r
  clrmap[0,tbl_size:*]	= r[tbl_size]
  clrmap[1,0:tbl_size]	= g
  clrmap[1,tbl_size:*]	= g[tbl_size]
  clrmap[2,0:tbl_size]	= b
  clrmap[2,tbl_size:*]	= b[tbl_size]

  ; Write the result
  openw, unit, file, /GET_LUN

  hdr	=  { giffile, $		;Make the header
  magic:'GIF89a', 		$
  width_lo:0b, width_hi:0b,	$
  height_lo:0b, height_hi:0b,	$
  global_info: BYTE('F7'X),	$	; global map, 8 bits color
  background:0b, reserved:0b }		; 8 bits/pixel

  hdr.width_lo	= width AND 255
  hdr.width_hi	= width / 256
  hdr.height_lo	= height AND 255
  hdr.height_hi	= height / 256

  writeu, unit, hdr				;Write header
  writeu, unit, clrmap				;Write color map

  if keyword_set(loop) then begin
    writeu, unit, [33b, 255b, 11b]
    writeu, unit, "NETSCAPE2.0"
    writeu, unit, [3b, 1b, 255b, 255b, 0b]
  endif

endelse

if delay gt 0 then begin
  writeu, unit, [33b, 249b, 4b, 0b, $
    byte(delay and 255), byte(delay/256), $
    0b, 0b]
endif

; Write image header, then image data.

ihdr = { $
  imagic: BYTE('2C'X),		$
  left:0, top: 0,			$
  width_lo:0b, width_hi:0b,	$
  height_lo:0b, height_hi:0b,	$
  image_info:7b }
ihdr.width_lo	= width AND 255
ihdr.width_hi	= width / 256
ihdr.height_lo	= height AND 255
ihdr.height_hi	= height / 256
WRITEU, unit, ihdr

ENCODE_GIF, unit, img

POINT_LUN, -unit, position
END
;=============================================================================

