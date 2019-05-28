#!/bin/bash
#Created on Tue Apr 30 02:41:28 2019
#Author: Gerardo A. Rivera Tello
#Email: grivera@igp.gob.pe
#-----
#Copyright (c) 2019 Instituto Geofisico del Peru
#-----

echo "Compiling source file"
gfortran netcdf_mean_to_bin.f90 -o netcdf_mean_to_bin.exe $(nf-config --fflags --flibs) -I/home/grivera/datetime-fortran/build/include -L/home/grivera/datetime-fortran/build/lib -ldatetime
status=$?

if [ $status == 0 ]; then
    echo "File compiled. Running"
    for year in {1992..1992}; do
        for month in {01..12}; do
            for day in {01..31}; do
                file_count=$(ls ../Input/$year$month$day*.nc)
                ./netcdf_mean_to_bin.exe "$file_count" "../Output/l4_blended$year$month$day.dat" "../Output/l4_blended$year$month$day.nc"
            done
        done
    done
else
    echo "File did not compile"
fi