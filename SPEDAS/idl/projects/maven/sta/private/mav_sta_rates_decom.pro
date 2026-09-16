function mav_sta_rates_decom,msg

    if msg.valid eq 0 then return,0

    len = msg.length
;    st =   {time:0d,cycle:0u,counts:replicate(0,10)}
    st =   {time:0d,cyclestep:0u,counts:replicate(0,len-1)}

    cyclestep =  msg.data[0] and '3ff'x
;    dt = cyclestep * (4d - 0.011d)/64d  / 16d     		; this works with offset_time=0. rather than .005
    dt = 0.005d + cyclestep * (4d - 0.021d)/64d  / 16d     	; this works with offset_time=005.
    time = msg.time + (dt mod 1)
;    time = msg.time + (cyclestep mod 256) /256.d

    st.time = time
    st.cyclestep   = cyclestep
;    st.counts     = msg.data[1:10]
;    st.counts     = msg.data[1:12]
    st.counts     = msg.data[1:len-1]

    return,st
end