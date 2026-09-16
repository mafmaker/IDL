function mav_sta_hkp_decom,msg,status=status

    st =   {time:0d,channel:0b,dwell:0b,cyclestep:0u,adc:0,dig_flag:0u}

    cyclestep =  msg.data[0] and '3ff'x
;    dt = cyclestep * (4d - 0.011d)/64d  / 16d     			; should be 21 ms gap but 11 ms gap works better
    dt = 0.005d + cyclestep * (4d - 0.021d)/64d  / 16d     		; this works with offset_time=005.
    time = msg.time + (dt mod 1)

; THIS IS A TOTALLY STUPID TIMING SYSTEM!!!!

    st.time = time
    st.channel = ishft(msg.data[0],-11)
    st.dwell   = ishft(msg.data[0],-10) and 1
    st.cyclestep   = cyclestep
    st.adc     = msg.data[1]
    st.dig_flag= msg.data[2]

    return,st
end