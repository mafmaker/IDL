
; for help:           IDL> uvilook,/help
; for version number: IDL> uvilook,/vers


; Ancillary routines ------------------------------------

FUNCTION atan2d,x1,x2
   RETURN,DOUBLE(ATAN(x1,x2) * 57.2958)
END
FUNCTION sind,x
   RETURN,DOUBLE(sin(x/57.2958))
END
FUNCTION cosd,x
   RETURN,DOUBLE(cos(x/57.2958))
END
FUNCTION dfmag,x1,x2,x3
   RETURN,double(SQRT(x1*x1+x2*x2+x3*x3))
END
PRO dunit,vector,uvector
   uvector = DBLARR(3)
   dmag=dfmag(vector(0),vector(1),vector(2))
   IF (dmag NE 0) THEN BEGIN
      uvector=vector/dmag
   ENDIF ELSE BEGIN
      uvector[*]=0.0
   ENDELSE
END
PRO vector_to_ra_dec,x,y,z,ra,dec
   IF((x EQ y) AND (x EQ 0)) THEN BEGIN
     dec = 90.*z/ABS(z)
     ra  = 0
   ENDIF ELSE BEGIN
     dec = atan2d(z,SQRT(x*x+y*y))
     ra  = atan2d(y,x)
   ENDELSE
   IF(ra LT 0) THEN ra=ra+360
END

PRO get_rotm,axis,angle,m

    ;routine to calculate rotation matrix about an arbitrary axis
    ;inputs
    ;   axis    3 element vector defining the axis of rotation
    ;   angle   scalar giving the angle of rotation
    ;outputs
    ;   m       3x3 array containing the rotation matrix
    ;  REF: Spacecraft Attitude Determination and Control,
    ;       J.R.Wertz, ed., 1991, eq (E-6).

    m = DBLARR(3,3)

    s=DOUBLE(sind(angle))
    c=DOUBLE(cosd(angle))
    c1=1-c

    e1=axis(0)
    e2=axis(1)
    e3=axis(2)

    m(0,0) = c1*e1*e1 + c
    m(1,0) = c1*e1*e2 + e3*s
    m(2,0) = c1*e1*e3 - e2*s

    m(0,1) = c1*e1*e2 - e3*s
    m(1,1) = c1*e2*e2 + c
    m(2,1) = c1*e2*e3 + e1*s

    m(0,2) = c1*e1*e3 + e2*s
    m(1,2) = c1*e2*e3 - e1*s
    m(2,2) = c1*e3*e3 + c

END



; Main routine ---------------------------------------------------

PRO uvilook,time,o_gci,a_gci3,dsp_angle,filter,versStr,l0,ra,dec $
                ,system=system,help=help,vers=vers

      IF(KEYWORD_SET(help)) THEN BEGIN
       PRINT,''
       PRINT,' PRO uvilook,time,o_gci,a_gci3,dsp_angle,filter $
       PRINT,'             versStr,10,ra,dec
       PRINT,''
       PRINT,' routine calculates central look direction of uvi
       PRINT,' field of view (in gci coordinates).
       PRINT,'
       PRINT,' input
       PRINT,'    time            obsolete variable, not used
       PRINT,'    o_gci           orbital position vector
       PRINT,'    a_gci3          s/c attitude vector (gci)
       PRINT,'    dsp_angle       despun nadir offset angle
       PRINT,'    filter          filter index (see below)
       PRINT,'
       PRINT,' output
       PRINT,'    versStr         sw version string
       PRINT,'    10              look direction of uvi fov
       PRINT,'    ra              right ascension of look direction
       PRINT,'    dec             declination of look direction
       PRINT,'
       PRINT,' keywords
       PRINT,'    system          (in) detector in use
       PRINT,'
       PRINT,' library routines
       PRINT,'    dcross_product
       PRINT,'    dunit
       PRINT,'    dmmult
       PRINT,'    vector_to_ra_dec
       PRINT,'    get_rotm
       PRINT,'
       PRINT,'
       PRINT,' notes:
       PRINT,' filter  = 0  BKG
       PRINT,'         = 1  1304
       PRINT,'         = 2  1356
       PRINT,'         = 3  LBHS
       PRINT,'         = 4  LBHL
       PRINT,'         = 5  SOLR
       PRINT,'
       PRINT,' system  =1 PRI, =2 SEC
       PRINT,'
       RETURN
      ENDIF

      ;Notes
      ;2/03  Along-track corrections added by Yeh-Kai Tung


      versStr = 'v1.2a 2/03'
      IF(kEYWORD_SET(vers)) THEN BEGIN
         PRINT,''
         PRINT,  versStr
         PRINT,''
         RETURN
      ENDIF

      primary = 1  & secondary = 2
      IF(NOT KEYWORD_SET(system)) THEN BEGIN
         MESSAGE,/INFO,'Assuming primary detector in use.'
         system=primary
      ENDIF ELSE BEGIN
         CASE system OF
          primary :
          secondary :
          ELSE : MESSAGE,'ERROR: Unsupported system value: ' $
                      +STRTRIM(STRING(system),2)
         ENDCASE
      ENDELSE

