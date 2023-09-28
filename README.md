# Drosophila genome analysis workflows
This repository contains scripts, Snakemake workflows, and Dockerfiles
used for genome assembly in our latest manuscript [LINK].

## Setting up for genome assembly

### Container setup
The system used for building images must have Docker and/or Singularity 
(recommended) set up for the builds to run properly. Some images may not 
work properly without an NVIDIA graphics card. We generally use Ubuntu 
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
