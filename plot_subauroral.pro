;asdfas

ps_flag = 0
ps_question,ps_flag

if ps_flag eq 1 then begin
  set_plot,'ps'
  device,filename='plot_subauroral.ps',/land,xsize=10,ysize=8,/inches,$
	xoffset=0.25,yoffset=10.5,bits=8,/color

endif else begin

;if ps_flag eq 1 then cline=0

xsize=11.  * 50.
ysize=8.5  * 50.

window,0,xsize=xsize,ysize=ysize

endelse

line_color=254


restore,'s1320010232323.idl'
s13maf=imageinfo
restore,'s1220010232323.idl'
s12maf=imageinfo
restore,'wic20010232323.idl'
wicmaf=imageinfo

print,s13maf.time
print,s12maf.time
print,wicmaf.time

wait,5

restore,'wic20010232323.mag'
wic=mapim
wicmin=minlat
wiclonres=lon_res
restore,'wic20010232323.magbck'
wicbck=mapim

restore,'s1220010232323.mag'
s12=mapim
restore,'s1220010232323.magbck'
s12bck=mapim

restore,'s1320010232323.mag'
s13=mapim
restore,'s1320010232323.magbck'
s13bck=mapim

truwic=wic - (1.1*wicbck -200)   ; (fitted by eye at x=480)
trus12=s12 - s12bck
trus13=s13 - (s13bck*1.2)	;(same, fitted by eye)

wicbad=where(wic eq -1)
s12bad=where(s12 eq -1)
s13bad=where(s13 eq -1)

predict_wic_lo=truwic
predict_s13_lo=trus13

predict_wic_mid=truwic
predict_s13_mid=trus13

predict_wic_hi=truwic
predict_s13_hi=trus13

fuv_from_s12,trus12,predict_wic_lo,predict_s13_lo,proton_energy=8.
fuv_from_s12,trus12,predict_wic_mid,predict_s13_mid,proton_energy=20.
fuv_from_s12,trus12,predict_wic_hi,predict_s13_hi,proton_energy=70.

energy_flux_p,2001,23,trus12,truwic,trus13,ee,ef,/no_corr,/golow,proton_energy=5

pos_arr=fltarr(4,6)
pos_arr(*,0)=[.03,.58,.33,.98]
pos_arr(*,1)=[.34,.58,.64,.98]
pos_arr(*,2)=[.65,.58,.95,.98]

pos_arr(*,3)=[.05,.05,.30,.45]
pos_arr(*,4)=[.38,.05,.63,.45]
pos_arr(*,5)=[.71,.05,.97,.45]

;loadct,file='~/sci/fuv/colortable/colors1.tbl',41
loadct,5

plot_dex=480	;x position of meridional plot
plot_lon=(plot_dex*wiclonres)-180.
low_lat=50

!p.position=pos_arr(*,0)
map_set,90,180.,/ortho,limit=[low_lat,0,90,360],/noerase,/advance,$
	title='WIC'
mincts=100 & maxcts=1000
mapwic=map_image(bytscl(truwic,min=mincts,max=maxcts),$
	startx,starty,xsiz,ysiz,latmin=wicmin-90.,latmax=90.,compress=1)
tv,mapwic,startx,starty,xsize=xsiz,ysize=ysiz
map_grid,label=1,lats=[50,60,70,80],lons=[-180,-90,0,90,180],$
	lonnames=[' ','6:00',' ','18:00','24:00'],$
	lon_align=0,glinestyle=0,color=line_color,glinethick=3
plots,[plot_lon,plot_lon],[90,low_lat],linestyle=2,thick=6,$
	color=line_color

cbar,[!p.position(0)+0.02,!p.position(1)-0.07,!p.position(2)-0.02,$
   !p.position(1)-0.05],mincts,maxcts,'WIC counts',0.8,/horiz,numticks=4

!p.position=pos_arr(*,1)
mincts=0 & maxcts=15	
map_set,90,180.,/ortho,limit=[low_lat,0,90,360],/noerase,/advance,$
	title='S13'
mapwic=map_image(bytscl(trus13,min=mincts,max=maxcts),$
	startx,starty,xsiz,ysiz,latmin=wicmin-90.,latmax=90.,compress=1)
