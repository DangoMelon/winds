dset ^%y4/%y4%m2%d2.nc
undef -999. _FillValue
dtype netcdf
unpack scale_factor
options template 
xdef  1440 linear -180  0.25
ydef   641 linear -80  0.25
zdef     1 levels       0
tdef NTIME linear 01jan1992 1dy

vars 4
taux      00 t,y,x  ** Zonal wind stress
tauy      00 t,y,x  ** Meridional wind stress
taux_anom 00 t,y,x  ** Zonal wind stress anomaly
tauy_anom 00 t,y,x  ** Meridional wind stress anomaly
endvars