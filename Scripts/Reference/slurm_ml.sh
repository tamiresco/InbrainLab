#!/bin/bash

#BATCH --job-name=mpi_job           # Job name
#SBATCH --ntasks=1                   # Number of MPI tasks (i.e. processes)
#SBATCH --output=/home/brunovieira/Tamires_Experiments/Outputs/Logs/mpi_%j.log          # Path to the standard output and error files relative to the working directory
#SBATCH --exclude=clusterneuromat,c01 # Exclude front node and c01

python /home/brunovieira/Tamires_Experiments/Scripts/tamires_ml.py --sample_size 600 
