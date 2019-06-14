'reinit'
'set display color white'
'c'
'set grads off'
'rgbset2'

outdir='../Output/'
name='hov_ataux_blend_eq'

niveles=" -20 -15 -10 -5 -2.5  2.5  5  10  15  20"
colores=" 49 48  46  44 42   0    22  24  26  28 29  "
niveles2=" -20 -15 -10 -5  5  10  15  20  "

************

'open /data/datos/ASCAT/DATA_L4_bin/winds_l4_blended_bin.ctl'

************

'set t last'
'q time'
tiempo=subwrd(result,3)
day=substr(tiempo,4,2)
month=substr(tiempo,6,3)
year=substr(tiempo,9,4)

time1=day''month''year-1
time2=tiempo

************

lonini=120
lonfin=280
dlon=30

latini=-2
latfin=2
'set xlopts 1 1 0.15'
'set ylopts 1 1 0.15'

'subplot 1 1 1 0.5'
'set gxout grfill'
'set time 'time1' 'time2
'set lon 'lonini' 'lonfin
'set xlint 'dlon
'set lat 'latini' 'latfin
'define anom=ave(taux_anom,lat='latini',lat='latfin')'
'set yflip on'
'set lat 0'
'set clevs 'niveles
'set ccols 'colores
'd 100*anom'
'cbarn 0.8 1'
'set strsiz 0.12 0.14'
'set gxout contour'
'set ccolor 1'
'set clevs 'niveles2
'd 100*smth9(anom)'

'set string 1 tc 6 0'
'set strsiz 0.11 0.11'
'draw string 4.25 0.4 Source: CMEMS/CERSAT Blended Mean Wind   Processing: IGP   Latest Data: 'day' 'month' 'year''
'set string 1 tl 6 0'
'draw string 0.38 0.2 Clim: 1992-2010'

'set string 1 c 8'
'set strsiz 0.16 0.17'
'draw string 4.25 10.6 Zonal Wind stress Anomaly (10^2Nm^-2)'
'draw string 4.25 10.3 averaged between 'latfin'S y 'latfin'N '


'gxprint 'outdir''name'.eps'
'quit'
