#!/bin/bash
#Created on Thu Apr 25 10:03:48 2019
#Author: Gerardo A. Rivera Tello
#Email: grivera@igp.gob.pe
#-----
#Copyright (c) 2019 Instituto Geofisico del Peru
#-----

# WARNING!!!!
# This bash script generates binary files from a folder
# containing netcdf files using the fortran script 
# netcdf_to_bin.exe (inside src folder) which usage is as follows:
#       $ ./netcdf_to_bin.o SOURCE_NC TARGET_BIN
# You only have to run this script when the fortran script source
# changed or the database was lost.

data_dir=/data/datos/ASCAT/DATA_L4
src_dir=/data/users/service/ASCAT_L4/Daily/src
subdirs=$(ls -d $data_dir/*/)
new_dirs=${subdirs//DATA_L4/DATA_L4_bin}
new_dirs_nc=${subdirs//DATA_L4/DATA_L4_new}

# Set up the environment
export LD_LIBRARY_PATH="/usr/local/netcdf-fortran/4.4.3/gnu4.8.5/lib64:${LD_LIBRARY_PATH}"

# Verify if the out directories exist
for bin_out in $new_dirs; do
    ls "$bin_out" || mkdir -p "$bin_out"
done

for bin_out in $new_dirs_nc; do
    ls "$bin_out" || mkdir -p "$bin_out"
done

# Loop throught all the files in subdirs
for year in $subdirs; do
    yearnum=$(echo "$year" | cut -d '/' -f 6)
    for month in {01..12}; do
        for day in {01..31}; do
            indv_files=$(ls $year$yearnum$month$day*.nc)
            out_file=${year//DATA_L4/DATA_L4_bin}$yearnum$month$day.bin
            out_file_nc=${year//DATA_L4/DATA_L4_new}$yearnum$month$day.nc
            $src_dir/netcdf_mean_to_bin.exe "$indv_files" "$out_file" "$out_file_nc"
        done
    done
done