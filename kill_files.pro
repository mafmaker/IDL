;
; Program to remove WIC files which have no partner in either SI, and vice-versa
;
;

spawn,'ls wic*.idl',wiclist
spawn,'ls s12*.idl',s12list
spawn,'ls s13*.idl',s13list

help,wiclist,s12list,s13list

for i=0,1000 do begin

  print,wiclist(i),s12list(i),s13list(i)

endfor

end
