#!/usr/bin/env bash
set -euo pipefail

# Activate environment
conda activate rmats-env

OUTDIR="data/raw"
mkdir -p "$OUTDIR"

# SRA accessions: 2 WT heart + 2 Mbnl1 KO heart replicates
ACCESSIONS=(
    SRR497699   # WT heart rep1
    SRR497700   # WT heart rep2
    SRR497704   # Mbnl1 KO heart rep1
    SRR497705   # Mbnl1 KO heart rep2
)

for SRR in "${ACCESSIONS[@]}"; do
    echo "Downloading $SRR ..."
    prefetch "$SRR" --output-directory "$OUTDIR"
    fastq-dump --split-files --gzip --outdir "$OUTDIR" "$OUTDIR/${SRR}/${SRR}.sra"
    echo "Done: $SRR"
done

# Download mm10 reference genome (chromosome-level FASTA)
echo "Downloading mm10 reference genome..."
mkdir -p data/reference
wget -P data/reference \
    ftp://ftp.ensembl.org/pub/release-102/fasta/mus_musculus/dna/Mus_musculus.GRCm38.dna.primary_assembly.fa.gz

# Download Ensembl mm10 GTF (release 102)
wget -P data/reference \
    ftp://ftp.ensembl.org/pub/release-102/gtf/mus_musculus/Mus_musculus.GRCm38.102.gtf.gz

# Decompress
gunzip data/reference/*.gz

echo "All downloads complete."