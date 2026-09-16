

pro mav_sta_msg_handler,msg,status=status,decom=decom,cmdpkt=cmdpkt,completed=completed,init=init,buffer=buffer,rawdat=rawdat,$
  p1=p1,p2=p2,p3=p3,p4=p4,$
  prod1=prod1,prod2=prod2,prod3=prod3,prod4=prod4

    common MISG_STATIC_PROCESS_COM2,  $
    last_status, status_ptrs,  $
    static_hkp, static_hkp_ptrs,  $
    static_rawsummary_ptrs,   static_rawevents_ptrs, $
    static_masshist, static_masshist_ptrs, $
    static_checksum, static_checksum_ptrs, $
    static_rates, static_rates_ptrs,  $
    static_prod1_ptrs,static_prod2_ptrs,static_prod3_ptrs,static_prod4_ptrs, $
    static_command, static_commands_ptrs



    name = 'STA_'
    realtime =0
      
    if keyword_set(cmdpkt) then begin         ; Interpret SEP commands
        mav_gse_command_decom,cmdpkt,memstate,membuff=membuff    ; Note this will not work properly with two SEPs !!!
        mav_gse_structure_append  ,memstate_ptrs, memstate, realtime=realtime
        return
    endif
      
      
            if keyword_set(status) then last_status = status

;*********************************************************************
    if  keyword_set(init) then begin
        time = 0d
        status=0           &  status_ptrs=0
        static_hkp=0       &  static_hkp_ptrs=0
        static_rates=0     &  static_rates_ptrs=0
        static_rawsummary_ptrs=0 &  static_rawevents_ptrs = 0
        static_masshist=0  &  static_masshist_ptrs = 0
        static_checksum=0  &  static_checksum_ptrs = 0
        static_prod1_ptrs=0
        static_prod2_ptrs=0
        static_prod3_ptrs=0
        static_prod4_ptrs=0

        return
    endif
;*********************************************************************
    if keyword_set(completed) then begin
;        mav_gse_structure_append  ,status_ptrs,      tname = 'MISG_STATUS', tags = '*'

 ;	*********************************************************************
	mav_gse_structure_append  ,static_hkp_ptrs
        if size(/type,static_hkp_ptrs) eq 8 then begin
              d = *static_hkp_ptrs.x
              for i=0,31 do begin
                  w = where(d.channel eq i,nw)
                  tnm = 'STA_HKP_CH'+strtrim(i,2)
                  if nw gt 0 then store_data,tnm, d[w].time,d[w].adc else del_data,tnm
              endfor
        endif
        mav_gse_structure_append  ,static_hkp_ptrs,      tname = 'STA_HKP', tags = '*'

;	*********************************************************************
        mav_gse_structure_append, static_rawevents_ptrs  ;  truncate but don't make tplot vars
	if size(/type,static_rawevents_ptrs) eq 8 then rawdat = *static_rawevents_ptrs.x else rawdat=0
;          rawdat = *static_rawevents_ptrs.x
        if 0 then begin   ; WARNING  this option is misleading!!!! hides bad data!
		ok = (*static_rawevents_ptrs.x).ok
		w =where(ok,nw)
		*static_rawevents_ptrs.x  = (*static_rawevents_ptrs.x)[w]
		*static_rawevents_ptrs.xi  = nw
        endif

;	*********************************************************************
        mav_gse_structure_append  ,static_rawevents_ptrs,    tname = 'STA_RAW', tags = '*'
		options,'STA_RAW_TDC*',psym=3
		ylim,'STA_RAW_TDC[3,4]',-1100,1100
		ylim,'STA_RAW_TDC[1,2]',-100,1100

