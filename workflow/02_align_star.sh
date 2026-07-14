#!/usr/bin/env bash
set -euo pipefail

# Initialize conda
if [ -f "$HOME/miniforge3/etc/profile.d/conda.sh" ]; then
    source "$HOME/miniforge3/etc/profile.d/conda.sh"
elif [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
    source "$HOME/miniconda3/etc/profile.d/conda.sh"
elif [ -f "$HOME/anaconda3/etc/profile.d/conda.sh" ]; then
    source "$HOME/anaconda3/etc/profile.d/conda.sh"
fi

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

# ──────────────────────────────────────────────────────────────────────────
# Step 1: Decompress all FASTQ files
# (This avoids STAR's readFilesCommand subprocess PATH issues)
# ──────────────────────────────────────────────────────────────────────────
echo "Step 1: Decompressing FASTQ files..."
for SRR in "${!SAMPLES[@]}"; do
    if [ -f "${RAW}/${SRR}_1.fastq.gz" ] && [ ! -f "${RAW}/${SRR}_1.fastq" ]; then
        echo "  Decompressing ${SRR}_1.fastq.gz..."
        gunzip -c "${RAW}/${SRR}_1.fastq.gz" > "${RAW}/${SRR}_1.fastq"
    fi
    if [ -f "${RAW}/${SRR}_2.fastq.gz" ] && [ ! -f "${RAW}/${SRR}_2.fastq" ]; then
        echo "  Decompressing ${SRR}_2.fastq.gz..."
        gunzip -c "${RAW}/${SRR}_2.fastq.gz" > "${RAW}/${SRR}_2.fastq"
    fi
done
echo "Decompression complete."

# ──────────────────────────────────────────────────────────────────────────
# Step 2: Align with STAR using uncompressed FASTQs
# ──────────────────────────────────────────────────────────────────────────
echo "Step 2: Aligning samples with STAR..."
for SRR in "${!SAMPLES[@]}"; do
    LABEL="${SAMPLES[$SRR]}"
    OUTPREFIX="${ALIGNED}/${LABEL}_"
    echo "Aligning $LABEL ($SRR)..."

    # Check which FASTQ files exist (single-end or paired-end)
    if [ -f "${RAW}/${SRR}_1.fastq" ] && [ -f "${RAW}/${SRR}_2.fastq" ]; then
        # Paired-end
        echo "  -> Paired-end alignment"
        STAR \
            --runThreadN 4 \
            --genomeDir "$GENOME_DIR" \
            --readFilesIn "${RAW}/${SRR}_1.fastq" "${RAW}/${SRR}_2.fastq" \
            --outSAMtype BAM SortedByCoordinate \
            --outSAMattributes NH HI AS NM MD \
            --outFileNamePrefix "$OUTPREFIX" \
            --sjdbGTFfile "$GTF" \
            --outSAMstrandField intronMotif \
            --outFilterIntronMotifs RemoveNoncanonical \
            --limitBAMsortRAM 4000000000
    elif [ -f "${RAW}/${SRR}_1.fastq" ]; then
        # Single-end
        echo "  -> Single-end alignment"
        STAR \
            --runThreadN 4 \
            --genomeDir "$GENOME_DIR" \
            --readFilesIn "${RAW}/${SRR}_1.fastq" \
            --outSAMtype BAM SortedByCoordinate \
            --outSAMattributes NH HI AS NM MD \
            --outFileNamePrefix "$OUTPREFIX" \
            --sjdbGTFfile "$GTF" \
            --outSAMstrandField intronMotif \
            --outFilterIntronMotifs RemoveNoncanonical \
            --limitBAMsortRAM 4000000000
    else
        echo "ERROR: No FASTQ files found for $SRR"
        exit 1
    fi

    # Index the BAM
    echo "  Indexing BAM..."
    samtools index "${OUTPREFIX}Aligned.sortedByCoord.out.bam"
    echo "Done: $LABEL"
done

echo "All alignments complete."