#!/bin/bash

#BATCH --job-name=mpi_job           # Job name
#SBATCH --ntasks=1                   # Number of MPI tasks (i.e. processes)
#SBATCH --mem=4gb                    # Job memory request
#SBATCH --nodes=1                    # Maximum number of nodes to be allocated
#SBATCH --time=30:00:00              # Wall time limit (days-hrs:min:sec)
#SBATCH --output=/home/brunovieira/Tamires_Experiments/Outputs/Logs/mpi_%j.log          # Path to the standard output and error files relative to the working directory
#SBATCH --exclude=clusterneuromat,c01 # Exclude front node and c01

SUBJECTS_DIR_NKI=/home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data

execute_freesufer_analyses(){
    mkdir -p $SUBJECTS_DIR_NKI/$1/mri/orig/
    echo "============= Initianting nii conversion to mgz ============="
    # Convert
    mri_convert \
        --in_type nii \
        --out_type mgz \
        /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nkienhanced/$2 \
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
            /home/brunovieira/Tamires_Experiments/Bases_de_Dados/AtlasCollection/Economo/$hemisphere.atlas.gcs \
            $SUBJECTS_DIR_NKI/$1/label/$hemisphere.Eco.annot 
    done
}

execute_freesufer_analyses A00066926 ./sub-A00066926/ses-NFB3/anat/sub-A00066926_ses-NFB3_T1w.nii.gz
