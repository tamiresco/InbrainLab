#!/bin/bash

dir=/home/brunovieira/backup/Tamires_Experiments/Data/Nki_data

# use find command to get all subfolders
folders=`find "$dir" -type d -mindepth 1 -maxdepth 1`

# loop through the list of subfolders
for folder in $folders; do
    subject=$(basename "$folder")
    echo "$subject"
    for hemisphere in rh lh; do
        mris_ca_label \
            -sdir $dir/ \
            $subject \
            $hemisphere \
            sphere.reg \
            /home/brunovieira/backup/Tamires_Experiments/Data/Brainnetome/$hemisphere.BN_Atlas.gcs \
            $dir/$subject/label/$hemisphere.BN_Atlas.annot
    done
done


#for subject in $SUBJECTS_DIR_NKI
#do
    #subject="${folder:6:9}" 
 #   for hemisphere in rh lh
  #  do
   #     mris_ca_label \
    #        -sdir $SUBJECTS_DIR_NKI/ \
     #       $subject \
      #      $hemisphere \
       #     sphere.reg \
        #    /home/brunovieira/backup/Tamires_Experiments/Data/Brainnetome/$hemisphere.BN_Atlas.gcs \
         #   $SUBJECTS_DIR_NKI/$subject/label/$hemisphere.BN_Atlas.annot
   # done
#done
