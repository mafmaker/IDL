function mav_sta_checksum_decom,msg

    st =   {time:0d,sample_time:0b,fpga_rev:0b,chksum_slut:bytarr(8),chksum_mlut:bytarr(4),$
		cpn_cmd_cnt:0,reg_data:0,reg_read_ptr:0,mtp_mem_mode:0b,fixed_diag_data:0}

    st.time = msg.time
    st.sample_time = msg.data[0] and '00ff'x
    st.fpga_rev = ishft(msg.data[0] and 'ff00'x,-8)
    st.chksum_slut[0] = msg.data[1] and '00ff'x
    st.chksum_slut[1] = ishft(msg.data[1] and 'ff00'x,-8)
    st.chksum_slut[2] = msg.data[2] and '00ff'x
    st.chksum_slut[3] = ishft(msg.data[2] and 'ff00'x,-8)
    st.chksum_slut[4] = msg.data[3] and '00ff'x
    st.chksum_slut[5] = ishft(msg.data[3] and 'ff00'x,-8)
    st.chksum_slut[6] = msg.data[4] and '00ff'x
    st.chksum_slut[7] = ishft(msg.data[4] and 'ff00'x,-8)
    st.chksum_mlut[0] = msg.data[5] and '00ff'x
    st.chksum_mlut[1] = ishft(msg.data[5] and 'ff00'x,-8)
    st.chksum_mlut[2] = msg.data[6] and '00ff'x
    st.chksum_mlut[3] = ishft(msg.data[6] and 'ff00'x,-8)
    st.cpn_cmd_cnt = msg.data[7] 
    st.reg_data = msg.data[8] 
    st.mtp_mem_mode = msg.data[9] and '00ff'x
    st.reg_read_ptr = ishft(msg.data[9] and 'ff00'x,-8)
    st.fixed_diag_data = msg.data[10] 

    return,st
end