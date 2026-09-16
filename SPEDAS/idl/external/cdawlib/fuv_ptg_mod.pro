
; Tables provided by H.Frey on 12/3/2001
;
FUNCTION image_fuv_wic_angle_table
year  = intarr(72)
doy   = intarr(72)
angles= fltarr(3,72) ; omega,theta,phi
year( 0)=2000 & doy( 0)=159 & angles(* ,0)= [43.13  ,   1.06  ,  -0.05]
year( 1)=2000 & doy( 1)=160 & angles(*, 1)= [43.04  ,   0.96  ,  -0.05]
year( 2)=2000 & doy( 2)=162 & angles(*, 2)= [43.80  ,   0.95  ,  -0.05]
year( 3)=2000 & doy( 3)=163 & angles(*, 3)= [43.87  ,   0.96  ,  -0.05]
year( 4)=2000 & doy( 4)=175 & angles(*, 4)= [43.14  ,   0.93  ,  -0.05]
year( 5)=2000 & doy( 5)=176 & angles(*, 5)= [43.14  ,   0.93  ,  -0.05]
year( 6)=2000 & doy( 6)=177 & angles(*, 6)= [43.15  ,   0.91  ,  -0.05]
year( 7)=2000 & doy( 7)=178 & angles(*, 7)= [43.12  ,   0.90  ,  -0.05]
year( 8)=2000 & doy( 8)=179 & angles(*, 8)= [43.20  ,   0.95  ,  -0.05]
year( 9)=2000 & doy( 9)=180 & angles(*, 9)= [43.26  ,   0.94  ,  -0.05]
year(10)=2000 & doy(10)=191 & angles(*,10)= [43.62  ,   0.89  ,  -0.05]
year(11)=2000 & doy(11)=192 & angles(*,11)= [43.62  ,   0.82  ,  -0.05]
year(12)=2000 & doy(12)=193 & angles(*,12)= [43.63  ,   0.82  ,  -0.05]
year(13)=2000 & doy(13)=197 & angles(*,13)= [43.60  ,   0.80  ,  -0.05]
year(14)=2000 & doy(14)=198 & angles(*,14)= [43.60  ,   0.80  ,  -0.55]
year(15)=2000 & doy(15)=208 & angles(*,15)= [44.29  ,   0.76  ,  -0.05]
year(16)=2000 & doy(16)=210 & angles(*,16)= [44.22  ,   0.75  ,  -0.05]
year(17)=2000 & doy(17)=211 & angles(*,17)= [44.26  ,   0.75  ,  -0.05]
year(18)=2000 & doy(18)=225 & angles(*,18)= [43.12  ,   0.91  ,  -0.05]
year(19)=2000 & doy(19)=236 & angles(*,19)= [43.19  ,   0.91  ,  -0.05]
year(20)=2000 & doy(20)=237 & angles(*,20)= [43.23  ,   0.91  ,  -0.05]
year(21)=2000 & doy(21)=259 & angles(*,21)= [43.10  ,   0.95  ,  -0.05]
year(22)=2000 & doy(22)=261 & angles(*,22)= [43.17  ,   0.86  ,  -0.05]
year(23)=2000 & doy(23)=262 & angles(*,23)= [43.26  ,   0.86  ,  -0.05]
year(24)=2000 & doy(24)=273 & angles(*,24)= [43.26  ,   0.86  ,  -0.05]
year(25)=2000 & doy(25)=277 & angles(*,25)= [43.26  ,   0.30  ,  -0.05]
year(26)=2000 & doy(26)=284 & angles(*,26)= [43.26  ,   0.37  ,  -1.85]
year(27)=2000 & doy(27)=302 & angles(*,27)= [43.16  ,   0.41  ,  -2.45]
year(28)=2000 & doy(28)=324 & angles(*,28)= [43.06  ,   0.42  ,  -2.55]
year(29)=2000 & doy(29)=329 & angles(*,29)= [43.17  ,   0.43  ,  -1.85]
year(30)=2000 & doy(30)=331 & angles(*,30)= [43.17  ,   0.43  ,  -1.85]                  
year(31)=2000 & doy(31)=339 & angles(*,31)= [43.19  ,   0.42  ,  -1.85]                  
year(32)=2000 & doy(32)=342 & angles(*,32)= [43.13  ,   0.43  ,  -1.85]                  
year(33)=2001 & doy(33)= 10 & angles(*,33)= [43.06  ,   0.28  ,  -1.85]                  
year(34)=2001 & doy(34)= 13 & angles(*,34)= [43.09  ,   0.28  ,  -1.85]                  
year(35)=2001 & doy(35)= 14 & angles(*,35)= [43.13  ,   0.43  ,  -1.85]                  
year(36)=2001 & doy(36)= 18 & angles(*,36)= [43.13  ,   0.30  ,  -1.85]                  
year(37)=2001 & doy(37)= 20 & angles(*,37)= [43.19  ,   0.30  ,  -1.85]                  
year(38)=2001 & doy(38)= 21 & angles(*,38)= [43.19  ,   0.30  ,  -1.85]
year(39)=2001 & doy(39)= 23 & angles(*,39)= [43.19  ,   0.30  ,  -1.85]
year(40)=2001 & doy(40)= 45 & angles(*,40)= [43.09  ,   0.28  ,  -1.85]
year(41)=2001 & doy(41)= 50 & angles(*,41)= [43.19  ,   0.32  ,  -1.85]
year(42)=2001 & doy(42)= 54 & angles(*,42)= [43.19  ,   0.33  ,  -1.85]
year(43)=2001 & doy(43)= 78 & angles(*,43)= [43.02  ,   0.30  ,  -1.85]
year(44)=2001 & doy(44)=114 & angles(*,44)= [43.03  ,   0.43  ,  -1.85]
year(45)=2001 & doy(45)=118 & angles(*,45)= [43.09  ,   0.43  ,  -1.85]
year(46)=2001 & doy(46)=119 & angles(*,46)= [43.12  ,   0.43  ,  -1.85]
year(47)=2001 & doy(47)=144 & angles(*,47)= [43.12  ,   0.41  ,  -1.85]
year(48)=2001 & doy(48)=145 & angles(*,48)= [43.13  ,   0.43  ,  -1.85]
year(49)=2001 & doy(49)=146 & angles(*,49)= [43.07  ,   0.45  ,  -1.85]
year(50)=2001 & doy(50)=147 & angles(*,50)= [43.07  ,   0.45  ,  -1.85]
year(51)=2001 & doy(51)=148 & angles(*,51)= [43.12  ,   0.44  ,  -1.85]
year(52)=2001 & doy(52)=149 & angles(*,52)= [43.08  ,   0.47  ,  -1.85]
year(53)=2001 & doy(53)=158 & angles(*,53)= [42.96  ,   0.65  ,  -1.85]
year(54)=2001 & doy(54)=164 & angles(*,54)= [38.76  ,  -0.91  ,  -1.85]
year(55)=2001 & doy(55)=170 & angles(*,55)= [39.86  ,   0.09  ,  -1.85]
year(56)=2001 & doy(56)=174 & angles(*,56)= [38.94  ,  -0.02  ,  -1.85]
year(57)=2001 & doy(57)=185 & angles(*,57)= [39.59  ,  -0.75  ,  -1.85]
year(58)=2001 & doy(58)=195 & angles(*,58)= [39.59  ,  -0.75  ,  -1.85]
year(59)=2001 & doy(59)=196 & angles(*,59)= [42.59  ,  -1.04  ,  -1.85]
year(60)=2001 & doy(60)=197 & angles(*,60)= [42.59  ,  -0.16  ,  -1.85]
year(61)=2001 & doy(61)=198 & angles(*,61)= [42.79  ,  -0.30  ,  -1.85]
year(62)=2001 & doy(62)=203 & angles(*,62)= [43.29  ,  -1.04  ,  -1.85]
year(63)=2001 & doy(63)=207 & angles(*,63)= [44.19  ,   0.24  ,  -1.85]
year(64)=2001 & doy(64)=212 & angles(*,64)= [43.84  ,   0.54  ,  -1.85]
year(65)=2001 & doy(65)=218 & angles(*,65)= [43.19  ,   0.04  ,  -1.85]
year(66)=2001 & doy(66)=229 & angles(*,66)= [41.26  ,   0.40  ,  -1.85]
year(67)=2001 & doy(67)=235 & angles(*,67)= [42.99  ,   0.47  ,  -1.85]
year(68)=2001 & doy(68)=245 & angles(*,68)= [42.99  ,   0.97  ,  -2.45]
year(69)=2001 & doy(69)=261 & angles(*,69)= [42.99  ,   0.47  ,  -2.45]
year(70)=2001 & doy(70)=265 & angles(*,70)= [43.10  ,   0.99  ,  -2.45]
year(71)=2001 & doy(71)=294 & angles(*,71)= [42.89  ,   1.26  ,  -2.45]
return,{year:year,doy:doy,angles:angles}
end 
 