;	*********************************************************************
        mav_gse_structure_append  ,static_rawsummary_ptrs,    tname = 'STA_RAWSUM', tags = '*'
        mav_gse_structure_append  ,static_rates_ptrs,  tname = 'STA_RATES', tags = '*'
		ratlab = strsplit('TimeA TimeB TimeC TimeD TimeRST StpNoStrt UnQual FullQ ABinReject MBinReject AandB CandD',' ',/ex)
		options,'STA_RATES_COUNTS',/def,colors='GgRrBMRBCR',labels = ratlab
		get_data,'STA_RATES_COUNTS',time,data,alim=lim
		store_data,'STA_RATES_EFF',time,data/(data[*,4] # replicate(1.,10)) ,dlim =lim

;	*********************************************************************
        mav_gse_structure_append  ,static_masshist_ptrs,  tname = 'STA_MASSHIST', tags = '*'

;	*********************************************************************
        mav_gse_structure_append  ,static_checksum_ptrs,  tname = 'STA_CHECKSUM', tags = '*'

;	*********************************************************************
        mav_gse_structure_append, static_prod1_ptrs  		;  truncate but don't make tplot vars
	if size(/type,static_prod1_ptrs) eq 8 then begin
		prod1 = *static_prod1_ptrs.x
		p1 = mav_sta_p1_misg_decom(prod1)
	endif else begin
		prod1=0
		p1=0
	endelse
        mav_gse_structure_append  ,static_prod1_ptrs,    tname = 'STA_PROD1', tags = '*'

;	*********************************************************************
        mav_gse_structure_append, static_prod2_ptrs  		;  truncate but don't make tplot vars
	if size(/type,static_prod2_ptrs) eq 8 then begin
		prod2 = *static_prod2_ptrs.x
		p2 = mav_sta_p2_misg_decom(prod2)
     	endif else begin
    		prod2=0
    		p2=0
     	endelse
        mav_gse_structure_append  ,static_prod2_ptrs,    tname = 'STA_PROD2', tags = '*'

;	*********************************************************************
        mav_gse_structure_append, static_prod3_ptrs  		;  truncate but don't make tplot vars
	if size(/type,static_prod3_ptrs) eq 8 then begin
		prod3 = *static_prod3_ptrs.x
		p3 = mav_sta_p3_misg_decom(prod3)
	endif else begin
		prod3=0
		p3=0
	endelse
        mav_gse_structure_append  ,static_prod3_ptrs,    tname = 'STA_PROD3', tags = '*'

;	*********************************************************************
        mav_gse_structure_append, static_prod4_ptrs  ;  truncate but don't make tplot vars
	if size(/type,static_prod4_ptrs) eq 8 then begin
		prod4 = *static_prod4_ptrs.x
		p4 = mav_sta_p4_misg_decom(prod4)
	endif else begin
		prod4=0
		p4=0
	endelse
        mav_gse_structure_append  ,static_prod4_ptrs,    tname = 'STA_PROD4', tags = '*'

        return
    endif
;*********************************************************************

    if not keyword_set(time) then time = 0d
 
    if size(/type,cmnpkt) eq 8 then begin
        if cmnpkt.mid4 eq 1 then begin   ; decommutate commands sent TO MISG
            mav_gse_command_decom,cmnpkt
            return
        endif
        if not keyword_set(time) then time = cmnpkt.time
        buffer = uint(cmnpkt.buffer,0,cmnpkt.data_size/2)
        byteorder,buffer,/swap_if_little_endian
    endif

    if keyword_set(status) then time = status.time

            id0 = msg.id
            if msg.time eq 0 then id0='ff'x   ; ignore data messages until time is established
            case id0 of
                '30'x:  mav_gse_structure_append  ,static_rates_ptrs, mav_sta_rates_decom(msg)
                '32'x: begin  ; Housekeeping
                    static_hkp = mav_sta_hkp_decom(msg,status=status)
                    mav_gse_structure_append  ,static_hkp_ptrs, static_hkp
                    end
                '33'x:  mav_gse_structure_append, static_checksum_ptrs,  mav_sta_checksum_decom(msg) ; memory checksum
                '34'x:  begin
                    mav_gse_structure_append, static_rawsummary_ptrs,  mav_sta_rawevent_decom(msg,rawevents=rawevents)
                    if keyword_set(rawevents) then mav_gse_structure_append, static_rawevents_ptrs, rawevents ; raw events
                    end
                '35'x:  mav_gse_structure_append, static_masshist_ptrs,  mav_sta_masshist_decom(msg) ; mass histogram
                '38'x:  mav_gse_structure_append, static_prod1_ptrs, mav_sta_px_decom(msg)
                '39'x:  mav_gse_structure_append, static_prod2_ptrs, mav_sta_px_decom(msg)
                '3A'x:  mav_gse_structure_append, static_prod3_ptrs, mav_sta_px_decom(msg)
                '3B'x:  mav_gse_structure_append, static_prod4_ptrs, mav_sta_px_decom(msg)
                'ff'x:  dprint,dlevel=3,'Ignore data without time code'
                else:   return
            endcase

            decom=1

end



