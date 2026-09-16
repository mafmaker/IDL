;+
;   This routine makes plots of the output from the tranport code.
;   The possible plots are line plots, surface plots, and contour
;   plots.  The selection of files and displays is widget driven.
;   To use type:
;                  trans
;   at the IDL> prompt.
;-

pro trans_event, event

@common
@common_w

; note: the cw_bgroup returns two events, one with event.select passed
; through from pressing the button.  If this is zero, we don't really
; want to do anything, i.e. we only want something to happen from the
; consequences of pressing the button.  (see case 'select')

widget_control, event.id, get_uvalue=action
case action of
  'path': begin
            ; select a path where the data are located
            subdir=mk_path(pathname, group=main_base)
            widget_control, event.id, set_value=subdir
            readflag=0
          end
  'text': begin
            spawn, 'xterm -geometry 140x30 -e less '+ $
                   pathname+'/'+subdir+'/TRANSOUT &', output
            ;msg_out, ['status of spawn xterm ...',string(output)]
         end
  'read': begin
            ; read all files in the selected subdirectory
            widget_control, /hourglass
            msg_out, 'reading files: '+ pathname+ '/'+ subdir
            read_all, subdir, pathname
            ;msg_out, 'looking for file: '+ strcompress(crs_file, /rem)
;            test = strcompress(crs_file, /rem)
;            crs_file = findfile(strcompress(crs_file, /rem))
;            if crs_file[0] eq '' then crs_file[0] =  $
            crs_file[0] =  $
              pathname+ '/'+ subdir+'//CRSxdr'
;                               dialog_pickfile(filter=test,  $
;                                 title='Select cross section file')
;            crs_file = findfile(strcompress(crs_file[0], /rem))
            if crs_file[0] ne '' then begin
               read_crs, strcompress(crs_file[0], /rem)
               msg_out, 'reading file: '+ strcompress(crs_file[0], /rem)
            endif else msg_out, 'could not find crs_file: '+test
            readflag=1
          end
  'ps':   begin
            ; switch between PS and X
            case event.value of
                0 : begin            ; plot to screen
                    device, /close
                    msg_out, 'plot is in file idl.ps'
                    set_plot, 'x'
                end
                1 : begin
                    set_plot, 'ps', /inter ; plot to PS-file
                    !p.charsize=0.8
                    end
                2 : begin       ; color PS
                   set_plot, 'ps', /inter
                   ;load_mycolor, /dmsp
                   loadct, 42,  file='/home/lmp/Idl/Lumm/colors1.tbl'
                   device, /color, bits=8
                end
                else: msg_out, string(event.value)+' case not found'
            endcase
          end
  'select': begin
            ; switch between different data locations
            if event.select eq 0 then return
            case event.value of
                0 : begin            ; loke
                     ;pathname =  '/lk/lumm/New_trans/output'
                     ;msg_out, 'get data from loke:'+pathname+'/'+subdir
                   test = dialog_pickfile(path=pathname, get_path=newpath,  $
                                          /directory)
                   pathname = newpath
                   msg_out, 'get data from:'+pathname+'/'+subdir
                end
                1 : begin   ; odin
                     pathname =  '/mydisks/home/lmp/Trans/Output'
                     msg_out, 'get data from odin:'+pathname+'/'+subdir
                end
                2 : begin
                     pathname =  '/home/lmp'
                     msg_out, 'get data from odin:'+pathname+'/'+subdir
                end
                3 : begin   ; local ../output
                     pathname =  extra_path
                     msg_out, 'get data from '+pathname+'/'+subdir
                end
                else: msg_out, string(event.value)+' case not found'
            endcase
            subdir=findfile(pathname)
            subdir = subdir(0)
            widget_control, path_but, set_value=subdir
            readflag = 0
          end
  'density': begin
            ; make line plots of the neutral density and temperature
            widget_control, /hourglass
            if readflag ne 1 then $
               prnt_error, 'Need to read the file first' $
            else density, _extra=ionr_param
          end
  'density_set': set_ionr    ; same parameters as ionrate
  'spectrum': begin
            ; make line plot of the electron spectrum at various
            ; altitude levels
            widget_control, /hourglass
            if readflag ne 1 then $
               prnt_error, 'Need to read the file first' $
            else spectrum, _extra=spectrum_param
          end
  'spectrum_set': set_spectrum ;prnt_error, 'No parameters to be set...'
  'penetration': begin
            ; make line plots of altitude profiles of the 
            ; electron intensity at various energy levels
            widget_control, /hourglass
            help, penetration_param, /str
            if readflag ne 1 then $
               prnt_error, 'Need to read the file first' $
            else penetration, _extra=penetration_param
          end
  'penetration_set': set_penetration
  'intensity': begin
            ; make grayscale plots of the 
            ; electron intensity at a given altitude level
            widget_control, /hourglass
            if readflag ne 1 then $
               prnt_error, 'Need to read the file first' $
            else intensity, _extra=intensity_param
          end
  'intensity_set': set_intensity
  'ionrate': begin
            ; make line plots of altitude profiles of 
            ; the ionization rates
            widget_control, /hourglass
            if readflag ne 1 then $
               prnt_error, 'Need to read the file first' $
            else ionrates, _extra=ionr_param
          end
  'ionrate_set': set_ionr
  'uv':   begin
            ; make plots of UV emission and brightness
            widget_control, /hourglass
            if readflag ne 1 then $
               prnt_error, 'Need to read the file first' $
            else uv_emission
          end
  'uv_set': prnt_error, 'No parameters to be set...'
  'exrate': begin
            ; make line plots of altitude profiles of the excitation rates
            widget_control, /hourglass
            if readflag ne 1 then $
               prnt_error, 'Need to read the file first' $
            else exrates, _extra=ionr_param
          end
  'exrate_set': set_excr
  'engdep': begin
            ; make line plots of altitude profiles of the 
            ; energy deposition rates
            widget_control, /hourglass
            if readflag ne 1 then $
               prnt_error, 'Need to read the file first' $
            else engdep, _extra=engdep_param
          end
  'engdep_set': set_engdep
  'flx_surf': begin
            ; plot fluxes as surface plots
            widget_control, /hourglass
            if readflag ne 1 then $
               prnt_error, 'Need to read the file first' $
            else flx_surf, _extra=flx_param
          end
  'flx_surf_set': set_flx_surf
  'flx_cont': begin
            ; plot fluxes as contour plots
            widget_control, /hourglass
            if readflag ne 1 then $
               prnt_error, 'Need to read the file first' $
            else flx_cont, _extra=flx_cont_param
          end
  'flx_cont_set': set_flx_cont
  'xload': xload_mycolor ;xloadct, file='/od/lumm/idl/colors1.tbl'
  'multi': begin
     case event.value of
        0 : !p.multi = 0
        1 : !p.multi = [0,1,2]
        2 : !p.multi = [0,2,2]
        3 : !p.multi = [0,1,4]
        else: msg_out, string(event.value)+' case not found'
      endcase