FUNCTION image_fuv_si12_angle_table    
year  = intarr(60)                    
doy   = intarr(60)                    
angles= fltarr(3,60) ; omega,theta,phi
year( 0)=2000 & doy( 0)=160 & angles(* ,0)= [44.40  ,  -0.54  ,      0]
year( 1)=2000 & doy( 1)=162 & angles(*, 1)= [44.50  ,  -0.61  ,      0]
year( 2)=2000 & doy( 2)=163 & angles(*, 2)= [44.70  ,  -0.58  ,      0]
year( 3)=2000 & doy( 3)=168 & angles(*, 3)= [43.37  ,  -0.84  ,      0]
year( 4)=2000 & doy( 4)=175 & angles(*, 4)= [42.76  ,  -0.79  ,      0]
year( 5)=2000 & doy( 5)=176 & angles(*, 5)= [42.76  ,  -0.79  ,      0]
year( 6)=2000 & doy( 6)=178 & angles(*, 6)= [42.80  ,  -0.79  ,      0]
year( 7)=2000 & doy( 7)=180 & angles(*, 7)= [42.88  ,  -0.78  ,      0]
year( 8)=2000 & doy( 8)=183 & angles(*, 8)= [43.05  ,  -0.80  ,      0]
year( 9)=2000 & doy( 9)=192 & angles(*, 9)= [43.27  ,  -0.91  ,      0]
year(10)=2000 & doy(10)=193 & angles(*,10)= [43.23  ,  -0.90  ,      0]
year(11)=2000 & doy(11)=195 & angles(*,11)= [43.25  ,  -0.80  ,      0]
year(12)=2000 & doy(12)=196 & angles(*,12)= [43.25  ,  -0.60  ,      0]
year(13)=2000 & doy(13)=197 & angles(*,13)= [43.22  ,  -0.93  ,      0]
year(14)=2000 & doy(14)=198 & angles(*,14)= [43.28  ,  -0.93  ,      0]
year(15)=2000 & doy(15)=208 & angles(*,15)= [43.92  ,  -0.98  ,      0]
year(16)=2000 & doy(16)=210 & angles(*,16)= [43.84  ,  -0.98  ,      0]
year(17)=2000 & doy(17)=211 & angles(*,17)= [43.80  ,  -0.98  ,      0]
year(18)=2000 & doy(18)=218 & angles(*,18)= [42.77  ,  -0.78  ,      0]
year(19)=2000 & doy(19)=225 & angles(*,19)= [42.84  ,  -0.80  ,      0]
year(20)=2000 & doy(20)=236 & angles(*,20)= [42.70  ,  -0.82  ,      0]
year(21)=2000 & doy(21)=237 & angles(*,21)= [42.70  ,  -0.82  ,      0]
year(22)=2000 & doy(22)=240 & angles(*,22)= [42.77  ,  -0.78  ,      0]
year(23)=2000 & doy(23)=250 & angles(*,23)= [42.74  ,  -0.78  ,      0]
year(24)=2000 & doy(24)=261 & angles(*,24)= [42.55  ,  -0.76  ,      0]
year(25)=2000 & doy(25)=262 & angles(*,25)= [42.55  ,  -0.76  ,      0]
year(26)=2000 & doy(26)=263 & angles(*,26)= [42.70  ,  -0.76  ,      0]
year(27)=2000 & doy(27)=265 & angles(*,27)= [42.75  ,  -0.68  ,      0]
year(28)=2000 & doy(28)=277 & angles(*,28)= [42.62  ,  -1.65  ,  -1.85]
year(29)=2000 & doy(29)=279 & angles(*,29)= [42.75  ,  -1.65  ,  -1.85]
year(30)=2000 & doy(30)=302 & angles(*,30)= [42.74  ,  -1.70  ,  -1.85]
year(31)=2000 & doy(31)=309 & angles(*,31)= [42.75  ,  -1.70  ,  -1.85]
year(32)=2000 & doy(32)=311 & angles(*,32)= [42.75  ,  -1.70  ,  -1.85]
year(33)=2000 & doy(33)=313 & angles(*,33)= [42.75  ,  -1.70  ,  -1.85]
year(34)=2000 & doy(34)=324 & angles(*,34)= [42.74  ,  -1.70  ,  -1.85]
year(35)=2000 & doy(35)=329 & angles(*,35)= [42.75  ,  -1.68  ,  -1.85]
year(36)=2000 & doy(36)=330 & angles(*,36)= [42.75  ,  -1.68  ,  -1.85]
year(37)=2000 & doy(37)=331 & angles(*,37)= [42.75  ,  -1.68  ,  -1.85]
year(38)=2000 & doy(38)=339 & angles(*,38)= [42.82  ,  -1.72  ,  -1.85]
year(39)=2000 & doy(39)=342 & angles(*,39)= [42.78  ,  -1.69  ,  -1.85]
year(40)=2001 & doy(40)= 14 & angles(*,40)= [42.69  ,  -1.68  ,  -1.85]
year(41)=2001 & doy(41)= 20 & angles(*,41)= [42.74  ,  -1.70  ,  -1.85]
year(42)=2001 & doy(42)= 21 & angles(*,42)= [42.74  ,  -1.70  ,  -1.85]
year(43)=2001 & doy(43)= 23 & angles(*,43)= [42.74  ,  -1.70  ,  -1.85]
year(44)=2001 & doy(44)= 24 & angles(*,44)= [42.74  ,  -1.70  ,  -1.85]
year(45)=2001 & doy(45)=114 & angles(*,45)= [42.85  ,  -1.75  ,  -1.85]
year(46)=2001 & doy(46)=118 & angles(*,46)= [42.95  ,  -1.72  ,  -1.85]
year(47)=2001 & doy(47)=119 & angles(*,47)= [42.75  ,  -1.72  ,  -1.85]
year(48)=2001 & doy(48)=144 & angles(*,48)= [42.80  ,  -1.70  ,  -1.85]
year(49)=2001 & doy(49)=158 & angles(*,49)= [42.80  ,  -1.70  ,  -1.85]
year(50)=2001 & doy(50)=185 & angles(*,50)= [39.48  ,  -2.92  ,  -1.85]
year(51)=2001 & doy(51)=195 & angles(*,51)= [39.48  ,  -2.92  ,  -1.85]
year(52)=2001 & doy(52)=196 & angles(*,52)= [42.48  ,  -3.05  ,  -1.85]
year(53)=2001 & doy(53)=203 & angles(*,53)= [43.18  ,  -3.05  ,  -1.85]
year(54)=2001 & doy(54)=207 & angles(*,54)= [43.98  ,  -2.05  ,  -1.85]
year(55)=2001 & doy(55)=218 & angles(*,55)= [42.98  ,  -1.65  ,  -1.85]
year(56)=2001 & doy(56)=228 & angles(*,56)= [41.48  ,  -0.85  ,  -1.85]
year(57)=2001 & doy(57)=235 & angles(*,57)= [42.98  ,  -1.75  ,  -1.85]
year(58)=2001 & doy(58)=269 & angles(*,58)= [42.98  ,  -0.90  ,  -1.85]
year(59)=2001 & doy(59)=294 & angles(*,59)= [42.63  ,  -0.92  ,  -2.45]
return,{year:year,doy:doy,angles:angles}
end 

