require 'distribution'

class HybridCross
  attr_accessor :parent1, :parent2, :f2_wild, :f2_p1, :f2_p2, :f2_p1p2
  attr_accessor :seed_stock_parent1, :seed_stock_parent2
  attr_accessor :chi_squared, :statistically_significant, :gene_name_parent1, :gene_name_parent2

  def initialize(parent1, parent2, f2_wild, f2_p1, f2_p2, f2_p1p2)
    @parent1 = parent1
    @parent2 = parent2
    @f2_wild = f2_wild.to_i
    @f2_p1 = f2_p1.to_i
    @f2_p2 = f2_p2.to_i
    @f2_p1p2 = f2_p1p2.to_i
    @seed_stock_parent1 = nil
    @seed_stock_parent2 = nil
    @chi_squared = 0.0
    @statistically_significant = false
    @gene_name_parent1 = nil
    @gene_name_parent2 = nil
  end

    
    ##ChatGPT helped in defining this function (using method .find)
    
def link_to_seed_stocks_and_genes_names(seed_stocks, gene_id_to_gene_name)
  # Find the seed stock for parent 1 based on their ID
  @seed_stock_parent1 = seed_stocks.find { |seed_stock| seed_stock.seed == parent1 }
  
  # Find the seed stock for parent 2 based on their ID
  @seed_stock_parent2 = seed_stocks.find { |seed_stock| seed_stock.seed == parent2 }

  # Retrieve the gene name for parent 1 using the gene ID from the seed stock
  @gene_name_parent1 = gene_id_to_gene_name[@seed_stock_parent1.gene_id]
  
  # Retrieve the gene name for parent 2 using the gene ID from the seed stock
  @gene_name_parent2 = gene_id_to_gene_name[@seed_stock_parent2.gene_id]
end
 
  def chi_squared_test
    observed_counts = [f2_wild, f2_p1, f2_p2, f2_p1p2]
    total_observations = observed_counts.sum

    expected_counts = [
      total_observations * 9 / 16.0,
      total_observations * 3 / 16.0,
      total_observations * 3 / 16.0,
      total_observations * 1 / 16.0
    ]

    @chi_squared = observed_counts.zip(expected_counts).sum do |observed, expected|
      ((observed - expected)**2) / expected
    end

##SOURCE: https://www.rubydoc.info/github/sciruby/distribution/Distribution/ChiSquare/Ruby_.q_chi2
    degrees_of_freedom = observed_counts.size - 1
    p_value = 1 - Distribution::ChiSquare.cdf(@chi_squared, degrees_of_freedom)

    @statistically_significant = p_value < 0.05
    @chi_squared
  end
    
  
# Create instances of HybridCross by reading data from the cross_data file and linking with seed_stocks and gene_id_to_gene_name
#in this instances a chi score is associated with each gene pair
def self.create_from_cross_data(cross_data_file, seed_stocks, gene_id_to_gene_name)
    cross_data = CSV.read(cross_data_file, col_sep: "\t", headers: true)
    hybrid_crosses = []

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

    hybrid_crosses
  end
    
   
   # Class method to generate the final report for a collection of hybrid crosses
def self.gene_linkage_final_report(hybrid_crosses)
    statistically_significant_genes = hybrid_crosses.select { |cross| cross.statistically_significant }
    
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
  end


    
end





