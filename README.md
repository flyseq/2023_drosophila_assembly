# Drosophila genome analysis workflows
This repository contains scripts, Snakemake workflows, and Dockerfiles
used for genome assembly in our latest manuscript [LINK].

## Setting up for genome assembly

### Container setup
The system used for building images must have Docker and/or Singularity 
(recommended) set up for the builds to run properly. Most of these workflows will not 
work out of the box without an NVIDIA graphics card. We generally use Ubuntu 
22.04 (native installation) and Ubuntu 22.04 on Windows with WSL2 for this.

For Nanopore base calling and assembly, an NVIDIA graphics card of the
Pascal (GTX 1000) generation or later should be installed as well as
NVIDIA/CUDA drivers and NVIDIA Docker. While the NVIDIA hardware and
libraries are *technically* not required, the pipeline is
prohibitively slow without GPU acceleration.

The following software must be installed to get images to build. Once
a Singularity image has been built, it can be transferred to and run
on any system with Singularity installed (e.g. a cluster) without 
elevated privileges.

* Docker: https://docs.docker.com/get-docker/  
* Singularity: https://docs.sylabs.io/guides/latest/user-guide/ 
* NVIDIA-Docker: https://github.com/NVIDIA/nvidia-docker

NVIDIA drivers are easily installed on Ubuntu systems with:    
```bash
ubuntu-drivers devices
sudo ubuntu-drivers autoinstall
```

Also note, the CUDA libraries do not have to be installed on the host
machine, just the drivers. Use `nvidia-smi` inside a running container
to check that drivers are installed and working and that the graphics card is
detected.

### Building Docker/Singularity images

Once Docker and Singularity have been installed, an image is built
from the supplied Dockerfiles. Note, these images contains all
libraries/programs sufficient to run the steps of our pipelines.
From the directory containing the Dockerfile of interest, run the
following code to build the Docker image. For example, to build the
Nanopore assembly image from the root directory of this repository:
```bash
cd dockerfiles/assembly

imageName="assembly"
sudo Docker build -t ${imageName} .
```  
Once the image is built, a Docker container can be launched with the image. The 
```--gpus all``` argument allows the container to access GPU resources; this can be 
omitted if you are not running a GPU image.
```bash
sudo docker run --gpus all -i -t assembly:latest
```
Because the Docker daemon requires root permissions we use Singularity 
to run containers on the cluster. A Singularity image is built from
the Docker image with the following command:
```bash
imageName="assembly"
sudo singularity build ${imageName}.simg \
    docker-daemon://${imageName}:latest
```  
The resulting `assembly.simg` Singularity image can be used to execute commands 
on the cluster. For example, to start an interactive shell at the current
working directory, use:
```bash
singularity shell --nv ${imageName}.simg
```
Similar to the Docker command above, omit the ```--nv``` argument if GPUs are
not needed for the workflow. Once the Singularity image is built, it can be
copied to a different system and run immediately.

### Installing Conda/Mamba
Miniconda is installed from the scripts here: https://docs.conda.io/en/latest/miniconda.html

Once Conda is installed, Mamba is installed into the base environment with
```bash
conda install -c conda-forge mamba
```

### Installing Snakemake
Snakemake is used to manage workflows both locally and on the cluster. Install
Snakemake into a new environment with Mamba:
```bash
mamba create -c conda-forge -c bioconda -n snakemake snakemake
```

## Haploid genome assembly

The genome assembly pipeline is run with a single command to execute the Snakemake pipeline.

It can either be run with Illumina data,
```bash
snakemake --cores $(nproc) --jobs $(nproc) --use-singularity --singularity-args ' --nv' \
  --config sample="D.melanogaster" fwd="D.melanogaster_R1.fastq.gz" rev="D.melanogaster_R2.fastq.gz" \
  --rerun-incomplete
```

Or without Illumina data.
```bash
snakemake --cores $(nproc) --jobs $(nproc) --use-singularity --singularity-args ' --nv' \
  --config sample="D.melanogaster" --rerun-incomplete
```