FUNCTION image_fuv_si13_angle_table    
year  = intarr(48)                    
doy   = intarr(48)                    
angles= fltarr(3,48) ; omega,theta,phi
year( 0)=2000 & doy( 0)=160 & angles(* ,0)= [44.40  ,  -0.54  ,      0]
year( 1)=2000 & doy( 1)=163 & angles(*, 1)= [44.40  ,  -0.58  ,      0]
year( 2)=2000 & doy( 2)=168 & angles(*, 2)= [44.22  ,  -0.56  ,      0]
year( 3)=2000 & doy( 3)=175 & angles(*, 3)= [43.62  ,  -0.55  ,      0]
year( 4)=2000 & doy( 4)=176 & angles(*, 4)= [43.62  ,  -0.55  ,      0]
year( 5)=2000 & doy( 5)=180 & angles(*, 5)= [43.77  ,  -0.50  ,      0]
year( 6)=2000 & doy( 6)=192 & angles(*, 6)= [44.12  ,  -0.70  ,      0]
year( 7)=2000 & doy( 7)=193 & angles(*, 7)= [44.12  ,  -0.70  ,      0]
year( 8)=2000 & doy( 8)=196 & angles(*, 8)= [44.25  ,  -0.60  ,      0]
year( 9)=2000 & doy( 9)=208 & angles(*, 9)= [44.76  ,  -0.72  ,      0]
year(10)=2000 & doy(10)=210 & angles(*,10)= [44.73  ,  -0.74  ,      0]
year(11)=2000 & doy(11)=225 & angles(*,11)= [43.59  ,  -0.59  ,      0]
year(12)=2000 & doy(12)=236 & angles(*,12)= [43.64  ,  -0.60  ,      0]
year(13)=2000 & doy(13)=237 & angles(*,13)= [43.64  ,  -0.60  ,      0]
year(14)=2000 & doy(14)=259 & angles(*,14)= [43.54  ,  -0.50  ,      0]
year(15)=2000 & doy(15)=261 & angles(*,15)= [43.58  ,  -0.52  ,      0]
year(16)=2000 & doy(16)=262 & angles(*,16)= [43.58  ,  -0.52  ,      0]
year(17)=2000 & doy(17)=265 & angles(*,17)= [43.15  ,  -0.40  ,      0]
year(18)=2000 & doy(18)=277 & angles(*,18)= [43.25  ,  -1.47  ,      0]
year(19)=2000 & doy(19)=301 & angles(*,19)= [43.15  ,  -1.40  ,  -2.15]
year(20)=2000 & doy(20)=302 & angles(*,20)= [43.15  ,  -1.45  ,  -2.15]
year(21)=2000 & doy(21)=331 & angles(*,21)= [43.24  ,  -1.47  ,  -1.85]
year(22)=2000 & doy(22)=339 & angles(*,22)= [44.23  ,  -1.47  ,  -1.85]
year(23)=2000 & doy(23)=344 & angles(*,23)= [43.15  ,  -1.40  ,  -2.15]
year(24)=2001 & doy(24)= 14 & angles(*,24)= [43.18  ,  -1.41  ,  -1.85]
year(25)=2001 & doy(25)= 20 & angles(*,25)= [43.10  ,  -1.45  ,  -1.85]
year(26)=2001 & doy(26)= 21 & angles(*,26)= [43.10  ,  -1.45  ,  -1.85]
year(27)=2001 & doy(27)= 23 & angles(*,27)= [43.17  ,  -1.45  ,  -1.85]
year(28)=2001 & doy(28)=114 & angles(*,28)= [43.25  ,  -1.48  ,  -1.85]
year(29)=2001 & doy(29)=118 & angles(*,29)= [43.28  ,  -1.53  ,  -1.85]
year(30)=2001 & doy(30)=119 & angles(*,30)= [43.21  ,  -1.49  ,  -1.85]
year(31)=2001 & doy(31)=144 & angles(*,31)= [43.29  ,  -1.47  ,  -1.85]
year(32)=2001 & doy(32)=145 & angles(*,32)= [43.33  ,  -1.53  ,  -1.85]
year(33)=2001 & doy(33)=146 & angles(*,33)= [43.33  ,  -1.53  ,  -1.85]
year(34)=2001 & doy(34)=147 & angles(*,34)= [43.35  ,  -1.58  ,  -1.85]
year(35)=2001 & doy(35)=148 & angles(*,35)= [43.38  ,  -1.61  ,  -1.85]
year(36)=2001 & doy(36)=149 & angles(*,36)= [43.40  ,  -1.62  ,  -1.85]
year(37)=2001 & doy(37)=158 & angles(*,37)= [43.20  ,  -1.35  ,  -1.85]
year(38)=2001 & doy(38)=185 & angles(*,38)= [39.88  ,  -2.73  ,  -1.85]
year(39)=2001 & doy(39)=195 & angles(*,39)= [39.88  ,  -2.73  ,  -1.85]
year(40)=2001 & doy(40)=196 & angles(*,40)= [42.88  ,  -2.93  ,  -1.85]
year(41)=2001 & doy(41)=203 & angles(*,41)= [43.58  ,  -2.93  ,  -1.85]
year(42)=2001 & doy(42)=207 & angles(*,42)= [44.48  ,  -1.73  ,  -1.85]
year(43)=2001 & doy(43)=218 & angles(*,43)= [43.48  ,  -1.43  ,  -1.85]
year(44)=2001 & doy(44)=228 & angles(*,44)= [41.98  ,  -0.83  ,  -1.85]
year(45)=2001 & doy(45)=235 & angles(*,45)= [43.45  ,  -1.53  ,  -1.85]
year(46)=2001 & doy(46)=269 & angles(*,46)= [43.45  ,  -0.66  ,  -1.85]
year(47)=2001 & doy(47)=294 & angles(*,47)= [43.28  ,  -0.70  ,  -2.45]
return,{year:year,doy:doy,angles:angles}
end

