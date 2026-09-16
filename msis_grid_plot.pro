
;  MSIS_grid_plot.pro                      
;  Author : T. Immel
;  Date : 9-4-98
;
;  First shot at editing with development tool!
;
;--------------------------------------------

;restore N2 data

restore,'~/n2_grid.idl'

;shift such that long=0 is in the middle

n2_grid=n2_grid(0:359,*)
n2_grid=shift(n2_grid,180,0)

;ask about output

ps_flag=0
ps_question,ps_flag
if ps_flag eq 1 then begin

  set_plot,'ps'
  device,filename='MSIS_grid_plot.ps',/portrait,xsize=6.,ysize=9.,$
    xoffset=1.,yoffset=1.,/inches,bits=8

endif

;get ready to plot N2

plot_arr=fltarr(4,2)
plot_arr(*,0)=[.1,.55,.9,.9]
plot_arr(*,1)=[.1,.1,.9,.45]

sizer=size(n2_grid)
xx=findgen(sizer(1))
yy=findgen(sizer(2))

;---PLOT N2---

log_n2_grid=alog10(n2_grid)
b_log_n2_grid=bytscl(log_n2_grid,min=min(log_n2_grid),max=max(log_n2_grid))

!p.position=plot_arr(*,0)
plotscl,b_log_n2_grid,255,0,xx,yy,' ',' ',' '

;---Annotate N2 Plot---
hrs=fix(uts/3600.)
mins=fix((uts-(hrs*3600.))/60.)
title='MSIS-86 LOG10(N2) HT.= ' + strcompress(al,/rem) + $
	' UT = ' + strcompress(hrs,/rem) + ' hr ' + $
	strcompress(mins,/rem) + ' min'
xticklab=['-180','-120','-60','0','60','120','180']
yticklab=['-90','-60','-30','0','30','60','90']

;maxn2=fltarr(0)
maxn2=max(log_n2_grid)
;minnt=fltarr(0)
minn2=min(log_n2_grid)

;b_minn2=bytscl(minn2,min=min(log_n2_grid),max=max(log_n2_grid))
;b_maxn2=bytscl(maxn2,min=min(log_n2_grid),max=max(log_n2_grid))

num_levels=8
levels=findgen(num_levels)
levels=minn2 + levels*((maxn2-minn2)/num_levels)
b_levels=bytscl(levels,min=min(log_n2_grid),max=max(log_n2_grid))
contour,b_log_n2_grid,levels=b_levels,c_annotation=strcompress(levels,/rem),$
	/noerase,/xstyle,/ystyle,title=title,xticks=6,yticks=6,$
	xtickname=xticklab,ytickname=yticklab

;---Done with N2---
;---Start Rho
restore,'~/den_grid.idl'

;shift such that long=0 is in the middle

den_grid=den_grid(0:359,*)
den_grid=shift(den_grid,180,0)
;log_n2_grid=alog10(n2_grid)
b_den_grid=bytscl(den_grid,min=min(den_grid),max=max(den_grid))

!p.position=plot_arr(*,1)
oplotscl,b_den_grid,255,0,xx,yy,' ',' ',' '

;---Annotate N2 Plot---
hrs=fix(uts/3600.)
mins=fix((uts-(hrs*3600.))/60.)
title='MSIS-86 Mass Density (g/cc) HT.= ' + strcompress(al,/rem) + $
	' UT = ' + strcompress(hrs,/rem) + ' hr ' + $
	strcompress(mins,/rem) + ' min'
xticklab=['-180','-120','-60','0','60','120','180']
yticklab=['-90','-60','-30','0','30','60','90']


maxden=max(den_grid)
minden=min(den_grid)

num_levels=8
levels=findgen(num_levels)
levels=minden + levels*((maxden-minden)/num_levels)
b_levels=bytscl(levels,min=min(den_grid),max=max(den_grid))
contour,b_den_grid,levels=b_levels,c_annotation=strcompress(levels,/rem),$
	/noerase,/xstyle,/ystyle,title=title,xticks=6,yticks=6,$
	xtickname=xticklab,ytickname=yticklab

;---done with rho

if ps_flag eq 1 then begin

  device,/close
  set_plot,'x'

endif

end
