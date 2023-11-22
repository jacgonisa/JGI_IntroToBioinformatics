require 'rest-client'
require 'json'

class InteractomeProcessor
  # Accessor for networks attribute
  # @return [Array<Array<String>>] List of networks, where each network is an array of gene IDs
  attr_reader :networks

  # Initialize InteractomeProcessor with an interactome
  #
  # @param interactome [Hash] Hash representing the interactome with genes and their interactions
  # @return [InteractomeProcessor] An instance of InteractomeProcessor
  def initialize(interactome)
    @interactome = interactome
    @lists = create_lists
    @networks = []
    @network_overlaps = []
  end

  # Merge interactomes and calculate network overlaps
  #
  # @param builder_gene_list [Array<String>] List of gene IDs from the builder interactome
  # @return [Array<Array<String>>] List of networks after merging
  def merge_interactomes(builder_gene_list)
    process
    @network_overlaps = calculate_network_overlaps(builder_gene_list)
    print_network_report(builder_gene_list)
    networks
  end

  private

  # Create lists from the interactome
  #
  # @return [Array<Array<String>>] List of lists, where each list is an array of gene IDs
  def create_lists
    lists = []

    @interactome.each do |outer_key, inner_hash|
      current_list = [outer_key]

      inner_hash.each do |inner_key, inner_values|
        current_list << inner_key
        current_list.concat(inner_values)
      end

      # Ensure unique protein IDs within each list
      current_list.uniq!

      lists << current_list
    end

    lists.reject! { |list| list.size <= 1 } # Remove lists with only one gene
    lists
  end

  # Join lists to create networks
  #
  # @return [Array<Array<String>>] List of networks, where each network is an array of gene IDs
  def join
    joined_lists = []

    @lists.each do |list1|
      joined = false

      joined_lists.each do |list2|
        if (list1 & list2).any?
          list2.concat(list1).uniq!
          joined = true
          break
        end
      end

      joined_lists << list1 unless joined
    end

    joined_lists
  end

  # Process interactome to create networks
  #
  # @return [void]
  def process
    @networks = join
    @networks.reject! { |network| network.size <= 1 } # Remove networks with only one gene
  end

  # Calculate overlaps between networks and the builder gene list
  #
  # @param builder_gene_list [Array<String>] List of gene IDs from the builder interactome
  # @return [Array<Hash>] List of hashes containing overlap information for each network
  def calculate_network_overlaps(builder_gene_list)
    network_overlaps = @networks.map do |network|
      overlap_genes = network & builder_gene_list
      {
        size: overlap_genes.size,
        genes: overlap_genes
      }
    end

    network_overlaps
  end

  # Print a report of networks and their overlaps
  #
  # @param builder_gene_list [Array<String>] List of gene IDs from the builder interactome
  # @return [void]
  def print_network_report(builder_gene_list)
    puts "#{@networks.size} networks have been identified:"

    @networks.each_with_index do |network, index|
      puts "\n\nNetwork #{index + 1}:"
      print_components(network)

      # Print overlap information
      overlap_info = @network_overlaps[index]
      puts "Number of genes in Network also found in the initial Gene List: #{overlap_info[:size]}"
      puts "     #{overlap_info[:genes].join(', ')}"
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
end