;---------------------------------------------------------------

PRO fuv_drtollP,x,y,z,lat,lon,r

lat = atan2d(z,SQRT(x*x + y*y))
lon = atan2d(y,x)
r   = SQRT(x*x + y*y + z*z)

tmp = WHERE(x EQ Y) AND WHERE(x EQ 0)
IF ((size(tmp))(0) NE 0) THEN BEGIN
   lat(tmp)  = DOUBLE(90.D * z(tmp)/ABS(z(tmp)))
   lon(tmp) = 0.D
   r = 6371.D
ENDIF

tmp2 = WHERE(lon LT 0)
IF ((size(tmp2))(0) NE 0) THEN BEGIN
   lon(tmp2) = lon(tmp2) + 360.D
ENDIF

END

;---------------------------------------------------------------

PRO fuv_get_scalarP,Ox,Oy,Oz,Lx,Ly,Lz,emis_hgt,ncols,nrows,s,f, $
                off_axis,num_off_axis

;...  Equatoral radius (km) and polar flattening of the earth
;     Ref: Table 15.4, 'Explanatory Supplement to the
;          Astronomical Almanac,' K. Seidelmann, ed. (1992).
re_eq = 6378.136D
inv_f = 298.257D

;...  initialize output
s =  DBLARR(ncols,nrows)
s1 = DBLARR(ncols,nrows)
s2 = DBLARR(ncols,nrows)

;...  get polar radius
re_po = re_eq*(1.D - 1.D / inv_f)

;...  get radii to assumed emission height
ree = re_eq + emis_hgt
rep = re_po + emis_hgt

;...  get flattening factor based on new radii
f = (ree - rep)/ree

;...  get elements of quadratic formula
a = fgeodeP(ree,rep,Lx,Ly,Lz,Lx,Ly,Lz)      
b = fgeodeP(ree,rep,Lx,Ly,Lz,Ox,Oy,Oz) * 2.D
c = fgeodeP(ree,rep,Ox,Oy,Oz,Ox,Oy,Oz) - ree*ree

;...  check solutions to quadratic formula
determinant = b*b - 4.D * a*c

;...  remove points off the earth
determinant = determinant > 0.
off_axis = WHERE(determinant EQ 0.,num_off_axis)
IF(num_off_axis GT 0) THEN b(off_axis) = 0.D

;...  solve quadratic formula (choose smallest solution)
s1 = ( -b + SQRT(determinant) ) / ( 2.D * a )
s2 = ( -b - SQRT(determinant) ) / ( 2.D * a )

s = s1<s2

END

;-------------------------------------------------------------------------
;  ROUTINE: amia_transformation_matrix
;-------------------------------------------------------------------------
; Use this function to test the value returned by the fuv_rotation_matrix
; function.  It will return a 1 (true) if the value is a 3x3 matrix.  It
; will return a 0 (false) in any other case.  RBurley, 1/9/2001.
FUNCTION amia_transformation_matrix,v
s = size(v) & ns = n_elements(v)
if (s(0) eq 0) then return,0 ; scalar value isn't a matrix
return,1
end

;-------------------------------------------------------------------------
;  ROUTINE: get_inst_angles_new
;-------------------------------------------------------------------------
; Use this function to return FUV omega/theta/phi angles for
; a given instrument (0=wic,1=si12,2=si13) at a given year and day of year.
; Author : R Burley, Modified from original code by T Immel of UCB
;          to call function which return arrays of these values instead
;          of calling a routine which reads text files, for easier
;          incorporation to CDAWeb
; Date   : 5-22-2001 from T Immel code date of 2/11/2001
; Purpose: Provides a single routine to demand pointing information for getudf_var
;
FUNCTION get_inst_angles_new,inst_,year_,day_
; Ensure that inputs are integers
year=fix(year_) & day=fix(day_) & inst=fix(inst_)
; Load the timetagged angle arrays
case inst of
0    : s = image_fuv_wic_angle_table()
1    : s = image_fuv_si12_angle_table()
2    : s = image_fuv_si13_angle_table()
else : begin
       print,'ERROR>fuv_ptg_mod>get_inst_angles_new>Instrument < 0 or > 2!'
       return,-1
       end
