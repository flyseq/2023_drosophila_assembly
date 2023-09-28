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
