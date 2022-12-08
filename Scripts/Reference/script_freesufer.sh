#!/bin/bash

execute_freesufer_analyses(){
    mkdir -p $SUBJECTS_DIR_NKI/$1/mri/orig/
    echo "============= Initianting nii conversion to mgz ============="
    # Convert
    mri_convert \
        --in_type nii \
        --out_type mgz \
        /home/brunovieira/nkienhanced/$2 \
        $SUBJECTS_DIR_NKI/$1/mri/orig/001.mgz    
    echo "============= Initianting recon-all FreeSufer ============="
    # Run FreeSufer
    recon-all \
        -subject $1\
        -all \
        -sd $SUBJECTS_DIR_NKI
    echo "============= Initianting Add Atlas ============="
    for h in rh lh
    do
        # define hemisphere
        hemisphere=$h
        # Add Atlas - sphere.annot
        mris_ca_label \
            -sdir $SUBJECTS_DIR_NKI/ \
            $1\
            $hemisphere \
            sphere.reg \
            /home/brunovieira/AtlasCollection/Economo/$hemisphere.atlas.gcs \
            $SUBJECTS_DIR_NKI/$1/label/$hemisphere.Eco.annot 
    done
}

# Define data directory
touch processed_subjects.txt 
SUBJECTS_DIR_NKI=/home/brunovieira/freesurfer/nki_data
echo $1
sed -n "1,${1}p" nkienhanced.txt | while read line
do
    #Creating Directory
    subject_file=$line
    subject="${subject_file:6:9}"
    echo "===================== Processing subject: $subject =====================" 
    while read processed
    do
        if [ $subject == $processed ]
        then
            echo "Subject already have been processed" 
            continue 2
        fi
    done < processed_subjects.txt
    echo $subject >> processed_subjects.txt
    execute_freesufer_analyses $subject $subject_file &
    sleep 90s
done