;     if !p.multi(1) le 1 then begin
;        !p.multi = [0,2,2]
;        widget_control, event.id, set_value='One plot one panel'
;     endif else begin
;        !p.multi = 0
;        widget_control, event.id, set_value='Combine 4 plots on one panel'
;     endelse
  end
  'all_del': while !d.window ne -1 do wdelete
  'win_del': wdelete
  'exit': begin
            widget_control, event.top, /destroy
            while !d.window ne -1 do wdelete
            msg_out, /kill
          end
endcase 

return
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; this is a locally used function to generate the button rows
function mk_button, label, value

@common_w

base=widget_base(main_base, /row, /frame)

;font='avantgarde_demi14'
font='-misc-fixed-bold-r-normal--15-140-75-75-c-90-iso8859-1'
title = widget_label( base, value=label, font=font)
plot = widget_button( base, uvalue=value, $
      value='make plot')
set = widget_button( base, uvalue=value+'_set', $
      value='set parameters')

return, base
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; now comes the user routine...

pro trans, group=group, data_path=data_path

@common
@common_w

; define group if not set
if n_elements(group) eq 0 then group=0

; set various initial values.  These parameters are kept in the
; various common blocks.
;pathname =  '/lk/lumm/New_trans/output'   ; for loke
pathname =  '/home/lmp/Idl/Lumm/Trans/Output'    ; for odin
if n_elements(data_path) le 0 then extra_path = '../output' $
                              else extra_path = data_path
