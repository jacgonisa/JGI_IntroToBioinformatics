require 'csv'
require 'date'

class SeedStock
  attr_accessor :seed, :gene_id, :last_planted, :storage, :grams_remaining

  def initialize(seed, gene_id, last_planted, storage, grams_remaining)
    @seed = seed
    @gene_id = gene_id
    @last_planted = last_planted
    @storage = storage
    @grams_remaining = grams_remaining.to_i
  end

  # Class method to load data from a file and return an array of SeedStock objects
  def self.load_from_file(file_path)
    seed_stocks = []
    CSV.foreach(file_path, col_sep: "\t", headers: true) do |row|
       gene_id = row['Mutant_Gene_ID']  
      seed_stock = SeedStock.new(row['Seed_Stock'], gene_id, row['Last_Planted'], row['Storage'], row['Grams_Remaining'])
      seed_stocks << seed_stock
    end
    seed_stocks
  end
    
  # Class method to simulate planting seeds for an array of SeedStock objects
  # Used to simulate planting 7 grams of seeds for all SeedStock objects
  def self.planting_simulation(seed_stocks, amount)
    seed_stocks.each do |seed_stock|
      seed_stock.planting_simulation(amount)
    end
  end

  # Write the database to a new file
  def self.write_database(seed_stocks, output_file)
    CSV.open(output_file, 'w', col_sep: "\t") do |csv|
      # Write the header row
      csv << ['Seed_Stock', 'Mutant_Gene_ID', 'Last_Planted', 'Storage', 'Grams_Remaining']
      # Write the data for each SeedStock object to the file
      seed_stocks.each { |seed_stock| csv << seed_stock.to_csv }
    end
    puts "Data saved to #{output_file}"
  end

# Instance method to simulate planting seeds and update the last_planted date

  def planting_simulation(amount)
    @grams_remaining -= amount
    @grams_remaining = [0, @grams_remaining].max  ## ChatGPT helped in this
    @last_planted = Time.now.strftime('%m/%d/%Y')  # Update the last_planted date to today  
    puts "WARNING: we have run out of Seed Stock #{@seed}" if @grams_remaining == 0
  end

# Instance method to convert SeedStock object to an array for CSV output
  def to_csv
    [@seed, @gene_id, @last_planted, @storage, @grams_remaining]
  end
end


