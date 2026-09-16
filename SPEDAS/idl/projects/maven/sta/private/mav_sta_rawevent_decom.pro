function mav_sta_rawevent_decom,msg,rawevents=st

;    cyclestep = msg.data[0]
    cyclestep =  msg.data[0] and '3ff'x
    n = (msg.length-1) / 3

;    dt = (4d - 0.021d)/64d  / 16d     	; 21 ms gap this doesn't quite work, needs offset_time=.005 
    dt = (4d - 0.021d)/64d  / 16d     	; 21 ms gap and 0.006 ms offset_time works 
    time = msg.time + ((0.006d + dt * cyclestep) mod 1)  ; get crude time

    st0={time:0d,cyclestep:cyclestep,tdc1:0,tdc2:0,tdc3:0,tdc4:0,bits_flag:0b,  ok:0b}
    rawsum =    {time:time,cyclestep:cyclestep,ntot:n,n4:0,ng:0}

    if n gt 0 then begin

    rawdata = reform(msg.data[1:*],3,n)

    time += dindgen(n) * dt/32/2    ; spread samples thru half the time interval

    st = replicate(st0 , n)

    st.time = time
    st.bits_flag = reform( rawdata[0,*] ) and byte('111111'b)
    st.tdc1 = ishft( reform( rawdata[0,*] ) ,-6)
    st.tdc2 = reform( rawdata[1,*])  and '3ff'x
    sgn = 1-2*((st.bits_flag and '1'b) ne 0)
    st.tdc3 = sgn * ( ishft( reform(rawdata[2,*]) and '1111'b, 6) or  ishft( reform( rawdata[1,*] ) , -10) )
    sgn = 1-2*((st.bits_flag and '10'b) ne 0)
    st.tdc4 = sgn * ( ishft( reform(rawdata[2,*]), -4) and '3ff'x )

    ok =        (st.tdc1 ne 0) and (abs(st.tdc1) ne 1023)
    ok = ok and (st.tdc2 ne 0) and (abs(st.tdc2) ne 1023)
    ok = ok and (st.tdc3 ne 0) and (abs(st.tdc3) ne 1023)
    ok = ok and (st.tdc4 ne 0) and (abs(st.tdc4) ne 1023)

    st.ok = ok

 ;   dprint,st,dlevel=3
    if 1 then begin
        w4 = where((st.bits_flag and '111100'b) eq '111100'b,n4)
        wg = where(ok,ng)
        rawsum.ntot=n
        rawsum.ng=ng
        rawsum.n4 = n4
    endif
    endif else st=0

    return,rawsum
end