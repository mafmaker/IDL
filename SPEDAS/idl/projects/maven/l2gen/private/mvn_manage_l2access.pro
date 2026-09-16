;Helper function that will create
;directory names from 2014/10 until
;the end time input
Function mvn_temp_month_dir, end_time

  one_day = 24.0*3600.0d0
  t0 = time_double('2014-10-01/00:00:00')
  t1 = time_double(end_time)
  If(t1 Le 0) Then Return, ''
  ndays = ceil((t1-t0)/one_day)
  ttemp = t0+one_day*lindgen(ndays)
  months = strmid(time_string(ttemp), 0, 7)
  uu = uniq(months)
  months = ssw_str_replace(months[uu], '-', '/')
  Return, months
End

;+
;NAME:
; mvn_manage_l2access
;PURPOSE:
; moves htaccess links for the MAVEN PFP data located here at SSL. For
; each monthly data directory, the .htaccess file protects that
; directory from access, requiring a password. (See
; /disks/data/maven/pfp/.hidden/README.html)
; In each protected monthly directory, there should be a link
; .htpasswd linked to the master pasword file: .htaccess ->
; /disks/data/maven/pfp/.hidden/.htaccess.secure
; Run this as muser, be careful to preview when you first run it.
; The release date is now calculated, every 3 months starting with
; 2015-02-01. The latest release date is used.
;CALLING SEQUENCE:
; mvn_manage_l2access, instr
;INPUT:
; instr = A PFP instrument, ['euv', 'iuv', 'kp', 'lpw', 'mag', 'ngi',
;                            'pfp', 'sep', 'sta', 'swe', 'swi'] 
;KEYWORDS:
; preview = Just print messsages about what will happen, don't
;           delete or spawn
; release_date_in = set this as the rleease date, this allows
;                   reversion if we want to un-release files. 
; subdir_to_manage = if set, manage these subdirectories of the
;                    instrument directory. The default is to manage
;                    only directories that start with 'l2'. Un-managed
;                    directories are fully protected.
; use_end_date = if set, the create and protect monthly directories up
;                to an end date, either the current date, or a date
;                passed in with the end_date_int keyword.
; end_date_in = the date to protect monthly directories up until. He
;               default is to use the current date.
;EXAMPLE:
; for STATIC:
; mvn_manage_l2access, 'sta', /preview, release_date_in = '2015-09-01'
; OPEN UP THE INSTRUMENT DIRECTORY
;% MVN_MANAGE_L2ACCESS:Deleting:/disks/data/maven/data/sci/sta/.htaccess
; CHECK MONTHLY L2 DIRECTORIES, THEN SECURE THE ONES AFTER THE RELEASE DATE:
;% MVN_MANAGE_L2ACCESS: No file: /disks/data/maven/data/sci/sta/l2/2000/01/.htaccess needed
;% MVN_MANAGE_L2ACCESS: No file: /disks/data/maven/data/sci/sta/l2/2013/12/.htaccess needed
;% MVN_MANAGE_L2ACCESS: No file: /disks/data/maven/data/sci/sta/l2/2014/01/.htaccess needed
;% MVN_MANAGE_L2ACCESS: No file: /disks/data/maven/data/sci/sta/l2/2014/02/.htaccess needed
;% MVN_MANAGE_L2ACCESS: No file: /disks/data/maven/data/sci/sta/l2/2014/03/.htaccess needed
;% MVN_MANAGE_L2ACCESS: No file: /disks/data/maven/data/sci/sta/l2/2014/04/.htaccess needed
;% MVN_MANAGE_L2ACCESS: No file: /disks/data/maven/data/sci/sta/l2/2014/05/.htaccess needed
;% MVN_MANAGE_L2ACCESS: No file: /disks/data/maven/data/sci/sta/l2/2014/06/.htaccess needed
;% MVN_MANAGE_L2ACCESS: No file: /disks/data/maven/data/sci/sta/l2/2014/07/.htaccess needed
;% MVN_MANAGE_L2ACCESS: No file: /disks/data/maven/data/sci/sta/l2/2014/08/.htaccess needed
;% MVN_MANAGE_L2ACCESS: No file: /disks/data/maven/data/sci/sta/l2/2014/09/.htaccess needed
;% MVN_MANAGE_L2ACCESS: No file: /disks/data/maven/data/sci/sta/l2/2014/10/.htaccess needed
;% MVN_MANAGE_L2ACCESS: No file: /disks/data/maven/data/sci/sta/l2/2014/11/.htaccess needed
;% MVN_MANAGE_L2ACCESS: No file: /disks/data/maven/data/sci/sta/l2/2014/12/.htaccess needed
;% MVN_MANAGE_L2ACCESS: No file: /disks/data/maven/data/sci/sta/l2/2015/01/.htaccess needed
;% MVN_MANAGE_L2ACCESS: No file: /disks/data/maven/data/sci/sta/l2/2015/02/.htaccess needed
;% MVN_MANAGE_L2ACCESS: No file: /disks/data/maven/data/sci/sta/l2/2015/03/.htaccess needed
;% MVN_MANAGE_L2ACCESS: No file: /disks/data/maven/data/sci/sta/l2/2015/04/.htaccess needed
;% MVN_MANAGE_L2ACCESS: No file: /disks/data/maven/data/sci/sta/l2/2015/05/.htaccess needed
;% MVN_MANAGE_L2ACCESS: No file: /disks/data/maven/data/sci/sta/l2/2015/06/.htaccess needed
;% MVN_MANAGE_L2ACCESS: No file: /disks/data/maven/data/sci/sta/l2/2015/07/.htaccess needed
;% MVN_MANAGE_L2ACCESS: No file: /disks/data/maven/data/sci/sta/l2/2015/08/.htaccess needed
;% MVN_MANAGE_L2ACCESS: Spawning: ln -s /disks/data/maven/pfp/.hidden/.htaccess.secure /disks/data/maven/data/sci/sta/l2/2015/09/.htaccess
;% MVN_MANAGE_L2ACCESS: Spawning: ln -s /disks/data/maven/pfp/.hidden/.htaccess.secure /disks/data/maven/data/sci/sta/l2/2015/10/.htaccess
;% MVN_MANAGE_L2ACCESS: Spawning: ln -s /disks/data/maven/pfp/.hidden/.htaccess.secure /disks/data/maven/data/sci/sta/l2/2015/11/.htaccess
; PROTECT THE NON-L2 DIRECTORIES
;% MVN_MANAGE_L2ACCESS: Spawning: ln -s /disks/data/maven/pfp/.hidden/.htaccess.secure /disks/data/maven/data/sci/sta/ql/.htaccess
;% MVN_MANAGE_L2ACCESS: Spawning: ln -s /disks/data/maven/pfp/.hidden/.htaccess.secure /disks/data/maven/data/sci/sta/tplot/.htaccess
;
;HISTORY:
; 2015-07-13, jmm, jimm@ssl.berkeley.edu
; 2015-09-03, jmm, hard-coded date.
; 2015-09-30, jmm, Un hard-coded the date
; 2015-10-05, jmm, Added the release_date_in keyword
; 2015-11-05, jmm, Added the subdir_to_manage keyword
; 2015-11-17, jmm, Added use_end_date and end_date_in
; $LastChangedBy: jimm $
; $LastChangedDate: 2016-11-21 15:08:15 -0800 (Mon, 21 Nov 2016) $
; $LastChangedRevision: 22393 $
; $URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/spdsoft/trunk/projects/maven/l2gen/private/mvn_manage_l2access.pro $
;-
Pro mvn_manage_l2access, instr, preview=preview, $
                         release_date_in = release_date_in, $
                         use_end_date = use_end_date, $
                         end_date_in = end_date_in, $
                         subdir_to_manage = subdir_to_manage

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
;Releases happen every 3 months, but we are releasing the full month
;of the release date. So release files prior to month mm
     mm = ['02', '05', '08', '11']
