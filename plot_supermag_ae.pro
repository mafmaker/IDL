
syear='2021'
smonth='5'

ps_flag = 0
ps_question,ps_flag

if ps_flag gt 0 then begin
   set_plot,'ps'   
endif

print,'Enter Year to read in : '
read,syear
syear=strcompress(syear,/rem)
print,'Enter Month to plot: '
read,smonth
themonth=fix(smonth)

print,syear
print,smonth



if ps_flag gt 0 then begin
   !p.font=0
   !p.charsize=1.
   device,filename='outputs/supermag_AE_' + syear + '_'+smonth+'.eps',/helvetica,/color,bits=8,$
          /encapsulated,xsize=8,ysize=2.5,/inches
endif




supermag_dir='~immel/sci/supermag/data_processing/'
datafile='supermag_AE_' + syear + '.idl'
restore,supermag_dir + datafile

loadct,12
!p.multi=[0,2,1,0]

ae_24=smooth(ae,1440)
ae_median=median(ae,120)

toplot=where(month eq themonth)

plot,dayofmonth[toplot]+findgen(n_elements(toplot))/1440. mod 1 ,ae[toplot],$
     xrange=[1,30],ytitle='AE (nT)',xtitle='Day of Month',/xstyle

oplot,dayofmonth[toplot]+findgen(n_elements(toplot))/1440. mod 1 ,smooth(ae[toplot],1440),$
      color=150,thick=3

;plot,dayofmonth[toplot]+findgen(n_elements(toplot))/1440. mod 1 ,ae_median[toplot]

plot,dayofmonth[toplot] +findgen(n_elements(toplot))/1440. mod 1   ,$
     smooth(abs(deriv(ae[toplot])),60),  $
     xrange=[1,30],ytitle='d(AE)/dT (nT/hour)',xtitle='Day of Month',/xstyle       

if ps_flag gt 0 then begin
   !p.font=-1
   ps_close 
endif

end
