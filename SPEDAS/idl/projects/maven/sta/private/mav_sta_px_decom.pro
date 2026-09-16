function mav_sta_px_decom,msg

    st =   {time:0d,P4sel:0b,Abinmode:0b,Massbinmode:0b,cyclestep:0u,data:uintarr(48) }
    d0 = msg.data[0]

    st.time = msg.time
    st.p4sel = ishft(d0,-14) and '11'b
    st.abinmode = ishft(d0, -12) and '11'b
    st.massbinmode = ishft(d0, -10) and '11'b
    st.cyclestep=  d0 and '3ff'x
    st.data = msg.data[1:*]

    return,st
end