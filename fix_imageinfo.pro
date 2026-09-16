pro fix_imageinfo,imageinfo

;
;  procedure to fix infernal array transpositions in structure
;  assume handed a 0-d structure array

imageinfo.image=rotate(imageinfo.image,3)
imageinfo.glat=reverse(imageinfo.glat,1)
imageinfo.glon=reverse(imageinfo.glon,1)
imageinfo.mlt=reverse(imageinfo.mlt,1)
imageinfo.mlat=reverse(imageinfo.mlat,1)

return
end