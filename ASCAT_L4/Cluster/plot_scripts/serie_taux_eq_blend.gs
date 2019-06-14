'reinit'
'set display color white'
'c'

'set mpdset hires'
'open /data/datos/ASCAT/DATA_L4_bin/winds_l4_blended_bin.ctl'

outdir='../Output/'
name='serie_ataux_blend_eq_box'

'set t last'
'q dims'
tline=sublin(result,5)
Nt=subwrd(tline,9)
tiempo=subwrd(tline,6)
day=substr(tiempo,4,2)
month=substr(tiempo,6,3)
year=substr(tiempo,9,4)

Nti=Nt-200

****************************************************
'set t 'Nti' 'Nt
'ataux=taux_anom'

******************************************************************

opt='0.32 0 0 0.1 0.1'

ilon=140
lonlim=280
dlon=20
flon=0
head=10.6
dhead=1.48

np=(lonlim-ilon)/dlon
n=1


while (flon < lonlim)
    flon=ilon+dlon
    'set lon 'ilon' 'flon
    'define uz=aave(ataux*100,lon='ilon',lon='flon',lat=-5,lat=5)'
    
    'subplot 1 'np' 'n' 'opt
    'set grads off'
    'set gxout linefill'
    'set lfcols 12 5'
    'set ylpos 0 l'
    'set vrange -10 17'
    'set ylint 5'
    'set x 1'
    'set y 1'
    'd uz;uz*0'

    'set gxout line'
    'set cmark 0'
    'set cthick 5'
    'set ccolor 1'
    'set ylpos 0 l'
    'set ylint 5'
    'd uz'
    
    'set string 1 tc 6 0'
    'set strsiz 0.14 0.15'
    if (flon>180)
        flont=360-flon
        LETf='W'
    else
        flont=flon
        LETf='E'
    endif

    if (ilon>180)
        ilont=360-ilon
        LETf='W'
    else
        ilont=ilon
        LETi='E'
    endif

    'draw string 4.25 'head' 'ilont'`3.`0'LETi'-'flont'`3.`0'LETf
    
    head=head-dhead
    ilon=flon
    n=n+1
endwhile

'draw string 4.25 10.9 Anomalia del esfuerzo de viento zonal 5`3.`0S-5`3.`0N (10`a-2`n Nm`a-2`n)'

'set strsiz 0.09 0.11'
'draw string 4.25 0.13 Source: CMEMS/CERSAT Blended Mean Wind   Processing: IGP   Clim: 1992-2010   Latest Data: 'day''month''year' '

'gxprint 'outdir''name'.eps'
'quit'


