#!/usr/bin/env bash
set -euo pipefail

conda activate rmats-env

GENOME_DIR="data/reference/star_index_mm10"
GTF="data/reference/Mus_musculus.GRCm38.102.gtf"
RAW="data/raw"
ALIGNED="data/aligned"

mkdir -p "$ALIGNED"

# Define samples: (SRR, label) pairs
declare -A SAMPLES=(
    ["SRR497699"]="WT_heart_rep1"
    ["SRR497700"]="WT_heart_rep2"
    ["SRR497704"]="KO_heart_rep1"
    ["SRR497705"]="KO_heart_rep2"
)

for SRR in "${!SAMPLES[@]}"; do
    LABEL="${SAMPLES[$SRR]}"
    OUTPREFIX="${ALIGNED}/${LABEL}_"
    echo "Aligning $LABEL ($SRR)..."

    STAR \
        --runThreadN 4 \
        --genomeDir "$GENOME_DIR" \
        --readFilesIn "${RAW}/${SRR}_1.fastq.gz" "${RAW}/${SRR}_2.fastq.gz" \
        --readFilesCommand zcat \
        --outSAMtype BAM SortedByCoordinate \
        --outSAMattributes NH HI AS NM MD \
        --outFileNamePrefix "$OUTPREFIX" \
        --sjdbGTFfile "$GTF" \
        --outSAMstrandField intronMotif \
        --outFilterIntronMotifs RemoveNoncanonical \
        --limitBAMsortRAM 4000000000
        # --limitBAMsortRAM caps the BAM coordinate-sort step at 4GB.
        # Without this, the sort can spike unexpectedly on 16GB machines.
        # Safe to remove or increase if you have more RAM available.

    # Index the BAM
    samtools index "${OUTPREFIX}Aligned.sortedByCoord.out.bam"
    echo "Done: $LABEL"
done

echo "All alignments complete."