endcase

; Pull arrays out of structures
year_arr = s.year
day_arr  = s.doy
ang_arr  = s.angles

; Locate desired year/day in table
finder=where(year_arr eq year and day_arr eq day,found)

; Interpolate
if found eq 0 then begin
  time_array=(year_arr-2000.)*364.+day_arr
  time_difference=time_array-(year-2000.)*364.-day
  new_found=where(abs(time_difference) eq min(abs(time_difference)))
  angles=ang_arr[*,new_found[0]]
endif else angles=ang_arr(*,finder[0])
angles_=angles ;& print,'angles=',angles
return,angles
end


;+------------------------------------------------------------------------
; NAME: FUV_PTG_MOD  
;
; PURPOSE: calculates geocentric lat,lon, for a complete image
;
; CALLING SEQUENCE:fuv_ptg_mod,system,vname,time,emis_hgt,gclat,gclon,l0,ras,decl
;
; INPUTS:
;	image_info_for_instrument:structure which contains all values for 
;				  pointing calculation
;	vname: name of the variable in the structure to plot 
;	time: time(1)=yyyyddd, time(2)=msec of day
;	emis_hgt: los altitude
; KEYWORD PARAMETERS:
;	geodetic        (set) returns geodetic values if set
;	getra           (set) calculates ra & dec if set
;	ra           (out) right ascension (deg)
;	dec           (out) declination (deg)
;	s           (out) scalar for lpix
;	lpixX           (out) x component of unit look direction
;	lpixY           (out) y component of unit look direction
;	lpixZ           (out) z component of unit look direction
;	posX           (out) x,y,z components of vector from
;	posY           (out)       earth center to emission
;	posZ           (out)
;	versStr           (out) software version string
;	orbpos         (in) hfrey, added 10/23/2000 orb pos in gci.
;	record_number  (in) hfrey, added 10/23/2000 record number.
;	earthlat       (out) hfrey, added 10/23/2000 center of proj.
;	earthlon       (out) hfrey, added 10/23/2000 center of proj.
; OUTPUTS:
;	l0		  look direction in gci for central pixel
;	ras		  RA for central pixel
;	decl		  DEC for central pixel
;	gclat           geocentric latitude
;	gclon           geocentric longitude
;
; MODIFICATION HISTORY:
;  this routine is based on the POLAR UVI ptg.pro but was modified for the
;	IMAGE FUV instrument
;	Harald Frey, 01/05/2000
;  RCJ, 10/01. Modified to work with CDAWeb s/w
;-------------------------------------------------------------------------

PRO fuv_ptg_mod,image_info_for_instrument,vname,time,emis_hgt,gclat,gclon,l0,ras,decl $
       ,geodetic=geodetic,getra=getra,ra=ra,dec=dec,s=s $
       ,LpixX=LpixX,LpixY=LpixY,LpixZ=LpixZ $
       ,posX=posX,posY=posY,posZ=posZ $
       ,versStr=versStr,help=help, orbpos=orbpos, record_number=record_number $
       ,earthlat=earthlat,earthlon=earthlon
COMMON stars,new_starsx,new_starsy
IF(KEYWORD_SET(help)) THEN BEGIN
   PRINT,''
   PRINT,' PRO fuv_ptg_mod,system,vname,time,emis_hgt,gclat,gclon,l0,ras,decl
   PRINT,''
   PRINT,' Original base code:  UVIPTG'
   PRINT,' 7/31/95  Author:  G. Germany'
   PRINT,' Development into PTG: 01/15/98'
   PRINT,' Authors:  Mitch Brittnacher & John O''Meara'
   PRINT,'           changed into fuv_ptg_mod by Harald Frey, 01/05/2000'
   PRINT,''
   PRINT,' calculates geocentric lat,lon, for a complete image
   PRINT,'
   PRINT,' input
   PRINT,'    image_info_for_instrument   structure which contains all values
   PRINT,'    				for pointing calculation
   PRINT,'    vname           name of the variable in the structure to plot 
   PRINT,'    time            time(1)=yyyyddd, time(2)=msec of day
   PRINT,'    emis_hgt        los altitude
   PRINT,'
   PRINT,' output
   PRINT,'	  l0		  look direction in gci for central pixel
   PRINT,'    ras		  RA for central pixel
   PRINT,'	  decl		  DEC for central pixel
   PRINT,'    gclat           geocentric latitude
   PRINT,'    gclon           geocentric longitude
   PRINT,'
   PRINT,' keywords
   PRINT,'    geodetic        (set) returns geodetic values if set
   PRINT,'    getra           (set) calculates ra & dec if set
   PRINT,'       ra           (out) right ascension (deg)
   PRINT,'      dec           (out) declination (deg)
   PRINT,'        s           (out) scalar for lpix
   PRINT,'    lpixX           (out) x component of unit look direction
   PRINT,'    lpixY           (out) y component of unit look direction
   PRINT,'    lpixZ           (out) z component of unit look direction
   PRINT,'     posX           (out) x,y,z components of vector from
   PRINT,'     posY           (out)       earth center to emission
   PRINT,'     posZ           (out)
   PRINT,'  versStr           (out) software version string
   PRINT,'     orbpos         (in) hfrey, added 10/23/2000 orb pos in gci.
   PRINT,'     record_number  (in) hfrey, added 10/23/2000 record number.
   PRINT,'     earthlat       (out) hfrey, added 10/23/2000 center of proj.
   PRINT,'     earthlon       (out) hfrey, added 10/23/2000 center of proj.
   PRINT,'
   PRINT,' external library routines required
   PRINT,'    ic_gci_to_geo
   PRINT,'    fuv_rotation_matrix
   PRINT,'
   PRINT,' NOTES:
   PRINT,'
   PRINT,' 1. Unlike UVIPTG, this routine returns latitude and longitude
   PRINT,'    for all pixels in an image.  It does the calculation in a
   PRINT,'    fraction of the time required by UVIPTG.
   PRINT,'
   PRINT,' 2. The default lat/lon values are in geocentric coordinates.
   PRINT,'    Geographic (geocentric) coordinates assume the earth is
   PRINT,'    a sphere and are defined from the center of the sphere.
   PRINT,'    For geodetic coordinates, the earth is assumed to be an
   PRINT,'    ellipsoid of revolution.  See the routine fgeode for
   PRINT,'    details.
   PRINT,'    Geodetic coordinates are defined from the normal to the
   PRINT,'    geode surface.  To enable geodetic calculations, set the
   PRINT,'    keyword /GEODETIC.
   PRINT,'
   PRINT,' 3. The look direction for a specified pixel (Lpix) is
   PRINT,'    calculated from the rotation matrix provided by the
   PRINT,'    routine fuv_rotation_matrix.
   PRINT,'    Each pixel is assumed to have
   PRINT,'    a fixed angular width.  The angular distance from the center
   PRINT,'    of the pixel to the center of the fov is calculated and then
   PRINT,'    the look direction of this pixel is determined.
   PRINT,'
   PRINT,' 4. Geocentric lat/lon values are the intersection
   PRINT,'    of the look direction for the specified pixel (Lpix) and
   PRINT,'    the surface of the earth.  The geocentric values are then
   PRINT,'    transformed into geodetic values.  The vector from the
   PRINT,'    center of the earth to the intersection is pos so that
   PRINT,'    pos = orb + S*Lpix, where orb is the GCI orbit vector
   PRINT,'    and S is a scalar.
   PRINT,'
   PRINT,' 5. The intersection of Lpix and the earth is calculated first
   PRINT,'    in GCI coordinates and then converted to geographic
   PRINT,'    coordinates.  The conversion is by means of ic_gci_to_geo.
   PRINT,'    This routine and its supporting routines, was taken from
   PRINT,'    the CDHF and is part of the ICSS_TRANSF_orb call.
   PRINT,'
   PRINT,' 6. The viewed emissions are assumed to originate emis_hgt km
   PRINT,'    above the surface of the earth.  See get_scalar for details.
   PRINT,'
   PRINT,' 7. The keywords POS(xyz) are needed for LOS corrections.
   PRINT,'
   RETURN