w_scale = 0.7
readflag=0
subdir=findfile(pathname)
subdir = subdir(0)
e_label='particle flux'
t_label='individual states'
ps_label='open and plot to postscript file'
oldvalue=1
oldvalue1=0
oldvalue2=0
old_surf = 0
pick_n2 = -1
pick_o2 = -1
pick_o = -1

; these structures are used to transfer any number of parameters to
; the various programs.  The structures are kept in common blocks.
; The "ionr_param" structure is common to ionrate, exrate, density
flx_param={emax:0., fmin:0., alt_r:[0.,0.]}
ionr_param={npowers:0, yrange:[0.,0.]}
flx_cont_param={frange:[0.,0.], yrange:[0.,0.], xrange:[0.,0.], $
                up:0, energyflux:0, total:0, net:0, photo:0, surf:0}
engdep_param={npowers:0, yrange:[0.,0.], only_total:0}
intensity_param={alt:0, erange:[0.,0.], irange:[0.,0.]}
penetration_param={zrange:[0.,0.], frange:[0.,0.], updn:1, total:0, $
                  photo:0, net:0, eflux:0}
spectrum_param={emin:0., emax:0., fmin:0., fmax:0., count:0}

; make a main base
main_base = widget_base(group_leader=group, $
      title='TRANS output', /column, xoffset=150, yoffset=50)

; define the message window if it does not yet exist
msg_out, ' ', group=main_base

; make additional bases to group the buttons
top_base = widget_base(main_base, /column, /align_center)

xsize=400
; button for the path selection
top_base1=widget_base(top_base, /row, xsize=xsize)
path_lab = widget_label( top_base1, value=' select data set: ')
path_but = widget_text( top_base1, value=subdir, $
      uvalue='path', /all, /edit, xsize=xsize/3)

; button to show the textfile
text_but = widget_button( top_base, value='show text file', $
      uvalue='text', xsize=xsize)

; button to read the files
read_but = widget_button( top_base, uvalue='read', $
      value='read data files', xsize=xsize)

; postscript button
top_base2=widget_base(top_base, /row, xsize=xsize)
ps_but = widget_label( top_base2, value='Destination for the plot: ')
ps_sel = cw_bgroup( top_base2, uvalue='ps',  $
                    ['screen', 'B/W PS', 'Color PS'], $
                    row=1, /exclusive, set_val=0)

; select either loke or odin as a data source
top_base3=widget_base(top_base, /row, xsize=xsize)
loke_but = widget_label( top_base3, value='Source of data: ')
loke_sel = cw_bgroup( top_base3, uvalue='select',  $
                      ['select', 'Trans', 'lmp', extra_path], $
                      /row, /exclusive, set_val=2)

; select the number of plots in one window/page
top_base4=widget_base(top_base, /row, xsize=xsize)
multi_but = widget_label( top_base4, value='!p.multi: ')
multi_sel = cw_bgroup( top_base4, uvalue='multi',  $
                      ['[1]', '[1,2]', '[2,2]', '[1,4]'], $
                      /row, /exclusive, set_val=0)

; change color table
win_but=widget_button( top_base, uvalue='xload', $
      value='Change color table', xsize=xsize)

; combine 4 plots on one panel
;win_but=widget_button( top_base, uvalue='multi', $
;      value='Combine 4 plots on one panel', xsize=xsize)

; delete the last window
win_but=widget_button( top_base, uvalue='win_del', $
      value='Delete the last plot', xsize=xsize)

; delete all plot windows
win_but=widget_button( top_base, uvalue='all_del', $
      value='Delete all plots', xsize=xsize)

; make buttons:
labels=['         neutral density', $
        '       electron spectrum', $
        '  flux altitude profiles', $
        '               intensity', $
        ' energy deposition rates', $
        'excitation rate profiles', $
        'ionization rate profiles', $
        '             UV emission', $
        '  surface plot of fluxes', $
        '  contour plot of fluxes']
values=['density', $
        'spectrum', $
        'penetration', $
        'intensity', $
        'engdep', $
        'exrate', $
        'ionrate', $
        'uv', $
        'flx_surf', $
        'flx_cont']

num_but=n_elements(labels)
for i=0,num_but-1 do base=mk_button(labels(i), values(i))

; done button
done_but = widget_button( top_base, uvalue='exit', value='DONE')

widget_control, main_base, /realize
xmanager, 'trans', main_base

;print, 'spawning ', msg_kill
;spawn, msg_kill, out
;print, out

end
