#!/bin/bash
#Created on Thu Mar 28 07:27:58 2019
#Author: Gerardo A. Rivera Tello
#Email: grivera@igp.gob.pe
#-----
#Copyright (c) 2018 Instituto Geofisico del Peru
#-----


input="ftp://nrt.cmems-du.eu/Core/WIND_GLO_WIND_L4_NRT_OBSERVATIONS_012_004/CERSAT-GLO-BLENDED_WIND_L4-V6-OBS_FULL_TIME_SERIE"
alias netcdf_bin="/data/users/service/ASCAT_L4/Daily/src/netcdf_mean_to_bin.exe"
echo "Downloading data"

# Set up the environment
export LD_LIBRARY_PATH="/usr/local/netcdf-fortran/4.4.3/gnu4.8.5/lib64:${LD_LIBRARY_PATH}"

for i in {7..0}; do
    fecha=$(date +%Y%m%d -d "-$i day")
    year=${fecha:0:4}
    month=${fecha:4:2}
    output="/data/datos/ASCAT/DATA_L4/$year"
    bin_out="/data/datos/ASCAT/DATA_L4_bin/$year"
    new_out="/data/datos/ASCAT/DATA_L4_new/$year"
    cd "$output" || mkdir -p "$output"
    rm -- "$output/"*"$fecha"*.nc*

    wget --user=$CMEMSuser --password=$CMEMSpass -nc -np -r -nH --cut-dirs=5 "$input/$year/$month/"*"$fecha"*-IFR-*.nc -P "$output"

    cd "$output" || echo "Output folder not found"
    for f in *-IFR-*.nc; do
        mv "$f" "${f%*-IFR-*.*.nc}.nc"
    done
    indv_files=$(ls $fecha*.nc)
    netcdf_bin "$indv_files" "$bin_out/$fecha".bin "$new_out/$fecha".nc
    
done

exit 0
