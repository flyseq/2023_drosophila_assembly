#! /bin/bash
#
#SBATCH --job-name=AM_asm
#SBATCH --time=144:00:00
#SBATCH --partition=dpetrov,hns
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=4G

. /home/users/bkim331/.bashrc
conda activate snakemake
SPECIES="A.minor" snakemake --cores 16 --jobs 30 --use-singularity \
    --rerun-incomplete -s Snakefile.R1041 --restart-times 20 \
    --cluster "sbatch -p {cluster.partition} --mem {cluster.mem} -c {cluster.cpus-per-task} --time {cluster.time} -C {cluster.constraint} --gres {cluster.gpus}" \
    --cluster-config cluster_config.yml --singularity-args ' --nv' --cluster-cancel "scancel" \
    A.minor.passReads.guppy642.fastq.gz A.minor.medaka.fasta
