#!/bin/bash
#Created on Mon Jun 3 03:11:25 2019
#Author: Gerardo A. Rivera Tello
#Email: grivera@igp.gob.pe
#-----
#Copyright (c) 2019 Instituto Geofisico del Peru
#-----

scripts_dir=/data/users/service/ASCAT_L4
data_dir=/data/datos/ASCAT/DATA_L4
bin_dir=/data/datos/ASCAT/DATA_L4_bin
new_dir=/data/datos/ASCAT/DATA_L4_new

export LD_LIBRARY_PATH="/usr/local/netcdf-fortran/4.4.3/gnu4.8.5/lib64:${LD_LIBRARY_PATH}"

cd $scripts_dir || exit

# Run Download script
# sh download_winds_l4_blend.sh

# Activate environment
# source /home/service/miniconda3/etc/profile.d/conda.sh
# conda activate cluster
# python Daily/src/find_missing.py

# Update ctl with new file count
file_count=$(find $data_dir -name '*.nc' | wc -l)
echo "$file_count total files"

# sed into base template
sed "s/NTIME/$file_count/" ctl_template/winds_l4_blended_template.ctl >$data_dir/winds_l4_blended.ctl

# Update ctl with new file count
file_count=$(find $new_dir -name '*.nc' | wc -l)
echo "$file_count total files"

sed "s/NTIME/$file_count/" ctl_template/winds_l4_blended_new_template.ctl >$new_dir/winds_l4_blended_new.ctl
sed "s/NTIME/$file_count/" ctl_template/winds_l4_blended_bin_template.ctl >$bin_dir/winds_l4_blended_bin.ctl

# Plot setup
cd plot_scripts || exit

module unload grads/2.0.2 
module load opengrads/2.2.1.oga.1
export GADDIR=/opt/opengrads/2.2.1.oga.1/data

#Plot scripts

/opt/opengrads/2.2.1.oga.1/bin/grads -bpc plot_taux_blend_era.gs
/opt/opengrads/2.2.1.oga.1/bin/grads -bpc plot_taux_blend.gs
/opt/opengrads/2.2.1.oga.1/bin/grads -bpc serie_taux_eq_blend_era.gs
/opt/opengrads/2.2.1.oga.1/bin/grads -bpc serie_taux_eq_blend.gs

cd $scripts_dir || exit
sh convert_eps.sh

cd Output || exit
cat >.chavin.log <<EOF
cd /home/web/www/variabclim/PRODUCTO_BLENDED/eq
mput *png
cd /home/web/www/variabclim/img/PRODUCTO_BLENDED/eq/
mput web/*gif
bye
EOF

sftp web < .chavin.log