;     mm = ['03', '06', '09', '12']
     For j = 0, dyy-1 Do Begin
        If(j eq 0) Then yymm = yy_arr[j]+'-'+mm $
        Else yymm = [yymm, yy_arr[j]+'-'+mm]
     Endfor
     yymm = shift(yymm, 1) & yymm[0] = yymm[1]
     trelease = time_double(yymm+'-01/00:00:00')
     xtime = max(where(trelease lt now))
     If(xtime[0] Eq -1) Then Begin
        dprint, 'No trelease date, returning'
        Return
     Endif 
;shift by one 3 month period -- the release date is 3 months prior to
;                               the value in yymm
     xtime = (xtime-1) > 0
;Date is 
     date = trelease[xtime]
  Endelse
  time_in = time_double(date)
  If(keyword_set(use_end_date)) Then Begin
     If(keyword_set(end_date_in)) Then end_date = time_double(end_date_in) $
     Else end_date = systime(/sec)
  Endif

;Data directory is hard-wired here:
  data_dir = '/disks/data/maven/data/sci/'
;THe global htaccess file to be linked to:
  htfile = '/disks/data/maven/pfp/.hidden/.htaccess.secure'

  instr0 = strcompress(/remove_all, strlowcase(instr[0]))
  test_dir = file_search(data_dir+instr0, /mark_directory, /test_directory)
  If(is_string(test_dir)) Then Begin
     If(instr0 Eq 'kp') Then Begin ;the 'kp' directory is different but we are not touching that yet.
     Endif Else Begin
