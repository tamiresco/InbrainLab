#!/bin/bash

# Define data directory
DIR_SCR=/home/brunovieira/Tamires_Experiments/Scripts/ImageProcessing
SUBJECTS_DIR_NKI=/home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data

touch $DIR_SCR/processed_subjects.txt 
echo $1
sed -n "1,/$1/p" $DIR_SCR/nkienhanced.txt | while read line
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
    done < $DIR_SCR/processed_subjects.txt
    echo $subject >> $DIR_SCR/processed_subjects.txt

    cp $DIR_SCR/script_slurm_.sh $DIR_SCR/script_slurm_subs/script_slurm_${subject}.sh
    echo execute_freesufer_analyses $subject $subject_file >> $DIR_SCR/script_slurm_subs/script_slurm_${subject}.sh
    sbatch $DIR_SCR/script_slurm_subs/script_slurm_${subject}.sh
done


