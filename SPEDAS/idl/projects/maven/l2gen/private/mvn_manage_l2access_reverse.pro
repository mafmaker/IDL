;+
;NAME:
; mvn_manage_l2access_reverse
;PURPOSE:
; moves htaccess_insecure links for the MAVEN PFP data located here at
; SSL. For each instrument data directory, the .htaccess file protects
; that directory from access, requiring a password. (See
; /disks/data/maven/pfp/.hidden/README.html) In each released monthly
; directory, there will be a link to
; /disks/data/maven/data/sci/pfp/.hidden/.htaccess.release, which should
; override the protection at the "top" or "instrument" level.  Run
; this as muser, be careful to preview when you first run it.  The
; release date is now calculated, every 3 months starting with
; 2015-02-01. The latest release date is used, or can be passed in as
; a keyword.
;CALLING SEQUENCE:
; mvn_manage_l2access_reverse, instr
;INPUT:
; instr = A PFP instrument, ['euv', 'iuv', 'kp', 'lpw', 'mag', 'ngi',
;                            'pfp', 'sep', 'sta', 'swe', 'swi'] 
;KEYWORDS:
; preview = Just print messsages about what will happen, don't
;           delete or spawn
; release_date_in = set this as the rleease date, this allows reversion if we
;           want to un-release files. 
;HISTORY:
; 2015-07-13, jmm, jimm@ssl.berkeley.edu
; 2015-09-03, jmm, hard-coded date.
; 2015-09-30, jmm, Un hard-coded the date
; 2015-10-05, jmm, Added the release_date_in keyword
; 2015-10-30, jmm, Much better version from Davin's idea: keeps
;             protection at instrument level, and turns off for 
;             released months
; 2015-11-05, jmm, Dperecated, and renamed
; $LastChangedBy: jimm $
; $LastChangedDate: 2015-11-05 12:59:48 -0800 (Thu, 05 Nov 2015) $
; $LastChangedRevision: 19272 $
; $URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/spdsoft/trunk/projects/maven/l2gen/private/mvn_manage_l2access_reverse.pro $
;-
Pro mvn_manage_l2access_reverse, instr, preview=preview, $
                                 release_date_in = release_date_in
;  preview = 1                   ;temporary for testing
; get the appropriate month, start with 2014
  If(keyword_set(release_date_in)) Then Begin
     rdate = time_string(release_date_in)
     yy = strmid(time_string(rdate), 0, 4)
     mm = strmid(time_string(rdate), 5, 2)
     date = time_double(yy+'-'+mm+'-01/00:00:00')
  Endif Else Begin
     now = systime(/sec)
     yy = long(strmid(time_string(now), 0, 4))
     dyy = yy-2014+2
     yy_arr = string(2014+indgen(dyy), format = '(i4.4)')
;Releases happen every 3 months
     mm = ['02', '05', '08', '11']
     For j = 0, dyy-1 Do Begin
        If(j eq 0) Then yymm = yy_arr[j]+'-'+mm $
        Else yymm = [yymm, yy_arr[j]+'-'+mm]
     Endfor
     trelease = time_double(yymm+'-01/00:00:00')
     xtime = max(where(trelease lt now))
     If(xtime[0] Eq -1) Then Begin
        dprint, 'No trelease date, returning'
        Return
     Endif
;Date is 
     date = trelease[xtime]
  Endelse
  time_in = time_double(date)

;Data directory is hard-wired here:
  data_dir = '/disks/data/maven/data/sci/'
;The htaccess file to be linked to:
  htfile = '/disks/data/maven/data/sci/pfp/.hidden/.htaccess.release'

  instr0 = strcompress(/remove_all, strlowcase(instr[0]))
  test_dir = file_search(data_dir+instr0, /mark_directory, /test_directory)
  If(~is_string(test_dir)) Then Begin
     dprint, 'Bad directory input?'
     Return
  Endif
;Work with subdirectories
  subdirs = file_search(test_dir+'*', /mark_directory, /test_directory)
;Only process directories starting with "l2". Descend through the
;monthly sub-sub-directories and place .htaccess links prior to the
;input month
  subdirs0 = file_basename(subdirs)
  qll2_test = strmid(subdirs0, 0, 2)
  nsd = n_elements(subdirs0)
  For j = 0, nsd-1 Do Begin
     If(qll2_test[j] Eq 'l2') Then Begin
;Here descend through the monthly files, should work until 2099...
        sdj = file_search(subdirs[j], '20??/??', /mark_directory, /test_directory)
        If(~is_string(sdj)) Then Begin
           message, /info, 'Not Processing: '+subdirs[j]
           continue             ;nothing to see here, move along
        Endif
        nmonths = n_elements(sdj)
        For k = 0, nmonths-1 Do Begin
;Extract the year and month
           ppp = strsplit(sdj[k], '/', /extract)
           yyyy = ppp[n_elements(ppp)-2]
           mm = ppp[n_elements(ppp)-1]
;And get the date
           test_time = yyyy+'-'+mm+'-01/00:00:00'
;sdjk is the file to test for
           sdjk = sdj[k]+'.htaccess'
           If(time_double(test_time) Lt time_in) Then Begin
;Here I want to keep the file if it exists, and create the link if not
              If(~is_string(file_search(sdjk))) Then Begin
                 cmdjk = 'ln -s '+htfile+' '+sdjk
                 message, /info, 'Spawning: '+cmdjk
                 If(~keyword_set(preview)) Then spawn, cmdjk
              Endif Else message, /info, 'File exists: '+sdjk
           Endif Else Begin
;Here I want to check for the link, and delete it if it exists
              If(is_string(file_search(sdjk))) Then Begin
                 message, /info, 'Deleting: '+sdjk
                 If(~keyword_set(preview)) Then file_delete, sdjk
              Endif Else message, /info, 'No file: '+sdjk+' copied'
           Endelse
        Endfor                  ;k, monthly files
     Endif
  Endfor                        ;j, subdirs

  Return
End


  
  

