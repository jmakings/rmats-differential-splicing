conda activate rmats-env

# Run FastQC on the aligned BAMs (quick QC)
fastqc -t 4 data/aligned/*.bam -o results/

# Aggregate with MultiQC
multiqc data/aligned/ -o results/multiqc_report/