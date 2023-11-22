require 'rest-client'
require 'json'

class InteractomeAnnotator
  # Accessor for networks attribute
  # @return [Array<Array<String>>] List of networks, where each network is an array of gene IDs
  attr_reader :networks

  # Initialize InteractomeAnnotator with a list of networks
  #
  # @param networks [Array<Array<String>>] List of networks, where each network is an array of gene IDs
  # @return [InteractomeAnnotator] An instance of InteractomeAnnotator
  def initialize(networks)
    @networks = networks
    @go_annotations = Hash.new { |hash, key| hash[key] = { count: 0, genes: [] } }
    @kegg_annotations = Hash.new { |hash, key| hash[key] = { count: 0, genes: [] } }
  end

  # Annotate networks with GO and KEGG annotations
  #
  # @return [void]
  def annotate_with_go_and_kegg
    annotate_networks
    print_network_report
  end

  private

  # Retrieve GO annotations for a given protein ID
  #
  # @param protein_id [String] Protein ID for which GO annotations are retrieved
  # @return [Hash] Hash of GO annotations (GO ID => GO Name)
  def retrieve_go_annotations(protein_id)
    # API endpoint for GO annotations
    address = "http://togows.dbcls.jp/entry/uniprot/#{protein_id}/dr.json"
    response = RestClient::Request.execute(method: :get, url: address)
    data = JSON.parse(response.body)

    go_terms = data[0]["GO"] if data[0]["GO"]

    go_terms.each_with_object({}) do |go, hash|
      next unless (go[2] =~ /IDA:/) || (go[2] =~ /IMP:/)

      go_id = go[0]
      go_name = go[1]
      hash[go_id] = go_name
    end if go_terms.is_a?(Array)
  rescue RestClient::Exception => e
    puts "Error retrieving GO annotations for #{protein_id}: #{e.message}"
    {}
  end

  # Retrieve KEGG annotations for a given gene ID
  #
  # @param gene_id [String] Gene ID for which KEGG annotations are retrieved
  # @return [Array<Hash>] Array of KEGG annotations (KEGG ID => KEGG Description)
  def retrieve_kegg_annotations(gene_id)
    # API endpoint for KEGG annotations
    address = "http://togows.dbcls.jp/entry/uniprot/#{gene_id}/dr.json"
    response = RestClient::Request.execute(method: :get, url: address)
    data = JSON.parse(response.body)

    kegg_terms = data[0]["KEGG"] if data[0]["KEGG"]

    kegg_terms.each_with_object([]) do |kegg_info, result|
      kegg_id = kegg_info[0]
      # API endpoint for KEGG pathways
      address = "http://togows.org/entry/kegg-genes/#{kegg_id}/pathways.json"

      begin
        response = RestClient::Request.execute(method: :get, url: address)
        data = JSON.parse(response.body)

        result << { 'id' => data[0].keys[0], 'description' => data[0] } if data[0]&.any?
      rescue RestClient::Exception => e
        puts "Error retrieving KEGG annotations for #{gene_id}: #{e.message}"
      end
    end
  end

  # Annotate a gene with GO and KEGG information
  #
  # @param gene [String] Gene ID to be annotated
  # @param network_index [Integer] Index of the network to which the gene belongs
  # @return [void]
  def annotate_gene(gene, network_index)
    go_terms = retrieve_go_annotations(gene)

    if go_terms.nil?
      return
    end

    go_terms.each do |go_id, go_name|
      @go_annotations[go_id][:count] += 1
      @go_annotations[go_id][:genes] << { gene: gene, network: network_index + 1, go_name: go_name }
    end

    kegg_terms = retrieve_kegg_annotations(gene)

    if kegg_terms[0].nil?
      return
    end

    kegg_terms.each do |kegg_info|
      kegg_id = kegg_info['id']
      kegg_data = kegg_info['description']

      @kegg_annotations[kegg_id][:count] += 1
      @kegg_annotations[kegg_id][:genes] << { gene: gene, network: network_index + 1, kegg_data: kegg_data }
    end
  end

  # Annotate a network with GO and KEGG information
  #
  # @param network [Array<String>] List of gene IDs in the network
  # @param network_index [Integer] Index of the network
  # @return [void]
  def annotate_network(network, network_index)
    network.each do |gene|
      annotate_gene(gene, network_index)
    end
  end

  # Annotate all networks with GO and KEGG information
  #
  # @return [void]
  def annotate_networks
    @networks.each_with_index do |network, index|
      annotate_network(network, index)
    end
  end

  # Print a report of networks, GO terms, and KEGG terms
  #
  # @return [void]
  def print_network_report
    puts "\nNETWORK REPORT:"
    puts " "
    @networks.each_with_index do |network, index|
      puts "Network #{index + 1}:"
      print_components(network)
      print_go_terms(network)
      print_kegg_terms(network)
      puts "\n"
    end
  end

  # Print components of a network
  #
  # @param network [Array<String>] List of gene IDs in a network
  # @return [void]
  def print_components(network)
    puts "Components:"
    network.each do |gene|
      puts "#{gene}"
    end
  end

  # Print GO terms for a network
  #
  # @param network [Array<String>] List of gene IDs in a network
  # @return [void]
  def print_go_terms(network)
    puts "\nGO terms:"
    sorted_go_annotations = @go_annotations.sort_by { |_, info| -info[:count] }

    sorted_go_annotations.each do |go_id, info|
      next unless info[:genes].any? { |gene_info| network.include?(gene_info[:gene]) }

      puts "#{go_id} (#{info[:count]} occurrences): #{info[:genes].first[:go_name]}"
      info[:genes].each do |gene_info|
        next unless network.include?(gene_info[:gene])

        puts "  Gene: #{gene_info[:gene]}"
      end
    end
  end

  # Print KEGG terms for a network
  #
  # @param network [Array<String>] List of gene IDs in a network
  # @return [void]
  def print_kegg_terms(network)
    puts "\nKEGG terms:"
    sorted_kegg_annotations = @kegg_annotations.sort_by { |_, info| -info[:count] }

    sorted_kegg_annotations.each do |kegg_id, info|
      next unless info[:genes].any? { |gene_info| network.include?(gene_info[:gene]) }

      puts "#{kegg_id} (#{info[:count]} occurrences): #{info[:genes][0][:kegg_data].values[0]}"
      info[:genes].each do |gene_info|
        next unless network.include?(gene_info[:gene])
        puts "  Gene: #{gene_info[:gene]}"
      end
    end
  end
end
