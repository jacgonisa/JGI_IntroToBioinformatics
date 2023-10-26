class Gene
  attr_accessor :gene_id, :gene_name, :mutant_phenotype

  def initialize(gene_id, gene_name, mutant_phenotype)
    if valid_gene_id?(gene_id)
      @gene_id = gene_id
      @gene_name = gene_name
      @mutant_phenotype = mutant_phenotype
    else
      puts "Error: Invalid gene ID format"
    end
  end

  def self.build_gene_id_to_gene_name_mapping(file_path)
    gene_info_data = CSV.read(file_path, col_sep: "\t", headers: true)
    gene_id_to_gene_name = {}
    gene_info_data.each do |row|
      gene_id = row['Gene_ID']
      gene_name = row['Gene_name']
      gene_id_to_gene_name[gene_id] = gene_name
    end
    gene_id_to_gene_name
  end

  private

  def valid_gene_id?(gene_id)
    gene_id.match(/A[Tt]\d[Gg]\d\d\d\d\d/)
  end
end


