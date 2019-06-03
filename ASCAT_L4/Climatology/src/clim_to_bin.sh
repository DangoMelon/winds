#!/bin/bash
#Created on Tue Apr 30 02:41:28 2019
#Author: Gerardo A. Rivera Tello
#Email: grivera@igp.gob.pe
#-----
#Copyright (c) 2019 Instituto Geofisico del Peru
#-----

echo "Compiling source file"
gfortran clim_to_bin.f90 -o clim_to_bin.exe $(nf-config --fflags --flibs)
status=$?

if [ $status == 0 ]; then
    echo "File compiled. Running"
    ./clim_to_bin.exe "/data/users/grivera/WIND_L4BLEND/clim/clim_taux_blend_1992-2010_365.nc" "/data/users/grivera/WIND_L4BLEND/clim/clim_taux_blend_1992-2010_365.dat" "365"
    ./clim_to_bin.exe "/data/users/grivera/WIND_L4BLEND/clim/clim_taux_blend_1992-2010_366.nc" "/data/users/grivera/WIND_L4BLEND/clim/clim_taux_blend_1992-2010_366.dat" "366"
    ./clim_to_bin.exe "/data/users/grivera/WIND_L4BLEND/clim/clim_tauy_blend_1992-2010_365.nc" "/data/users/grivera/WIND_L4BLEND/clim/clim_tauy_blend_1992-2010_365.dat" "365"
    ./clim_to_bin.exe "/data/users/grivera/WIND_L4BLEND/clim/clim_tauy_blend_1992-2010_366.nc" "/data/users/grivera/WIND_L4BLEND/clim/clim_tauy_blend_1992-2010_366.dat" "366"
else
    echo "File did not compile"
fi