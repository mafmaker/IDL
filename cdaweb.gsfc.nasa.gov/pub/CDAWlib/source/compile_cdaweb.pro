;$Author: kovalick $
;$Date: 2000/12/22 17:08:45 $
;$Header: /home/rumba/cdaweb/dev/control/RCS/compile_cdaweb.pro,v 1.37 2000/12/22 17:08:45 kovalick Exp kovalick $
;$Locker: kovalick $
;$Revision: 1.37 $
;set ld_library
setenv, 'LD_LIBRARY_PATH=/ncf/alpha/lib/rsi/idl_4/bin/bin.alpha:/home/rumba/cdaweb/lib'
.run version
;reading cdf routines:
.run break_mySTRING
.run decode_CDFEPOCH
.run encode_CDFEPOCH
.run TAGindex
.run save_mystruct
.run restore_mystruct
;;; listing portion of cdaweb - following file contains all listing routines.
.run replace_bad_chars
.run LIST_mystruct
;;; virtual variables
.run geopack
.run ic_gci_transf
.run virtual_funcs
.run vis
.run create_vis
.run create_plain_vis
.run create_plmap_vis
.run apply_qflag
.run convert_log10
.run read_myCDF
.run write_mycdf
;plotting routines:
.run semiminmax
.run find_gaps
.run project_subtitle
.run plot_timeseries
.run examine_SPECTROGRAM_DT
.run plot_stack
.run plot_spectrogram
.run plot_images
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
.run movie_images.pro
.run movie_map_images.pro
.run map_keywords.pro
.run bar_chart
.run plot_enaflux5.pro
.run flux_movie.pro
.run plot_fluximages.pro
.run evaluate_varstruct
.run plotmaster
.run Compare_myCDFs
.run plot_timetext
;device routines - MAC, WIN, X, PS, etc.:
.run DeviceClose
.run DeviceOpen
;Spectrogram routines:
.run findGaps
.run Colorbar
.run align_center
.run spectrogram
.run timeaxis_text
.run TNAXES
.run ssc_plot
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



