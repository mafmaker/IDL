;+
;NAME:
; mvn_revert_l2access
;PURPOSE:
; moves htaccess links for the MAVEN PFP data located here at SSL. 
; for each instrument, back to the instrument level
;  (/disks/data/maven/data/sci/instrument). Should only be needed once.
;CALLING SEQUENCE:
; mvn_revert_l2access, instr
;INPUT:
; instr = A PFP instrument, ['euv', 'iuv', 'kp', 'lpw', 'mag', 'ngi',
;                            'pfp', 'sep', 'sta', 'swe', 'swi'] 
;KEYWORDS:
; preview = Just print messsages about what will happen, don't
;           delete or spawn
;HISTORY:
; $LastChangedBy: $
; $LastChangedDate: $
; $LastChangedRevision: $
; $URL: $
;-
Pro mvn_revert_l2access, instr, preview=preview

;  preview = 1                   ;temporary for testing
;Data directory is hard-wired here:
  data_dir = '/disks/data/maven/data/sci/'
;THe global htaccess file to be linked to:
  htfile = '/disks/data/maven/pfp/.hidden/.htaccess.secure'

  instr0 = strcompress(/remove_all, strlowcase(instr[0]))
  test_dir = file_search(data_dir+instr0, /mark_directory, /test_directory)
  If(is_string(test_dir)) Then Begin
;If there is an .htaccess link here, do nothing
     test_global_htaccess = file_search(test_dir+'.htaccess')
     If(~is_string(test_global_htaccess)) Then Begin
        cmd = 'ln -s '+htfile+' '+test_dir+'.htaccess'
        message, /info, 'Spawning: '+cmd
        If(~keyword_set(preview)) Then spawn, cmd
     Endif
;Work with subdirectories, remove all .htaccess files, do not do
;anything to l0_all
     subdirs = file_search(test_dir+'*', /mark_directory, /test_directory)
     subdirs0 = file_basename(subdirs)
     qll2_test = strmid(subdirs0, 0, 2)
     nsd = n_elements(subdirs0)
     For j = 0, nsd-1 Do Begin
        If(subdirs0[j] Ne 'l0_all') Then Begin
           sdj = subdirs[j]+'.htaccess'
           If(is_string(file_search(sdj))) Then Begin
              message, /info, 'Deleting: '+sdj
              If(~keyword_set(preview)) Then file_delete, sdj
           Endif Else message, /info, 'No File exists: '+sdj
;Here descend through the monthly files, should work until 2099...
           sdj = file_search(subdirs[j], '20??/??', /mark_directory, /test_directory)
           If(~is_string(sdj)) Then Begin
              message, /info, 'Not Monthly Processing: '+subdirs[j]
              continue          ;nothing to see here, move along
           Endif
           nmonths = n_elements(sdj)
           For k = 0, nmonths-1 Do Begin
;Extract the year and month
              ppp = strsplit(sdj[k], '/', /extract)
              yyyy = ppp[n_elements(ppp)-2]
              mm = ppp[n_elements(ppp)-1]
;sdjk is the file to test for
              sdjk = sdj[k]+'.htaccess'
              If(is_string(file_search(sdjk))) Then Begin
                 message, /info, 'Deleting: '+sdjk
                 If(~keyword_set(preview)) Then file_delete, sdjk
              Endif Else message, /info, 'No file: '+sdjk+' found'
           Endfor               ;k, monthly files
        Endif
     Endfor                     ;j, subdirs
  Endif Else message, /info, 'Bad input: '+instr
  Return
End


  
  

