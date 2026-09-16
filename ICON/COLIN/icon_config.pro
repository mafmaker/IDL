;+
; Copied from thm_config 20 Jan 2016
;
;
;
;
;
;


PRO icon_config,caching=caching,colortable=colortable,$
  no_color_setup=no_color_setup,no_download=no_download

  ;List of ICON servers:  (Comment out the others)

  !icon.remote_data_dir = 'NO PUBLIC SERVER YET!'

  !icon.local_data_dir = root_data_dir() + 'icon/'

  ;settings in your local icon_config.txt file will override the
  ;defaults,
  ftest = icon_read_config()
  If(size(ftest, /type) Eq 8) Then Begin
    !icon.local_data_dir = ftest.local_data_dir
    !icon.remote_data_dir = ftest.remote_data_dir
    !icon.no_download = ftest.no_download
    !icon.no_update = ftest.no_update
    !icon.downloadonly = ftest.downloadonly
    !icon.verbose = ftest.verbose
  Endif

  if file_test(!icon.local_data_dir + '.master',/regular) then !icon.no_server = 1 ;Checks to see if local dir is master dir

  ;check for slashes, add if necessary, taken from thm_config (jmm, 2-jul-2007)
  temp_string = strtrim(!icon.local_data_dir, 2)
  ll = strmid(temp_string, strlen(temp_string)-1, 1)
  If(ll Ne '/' And ll Ne '\') Then temp_string = temp_string+'/'
  !icon.local_data_dir = temporary(temp_string)
  temp_string = strtrim(!icon.remote_data_dir, 2)
  ll = strmid(temp_string, strlen(temp_string)-1, 1)
  If(ll Ne '/' And ll Ne '\') Then temp_string = temp_string+'/'
  !icon.remote_data_dir = temporary(temp_string)

  if keyword_set(no_download) then !icon.no_download=1

  ;Sets graphics to the THEMIS defaults
  if not keyword_set(no_color_setup) then begin
    thm_graphics_config,colortable=colortable
  endif

  ;Changed IDL prompt
  if !prompt eq 'IDL> ' then !prompt = 'ICON> '

  ;Next two taken from thm_config 20 Jan 2016

  ; The following calls set persistent flags in dprint that change subsequent output
  ;dprint,setdebug=3       ; set default debug level to value of 3
  ;dprint,/print_dlevel    ; uncomment to display dlevel/verbose at each dprint statement
  ;dprint,/print_dtime     ; uncomment to display time interval between dprint statements.
  dprint,print_trace=1    ; uncomment to display current procedure and line number on each line. (recommended)
  ;dprint,print_trace=3    ; uncomment to display entire program stack on each line.

  ; Some other useful options:
  tplot_options,window=0            ; Forces tplot to use only window 0 for all time plots
  tplot_options,'wshow',1           ; Raises tplot window when tplot is called
  ;If(!themis.verbose Eq 0) Then tplot_options, 'verbose', 0 $ ;turn off default to verbose if !themis.verbose is zero, jmm, 30-sep-2009
  ;Else tplot_options,'verbose',1         ; Displays some extra messages in tplot (e.g. When variables get created/altered)
  ;tplot_options,'psym_lim',100      ; Displays symbols if less than 100 point in panel
  tplot_options,'ygap',.5           ; Set gap distance between tplot panels.
  tplot_options,'lazy_ytitle',1     ; breaks "_" into carriage returns on ytitles
  tplot_options,'no_interp',1      ; prevents interpolation in spectrograms (recommended)



END
