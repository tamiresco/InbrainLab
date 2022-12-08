#!/bin/bash

# Define data directory
touch processed_subjects.txt 
SUBJECTS_DIR_NKI=/home/brunovieira/freesurfer/nki_data
echo $1
sed -n "1,/$1/p" nkienhanced.txt | while read line
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

    cp ./script_slurm_.sh ./script_slurm_${subject}.sh
    echo execute_freesufer_analyses $subject $subject_file >> ./script_slurm_${subject}.sh
    sbatch ./script_slurm_${subject}.sh
done


