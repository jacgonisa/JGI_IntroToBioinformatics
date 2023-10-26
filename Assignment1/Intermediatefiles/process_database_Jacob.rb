require 'csv'

require './Gene_object.rb'
require './SeedStock_object.rb'
require './HybridCross_object.rb'

# Check if the correct number of arguments is provided
unless ARGV.count = 4
  puts "Usage: ruby process_database_Jacob.rb gene_information.tsv seed_stock_data.tsv cross_data.tsv new_stock_file.tsv"
  abort
end

# Assign the input file names to variables
gene_information_file, seed_stock_data_file, cross_data_file, output_file = ARGV

#########TASK 1#############

# Create an array of SeedStock objects by loading data from the file
my_seed_stock = SeedStock.load_from_file(seed_stock_data_file)

# Simulate planting 7 grams of seeds for all SeedStock objects
SeedStock.planting_simulation(my_seed_stock, 7)

# Specify the path to the output TSV file
output_file = output_file

# Use the class method to write the data to the output file
SeedStock.write_database(my_seed_stock, output_file)


#########TASK 2##############


# Read data from seed_stock.tsv AND link with gene names
seed_stock_data = CSV.read(seed_stock_data_file, col_sep: "\t", headers: true)
seed_stocks = seed_stock_data.map do |row|
  gene_id = row['Mutant_Gene_ID']
  seed_stock = SeedStock.new(row['Seed_Stock'], gene_id, row['Last_Planted'], row['Storage'], row['Grams_Remaining'])
  seed_stock
end

# Read data from cross_data.tsv
cross_data = CSV.read(cross_data_file, col_sep: "\t", headers: true)

# Create an array to store instances of the HybridCross class
hybrid_crosses = []

# Get the gene_id to gene_name mapping using the class method
gene_id_to_gene_name = Gene.build_gene_id_to_gene_name_mapping(gene_information_file)

# Iterate through the CSV data and create instances of HybridCross
cross_data.each do |row|
  hybrid_cross = HybridCross.new(
    row['Parent1'],
    row['Parent2'],
    row['F2_Wild'],
    row['F2_P1'],
    row['F2_P2'],
    row['F2_P1P2']
  )
  hybrid_cross.link_to_seed_stocks_and_genes_names(seed_stocks, gene_id_to_gene_name)
  chi_squared = hybrid_cross.chi_squared_test
  hybrid_cross.chi_squared = chi_squared
  hybrid_crosses << hybrid_cross
end

# Link gene names to hybrid crosses
statistically_significant_genes = hybrid_crosses.select { |gene| gene.statistically_significant }

puts "Recording:"
statistically_significant_genes.each do |gene|
  parent1_gene_name = gene.gene_name_parent1
  parent2_gene_name = gene.gene_name_parent2
  chi_squared = gene.chi_squared
  puts "#{parent1_gene_name} is linked to #{parent2_gene_name} with chi-squared score #{format('%.7f', chi_squared)}"
end

puts
puts "Final Report:"

statistically_significant_genes.each do |gene|
  parent1_gene_name = gene.gene_name_parent1
  parent2_gene_name = gene.gene_name_parent2
  puts "#{parent1_gene_name} is linked to #{parent2_gene_name}"
  puts "#{parent2_gene_name} is linked to #{parent1_gene_name}"
end