;     calculate look direction in spacecraft frame (lsc).
;     defined as a unit vector positioned at the spacecraft,
;     perpendicular to the attitude vector, coplanar with
;     the attitude and position vectors, and pointing in
;     the opposite sense of the position vector.  the
;     position vector is assumed to point from the center
;     of the earth to the spacecraft.  the look vector will
;     be converted to a unit vector and positioned at the
;     spacecraft after it has been converted to the image
;     reference frame.
;     lsc = (r x a) x a
      dtemp = DOUBLE(CROSSP(o_gci,a_gci3))
      lsc   = DOUBLE(CROSSP(dtemp,a_gci3))

;     calculate look direction in despun platform frame (ldsp).
;     defined as look direction in spaceraft frame rotated
;     about the z-axis by the despun offset angle.
      get_rotm,a_gci3,dsp_angle,m
      ldsp = TRANSPOSE(TRANSPOSE(m) # lsc)
      ldsp = REFORM(ldsp)

;     transform from dsp reference frame to uvi reference frame.
;     this corresponds to the alignment cube placement relative
;     to the dsp.  this is the mean pointing error relative to
;     the dsp, but does not include the filter-dependent pointing
;     error.
      ;conversion to change from pixels to degrees
      ;pix_conv = 8.0D/228.

      ;mean cross track error in pixels
      ;CASE system OF
      ; primary   : mean_cross_track = 7.0
      ; secondary : mean_cross_track = 41.6
      ; ELSE : MESSAGE,'ERROR: Unknown system value: '+STRTRIM(STRING(system),2)
      ;ENDCASE
      CASE system OF
       primary   : BEGIN
                     mean_cross_track = 7.0
                     pix_conv = 0.03380D
                   END
       secondary : BEGIN
                     mean_cross_track = 41.6
                     pix_conv = 0.03511D
                   END
       ELSE : MESSAGE,'ERROR: Unknown system value: '+STRTRIM(STRING(system),2)
      ENDCASE


      dtemp=DOUBLE(CROSSP(a_gci3,ldsp))
      dunit,dtemp,y_img_axis
      get_rotm,y_img_axis,mean_cross_track*pix_conv,m

NOTE_PT_1: ;see comment at end of code
      luvi = TRANSPOSE(TRANSPOSE(m) # ldsp)
      luvi = REFORM(luvi)


;     transform from uvi reference frame to image plane reference frame.
;     the corresponds to the look direction for the center of the image
;     plane and is different for each detector and filter combination.
;     cross track error in pixels

;     along track error in pixels                             Y-K Tung    2/7/03
;     SOLR cross-track value from J. Spann calibration notes  G. Germany 2/18/03

;     NOTE: All cross track values, except for SOLR, were determined from on-orbit
;           calibrations.  All other values were taken from Jim Spann's ground
;           calibration notes.

      CASE system OF
       primary   : BEGIN
                      CASE filter OF
                       0 :   BEGIN
                               cross_track =  0.0 ;bkg
                               along_track =  0.0
                             END
                       1 :   BEGIN
                               cross_track =  0.9 ;1304 (2 & 1 from ground calibrations)
                               along_track = -1.0
                             END
                       2 :   BEGIN
                               cross_track =  2.1 ;1356 (3)
                               along_track =  0.0
                             END
                       3 :   BEGIN
                               cross_track =  0.0 ;LBHS
                               along_track =  0.0
                             END
                       4 :   BEGIN
                               cross_track = -5.3 ;LBHL (-5)
                               along_track =  2.0
                             END
                       5 :   BEGIN
                               cross_track =  6.0 ;SOLR (6)
                               along_track =  8.0
                             END
                       ELSE: BEGIN
                               cross_track =  0.0
                               along_track =  0.0
                             END
                      ENDCASE
                   END
       secondary : BEGIN
                      CASE filter OF
                       0 :   BEGIN
                               cross_track =  0.0 ;bkg
                               along_track =  0.0
                             END
                       1 :   BEGIN
                               cross_track =  0.7 ;1304 (1 from ground calibration)
                               along_track = -2.0
                             END
                       2 :   BEGIN
                               cross_track =  2.7 ;1356 (3)
                               along_track = -1.0
                             END
                       3 :   BEGIN
                               cross_track =  0.0 ;LBHS
                               along_track =  0.0
                             END
                       4 :   BEGIN
                               cross_track = -5.3 ;LBHL (-5)
                               along_track =  2.0
                             END
                       5 :   BEGIN
                               cross_track =  6.0 ;SOLR (6)
                               along_track =  7.0
                             END
                       ELSE: BEGIN
                               cross_track =  0.0
                               along_track =  0.0
                             END
                      ENDCASE
                   END
       ELSE : MESSAGE,'ERROR: Unknown system value: '+STRTRIM(STRING(system),2)
      ENDCASE

;     Cross-track correction
;     NOTE: These two lines commented out for efficiency.
;           Y_IMG_AXIS is unchanged by previous rotation
;           at NOTE_PT_1 above
;      dtemp=DOUBLE(CROSSP(a_gci3,luvi))
;      dunit,dtemp,y_img_axis
      get_rotm,y_img_axis,cross_track*pix_conv,m

      limg = TRANSPOSE(TRANSPOSE(m) # luvi)
      limg = REFORM(limg)


;     Along-track correction Y-K Tung 2/7/03
      get_rotm, a_gci3, along_track*pix_conv, m2
      limg = TRANSPOSE(TRANSPOSE(m2) # limg)
      limg = REFORM(limg)


;     convert look direction to unit vector
      dunit,limg,l0

;     calculate right ascension & declination (gci)
      vector_to_ra_dec,l0(0),l0(1),l0(2),ra,dec

END
