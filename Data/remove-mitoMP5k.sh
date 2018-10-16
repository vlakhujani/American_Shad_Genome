#!/bin/bash -l
# author: rfitak
#SBATCH -J MP5k
#SBATCH -o MP5krmMito.out
#SBATCH -e MP5krmMito.err
#SBATCH -p biodept
#SBATCH -n 1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH -t 12:00:00
#SBATCH --mem-per-cpu=8000
#SBATCH --mail-type=END
#SBATCH --mail-user=rfitak9@gmail.com

cd /datacommons/netscratch/frr6/SHAD_GENOME
name="MP5k"

# Do Mapping for PE reads
bowtie2 \
   --phred33 \
   -q \
   --very-sensitive \
   --minins 2000 \
   --maxins 10000 \
   --rf \
   --threads 8 \
   --reorder \
   -x Asap_mito \
   -1 ${name}_F.trimmed.uniq.unj.fq.gz \
   -2 ${name}_R.trimmed.uniq.unj.fq.gz | \
   samtools1.3 view -b -F 2 | \
   samtools1.3 sort -T ${name}.tmp -n -O bam | \
   bedtools bamtofastq -i - -fq ${name}_F.trimmed.uniq.unj.noMito.fq -fq2 ${name}_R.trimmed.uniq.unj.noMito.fq

# Get Stats
seqtk fqchk -q20 <(cat ${name}_*.trimmed.uniq.unj.noMito.fq) | head
seqtk fqchk -q30 <(cat ${name}_*.trimmed.uniq.unj.noMito.fq) | head

# Compress the resulting reads
gzip ${name}_F.trimmed.uniq.unj.noMito.fq
gzip ${name}_R.trimmed.uniq.unj.noMito.fq
