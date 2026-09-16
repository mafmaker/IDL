@compile_cdaweb

;NOTE to users please set the LD_LIBRARY_PATH to the appropriate directories
;on your system, the 1st should be the location of the idl executable, the
;second should be the name of a directory which can contain a version of
;this whole set of s/w in an IDL save file.

;setenv, 'LD_LIBRARY_PATH=/ncf/alpha/lib/rsi/idl_4/bin/bin.alpha:/home/rumba/cdaweb/lib'

;small subset of John Hopkins routines used by CDAWlib
;these files are kept in the jh subdirectory so they won't 
;be confused w/ our own utility routines.

.run jh/monthnames.pro
;run jh/dt_tm_mak.pro
.run jh/jd2ymd.pro
.run jh/pmod.pro
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

.compile cdfx_utils
.compile cdfx_prefs
.compile cdfx_windowlist
.compile cdfx_opencdfs
.compile cdfx_timeslice
.compile cdfx_editvattrs
.compile cdfx_showstats
.compile cdfx_xinteranimate
.compile cdfx

;save, filename='cdfx.sav', /routines
;save, filename='cdfx_vars.sav'

;=============================================================================
