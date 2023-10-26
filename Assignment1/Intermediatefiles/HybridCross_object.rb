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

    
##ChatGPT helped in defining this function
 def link_to_seed_stocks_and_genes_names(seed_stocks, gene_id_to_gene_name)
    @seed_stock_parent1 = seed_stocks.find { |seed_stock| seed_stock.seed == parent1 }
    @seed_stock_parent2 = seed_stocks.find { |seed_stock| seed_stock.seed == parent2 }
    
    @gene_name_parent1 = gene_id_to_gene_name[@seed_stock_parent1.gene_id]
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

    degrees_of_freedom = observed_counts.size - 1
    p_value = 1 - Distribution::ChiSquare.cdf(@chi_squared, degrees_of_freedom)

    @statistically_significant = p_value < 0.05
    @chi_squared
  end
end