ENDIF

; here we define individual variables
; this may look ugly, but we use as much of the old ptg.pro as possible
; ; hfrey hard coded
; RCJ added code to look for .DAT or .HANDLE for each variable 02/2001
       
;Determine the field number associated with the variable 'vname'
w = where(tag_names(image_info_for_instrument) eq strupcase(vname),wc)
if (wc eq 0) then begin
   print,'ERROR= (In fuv_ptg_mod.pro) No variable with the name:',vname & return
endif else vnum = w(0)
 
        
d = tagindex('DAT',tag_names(image_info_for_instrument.(vnum)))
if (d(0) ne -1) then idat = image_info_for_instrument.(vnum).DAT $
else begin
   d = tagindex('HANDLE',tag_names(image_info_for_instrument.(vnum)))
   if (d(0) ne -1) then handle_value,image_info_for_instrument.(vnum).HANDLE,idat $
   else begin
      print,'ERROR= (In fuv_ptg_mod.pro) Parameter does not have DAT or HANDLE tag' & return
   endelse
endelse
       

nrows = n_elements(idat[1,*])
ncols = n_elements(idat[0,*])

angle_res_r=17.2/nrows
angle_res_c=17.2/ncols

d = tagindex('DAT',tag_names(image_info_for_instrument.epoch))
if (d(0) ne -1) then edat = image_info_for_instrument.epoch.DAT $
else begin
   d = tagindex('HANDLE',tag_names(image_info_for_instrument.epoch))
   if (d(0) ne -1) then handle_value,image_info_for_instrument.epoch.HANDLE,edat $
   else begin
      print,'ERROR= (In fuv_ptg_mod.pro) Parameter does not have DAT or HANDLE tag' & return
   endelse
endelse

cdf_epoch,edat[record_number],y_,m_,d_,h_,mi_,s_,/break
;print,'INFO>fuv_ptg_mod>Time: ',fix([y_,m_,d_,h_,mi_,s_])
result=get_doy(d_,m_,y_)

inst_angles=get_inst_angles_new(0,y_,result)
omega = inst_angles[2]
theta = inst_angles[1]
phi   = inst_angles[0]

        
;d = tagindex('DAT',tag_names(image_info_for_instrument.vfov))
;if (d(0) ne -1) then vfov_dat = image_info_for_instrument.vfov.DAT $
;else begin
;   d = tagindex('HANDLE',tag_names(image_info_for_instrument.vfov))
;   if (d(0) ne -1) then handle_value,image_info_for_instrument.vfov.HANDLE,vfov_dat $
;      else begin
;      print,'ERROR= image_info_for_instrument.vfov does not have DAT or HANDLE tag' & return
;   endelse
;endelse

;angle_res_r = vfov_dat/nrows

;d = tagindex('DAT',tag_names(image_info_for_instrument.hfov))
;if (d(0) ne -1) then hfov_dat = image_info_for_instrument.hfov.DAT $
;else begin
;   d = tagindex('HANDLE',tag_names(image_info_for_instrument.hfov))
;   if (d(0) ne -1) then handle_value,image_info_for_instrument.hfov.HANDLE,hfov_dat $
;      else begin
;      print,'ERROR= image_info_for_instrument.hfov does not have DAT or HANDLE tag' & return
;   endelse
;endelse
        
;d = tagindex('DAT',tag_names(image_info_for_instrument.fovscale))
;if (d(0) ne -1) then fovscale_dat = image_info_for_instrument.fovscale.DAT $
;else begin
;   d = tagindex('HANDLE',tag_names(image_info_for_instrument.fovscale))
;   if (d(0) ne -1) then handle_value,image_info_for_instrument.fovscale.HANDLE,fovscale_dat $
;      else begin
;      print,'ERROR= image_info_for_instrument.fovscale does not have DAT or HANDLE tag' & return
;   endelse
;endelse
        
;angle_res_c = hfov_dat*fovscale_dat/ncols

;angle_res_r=17.2/nrows
;angle_res_c=17.2/ncols

d = tagindex('DAT',tag_names(image_info_for_instrument.scsv_x))
if (d(0) ne -1) then scsv_xdat = image_info_for_instrument.scsv_x.DAT $
else begin
   d = tagindex('HANDLE',tag_names(image_info_for_instrument.scsv_x))
   if (d(0) ne -1) then handle_value,image_info_for_instrument.scsv_x.HANDLE,scsv_xdat $
      else begin
     print,'ERROR= image_info_for_instrument.scsv_x does not have DAT or HANDLE tag' & return
   endelse
endelse
 
d = tagindex('DAT',tag_names(image_info_for_instrument.scsv_y))
if (d(0) ne -1) then scsv_ydat = image_info_for_instrument.scsv_y.DAT $
else begin
   d = tagindex('HANDLE',tag_names(image_info_for_instrument.scsv_y))
   if (d(0) ne -1) then handle_value,image_info_for_instrument.scsv_y.HANDLE,scsv_ydat $
      else begin
     print,'ERROR= image_info_for_instrument.scsv_y does not have DAT or HANDLE tag' & return
   endelse
