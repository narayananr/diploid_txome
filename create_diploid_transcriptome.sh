#!/bin/bash
#PBS -l nodes=1:ppn=1,walltime=23:00:00
cd $PBS_O_WORKDIR
module load Anaconda
source activate g2gtools
source activate emase
module load tabix

# Sanger genetic variation
# ftp://ftp-mouse.sanger.ac.uk/REL-1410-SNPs_Indels/
sanger_snp=mgp.v4.snps.dbSNP.vcf.gz
sanger_indel=mgp.v4.indels.dbSNP.vcf.gz

# get NOD and PWK SNP and Indels from Sanger files
NOD_PWK_SNP=mgp_v4_snps_NOD_PWK.vcf
NOD_PWK_Indel=mgp_v4_indels_NOD_PWK.vcf
zcat ${sanger_snp} | awk 'BEGIN {OFS="\t"} {print $1,$2,$3,$4,$5,$6,$7,$8,$9,$30,$34}' > ${NOD_PWK_SNP}
zcat ${sanger_indel} | awk 'BEGIN {OFS="\t"} {print $1,$2,$3,$4,$5,$6,$7,$8,$9,$30,$34}' > ${NOD_PWK_Indel}

# bgzip the SNP and Indel file and index them 
bgzip -c ${NOD_PWK_SNP} > ${NOD_PWK_SNP}.gz
tabix -p vcf ${NOD_PWK_SNP}.gz
bgzip -c ${NOD_PWK_Indel} > ${NOD_PWK_Indel}.gz
tabix -p vcf ${NOD_PWK_Indel}.gz

# reference genome in fasta format
# ftp://ftp.ensembl.org/pub/release-75/gtf/mus_musculus/
REF=C57BL6J.fa
# strain name (usually a column name in the vcf file), e.g., CAST_EiJ
STRAIN1=NOD_ShiLtJ
STRAIN2=PWK_PhJ
mkdir -p ${STRAIN1}
mkdir -p ${STRAIN2}
###########
# g2gtools to create NOD specific genome and transcriptome
###########
# ftp://ftp.ensembl.org/pub/release-75/gtf/mus_musculus/
GTF=C57BL6J.gtf
# Create a chain file for mapping bases between two genomes. In this case, between reference and NOD
g2gtools vcf2chain -f ${REF} -i ${NOD_PWK_Indel}.gz -s ${STRAIN1} -o ${STRAIN1}/REF-to-${STRAIN1}.chain
# patch SNPs on to reference genome
g2gtools patch -i ${REF} -s ${STRAIN1} -v ${NOD_PWK_SNP}.gz -o ${STRAIN1}/${STRAIN1}.patched.fa
g2gtools transform -i ${STRAIN1}/${STRAIN1}.patched.fa -c ${STRAIN1}/REF-to-${STRAIN1}.chain -o ${STRAIN1}/${STRAIN1}.fa
g2gtools convert -c ${STRAIN1}/REF-to-${STRAIN1}.chain -i ${GTF} -f gtf -o ${STRAIN1}/${STRAIN1}.gtf
#g2gtools gtf2db -i ${STRAIN1}/${STRAIN1}.gtf -o ${STRAIN1}/${STRAIN1}.gtf.db
# extract transcripts from NOD genome
#g2gtools extract --transcripts -i ${STRAIN1}/${STRAIN1}.fa -db ${STRAIN1}/${STRAIN1}.gtf.db > ${STRAIN1}/${STRAIN1}.transcripts.fa

###########
# g2gtools to create PWK specific genome and transcriptome
###########
# Create a chain file for mapping bases between two genomes. In this case, between reference and PWK
g2gtools vcf2chain -f ${REF} -i ${NOD_PWK_Indel}.gz -s ${STRAIN2} -o ${STRAIN2}/REF-to-${STRAIN2}.chain
# patch SNPs on to reference genome
g2gtools patch -i ${REF} -s ${STRAIN2} -v ${NOD_PWK_SNP}.gz -o ${STRAIN2}/${STRAIN2}.patched.fa
g2gtools transform -i ${STRAIN2}/${STRAIN2}.patched.fa -c ${STRAIN2}/REF-to-${STRAIN2}.chain -o ${STRAIN2}/${STRAIN2}.fa
# PWK specific GTF file
g2gtools convert -c ${STRAIN2}/REF-to-${STRAIN2}.chain -i ${GTF} -f gtf -o ${STRAIN2}/${STRAIN2}.gtf
#g2gtools gtf2db -i ${STRAIN2}/${STRAIN2}.gtf -o ${STRAIN2}/${STRAIN2}.gtf.db
# extract transcripts from PWK genome
#g2gtools extract --transcripts -i ${STRAIN2}/${STRAIN2}.fa -db ${STRAIN2}/${STRAIN2}.gtf.db > ${STRAIN2}/${STRAIN2}.transcripts.fa

# use prepare-emase function  from emase package (not in g2gtools)
# to create diploid transcriptome from NOD and PWk genome and GTF files
GENOME1=${STRAIN1}/${STRAIN1}.fa
GENOME2=${STRAIN2}/${STRAIN2}.fa
GTF1=${STRAIN1}/${STRAIN1}.gtf
GTF2=${STRAIN2}/${STRAIN2}.gtf
SUFFIX1=N
SUFFIX2=P
EMASE_DIR=NxP
prepare-emase -G ${GENOME1},${GENOME2} -g ${GTF1},${GTF2} -s ${SUFFIX1},${SUFFIX2} -o ${EMASE_DIR} -m






