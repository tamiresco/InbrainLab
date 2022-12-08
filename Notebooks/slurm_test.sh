#!/bin/bash

#BATCH --job-name=mpi_job           # Job name
#SBATCH --ntasks=1                   # Number of MPI tasks (i.e. processes)
#SBATCH --output=/home/brunovieira/Tamires_Experiments/Outputs/Logs/mpi_%j.log          # Path to the standard output and error files relative to the working directory
#SBATCH --exclude=clusterneuromat,c01,c02,c03,c04,c05 # Exclude front nodes

python /home/brunovieira/Tamires_Experiments/Notebooks/main.py 