endelse
 
d = tagindex('DAT',tag_names(image_info_for_instrument.scsv_z))
if (d(0) ne -1) then scsv_zdat = image_info_for_instrument.scsv_z.DAT $
   else begin
   d = tagindex('HANDLE',tag_names(image_info_for_instrument.scsv_z))
   if (d(0) ne -1) then handle_value,image_info_for_instrument.scsv_z.HANDLE,scsv_zdat $
      else begin
     print,'ERROR= image_info_for_instrument.scsv_z does not have DAT or HANDLE tag' & return
   endelse
endelse

scsv_x = scsv_xdat[record_number]
scsv_y = scsv_ydat[record_number]
scsv_z = scsv_zdat[record_number]
 
 
d = tagindex('DAT',tag_names(image_info_for_instrument.sv_x))
if (d(0) ne -1) then sv_xdat = image_info_for_instrument.sv_x.DAT $
else begin
   d = tagindex('HANDLE',tag_names(image_info_for_instrument.sv_x))
   if (d(0) ne -1) then handle_value,image_info_for_instrument.sv_x.HANDLE,sv_xdat $
      else begin
     print,'ERROR= image_info_for_instrument.sv_x does not have DAT or HANDLE tag' & return
   endelse
endelse
 
d = tagindex('DAT',tag_names(image_info_for_instrument.sv_y))
if (d(0) ne -1) then sv_ydat = image_info_for_instrument.sv_y.DAT $
else begin
   d = tagindex('HANDLE',tag_names(image_info_for_instrument.sv_y))
   if (d(0) ne -1) then handle_value,image_info_for_instrument.sv_y.HANDLE,sv_ydat $
      else begin
     print,'ERROR= image_info_for_instrument.sv_y does not have DAT or HANDLE tag' & return
   endelse
endelse
 
d = tagindex('DAT',tag_names(image_info_for_instrument.sv_z))
if (d(0) ne -1) then sv_zdat = image_info_for_instrument.sv_z.DAT $
else begin
   d = tagindex('HANDLE',tag_names(image_info_for_instrument.sv_z))
   if (d(0) ne -1) then handle_value,image_info_for_instrument.sv_z.HANDLE,sv_zdat $
      else begin
     print,'ERROR= image_info_for_instrument.sv_z does not have DAT or HANDLE tag' & return
   endelse
endelse
        
sc_x = sv_xdat[record_number]
sc_y = sv_ydat[record_number]
sc_z = sv_zdat[record_number]

d = tagindex('DAT',tag_names(image_info_for_instrument.spinphase))
if (d(0) ne -1) then sphase_dat = image_info_for_instrument.spinphase.DAT $
   else begin
   d = tagindex('HANDLE',tag_names(image_info_for_instrument.spinphase))
   if (d(0) ne -1) then handle_value,image_info_for_instrument.spinphase.HANDLE,sphase_dat $
      else begin
     print,'ERROR= image_info_for_instrument.spinphase does not have DAT or HANDLE tag' & return
   endelse
endelse

psi = sphase_dat[record_number] ; in degrees

d = tagindex('DAT',tag_names(image_info_for_instrument.orb_x))
if (d(0) ne -1) then oxdat = image_info_for_instrument.orb_x.DAT $
else begin
   d = tagindex('HANDLE',tag_names(image_info_for_instrument.orb_x))
   if (d(0) ne -1) then handle_value,image_info_for_instrument.orb_x.HANDLE,oxdat $
   else begin
      print,'ERROR= image_info_for_instrument.orb_x does not have DAT or HANDLE tag' & return
   endelse
endelse

d = tagindex('DAT',tag_names(image_info_for_instrument.orb_y))
if (d(0) ne -1) then oydat = image_info_for_instrument.orb_y.DAT $
else begin
   d = tagindex('HANDLE',tag_names(image_info_for_instrument.orb_y))
   if (d(0) ne -1) then handle_value,image_info_for_instrument.orb_y.HANDLE,oydat $
   else begin
      print,'ERROR= image_info_for_instrument.orb_y does not have DAT or HANDLE tag' & return
   endelse
endelse
d = tagindex('DAT',tag_names(image_info_for_instrument.orb_z))
if (d(0) ne -1) then ozdat = image_info_for_instrument.orb_z.DAT $
else begin
   d = tagindex('HANDLE',tag_names(image_info_for_instrument.orb_z))
   if (d(0) ne -1) then handle_value,image_info_for_instrument.orb_z.HANDLE,ozdat $
   else begin
      print,'ERROR= image_info_for_instrument.orb_z does not have DAT or HANDLE tag' & return
   endelse
endelse


Ox = oxdat[record_number]
Oy = oydat[record_number]
Oz = ozdat[record_number]        

versStr = 'FUV_PTG_mod v2.0  5/2001'
zrot  = DBLARR(ncols,nrows)
yrot  = DBLARR(ncols,nrows)
gclat = DBLARR(ncols,nrows)
gclon = DBLARR(ncols,nrows)
ra    = DBLARR(ncols,nrows)
dec   = DBLARR(ncols,nrows)

fill_value = -1.D31

;... single pixel angular resolution
pr = angle_res_r       ; determined from fov of WIC or SI
pc = angle_res_c       ; same

;... initialize output arrays to default
gclat(*,*) = fill_value
gclon(*,*) = fill_value
ra(*,*) = fill_value
dec(*,*) = fill_value

;... find rotation angles for each pixel
;    Remember, this is a modification of a routine used for polar/uvi data....
;    unless in uvilook, the axis definition is different for FUV
;    UVI defined the image axes as
;
;              UVI			FUV
;	zrot going horizontally		xrot going horizontally
;	yrot going vertically		yrot going vertically
;	x    going outward		z    going inward as photons

a = (FINDGEN(ncols)- (ncols-1)/2)*pc
b = REPLICATE(1.,nrows)
xrot = a#b
c = (FINDGEN(nrows)- (nrows-1)/2)*pr
d = REPLICATE(1.,ncols)
yrot = d#c

;Determine Lpix
tanx = tan(xrot*!DPI/180d)
tany = tan(yrot*!DPI/180d)

lpz = -1.D /SQRT(1.D + tany*tany + tanx*tanx)
lpx = -lpz*tanx
lpy = -lpz*tany

;... call the routine which determines the rotation matrix
;omega = -0.05
;theta = 0.94
;phi   = 43.26
transformation_matrix = fuv_rotation_matrix(omega,theta,phi, $
        scsv_x,scsv_y,scsv_z,sc_x,sc_y,sc_z,psi)

