pro image_altitude,imageinfo,alt

;   program to return the altitude of the image satellite
;   using information in the imageinfo structure. Number
;   is returned in RE. (~6340 km)
;
alt=sqrt(total(imageinfo.o_gci^2))/6340.
end
