;
; Auto Save File For ./plotit.pro
;
;  Wed Jul 20 16:25:55 AKDT 1994
;



; CODE MODIFICATIONS MADE ABOVE THIS COMMENT WILL BE LOST.
; DO NOT REMOVE THIS COMMENT: BEGIN HEADER


;+
; NAME:
;	ROUTINE_NAME
;
; PURPOSE:
;	Tell what your routine does here.  I like to start with the words:
;	"This function (or procedure) ..."
;	Try to use the active, present tense.
;
;-



; DO NOT REMOVE THIS COMMENT: END HEADER
; CODE MODIFICATIONS MADE BELOW THIS COMMENT WILL BE LOST.


; CODE MODIFICATIONS MADE ABOVE THIS COMMENT WILL BE LOST.
; DO NOT REMOVE THIS COMMENT: BEGIN MAIN13




PRO MAIN13_Event, Event

common junk, pathname, subdir

  WIDGET_CONTROL,Event.Id,GET_UVALUE=Ev

  CASE Ev OF 

  'path': BEGIN
      widget_control, event.id, get_val=pathname
      pathname=pathname(0)
      Print, 'Event for  ', pathname
      END
  'subdir': begin
      widget_control, event.id, get_val=subdir
      subdir=subdir(0)
      Print, 'Event for  ',subdir
            end
  'read': BEGIN
        Print, 'reading file: ',subdir,pathname
	read_all, subdir, pathname
      END
  'spectrum': BEGIN
;      Print, 'Event for Plot spectrum'
	spectrum
      END
  'penetration': BEGIN
;      Print, 'Event for Plot penetration'
	penetration
      END
  'exit': BEGIN
;      Print, 'Event for DONE'
	WIDGET_CONTROL, event.top, /DESTROY
	while !D.WINDOW ne -1 do wdelete
      END
  ENDCASE
END


; DO NOT REMOVE THIS COMMENT: END MAIN13
; CODE MODIFICATIONS MADE BELOW THIS COMMENT WILL BE LOST.



PRO plotit, GROUP=Group

common junk, pathname, subdir
  IF N_ELEMENTS(Group) EQ 0 THEN GROUP=0

  junk   = { CW_PDMENU_S, flags:0, name:'' }


  MAIN13 = WIDGET_BASE(GROUP_LEADER=Group, $
      COLUMN=1, $
      MAP=1, $
      UVALUE='MAIN13', $
      XOFFSET=200, $
      YOFFSET=150)

  pathname =  '../output' 
  FIELD12 = CW_FIELD( MAIN13,VALUE=pathname, $
      ROW=1, $
      STRING=1, $
      RETURN_EVENTS=1, $
      TITLE='pathname', $
      UVALUE='path', $
      XSIZE=20)
  subdir =  'ph0' 
  FIELD13 = CW_FIELD( MAIN13,VALUE=subdir, $
      ROW=1, $
      STRING=1, $
      RETURN_EVENTS=1, $
      TITLE='subdirectory', $
      UVALUE='subdir', $
      XSIZE=20)

  BUTTON17 = WIDGET_BUTTON( MAIN13, $
      UVALUE='read', $
      VALUE='Read Data')

  BUTTON13 = WIDGET_BUTTON( MAIN13, $
      UVALUE='spectrum', $
      VALUE='Plot spectrum')

  BUTTON19 = WIDGET_BUTTON( MAIN13, $
      UVALUE='penetration', $
      VALUE='Plot penetration')

  BUTTON21 = WIDGET_BUTTON( MAIN13, $
      UVALUE='exit', $
      VALUE='DONE')

  WIDGET_CONTROL, MAIN13, /REALIZE

  XMANAGER, 'MAIN13', MAIN13
END