;... validate the transformation matrix (rburley 1/9/2001)
if amia_transformation_matrix(transformation_matrix) eq 0 then begin
   print,'WARNING>FUV_PTG_MOD>Invalid transformation matrix>',time
   return ; this premature return will cause earthlat and earthlon to
       ; be undefined.
endif
        
;... apply rotation

result = transformation_matrix ## [[lpx[*]],[lpy[*]],[lpz[*]]]

;... determine Lpix

LpixX = reverse(reform(result[*,0],ncols,nrows),1)
LpixY = reverse(reform(result[*,1],ncols,nrows),1)
LpixZ = reverse(reform(result[*,2],ncols,nrows),1)

;    calculate right ascension and declination
IF(KEYWORD_SET(getra)) THEN vector_to_ra_decP,LpixX,LpixY,LpixZ,ra,dec

earth_center_rec=180.d/!dpi*atan(-orbpos[1],-orbpos[0])
earth_center_dec=180.d/!dpi*atan(-orbpos[2]/sqrt(orbpos[0]^2+orbpos[1]^2))
starrec=[earth_center_rec,186.658,184.617,182.097,204.980,210.965,196.577,$
   191.939,183.794]
stardec=[earth_center_dec,-63.102,-64.006,-50.725,-53.468,-60.375,-48.466,$
	-59.691,-58.751]
starsx=([128.0,19.78,4.65,197.83,153.68,42.22,235.75,$
	0.,0.]- (ncols-1)/2)*pc
starsy=([128.0,72.31,60.29,11.20,220.15,246.20,148.90,$
	0.,0.]- (nrows-1)/2)*pr

; convert star positions into x,y,z
starnum=n_elements(stardec)
f_lpixx=cos(!dtor*stardec)*cos(!dtor*starrec)
f_lpixy=cos(!dtor*stardec)*sin(!dtor*starrec)
f_lpixz=sin(!dtor*stardec)
f_res=dblarr(starnum,3)
f_res[*,0]=f_lpixx
f_res[*,1]=f_lpixy
f_res[*,2]=f_lpixz
f_lpx=transpose(transformation_matrix) ## f_res
f_lpx=reform(f_lpx,starnum,3)
n_startanx=-sqrt((1.-f_lpx[*,1]^2-f_lpx[*,2]^2) > 0.)/f_lpx[*,2]*f_lpx[*,0]/abs(f_lpx[*,0])
n_startany=-sqrt((1.-f_lpx[*,0]^2-f_lpx[*,2]^2) > 0.)/f_lpx[*,2]*f_lpx[*,1]/abs(f_lpx[*,1])
n_starsxrot=atan(n_startanx)*!radeg
n_starsyrot=atan(n_startany)*!radeg
new_starsx=n_starsxrot/pc+ (nrows-1)/2
new_starsy=n_starsyrot/pr+ (nrows-1)/2

;... Find scalar (s) such that s*L0 points to
;    the imaged emission source.  If the line of
;    sight does not intersect the earth s=0.0
fuv_get_scalarP,Ox,Oy,Oz,LpixX,LpixY,LpixZ,emis_hgt,ncols,nrows,s,f, $
           off_axis,num_off_axis

posX = Ox + s*LpixX
posY = Oy + s*LpixY
posZ = Oz + s*LpixZ

;... Convert from GCI to GEO coordinates.  ROTM is the
;    rotation matrix.
ic_gci_to_geo,time,rotm
p_geoX = rotm(0,0)*posX + rotm(1,0)*posY + rotm(2,0)*posZ
p_geoY = rotm(0,1)*posX + rotm(1,1)*posY + rotm(2,1)*posZ
p_geoZ = rotm(0,2)*posX + rotm(1,2)*posY + rotm(2,2)*posZ

;... Get geocentric lat/lon.  this converts from
;    a 3 element vector to two angles: lat & longitude
fuv_drtollP,p_geoX,p_geoY,p_geoZ,gclat,gclon,r
gclat = gclat < 90.

;... Convert to geodetic lat/lon.  F is the flattening
;    factor of the Earth.  See get_scalar for details.
;    Ref: Spacecraft Attitude Determination and Control,
;    J.R. Wertz, ed., 1991, p.821.
IF(KEYWORD_SET(geodetic)) THEN BEGIN
   gdlat = 90.D + 0.D * gclat
   ndx = WHERE(gclat LT 90.,count)
   IF(count GT 0) THEN BEGIN
      gdlat(ndx) = datand(dtand(gclat(ndx))/((1.D - f)*(1.D - f)))
   ENDIF
   gclat = gdlat
ENDIF

IF (num_off_axis GT 0) THEN BEGIN
   gclat(off_axis) = fill_value
   gclon(off_axis) = fill_value
ENDIF

;... provide some more output variables, at the moment I don't know if they
;	are really necessary, but who knows?

l0=[LpixX[ncols/2-1,nrows/2-1], $
    LpixY[ncols/2-1,nrows/2-1], $
    LpixZ[ncols/2-1,nrows/2-1]]
ras = 0d
decl = 0d
vector_to_ra_decP,l0[0],l0[1],l0[2],ras,decl

;... calculate the geographic coordinate of center of projection,
;    this is not the center of the image, as we apply sometimes an 
;    offset to limb. The output earthlat and earthlon are used in 
;    auroral_image.


earth_x=-ox/sqrt(ox^2+oy^2+oz^2)
earth_y=-oy/sqrt(ox^2+oy^2+oz^2)
earth_z=-oz/sqrt(ox^2+oy^2+oz^2)
fuv_get_scalarP,Ox,Oy,Oz,earth_x,earth_y,earth_z,emis_hgt,1,1,$
            sres,f_earth,off_array,num_off
pos_earth_X = Ox + sres*earth_x
pos_earth_Y = Oy + sres*earth_y
pos_earth_Z = Oz + sres*earth_z
p_earthX = rotm(0,0)*pos_earth_X + rotm(1,0)*pos_earth_Y + rotm(2,0)*pos_earth_Z
p_earthY = rotm(0,1)*pos_earth_X + rotm(1,1)*pos_earth_Y + rotm(2,1)*pos_earth_Z
p_earthZ = rotm(0,2)*pos_earth_X + rotm(1,2)*pos_earth_Y + rotm(2,2)*pos_earth_Z
fuv_drtollP,p_earthX,p_earthY,p_earthZ,earthlat,earthlon,earthr
earthlat = earthlat < 90.

END


