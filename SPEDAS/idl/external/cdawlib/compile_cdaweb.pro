;$Author: nikos $
;$Date: 2014-07-10 10:01:21 -0700 (Thu, 10 Jul 2014) $
;$Header: /home/cdaweb/dev/control/RCS/compile_cdaweb.pro,v 1.62 2009/11/03 16:06:55 kovalick Exp kovalick $
;$Locker: kovalick $
;$Revision: 15545 $
;set ld_library
;setenv, 'LD_LIBRARY_PATH=/ncf/alpha/lib/rsi/idl_5.3/bin/bin.alpha:/home/rumba/cdaweb/lib'
;setenv,'LD_LIBRARY_PATH=/usr/local/rsi/idl_6.3/bin/bin.linux.x86:/home/cdaweb/lib'
;;nikos.runversion
;reading cdf routines:
;;nikos.runbreak_mySTRING
;;nikos.rundecode_CDFEPOCH
;;nikos.runencode_CDFEPOCH
;;nikos.runTAGindex
;;nikos.runsave_mystruct
;;nikos.runrestore_mystruct
;;nikos.rundelete_myhandles
;;;; listing portion of cdaweb - following file contains all listing routines.
;;;nikos.runreplace_bad_chars
;;;nikos.runLIST_mystruct
;;;nikos.runmatch
;;; virtual variables
;;nikos.rungeopack
;;nikos.runic_gci_transf
;;nikos.runuvilook
;;nikos.runvirtual_funcs
;;nikos.runvis
;;nikos.runcreate_vis
;;nikos.runcreate_plain_vis
;;nikos.runcreate_plmap_vis
;;nikos.runapply_qflag
;;nikos.runconvert_log10
;;nikos.runregion_filt
;;nikos.runget_mydata
;;nikos.runtimeslice_mystruct
;;nikos.runparse_mydepend0
;;nikos.runread_myCDF
;;nikos.runwrite_mycdf
;;; listing portion of cdaweb - following file contains all listing routines.
;;nikos.runreplace_bad_chars
;;nikos.runLIST_mystruct
;;nikos.runmatch
;device routines - MAC, WIN, X, PS, etc.:
;;nikos.runDeviceClose
;;nikos.runDeviceOpen
;plotting routines:
;;nikos.runwrite_mgif
;;nikos.runcdaweb_velovect
;;nikos.runplot_wind_map
;;nikos.runmovie_wind_map
;;nikos.runsemiminmax
;;nikos.runthree_sigma
;;nikos.runfind_gaps
;;nikos.runproject_subtitle
;;nikos.runplot_timeseries
;;nikos.runexamine_SPECTROGRAM_DT
;;nikos.runplot_stack
;;nikos.runplot_spectrogram
;;nikos.runplot_images
;;nikos.runsign
;;nikos.runauroral_image
;;nikos.runplot_map_images
;;nikos.runhandle_check
;;nikos.runb_lib.pro
;;nikos.runorb_mgr.pro
;;nikos.runorbit_plt.pro
;;nikos.runxyzmap.pro
;;nikos.runplot_maps.pro
;;nikos.runplot_radar
;;nikos.runplot_plasmagram
;;nikos.runplasma_movie.pro
;;nikos.runmovie_images.pro
;;nikos.runmovie_map_images.pro
;;nikos.runmap_keywords.pro
;;nikos.runbar_chart
;;nikos.runplot_enaflux5.pro
;;nikos.runflux_movie.pro
;;nikos.runplot_fluximages.pro
;;nikos.runevaluate_varstruct
;;nikos.runred_offset.pro
;;nikos.runmovie_skymap.pro
;;nikos.runcdaweb_skymap.pro
;;nikos.runplot_skymap.pro
;;nikos.runplotmaster
;;nikos.runCompare_myCDFs
;;nikos.runplot_timetext
;;nikos.runcdaweb_errplot
;Spectrogram routines:
;;nikos.runplotlabel
;;nikos.runfindGaps
;;nikos.runColorbar
;;nikos.runalign_center
;;nikos.runspectrogram
;;nikos.runtimeaxis_text
;;nikos.runTNAXES
;;nikos.runssc_plot
; IMAGE FUV routines:
;;nikos.runget_doy
;;nikos.runchk_leap_year
;;nikos.runplot_fuv_images
;;nikos.runfuv_movie
;;nikos.runfuv_ptg_mod
;;nikos.runfuv_read_epoch
;;nikos.runfuv_rotation_matrix
;listing portion of cdaweb - following file contains all listing routines.
;;;nikos.runLIST_mystruct
; A group of conversion routines:
;;;nikos.runconv_pos
;;nikos.runcnv_mdhms_sec
;;nikos.runcnvtime
;;nikos.runcnv_sec_mdhms
;;nikos.runcnvcoord
;;nikos.runeccmlt
;;nikos.runmlt
;;nikos.runmonday
;;nikos.runangadj
;;nikos.rundt_tm_mak
;;nikos.rungetwrd
;;nikos.runinrange
;;nikos.runmakei
;;nikos.runjd2mdays
;;nikos.runjd2ymd
;;nikos.runmakex
;;nikos.runmonthnames
;;;nikos.runmonthdays
;;nikos.runpmod
;;nikos.runnearest
;;nikos.runrepchr
;;nikos.runsechms
;;nikos.runstrep
;;nikos.runstress
;;nikos.runtime_label
;;nikos.runweekday
;;nikos.runxprint
;;nikos.runymd2jd
; Radar vector plot routine:
;;nikos.runvectplt
;loadct, 39
;widget_control, default_font='6x10'


