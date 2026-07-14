#!/usr/bin/env bash
set -euo pipefail

conda activate rmats-env

GTF="data/reference/Mus_musculus.GRCm38.102.gtf"
OUTDIR="results/rmats_output"
TMPDIR="tmp/rmats_tmp"

mkdir -p "$OUTDIR" "$TMPDIR"

python $(which rmats.py) \
    --b1 config/b1.txt \
    --b2 config/b2.txt \
    --gtf "$GTF" \
    --od "$OUTDIR" \
    --tmp "$TMPDIR" \
    -t paired \
    --readLength 100 \           # adjust to actual read length (check FastQC)
    --nthread 8 \
    --tstat 8 \
    --cstat 0.0001 \
    --libType fr-unstranded \    # check strandedness of GSE39911; fr-unstranded is typical
    --task both                  # run prep + post in one step (fine for small datasets)

echo "rMATS complete. Results in: $OUTDIR"
ls "$OUTDIR"/*.txt