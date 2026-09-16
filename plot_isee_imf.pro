
pro plot_isee_imf, year, day, xwin = xwin,psflag=psflag,bt=bt,$
                   xyrange=xyrange,yyrange=yyrange,zyrange=zyrange

if year lt 100 then year =  year + 1900 ;assumption

filename = 'ISEE3_IMF_' + strcompress(year, /rem) + '.IDL'
ISEE_PATH = '/home/immel/sci/isee3/'



restore, ISEE_PATH + filename

x = reform(imf.bx(day-1, *))
y = reform(imf.by(day-1, *))
z = reform(imf.bz(day-1, *))
time = reform(imf.btime(day-1, *))
good = where(time ne 0., ngood)
bad = where(time eq 0., nbad)
xx = fltarr(288)-30000.
yy = fltarr(288)-30000.
zz = fltarr(288)-30000.
bt = fltarr(288)-30000.
xx(time(good)/24*288.) = x(good)
yy(time(good)/24*288.) = y(good)
zz(time(good)/24*288.) = z(good)
bt(time(good)/24*288.) = (x(good)^2 + y(good)^2 + z(good)^2)^(0.5)

!p.multi = [0, 1, 3, 0]

if ngood le 0 then begin
  for i = 0, 2 do begin
    plot, [0, 1], [0, 1]
    xyouts, .2, .45,'No ISEE-3 DATA AVAILABLE FOR' + strcompress(year) + ', DAY '+  strcompress(day), /data
  endfor
  return
endif

if keyword_set(xwin) ne 1 then begin

  set_plot, 'z'
  device, set_resolution = [640, 950]

endif


old_font=!p.font
if keyword_set(psflag) eq 1 then begin
  !p.font=0
  set_plot,'ps'
  device,/portrait,filename='ISEE3_IMF' + strcompress(year, /rem) + '-' + $
  strcompress(day, /rem) + '.ps',xsize=4.75,ysize=9,/inches,xoffset=0.75,$
  yoffset=1.0,/helvetica
  !p.charsize=1.6
  !x.charsize=1.6
  !y.charsize=1.6
  !p.thick=2.5
  !x.thick=2.5
  !y.thick=2.5
endif



thinger = size(x)
xaxis = findgen(thinger(1))/thinger(1) * 24.
zero = fltarr(thinger(1)) * 0.

if keyword_set(bt) lt 1 then begin
  plot, xaxis, xx, /noerase, /nodata,min_value = -300, xstyle = 4, ystyle = 4
;print, !y.crange
  plot, xaxis, xx, xtitle = 'Time (Hrs. UT)', $
  ytitle = 'IMF Bx (nT GSM)', min_value = -300, /xstyle, xrange = [0, 24], $
  yrange = [-1 * max(abs(!y.crange)), max(abs(!y.crange))], xticks = 4, $
  xminor = 6
endif else begin
  plot, xaxis, bt, /noerase, /nodata,min_value = -300, xstyle = 4, ystyle = 4
;print, !y.crange
  if keyword_set(xyrange) gt 0 then y_range=xyrange else $
    y_range = max(abs(!y.crange))
  plot, xaxis, bt, xtitle = 'Time (Hrs. UT)', $
  ytitle = 'IMF B!dtotal!n (nT GSM)', min_value = -300, /xstyle, xrange = [0, 24], $
  yrange = [-1 * max(abs(!y.crange)), max(abs(!y.crange))], xticks = 4, $
  xminor = 6
endelse

;oplot, time(good), x(good), psym = 7
oplot, xaxis, zero, linestyle = 2


plot, xaxis, yy, /noerase, /nodata,min_value = -300, xstyle = 4, ystyle = 4
  if keyword_set(yyrange) gt 0 then y_range=yyrange else $
    y_range = max(abs(!y.crange))
plot, xaxis, yy, xtitle = 'Time (Hrs. UT)', $
  ytitle = 'IMF By (nT GSM)', min_value = -300, /xstyle, xrange = [0, 24], $
  yrange = [-1 * y_range, y_range], xticks = 4, $
  xminor = 6,/ystyle

oplot, xaxis, zero, linestyle = 2

plot, xaxis, zz, /noerase, /nodata,min_value = -300, xstyle = 4, ystyle = 4
  if keyword_set(zyrange) gt 0 then y_range=zyrange else $
    y_range = max(abs(!y.crange))
plot, xaxis, zz, xtitle = 'Time (Hrs. UT)', $
  ytitle = 'IMF Bz (nT GSM)', min_value = -300, /xstyle, xrange = [0, 24], $
  yrange = [-1 * y_range, y_range], xticks = 4, $
  xminor = 6,/ystyle

oplot, xaxis, zero, linestyle = 2


if keyword_set(psflag) ne 1 then begin
  a = tvrd()
  write_png, 'ISEE3_IMF' + strcompress(year, /rem) + '-' + $
  strcompress(day, /rem) + '.gif', a
  endif else ps_close

;--- do not leave output in z buffer!
if keyword_set(xwin) lt 1 and keyword_set(psflag) lt 1 then ps_close
!p.font=old_font
;stop
end
