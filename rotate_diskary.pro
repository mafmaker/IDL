PRO ROTATE_DISKARY,DISKARY,SCA,newcount,nlines,inx,iny

;***The diskangles must be rotated st the cloac angle is zero at the subsolar
;point. This is done by subtraction. However, not all diskangles can be
;treated this way. Only diskangles in the limb region are to be rotated***

  in=where(newcount ne -1)
  inx= in mod nlines & iny= fix(in/nlines)
  Diskary(inx,iny)=diskary(inx,iny)-sca
  Fixit= where(diskary lt 0 and newcount ne -1)
  Fixitx= fixit mod nlines & Fixity= fix(fixit/nlines)
  Diskary(fixitx,fixity) = Diskary(fixitx,fixity)+360.0
end
