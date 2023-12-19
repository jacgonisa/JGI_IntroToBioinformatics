require 'bio'

# Parse command line arguments to get input and output file paths
file_path = ARGV[0]  # Input file path containing DNA sequences
output_file_path = ARGV[1]  # Output file path for amino acid sequences

# Read DNA sequences from the input file using BioRuby
sequences = Bio::FastaFormat.open(file_path)

# Open the output file for writing amino acid sequences
output_file = File.open(output_file_path, 'w')

# Translate DNA sequences to amino acid sequences and write to the output file
sequences.each do |sequence|
  # Create a BioRuby sequence object from the DNA sequence
  bio_sequence = Bio::Sequence::NA.new(sequence.seq)

  # Translate the DNA sequence to obtain the amino acid sequence
  amino_acid_sequence = bio_sequence.translate

  # Write the amino acid sequence along with sequence definition to the output file
  output_file.puts ">#{sequence.definition}"
  output_file.puts amino_acid_sequence
end

# Close the output file
output_file.close

# Display a message indicating successful completion
puts "Amino acid sequences have been saved to #{output_file_path}"

