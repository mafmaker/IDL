function mav_sta_masshist_decom,msg

    st =   {time:0d,mass:uintarr(1024)}

    st.time = msg.time
    st.mass = msg.data

    return,st
end