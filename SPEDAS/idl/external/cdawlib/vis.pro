;$Author: nikos $
;$Date: 2014-07-10 10:01:21 -0700 (Thu, 10 Jul 2014) $
;$Header: /home/rumba/cdaweb/dev/control/RCS/vis.pro,v 1.3 1998/05/20 15:22:55 kovalick Exp baldwin $
;$Locker: baldwin $
;$Revision: 15545 $
;----------------------------------------------------------
;This code was picked up from the polar vis web site mentioned 
;in their polar vis CDFs. http://eiger.physics.uiowa.edu/~vis/software/.
;The main function is called compute_crds (below).
;
;-------------------------------------------------------------
;+
; NAME:
;       XV_LOOKV_TO_GCI
; PURPOSE:
;       Converts the XVIS LOOK vector to GCI coordinates
; CATEGORY:
; 
; CALLING SEQUENCE:
;       XV_LOOKV_TO_GCI
; INPUTS:
;       NONE
; KEYWORD PARAMETERS:
;       NONE
; OUTPUTS:
;       NONE
; COMMON BLOCKS:
;       XV_RECORD_DATA
;       XV_FILE_DATA
;       XV_DERIVED_DATA
;       XV_FLAGS
; NOTES:
;       This routine is useful only within the XVIS application
;       It uses COMMON blocks extensively and certain values within
;       the blocks must be set prior to invocation.
; MODIFICATION HISTORY:
;       Kenny Hunt, 9/1/97
;
; Copyright (C) 1998, The University of Iowa Department of Physics and Astronomy
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.
;-------------------------------------------------------------
PRO XV_LOOKV_TO_GCI
   COMMON XV_RECORD_DATA, Image, Record, XPos, YPos, ROI, LastImage, Curr_Limit
   COMMON XV_FILE_DATA, Path, Filename, Fid, MaxRecs, ImageNum, LookVector, Header, UnDistort
   COMMON XV_DERIVED_DATA, LookV_GCI, ALTLS, Alts, Phis, SZAs, Locs, Glats, Glons
   COMMON XV_FLAGS, Flags
;
; Vectorized 9/98 RTB

   ROTATION = transpose(record.rotatn_matrix)
   LOOKV_GCI =  DBLARR(3,256,256,/NOZERO)
      FOR j=0,255 DO BEGIN
        LOOKV_GCI(*,*,j) = ROTATION # LookVector(*,*,j)
      END

END


;-------------------------------------------------------------
;+
; NAME:
;       COMPUTE_CRDS
; PURPOSE:
;       Computes all the variables in the XV_DERIVED_DATA block
;       for an entire image
; CATEGORY:
; 
; CALLING SEQUENCE:
;       Must set up the common block information properly.  This
;       routine is tightly integrated into the XVIS package.
; INPUTS:
;       None
; KEYWORD PARAMETERS:
;       NONE
; OUTPUTS:
;       RA and DEC values
; COMMON BLOCKS:
;       numerous
; NOTES:
;
; MODIFICATION HISTORY:
;       Kenny Hunt, 9/1/97
;
; Copyright (C) 1998, The University of Iowa Department of Physics and Astronomy
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.
;-
PRO COMPUTE_CRDS
   COMMON XV_DERIVED_DATA, LookV_GCI, ALTLS, Alts, Phis, SZAs, Locs, Glats, Glons
   COMMON XV_FLAGS, Flags
   COMMON XV_RECORD_DATA, Image, Record, XPos, YPos, ROI, LastImage, Curr_Limit
   COMMON XV_FILE_DATA, Path, Filename, Fid, MaxRecs, ImageNum, LookVector, Header, UnDistort
   COMMON XV_WIDS, MainWid, ViewWid, DrawWid, Handlers, HCount
   COMMON XV_DEBUG, dalts
   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   ;TJK defining FLAGS and calling some setup routines here.  In the 
   ;original VIS code this was defined/called in the "main" program, 
   ;which we obviously aren't using.
   ;
;   FLAGS = { loaded:0,$
;             LV:0,$
;             ALT:0,$
;             ALTLS:0,$
;             PHI:0,$
;             SZA:0,$
;             LOC:0,$
;             GLAT:0,$
;             GLON:0,$
;             XPAND:0,$
;             CDF_COLOR:1,$
;             DIST:0}
;   
;   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   ;; Initialize the radius function.  Table lookup is for speed.
;   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   INITIALIZE_EARTH_RADIUS
;
;   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;   IF(FLAGS.GLAT EQ 1) THEN RETURN
;
;TJK changed to initialize the arrays to 999.999 instead of
;the default of zero.
;
   GLATS = make_array(256,256,/double,value=999.99999)
   GLONS = make_array(256,256,/double,value=999.99999)
   Dalts = dblarr(256,256)

   SC_POS =  record.sc_pos_GCI
   AssumedAlt =  record.altf
; Convert look vector to GCI coordinates   RTB added 9/8/98  
   XV_LOOKV_TO_GCI
  ;
 orb=SC_POS
 LpixX=reform(LookV_GCI(0,*,*))
 LpixY=reform(LookV_GCI(1,*,*))
 LpixZ=reform(LookV_GCI(2,*,*))
 emis_hgt=AssumedAlt
 gclat=dblarr(256,256); GLATS
 gclon=dblarr(256,256); GLONS
 r=dblarr(256,256); Dalts
 epoch=Record.EPOCH

     ptg_new, orb,LpixX,LpixY,LpixZ,emis_hgt,gclat,gclon,r,epoch=epoch

     Glats=gclat
     GLons=gclon
     Dalts=r
    
END

pro vis
end

