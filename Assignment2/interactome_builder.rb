require 'rest-client'

class InteractomeBuilder
  # Accessor for gene_list attribute
  # @return [Array<String>] List of gene IDs
  attr_accessor :gene_list, :interactome
  
  # PSICQUIC base URL for fetching protein interaction data
  PSICQUIC_BASE_URL = 'http://www.ebi.ac.uk/Tools/webservices/psicquic/intact/webservices/current/search/query/'

  # Initialize the InteractomeBuilder with a gene list retrieved from a file
  #
  # @param filename [String] Path to the file containing gene IDs
  # @return [InteractomeBuilder] An instance of InteractomeBuilder
  def initialize(filename)
    @gene_list = retrieve_genes_from_file(filename)
  end

  # Retrieve genes from a file and extract the corresponding protein IDs
  #
  # @param filename [String] Path to the file containing gene IDs
  # @return [Array<String>] List of protein IDs
  def retrieve_genes_from_file(filename)
    protein_ids = []
    array_of_lines = IO.readlines(filename)
    array_of_lines[0..].each do |data|
      geneid = data.split("\t").first.chomp  # Remove newline character
      res = RestClient.get("https://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=ensemblgenomesgene&format=embl&id=#{geneid}&style=raw")

      unless res
        abort "failed to retrieve #{geneid}"
      end

      record = res.body

      if record.match(/db_xref="Uniprot\/SWISSPROT\:([^"]+)"/)
        protein_id = record.match(/db_xref="Uniprot\/SWISSPROT\:([^"]+)"/)[1]
      #puts "the protein ID of #{geneid} is #{protein_id}"
        protein_ids << protein_id
      else
        puts "couldn't find the protein ID of #{geneid}"
      end
    end
    protein_ids
  end

  # Build interactomes with three levels of depth
  #
  # @return [void]
  def build_interactome
    interactome = {}

    @gene_list.each do |query_gene|
      interactome[query_gene] = fetch_interactions(query_gene)
    end

    @interactome = expand_interactome(interactome)
      
    @interactome.each do |query_gene, second_level_interactions|
      puts "**1st-level**: #{query_gene} interacts with:"
      second_level_interactions.each do |second_gene, third_level_interactions|
        puts "2nd-level: #{second_gene}, which interacts with: 3rd-level: #{third_level_interactions.join(', ')}"
      end
    end
  end

  # Fetch interactions for a given query gene, with an optional quality threshold
  #
  # @param query_gene [String] Gene ID for which interactions are fetched
  # @param quality_threshold [Float] Minimum quality threshold for interactions (default: 0.55)
  # @return [Array<String>] List of interacting gene IDs
  def fetch_interactions(query_gene, quality_threshold = 0.55)
    url = "#{PSICQUIC_BASE_URL}#{query_gene}?format=tab25"
    response = RestClient.get(url)

    parse_interactions(response.body, query_gene, quality_threshold)
  rescue RestClient::Exception => e
    puts "Error fetching interactions for #{query_gene}: #{e.message}"
    []
  end

  # Parse interactions from the response body based on quality checks
  #
  # @param response_body [String] Response body containing interaction data
  # @param query_gene [String] Gene ID for which interactions are parsed
  # @param quality_threshold [Float] Minimum quality threshold for interactions
  # @return [Array<String>] List of interacting gene IDs
  def parse_interactions(response_body, query_gene, quality_threshold)
    interactions = []

    response_body.lines.each do |line|
      fields = line.strip.split("\t")
      next if fields.empty?

      # Check if the gene belongs to Arabidopsis
      next if fields[9].match(/taxid:(\d+)\(([^)]+)\)/)[1] != "3702"
          
      # Check if the intact score is better than the threshold
      intact_score_str = fields.last.match(/intact-miscore:(\d+\.\d+)/)&.captures&.first
      intact_score = intact_score_str.to_f if intact_score_str

      next if intact_score.nil? || intact_score < quality_threshold

      # Check if the query gene is in the first column
      next unless fields[0] == "uniprotkb:#{query_gene}"

      interacting_gene = fields[1].split(":").last

      # Skip self-interactions
      next if interacting_gene == query_gene

      # Add interacting gene only if not already present
      interactions << interacting_gene unless interactions.include?(interacting_gene)
    end

    interactions
  end

  # Expand the interactome by fetching interactions for each gene in the interactome
  #
  # @param interactome [Hash] Hash containing genes and their interactions
  # @return [Hash] Expanded interactome
  def expand_interactome(interactome)
    expanded_interactome = {}

    interactome.each do |query_gene, interactions|
      expanded_interactome[query_gene] = {}

      interactions.each do |gene|
        expanded_interactome[query_gene][gene] = fetch_interactions(gene).uniq
      end
    end

    expanded_interactome
  end
end
