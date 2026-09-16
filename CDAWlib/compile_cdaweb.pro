;$Author: kovalick $
;$Date: 2012/04/23 15:35:18 $
;$Header: /home/cdaweb/dev/control/RCS/compile_cdaweb.pro,v 1.66 2012/04/23 15:35:18 kovalick Exp kovalick $
;$Locker: kovalick $
;$Revision: 1.66 $
;set ld_library
;setenv, 'LD_LIBRARY_PATH=/ncf/alpha/lib/rsi/idl_5.3/bin/bin.alpha:/home/rumba/cdaweb/lib'
;setenv,'LD_LIBRARY_PATH=/usr/local/itt/idl_6.3/bin/bin.linux.x86:/home/cdaweb/lib'
setenv,'LD_LIBRARY_PATH=/usr/local/itt/idl/idl81/bin/:/home/cdaweb/lib'
setenv,'IDL_DLM_PATH=/home/cdf/idl_cdf340_dlmcode/'
.run version
;reading cdf routines:
.run break_mySTRING
.run decode_CDFEPOCH
.run encode_CDFEPOCH
.run TAGindex
.run save_mystruct
.run restore_mystruct
.run delete_myhandles
;;;; listing portion of cdaweb - following file contains all listing routines.
;.run replace_bad_chars
;.run LIST_mystruct
;.run match
;;; virtual variables
.run geopack
.run ic_gci_transf
.run uvilook
.run virtual_funcs
.run vis
.run create_vis
.run create_plain_vis
.run create_plmap_vis
.run apply_qflag
.run convert_log10
.run region_filt
.run get_mydata
.run timeslice_mystruct
.run parse_mydepend0
.run read_myCDF
.run write_mycdf
;;; listing portion of cdaweb - following file contains all listing routines.
.run replace_bad_chars
.run LIST_mystruct
.run match
;device routines - MAC, WIN, X, PS, etc.:
.run DeviceClose
.run DeviceOpen
;plotting routines:
.run write_mgif
.run cdaweb_velovect
.run plot_wind_map
.run movie_wind_map
.run semiminmax
.run three_sigma
.run find_gaps
.run project_subtitle
.run plot_timeseries
.run examine_SPECTROGRAM_DT
.run plot_stack
.run plot_spectrogram
.run plot_images
.run sign
.run auroral_image
.run plot_map_images
.run handle_check
.run b_lib.pro
.run orb_mgr.pro
.run orbit_plt.pro
.run xyzmap.pro
.run plot_maps.pro
.run plot_radar
.run plot_plasmagram
.run plasma_movie.pro
.run movie_images.pro
.run movie_map_images.pro
.run map_keywords.pro
.run bar_chart
.run plot_enaflux5.pro
.run flux_movie.pro
.run plot_fluximages.pro
.run evaluate_varstruct
.run red_offset.pro
.run movie_skymap.pro
.run cdaweb_skymap.pro
.run plot_skymap.pro
.run plotmaster
.run Compare_myCDFs
.run plot_timetext
.run cdaweb_errplot
;Spectrogram routines:
.run plotlabel
.run findGaps
.run Colorbar
.run align_center
.run spectrogram
.run timeaxis_text
.run TNAXES
.run ssc_plot
; IMAGE FUV routines:
.run get_doy
.run chk_leap_year
.run plot_fuv_images
.run fuv_movie
.run fuv_ptg_mod
.run fuv_read_epoch
.run fuv_rotation_matrix
;listing portion of cdaweb - following file contains all listing routines.
;.run LIST_mystruct
; A group of conversion routines:
;.run conv_pos
.run cnv_mdhms_sec
.run cnvtime
.run cnv_sec_mdhms
.run cnvcoord
.run eccmlt
.run mlt
.run monday
.run angadj
.run dt_tm_mak
.run getwrd
.run inrange
.run makei
.run jd2mdays
.run jd2ymd
.run makex
.run monthnames
;.run monthdays
.run pmod
.run nearest
.run repchr
.run sechms
.run strep
.run stress
.run time_label
.run weekday
.run xprint
.run ymd2jd
; Radar vector plot routine:
.run vectplt
;loadct, 39
;widget_control, default_font='6x10'


