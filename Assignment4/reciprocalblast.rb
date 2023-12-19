require 'bio'

## DATABASES FILENAMES
arabidopsis_db = ARGV[0]
spombe_db = ARGV[1]

# Define the paths to the databases
arabidopsis_db_path = "./databases/#{arabidopsis_db}"
spombe_db_path = "./databases/#{spombe_db}"

# Output file for ortholog pairs
output_file_path = './results/ortholog_pairs.tsv'

## COUNTING THE NUMBER OF GENES TO CHECK
# Read the total number of genes from the S. pombe database file
total_genes = File.read('database_spombe.fa').scan(/^>/).size
count = 1  # Initialize a counter for gene processing

# BLAST factory for Arabidopsis database
arabidopsis_factory = Bio::Blast.local('blastp', arabidopsis_db_path, '-e 10e-6')
# BLAST factory for S. pombe database
spombe_factory = Bio::Blast.local('blastp', spombe_db_path, '-e 10e-6')

# Open the output file for writing ortholog pairs
output_file = File.open(output_file_path, 'w')
output_file.puts "S_pombe_protein\tArabidopsis_protein\tE-value"

puts('Reciprocal BLAST!')
puts
spombe_proteome = Bio::FastaFormat.open('./database_spombe.fa')

# Iterate over each S. pombe sequence and perform reciprocal BLAST
spombe_proteome.each do |spombe_seq|
  # Perform BLAST search in S. pombe database
  warn "Gene #{count} out of #{total_genes}"
  count += 1
  warn "Searching ... #{spombe_seq.entry_id} ortholog in Arabidopsis"
  arabidopsis_report = arabidopsis_factory.query(spombe_seq.seq)

  # Get the first hit with e-value < 0.001
  arabidopsis_hit = arabidopsis_report.hits.first

  # If there is no hit, the query is skipped
  next if arabidopsis_hit.nil?

  # Perform reciprocal BLAST in Arabidopsis database
  arabidopsis_query = arabidopsis_hit.target_seq
  spombe_reciprocal_report = spombe_factory.query(arabidopsis_query)

  # Get the first hit in the reciprocal search
  spombe_reciprocal_hit = spombe_reciprocal_report.hits.first
  next if spombe_reciprocal_hit.nil?

  # Check if it's a reciprocal best hit
  if spombe_reciprocal_hit.definition.split('|')[0] == spombe_seq.entry_id
    output_file.puts "#{spombe_seq.entry_id}\t#{arabidopsis_hit.definition.split('|')[0]}\t#{arabidopsis_hit.evalue}"
  end
end

# Close the output file
output_file.close

# Display a message indicating successful completion
puts "Ortholog pairs have been saved to #{output_file_path}"

