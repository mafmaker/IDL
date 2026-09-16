pro wi_h1_wav_load,INDIR=INDIR
;
; Look for all rad1 files in the current directory
; it is required that they is a corresponding rad2 and tnr data
; for a cdf to be created for that day.
;
file_spec = ''
input_Dir = ''
if keyword_set(INDIR) then begin ; set tend
   input_Dir = indir + '/
endif
file_spec = input_Dir + "*.R1"

current_files = findfile(file_spec,count=num_files)
print,'Number of files',num_files

for i = 0,num_files-1 do begin
    wi_h1_wav_create_cdf,current_files[i],input_Dir
endfor

end
pro wi_h1_wav_create_cdf,path_name,indir
;
; arg1: path_name ==> complete path name for a rad1 file,
;                     rad2 and tnr must be there to complete.

x = strsplit(path_name,'/',/extract) 
filename_only = x[size(x,/N_ELEMENTS)-1]
y = strsplit(filename_only,'.',/extract)
time = y[0]

;
; Create the names of alll idl save set names
;

rad1_file = indir + time +  '.R1'
rad2_file = indir + time +  '.R2'
tmp = findfile(rad2_file,count=cnt)
if (cnt eq 0) then begin
    print,'Unable able to find expected rad2 file ',rad2_file,' skipping ',time
    return
endif
tnr_file  = indir + time +  '.tnr'
tmp = findfile(tnr_file,count=cnt)
if (cnt eq 0) then begin
    print,'Unable able to find expected rad2 file ',rad2_file,' skipping ',time
    return
endif

;rad2_file = 'wi_wav_rad2_' + time +  '_v01.idl'
;tnr_file = 'wi_wav_tnr_' + time +  '_v01.idl'
;
; Create output cdfname
;
out_cdf = 'wi_h1_wav_' + time + '_v01.cdf'


buf1 = read_master_cdf('/home/cdaweb/data/0MASTERS/wi_h1_wav_00000000_v01.cdf',out_cdf)
;buf1 = read_master_cdf('/ncf/rumba1/istp/0MASTERS/wi_h1_wav_00000000_v01.cdf',out_cdf)
;buf1 = read_master_cdf('wi_h1_wav_00000000_v01.cdf',out_cdf)
;
;restore IDL save set for RAD1 containing the data values for some variables
;
restore,rad1_file
;
;
; the data structure is 1441 records by 256 Voltage values.
; 1440 1 minutes records containing the Voltage values for 
; the day and record 1441 contains the mimimum voltage values
; for the entire day
;
; Records structure incompatible with CDF-IDL interface, the 
; number of records are contained in the first dimension.  It
; needs to be in the last dimension.  The transpose function will
; convert the array
;  
; 

Voltage_RAD1 = transpose(arrayb[0:1439,*])
;
; Minimum Voltage data is contained in the record 1441
;
minVoltage_RAD1 = transpose(arrayb[1440,*])

;
; get the year,month, and day and convert to integer
;
y = fix(strmid(time,0,4))
m = fix(strmid(time,4,2))
d = fix(strmid(time,6,2))
;
; Generate Epoch for the entire day (1440 1 minute records)
;

Epoch = dblarr(1440)

tmin = 0
for hr = 0, 23 do begin
    for minute = 0,59  do begin
        cdf_epoch,Ep,y,m,d,hr,minute,30,0, /compute_epoch
        Epoch[tmin] = Ep
        tmin = tmin+1
    endfor
endfor
;
; epoch2 will be a single record at hour 12 of the current day
; the minimum voltage data will point to this time
;
cdf_epoch,medEpoch,y,m,d,12,0,0,0, /compute_epoch

;
; Repeat the process for RAD2 and TNR, but no times need to be entered
; 

restore,rad2_file
Voltage_RAD2 = transpose(arrayb[0:1439,*])
minVoltage_RAD2 = transpose(arrayb[1440,*])

restore,tnr_file
Voltage_TNR = transpose(arrayb[0:1439,*])
minVoltage_TNR = transpose(arrayb[1440,*])

;; Now set the buf1 structure data pointers for each variable to the appropriate
;; data arrays/values.
;
*buf1.Epoch.data = Epoch
*buf1.E_VOLTAGE_RAD1.data = Voltage_RAD1
*buf1.MINIMUM_VOLTAGE_RAD1.data = minVoltage_RAD1
*buf1.E_VOLTAGE_RAD2.data = Voltage_RAD2
*buf1.MINIMUM_VOLTAGE_RAD2.data = minVoltage_RAD2
*buf1.E_VOLTAGE_TNR.data = Voltage_TNR
*buf1.MINIMUM_VOLTAGE_TNR.data = minVoltage_TNR
*buf1.Epoch2.data = medEpoch


;
;;write data in the above pointers back out to our new cdf
;
;!quiet=0
print,"Creating: ",out_cdf
stat2 = write_data_to_cdf(out_cdf, buf1)

end




