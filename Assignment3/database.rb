require './gene'
require './sequence'

require 'net/http'
require 'bio'
require 'fileutils'

# ==Summary
# The DataBase class represents a database of genes and provides methods for
# handling gene information, checking for repeated sequences, and writing GFF files.
class DataBase
  # Accessors for instance variables
  attr_accessor :filename, :genes_hash, :gff_array, :chromosome_array

  # Initializes a new DataBase instance with a specified filename.
  #
  # @param filename [String] The filename containing gene information.
  def initialize(filename)
    @filename = filename
    @genes_hash = {}
    @gff_array = []
    @chromosome_array = []

    # Reading gene information from the file and creating Gene objects
    lines = File.readlines(filename)
    lines.each do |gene|
      gene = gene[..8]
      @genes_hash[gene.upcase] = Gene.new(gene)
    end

    # Creating Ensembl objects for each gene
    create_ensembl_objects
  end

  # Creates Ensembl objects for each gene in the genes_hash.
  def create_ensembl_objects
    @genes_hash.each do |gene, object|
      object.create_ensembl
    end
  end

  # Checks for repeated sequences in the exons of each gene and updates the GFF array.
  #
  # @return [Array<String>] The GFF array containing information about repeated sequences.
  def check_repeats
    temporal_array = []
    @genes_hash.each do |gene, object|
      object.bring_exons
      line = object.check_sequences
      unless line[0].nil?
        temporal_array << line
      end
    end

    temporal_array.each do |gene_array|
      gene_array.each do |exon_array|
        exon_array.each do |line|
          @gff_array << line
        end
      end
    end

    @gff_array.compact!
    @gff_array.uniq!
    genes_without_repeats
  end

  # Identifies genes without "cttctt" sequence repeats and prints their names.
  def genes_without_repeats
    array_with_repeats = []
    array_without_repeats = []

    @gff_array.each do |line|
      array_with_repeats << line.split("\t")[8][14..22]
    end

    @genes_hash.keys.each do |gene|
      unless array_with_repeats.include?(gene)
        array_without_repeats << gene
      end
    end

    unless array_without_repeats.empty?
      puts "#{array_without_repeats.count} genes without CTTCTT sequence from #{@filename}"
      puts

      array_without_repeats.each do |gene|
        puts gene
      end
    end
  end

  # Writes the GFF array to a file in GFF3 format.
  #
  # @param output_filename [String] The name of the output GFF file. Default is 'output.gff3'.
  def write_gff(output_filename = 'output.gff3')
    File.open(output_filename, 'w') do |file|
      file.puts '##gff-version 3'
      @gff_array.each { |line| file.puts line }
    end
  end

  # Writes modified chromosome coordinates to a GFF file.
  #
  # @param output_filename [String] The name of the output GFF file. Default is 'gff_chromosome.gff'.
  def write_chromosome_gff(output_filename = 'gff_chromosome.gff')
    chromosome_coords
    File.open(output_filename, 'w') do |file|
      file.puts '##gff-version 3'
      @chromosome_array.each { |line| file.puts line }
    end
  end

  # Modifies chromosome coordinates based on gene and repeat coordinates.
  def chromosome_coords
    @gff_array.each do |line|
      fields = line.split("\t")

      # Getting the needed coordinates and the chromosome number
      chromosome = fields[0].split(':')[2].to_i
      gene_start_coord = fields[0].split(':')[3].to_i
      repeat_starting_coord = fields[3].to_i
      repeat_ending_coord = fields[4].to_i

      # New coords
      repeat_starting_coord_new = gene_start_coord + repeat_starting_coord - 1
      repeat_ending_coord_new = gene_start_coord + repeat_ending_coord - 1

      # Update line
      fields[0] = chromosome
      fields[3] = repeat_starting_coord_new.to_s
      fields[4] = repeat_ending_coord_new.to_s
      new_line = fields.join("\t")

      @chromosome_array << new_line
      @chromosome_array
    end
  end
end
