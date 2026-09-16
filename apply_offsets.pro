pro apply_offsets,maf,offset

;  program to apply offsets to all important coordinates 
;  given an imageinfo structure
;
;
    size_=size(maf.glat) & size_=size_(1)
    if offset gt 0 then begin
       maf.mlat(0:offset,*)=-1
       maf.mlt(0:offset,*)=-1
       maf.glat(0:offset,*)=-1
       maf.glon(0:offset,*)=-1
       maf.sza(0:offset,*)=-1
       maf.dza(0:offset,*)=-1
    endif else begin
       maf.mlat(size_-1+offset:size_-1,*)=-1
       maf.mlt(size_-1+offset:size_-1,*)=-1
       maf.glat(size_-1+offset:size_-1,*)=-1
       maf.glon(size_-1+offset:size_-1,*)=-1
       maf.dza(size_-1+offset:size_-1,*)=-1
       maf.sza(size_-1+offset:size_-1,*)=-1
    endelse

;---there is no shifting included yet, do this!

    maf.glat=shift(maf.glat,(-1) * offset)
    maf.glon=shift(maf.glon,(-1) * offset)
    maf.mlat=shift(maf.mlat,(-1) * offset)
    maf.mlt=shift(maf.mlt,(-1) * offset)
    maf.sza=shift(maf.sza,(-1) * offset)
    maf.dza=shift(maf.dza,(-1) * offset)

;---done shifting

end
