# == Summary
# The Gene class represents a gene and provides methods for retrieving gene information,
# extracting exons, checking exon sequences, and writing GFF (General Feature Format) files.
class Gene
  # Accessors for instance variables
  attr_accessor :gene_id, :embl, :exons, :gff_array

  # Initializes a new Gene instance with the given gene ID.
  #
  # @param gene_id [String] The gene ID.
  def initialize(gene_id)
    @gene_id = gene_id.upcase
    @embl = create_ensembl
    @exons = {}
    @gff_array = []
  end

  # Creates a Bio::EMBL object by fetching gene information from the Ensembl database.
  #
  # @return [Bio::EMBL] The Bio::EMBL object containing gene information.
  def create_ensembl
    address = URI("http://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=ensemblgenomesgene&format=embl&id=#{@gene_id}")
    response = Net::HTTP.get_response(address)

    # Control check
    unless response.code == '200'
      abort "Gene #{@id} not found in dbfetch database" 
    end

    # Writing the embl file in a new directory
    FileUtils.mkdir_p('data')
    File.open("data/#{@gene_id}.embl", 'w') do |embl_file|
      embl_file.puts response.body
    end

    return Bio::EMBL.new(response.body)
  end

  # Retrieves exons from the gene's EMBL information and creates ExonSequence objects.
  def bring_exons
    filter_array = []
    @embl.features.each do |feat|
      next unless feat.feature == 'exon'
      
      # Check for random genes. Some genes are associated with other genes in EMBL. We don't know why
      next unless feat.assoc.values[0].include?(@gene_id)

      # Filtering for repeated exons
      next if filter_array.include?(feat.assoc.values[0][-1])
      filter_array << feat.assoc.values[0][-1]

      # Creating the @exons hash with the exons of each gene
      exon_id = feat.assoc.values[0][8..]
      position = feat.position.scan(/\d+/)
      start_pos = position[0].to_i
      end_pos = position[1].to_i
      exon_seq = @embl.naseq[(start_pos - 1)..end_pos]

      @exons[exon_id] = ExonSequence.new(exon_id, exon_seq, @embl.accession, feat.position)
    end
  end

  # Checks sequences of exons for repeated patterns and updates the GFF array.
  #
  # @return [Array<String>] The GFF array containing information about repeated patterns in exons.
  def check_sequences
    @exons.each do |_key, value|
      value.check_ctt
      @gff_array << value.check_aag
      @gff_array.compact!
    end

    return @gff_array unless @gff_array.nil?
  end

  # Writes the GFF array to a file in GFF3 format.
  #
  # @param output_filename [String] The name of the output GFF file. Default is 'output.gff3'.
  def write_gff(output_filename = 'output.gff3')
    File.open(output_filename, 'a') do |file|
      @gff_array.each { |line| file.puts line }
    end
  end
end

