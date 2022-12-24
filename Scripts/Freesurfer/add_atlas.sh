#!/bin/bash

SUBJECTS_DIR_NKI=/home/brunovieira/Tamires_Experiments/Data/Nki_data

for subject in $SUBJECTS_DIR_NKI
do
    #subject="${folder:6:9}" 
    for hemisphere in rh lh
    do
        mris_ca_label \
            -sdir $SUBJECTS_DIR_NKI/ \
            $subject \
            $hemisphere \
            sphere.reg \
            /home/brunovieira/Tamires_Experiments/Data/Brainnetome/$hemisphere.BN_Atlas.gcs \
            $SUBJECTS_DIR_NKI/$subject/label/$hemisphere.BN_Atlas.annot
    done
done