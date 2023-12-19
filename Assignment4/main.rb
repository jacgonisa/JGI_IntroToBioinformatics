## Creating directories for logs, databases, and results
system('mkdir logs')
system('mkdir databases')
system('mkdir results')

# Preprocessing step
system('ruby preprocessing.rb TAIR10_cds_20101214_updated.fa ./logs/TAIR10_cds_20101214_updated_aminoacid.fa')

# Creating databases
# S. pombe
system("makeblastdb -in database_spombe.fa -dbtype 'prot' -out databases/database_spombe")

# Arabidopsis
# Cleaning Arabidopsis amino acid sequence data by removing asterisks
system("cat ./logs/TAIR10_cds_20101214_updated_aminoacid.fa | sed 's#*###' > ./logs/TAIR10_cds_20101214_updated_amino_acid_clean.fa")
# Creating Arabidopsis database
system("makeblastdb -in ./logs/TAIR10_cds_20101214_updated_amino_acid_clean.fa -dbtype 'prot' -out databases/database_arabidopsis")

# Reciprocal Blast
system('ruby reciprocalblast.rb database_arabidopsis database_spombe')

