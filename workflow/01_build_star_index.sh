#!/usr/bin/env bash
set -euo pipefail

conda activate rmats-env

GENOME_DIR="data/reference/star_index_mm10"
mkdir -p "$GENOME_DIR"

# Memory check:
# Default STAR index build for mm10 requires ~30GB RAM.
# If you have 16GB RAM (such as my MacBook Pro), use sparse mode below -- confirmed by
# STAR author (alexdobin) to fit within 16GB. Both produce correct alignments;
# sparse mode is ~2-4x slower at alignment time but not at all during rMATS.
# If you have >= 32GB RAM, comment out sparse mode and uncomment standard mode.

# STANDARD MODE (>=32GB RAM) -- uncomment to use
# STAR \
#     --runThreadN 8 \
#     --runMode genomeGenerate \
#     --genomeDir "$GENOME_DIR" \
#     --genomeFastaFiles data/reference/Mus_musculus.GRCm38.dna.primary_assembly.fa \
#     --sjdbGTFfile data/reference/Mus_musculus.GRCm38.102.gtf \
#     --sjdbOverhang 99

# SPARSE MODE (16GB RAM -- default for local MacBook use)
# --genomeSAsparseD 3   : sparse suffix array; main RAM reduction flag
# --genomeSAindexNbases 12 : slightly reduced index precision (default is 14)
# --limitGenomeGenerateRAM : explicit cap; 14GB leaves ~2GB headroom for OS
# --runThreadN 4        : fewer threads = lower peak RAM during build
STAR \
    --runThreadN 4 \
    --runMode genomeGenerate \
    --genomeDir "$GENOME_DIR" \
    --genomeFastaFiles data/reference/Mus_musculus.GRCm38.dna.primary_assembly.fa \
    --sjdbGTFfile data/reference/Mus_musculus.GRCm38.102.gtf \
    --sjdbOverhang 99 \
    --genomeSAsparseD 3 \
    --genomeSAindexNbases 12 \
    --limitGenomeGenerateRAM 14000000000

echo "STAR index built successfully."
echo "Index location: $GENOME_DIR"