Before the pipeline can be run, some initial setup is needed. The Snakemake workflow
is guided by the `Snakemake` file and the `config.yaml` configuration file. The following things should be
set up and defined correctly in the config file:

* Download/build Singularity images, and add paths to configfile:
  + Genome assembly image
  + NCBI fcs-adaptor (https://github.com/ncbi/fcs/wiki/FCS-adaptor)
  + NCBI fcsgx (https://github.com/ncbi/fcs/wiki/FCS-GX)
  + TETools (`https://github.com/Dfam-consortium/TETools`)
  + NVIDIA Parabricks (`https://catalog.ngc.nvidia.com/orgs/nvidia/teams/clara/containers/clara-parabricks`)
  + PEPPER-Margin-Deepvariant (`https://github.com/kishwarshafin/pepper`)

* Set up NCBI Foreign Contamination Screen
  + Download database, instructions at https://github.com/ncbi/fcs
  + Know what NCBI Taxonomy ID characterizes your organism

* Set Guppy/Medaka [models](https://github.com/epi2me-labs/wf-bacterial-genomes/blob/master/data/medaka_models.tsv)
  + Some Guppy models:
     - R9.4.1: `dna_r9.4.1_450bps_sup.cfg`
     - R10.4.1 400bps: `dna_r10.4.1_e8.2_400bps_sup.cfg`
     - R10.4.1 400bps 5khz: `dna_r10.4.1_e8.2_400bps_5khz_sup.cfg`
  + Some Medaka models:
     - R9.4.1: `r941_min_sup_g507`
     - R10.4.1: `r1041_e82_400bps_sup_v4.1.0`
     - R10.4.1 400bps 5khz: `r1041_e82_400bps_sup_v4.2.0`

* There are a few other settings/flags, some ONT chemistry-specific, that can be set in `config.yaml`.

### Input files
For each genome assembly, the following data are expected:
* Nanopore raw data (`./{sample}/` folder containing fast5/pod5 files) *or*  gzipped basecalls (`{sample}.fastq.gz`)
* Illumina paired-end reads (`{sample}_R1.fastq.gz`,`{sample}_R2.fastq.gz`)

This information is passed to Snakemake through 
`--config sample="D.melanogaster" fwd="D.melanogaster_R1.fastq.gz" rev="D.melanogaster_R2.fastq.gz"`

### Output files
- For all assemblies:
  * basecalled reads: `{sample}.fastq.gz`
  * raw Flye assembly: `{sample}.flye.fasta`
  * unmasked genome: `{sample}.cleaned.fasta`
  * NCBI Foreign Contamination Screen Report: `{sample}.fcs.report`
  * soft-masked genome: `{species}.rm.fasta`
  * repeat library: `{species}-families.fa` and `{species}-families.stk`
  * repeat annotations: `{species}.out.gff`
  * PEPPER-Margin-DeepVariant VCF: `{sample}.vcf.gz`
  * PEPPER-Margin-DeepVariant gVCF: `{sample}.g.vcf.gz`
  * P-M-D QV estimate: `{sample}.PMDqv.out`
- Assemblies with Illumina data additionally produce:
  * Merqury QV (single score): `{sample}.merqury.qv`
  * Merqury QV (by contig/chr): `{sample}.merqury.genome.qv`
  * Merqury completeness: `{sample}.merqury.completeness.stats`
  * Yak QV: `{sample}.yak.out`

## Progressive Cactus alignment
A preliminary version of the Progressive Cactus alignment can be downloaded 
[from this Google Drive link](https://drive.google.com/file/d/18GWhgdOo-IrvxwjLKJnpMLiCpWvsOFYu/view?usp=drive_link).
Note that genomes are subject to minor changes following submittion to NCBI GenBank.
A final alignment will eventually be archived at Dryad: DOI (10.5061/dryad.x0k6djhrd)


