;$author: kovalick $
;$Date: 2006-10-11 13:32:51 -0700 (Wed, 11 Oct 2006) $
;$Header: /home/cdaweb/dev/control/RCS/CDAWlib.pro,v 1.8 1998/06/11 12:48:38 kovalick Exp johnson $
;$Locker: johnson $
;$Revision: 8 $;
;NOTE to user's please set the LD_LIBRARY_PATH to the appropriate directories
;on your system, the 1st should be the location of the idl executable, the
;second should be the name of a directory which can contain a version of
;this whole set of s/w in an IDL save file.
;setenv, 'LD_LIBRARY_PATH=/ncf/alpha/lib/rsi/idl_4/bin/bin.alpha:/home/rumba/cdaweb/lib'
setenv,'LD_LIBRARY_PATH=/usr/local/rsi/idl_6.1/bin/bin.linux.x86:/home/cdaweb/lib'
;small subset of John Hopkins routines used by CDAWlib
;these files are kept in the jh subdirectory so they won't 
;be confused w/ our own utility routines.
.run jh/monthnames.pro
.run jh/dt_tm_mak.pro
.run jh/jd2ymd.pro
.run jh/nearest.pro
.run jh/strep.pro
.run jh/weekday.pro
.run jh/getwrd.pro
.run jh/makex.pro
.run jh/repchr.pro
.run jh/stress.pro
.run jh/xprint.pro
.run jh/inrange.pro
.run jh/sechms.pro
.run jh/time_label.pro
.run jh/ymd2jd.pro
.run version
;reading cdf routines:
.run Validate_myPath
.run break_mySTRING
.run decode_CDFEPOCH
.run encode_CDFEPOCH
.run TAGindex
.run save_mystruct
.run restore_mystruct
;;; listing portion of cdaweb - following file contains all listing routines.
.run LIST_mystruct
;;; virtual variables
.run geopack
.run ic_gci_transf
.run virtual_funcs
.run vis
.run create_vis
.run read_myCDF
;utility routines:
.run getdirs
.run find_myfiles
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
.run orbit_plt.pro
.run orb_mgr.pro
.run xyzmap.pro
.run plot_maps.pro
.run plot_radar
.run plot_plasmagram
.run map_keywords.pro
.run bar_chart
.run evaluate_varstruct
.run plotmaster
.run Compare_myCDFs
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
; Radar vector plot routine:
.run vectplt 
;X/widget routines to facilitate finding and opening cdfs:
.run Pickdir
.run Compare_myCDFs
.run Xread_mycdf
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
; A group of time conversion routines:
.run cnv_mdhms_sec
.run cnvtime
.run cnv_sec_mdhms
.run cnvcoord
.run eccmlt
.run mlt
.run monday
.run angadj
; Radar vector plot routine:
.run vectplt 
;X interface
.run cdfx
;NOTE to user's the following are just defaults that can obviously be
;changed to your liking.
loadct, 39
widget_control, default_font='6x10'


