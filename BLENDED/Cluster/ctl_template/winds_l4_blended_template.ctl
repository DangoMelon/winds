dset ^%y4/%y4%m2%d2%h2.nc
options template
undef 9.96920996838687e+36 _FillValue
xdef  lon  1440 linear -180  0.25
ydef  lat   641 linear -80  0.25
tdef time NTIME linear 00Z01jan1993 6hr
vars 2
surface_downward_eastward_stress=>taux
surface_downward_northward_stress=>tauy
endvars