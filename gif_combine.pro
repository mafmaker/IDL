spawn,'ls s12*.gif',s12list
spawn,'ls wic*.gif',wiclist


read_gif,s12list(0),s12,r,g,b

s12r=congrid(r,128)
s12g=congrid(g,128)
s12b=congrid(b,128)

read_gif,wiclist(0),wic,r,g,b

wicr=congrid(r,128)
wicg=congrid(g,128)
wicb=congrid(b,128)

rr=[wicr,s12r]
gg=[wicb,s12b]
bb=[wicb,s12b]


gifbuffer=bytarr(1024,512)

for i=0,n_elements(s12list) do begin

  read_gif,wiclist(i),wic,r,g,b
  read_gif,s12list(i),s12,r,g,b

  gifbuffer(0:511,*)=wic/2
  gifbuffer(512:1023,*)=s12/2 + 128

  write_gif,'gem' + strcompress(i,/rem) + '.gif',gifbuffer,rr,gg,bb

  gifbuffer(*)=0b

endfor

;tvlct,rr,gg,bb
;tvscl,gifbuffer

end