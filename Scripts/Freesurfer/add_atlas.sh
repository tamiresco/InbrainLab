#!/bin/bash

dir=/home/brunovieira/backup/Tamires_Experiments/Data/Nki_data

# use find command to get all subfolders
folders=`find "$dir" -type d -mindepth 1 -maxdepth 1`

# loop through the list of subfolders
for folder in $folders; do
    subject=$(basename "$folder")
    #echo "$subject"
    for hemisphere in rh lh; do
        if [ -f "$dir/$subject/label/$hemisphere.BN_Atlas.annot" ]; then
            #echo "File already exists, skipping."
            :
        else
            echo "$subject"
            #mris_ca_label \
                #-sdir $dir/ \
                #$subject \
                #$hemisphere \
                #sphere.reg \
                #/home/brunovieira/backup/Tamires_Experiments/Data/Brainnetome/$hemisphere.BN_Atlas.gcs \
                #$dir/$subject/label/$hemisphere.BN_Atlas.annot
        fi
    done
done
