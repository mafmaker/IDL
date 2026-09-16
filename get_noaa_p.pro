pro get_noaa_p,starttime,endtime,hp,ut,index,hemisphere,sat,norm

;
;  Thomas Immel , UCB
;
;   Program to read idl HP data from NOAA
;
;   starttime=[year,doy,hour,minute]
;   endtime=[year,doy,hour,minute]
;   Simpler program to return daily values will be hp_p.pro...
;

syear=strcompress(starttime(0),/rem)
noaa_path='/home/immel/sci/noaa/'
restore,noaa_path + 'noaa_power_' + syear + '.idl'

;this restores,
;DOY             INT       = Array[27035]
;HEMI            STRING    = Array[27035]
;HP_INDEX        FLOAT     = Array[27035]
;HP_NOAA         FLOAT     = Array[27035]
;NORMFACT        FLOAT     = Array[27035]
;SATNAME         STRING    = Array[27035]
;UTHHMM          INT       = Array[27035]

startut=starttime(2) + starttime(3)/60.
endut=endtime(2) + endtime(3)/60.
hp_ut=(uthhmm/100) + (uthhmm mod 100)/60.

finder=where(doy ge starttime(1) and doy le endtime(1))
subfinder=where(hp_ut(finder) ge startut and hp_ut(finder) le endut)

hp=hp_noaa(finder(subfinder))
ut=hp_ut(finder(subfinder))
index=hp_index(finder(subfinder))
hemisphere=hemi(finder(subfinder))
sat=satname(finder(subfinder))
norm=normfact(finder(subfinder))


;stop
return
end
