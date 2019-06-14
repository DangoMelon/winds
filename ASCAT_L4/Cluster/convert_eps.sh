#!/bin/bash
#Created on Fri Apr 26 05:56:00 2019
#Author: Gerardo A. Rivera Tello
#Email: grivera@igp.gob.pe
#-----
#Copyright (c) 2019 Instituto Geofisico del Peru
#-----

files='*.eps'

cd Output || exit

for line in ${files}; do
    file=$(echo $line |awk -F. '{print $1}')
    convert -density 400 "$line" "${file}.png"
    convert "$line" "web/${file}.gif"
done

# cd ../Output_monitoreo || exit
# files='*.eps'
# for line in ${files}; do
#     file=$(echo $line |awk -F. '{print $1}')
#     convert -background white -alpha remove -alpha off -density 400 "$line" "${file}.png"
#     convert -background white -alpha remove -alpha off "$line" "web/${file}.gif"
# done

# files='nivelmar*.eps'
# for line in ${files}; do
#     file=$(echo $line |awk -F. '{print $1}')
#     convert -background white -alpha remove -alpha off -rotate 90 -density 400 "$line" "${file}.png"
#     convert -background white -alpha remove -alpha off -rotate 90 "$line" "web/${file}.gif"
# done

# cd hist || exit
# files='*.eps'
# for line in ${files}; do
#     file=$(echo $line |awk -F. '{print $1}')
#     convert -density 400 "$line" "${file}.png"
#     convert "$line" "web/${file}.gif"
# done

# files='*trend*.eps'
# for line in ${files}; do
#     file=$(echo $line |awk -F. '{print $1}')
#     convert -rotate 90 -density 400 "$line" "${file}.png"
#     convert -rotate 90 "$line" "web/${file}.gif"
# done