;If there is an .htaccess link here, delete it
        test_global_htaccess = file_search(test_dir+'.htaccess')
        If(is_string(test_global_htaccess)) Then Begin
           dprint, 'Deleting: '+test_global_htaccess
           If(~keyword_set(preview)) Then file_delete, test_global_htaccess
        Endif
;Work with subdirectories
        subdirs = file_search(test_dir+'*', /mark_directory, /test_directory)
;Let's try this; for subdirectories *not* starting with 'l2' put the
;htaccess link into the subdirectory. Then everything is
;protected. Otherwise descend through the monthly sub-sub-directories
;and only place .htaccess links for the input month and after
;file_basename works here
        subdirs0 = file_basename(subdirs)
        qll2_test = strmid(subdirs0, 0, 2)
        nsd = n_elements(subdirs0)
        If(keyword_set(subdir_to_manage)) Then Begin
           subdirs_m = file_basename(subdir_to_manage) ;just in case there's a path
           ss_m = sswhere_arr(subdirs0, subdirs_m)
           If(ss_m[0] Eq -1) Then subdirs_m = '' ;Not managing these sbudirs
        Endif Else Begin
           ss_m = where(qll2_test Eq 'l2')
           If(ss_m[0] Ne -1) Then subdirs_m = subdirs0[ss_m] Else subdirs_m = ''
        Endelse
        For j = 0, nsd-1 Do Begin
;Looks like we have a special case for 'mag/ql' do not manage,
;also do'nt manage pfp/l0_all
           If(instr0 Eq 'mag' And subdirs0[j] Eq 'ql') Then Continue
           If(instr0 Eq 'pfp' And subdirs0[j] Eq 'l0_all') Then Continue
           manage = where(subdirs_m Eq subdirs0[j], okj) ;check to see if this subdir is to be managed
           If(okj Eq 0) Then Begin
              sdj = subdirs[j]+'.htaccess'
              If(~is_string(file_search(sdj))) Then Begin
                 cmdj = 'ln -s '+htfile+' '+sdj
                 dprint, 'Spawning: '+cmdj
                 If(~keyword_set(preview)) Then spawn, cmdj
              Endif Else dprint, 'File exists: '+sdj
           Endif Else Begin
;Here descend through the monthly files, should work until 2099...
              sdj = file_search(subdirs[j], '20??/??', /mark_directory, /test_directory)
              If(~is_string(sdj)) Then Begin
                 dprint, 'Not Processing: '+subdirs[j]
                 continue ;nothing to see here, move along
              Endif
              If(keyword_set(use_end_date)) Then Begin
;Create directories up to the requested date, if they don't
;already exist
                 tdirs = mvn_temp_month_dir(end_date)
                 If(is_string(tdirs)) Then Begin
                    ntdir = n_elements(tdirs)
;THere may be more than one directory here, use all of them
                    subsubdirs = file_dirname(file_dirname(sdj))+'/' ;this exists, otherwise we are not here
                    uu = uniq(subsubdirs)
                    subsubdirs = subsubdirs[uu]
                    For jss = 0, n_elements(subsubdirs)-1 Do For jtd = 0, ntdir-1 Do Begin
                       sdjx = file_search(subsubdirs[jss], tdirs[jtd], /mark_directory, /test_directory)
                       If(~is_string(sdjx)) Then Begin ;not here, so create it
                          dprint, 'Creating: '+subsubdirs[jss]+tdirs[jtd]
                          If(~keyword_set(preview)) Then Begin
                             file_mkdir, subsubdirs[jss]+tdirs[jtd]
                             file_chmod, subsubdir[jss]+tdirs[jtd], '664'o
                          Endif
                       Endif
                    Endfor
                 Endif
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
                 If(time_double(test_time) Ge time_in) Then Begin
;Here I want to keep the file if it exists, and create the link if not
                    If(~is_string(file_search(sdjk))) Then Begin
                       cmdjk = 'ln -s '+htfile+' '+sdjk
                       dprint, 'Spawning: '+cmdjk
                       If(~keyword_set(preview)) Then spawn, cmdjk
                    Endif Else dprint, 'File exists: '+sdjk
                 Endif Else Begin
;Here I want to check for the link, and delete it if it exists
                    If(is_string(file_search(sdjk))) Then Begin
                       dprint, 'Deleting: '+sdjk
                       If(~keyword_set(preview)) Then file_delete, sdjk
                    Endif Else dprint, 'No file: '+sdjk+' needed'
                 Endelse
              Endfor            ;k, monthly files
           Endelse
        Endfor                  ;j, subdirs
     Endelse
  Endif Else dprint, 'Bad input: '+instr
  Return
End


  
  

