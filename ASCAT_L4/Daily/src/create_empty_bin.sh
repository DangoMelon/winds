#!/bin/bash
#Created on Tue Apr 30 02:41:28 2019
#Author: Gerardo A. Rivera Tello
#Email: grivera@igp.gob.pe
#-----
#Copyright (c) 2019 Instituto Geofisico del Peru
#-----

echo "Compiling source file"
gfortran create_empty_bin.f90 -o create_empty_bin.exe $(nf-config --fflags --flibs) -I/home/grivera/datetime-fortran/build/include -L/home/grivera/datetime-fortran/build/lib -ldatetime
status=$?

if [ $status == 0 ]; then
    echo "File compiled. Running"
    ./create_empty_bin.exe "1992-10-18" "../Output/19921018.dat" "../Output/19921018.nc"
else
    echo "File did not compile"
fi