tv,mapwic,startx,starty,xsize=xsiz,ysize=ysiz
map_grid,label=1,lats=[50,60,70,80],lons=[-180,-90,0,90,180],$
	lonnames=[' ','6:00',' ','18:00','24:00'],$
	lon_align=0,glinestyle=0,color=line_color,glinethick=3
plots,[plot_lon,plot_lon],[90,low_lat],linestyle=2,thick=6,$
	color=line_color

cbar,[!p.position(0)+0.02,!p.position(1)-0.07,!p.position(2)-0.02,$
   !p.position(1)-0.05],mincts,maxcts,'S13 counts',0.8,/horiz,numticks=4

!p.position=pos_arr(*,2)
mincts=0 & maxcts=30	
map_set,90,180.,/ortho,limit=[low_lat,0,90,360],/noerase,/advance,$
	title='S12'
mapwic=map_image(bytscl(trus12,min=mincts,max=maxcts),$
	startx,starty,xsiz,ysiz,latmin=wicmin-90.,latmax=90.,compress=1)
tv,mapwic,startx,starty,xsize=xsiz,ysize=ysiz
map_grid,label=1,lats=[50,60,70,80],lons=[-180,-90,0,90,180],$
	lonnames=[' ','6:00',' ','18:00','24:00'],$
	lon_align=0,glinestyle=0,color=line_color,glinethick=3
plots,[plot_lon,plot_lon],[90,low_lat],linestyle=2,thick=6,$
	color=line_color

cbar,[!p.position(0)+0.02,!p.position(1)-0.07,!p.position(2)-0.02,$
   !p.position(1)-0.05],mincts,maxcts,'S12 counts',0.8,/horiz,numticks=4


!p.position=pos_arr(*,3)

sizer=size(truwic)
newsize=size(predict_wic_lo)
plot,truwic(plot_dex,sizer(2)-1-( (90-low_lat)/wiclonres):sizer(2)-1),$
	xticks=4,xminor=1,xticklen=0.06,xtitle='Mag Lat (N)',$
	xtickname=strcompress(indgen(5)*10 + 50,/rem),/noerase,/xstyle,$
	xthick=2,ythick=2,thick=4.5,ytitle='WIC Response - Dayglow',$
	yminor=0,yticks=5
oplot,$
  predict_wic_lo(plot_dex,newsize(2)-1-((90-low_lat)/wiclonres):newsize(2)-1),color=50,linestyle=2,thick=4
oplot,$
  predict_wic_mid(plot_dex,newsize(2)-1-((90-low_lat)/wiclonres):newsize(2)-1),color=100,linestyle=2,thick=4

!p.position=pos_arr(*,4)

sizer=size(trus13)
newsize=size(predict_s13_lo)
plot,trus13(plot_dex,sizer(2)-1-( (90-low_lat)/wiclonres):sizer(2)-1),$
	xticks=4,xminor=1,xticklen=0.06,xtitle='Mag Lat (N)',$
	xtickname=strcompress(indgen(5)*10 + 50,/rem),/noerase,/xstyle,$
	xthick=2,ythick=2,thick=2.5,ytitle='S13 Response - Dayglow',$
	yminor=0,yticks=4,yrange=[-5,15]
oplot,$
  predict_s13_lo(plot_dex,newsize(2)-1-((90-low_lat)/wiclonres):newsize(2)-1),color=50,linestyle=2,thick=4
oplot,$
  predict_s13_mid(plot_dex,newsize(2)-1-((90-low_lat)/wiclonres):newsize(2)-1),color=100,linestyle=2,thick=4


!p.position=pos_arr(*,5)
sizer=size(trus12)

plot,trus12(plot_dex,sizer(2)-1-( (90-low_lat)/wiclonres):sizer(2)-1),$
	xticks=4,xminor=1,xticklen=0.06,xtitle='Mag Lat (N)',$
	xtickname=strcompress(indgen(5)*10 + 50,/rem),/noerase,/xstyle,$
	xthick=2,ythick=2,thick=4.5,ytitle='S12 Response - Dayglow',$
	yminor=0,yticks=7,yrange=[-5,30]



if ps_flag eq 1 then ps_close


end

