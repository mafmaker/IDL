pro atest


vinst      = 'IMMSTATS'
start_date = [2004,70,2,30]
end_date   = [2004,70,2,33]


 ;Convert the given VINST to a full [PROJECT,MISSION,EXPERIMENT,etc].
 ;From that, obtain a UDF "key"
 ;key = udf_key(vinst_to_full_path(vinst, _Extra=_e))

 key = udf_key(['IMAGE','IMAGE1','MENA','MENASCI',vinst])


;       Open the UDF access.  If it fails, bomb out nicely, and return scalar -1

    fh = udf_open(key, start_date, end_date, _Extra=_e)

;       MAIN LOOP:
;       Keep reading until we see EOF.  The "l" array is a simple concatenated
;       list of data structures; "lrec" points to the current record number.

 lrec = 0UL
 WHILE NOT udf_eof(fh) DO BEGIN

    d = udf_read(fh)

;       First time through: define "l" as an array of "d" structures

    IF N_Elements(l) EQ 0 THEN l = replicate(d, 16)

;       If we're out of space in "l", allocate twice as much space.  This
;       is a _lot_ more efficient than adding records one-at-a-time.

    IF lrec GE N_Elements(l) THEN l = [l,l]

;       Store the record we just read, and increment the position pointer.

    l[lrec] = d
    lrec = lrec + 1

  ENDWHILE
 udf_close, fh

 IF lrec EQ 0 THEN BEGIN
    PRINT,  "No records read in. Try something else."
    EXIT
 ENDIF

;       Reduce the list to only those records read in.

 d = l[0:lrec-1]

 l = 0

 Print, lrec,vinst, format='("[",I0," ",A," records read]")'
 Print, " "

print,d[0:30].coarse_azimuth[0]
print," "
help,name="udf",/dlm

save, file='atest.idl'

end ;atest
