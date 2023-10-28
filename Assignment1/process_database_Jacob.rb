require 'csv'

require './Gene_object.rb'
require './SeedStock_object.rb'
require './HybridCross_object.rb'

# Check if the correct number of arguments is provided
arguments_number = ARGV.length
unless arguments_number == 4
  puts "WRONG USAGE!!!"
  puts "Your input has #{arguments_number} arguments - and 4 arguments needed!!!"
  puts "Usage: ruby process_database_Jacob.rb gene_information.tsv seed_stock_data.tsv cross_data.tsv new_stock_file.tsv"
  abort
end

# Assign the input file names to variables by retrieving the file paths from the command line arguments
gene_information_file = ARGV[0]
seed_stock_data_file = ARGV[1]
cross_data_file = ARGV[2]
output_file = ARGV[3]


#########TASK 1#############
puts
# Create an array of SeedStock objects by loading data from the file
seed_stocks = SeedStock.load_from_file(seed_stock_data_file)

# Simulate planting 7 grams of seeds for all SeedStock objects
SeedStock.planting_simulation(seed_stocks, 7)

# Use the class method to write the data to the output file
SeedStock.write_database(seed_stocks, output_file)

 
#########TASK 2##############
puts


#Get the gene_id to gene_name mapping using the class method
gene_id_to_gene_name = Gene.build_gene_id_to_gene_name_mapping(gene_information_file)

# Create instances of HybridCross by reading data from the cross_data file and linking with seed_stocks and gene_id_to_gene_name
#in this instances a chi score is associated with each gene pair
hybrid_crosses = HybridCross.create_from_cross_data(cross_data_file, seed_stocks, gene_id_to_gene_name)


# Generate the final report
HybridCross.gene_linkage_final_report(hybrid_crosses)
