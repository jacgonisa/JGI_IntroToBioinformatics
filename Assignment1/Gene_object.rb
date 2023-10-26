require 'csv'

class Gene
  attr_accessor :gene_id, :gene_name, :mutant_phenotype

  # Constructor to initialize a Gene object
  def initialize(gene_id, gene_name, mutant_phenotype)
    if valid_gene_id?(gene_id)
      @gene_id = gene_id
      @gene_name = gene_name
      @mutant_phenotype = mutant_phenotype
    else
      puts "Error: Invalid gene ID format"
      abort
    end
  end

  # Class method to build a mapping of gene IDs to gene names
  def self.build_gene_id_to_gene_name_mapping(file_path)
    gene_info_data = CSV.read(file_path, col_sep: "\t", headers: true)
    gene_id_to_gene_name = {}

   gene_info_data.each do |row|
  # Extract the 'Gene_ID' value from the current row and store it in the gene_id variable
  gene_id = row['Gene_ID']
  
  # Extract the 'Gene_name' value from the current row and store it in the gene_name variable
  gene_name = row['Gene_name']
  
  # At this point, we have the Gene_ID and Gene_name from the current row.
  # This information is key to build the mapping of gene IDs to gene names.
       
       
      if valid_gene_id?(gene_id)
        gene_id_to_gene_name[gene_id] = gene_name
      else
        puts "Error: Invalid gene ID format for Gene ID: #{gene_id}"
        # Abort if invalid ID
        abort
      end
    end

    gene_id_to_gene_name
  end

  # Class method to check the validity of a gene ID
  def self.valid_gene_id?(gene_id)
    !gene_id.match(/A[Tt]\d[Gg]\d\d\d\d\d/).nil?
  end
end



