pro gut_filename,filename,ext,main

;    Purpose:given an evil filename like this.file.is.too.damn.long
;            will return the _final_ extension. (here, long)
;
;    version history 
;    1.0   -  release
;    1.01  -  returns extension and main string

  counter=0
  truth=0
  gutfilename=filename

  while truth ge 0 do begin
    position=strpos(gutfilename,'.')
    counter=position+counter+1
    gutfilename=strmid(gutfilename,position+1,strlen(gutfilename))
    truth=strpos(gutfilename,'.')
  endwhile 

  ext=strmid(filename,counter ,strlen(filename)  )
  main=strmid(filename,0,counter-1)

  return

end