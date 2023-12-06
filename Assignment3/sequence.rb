# == Summary
# The ExonSequence class represents a biological exon sequence and provides methods
# for analyzing repeated patterns within the sequence.
class ExonSequence
  # Accessors for instance variables
  attr_accessor :sequence, :exon_id, :localization, :ctt_reapeats_array, :gene_accesion

  # Initializes a new ExonSequence instance with specified attributes.
  #
  # @param id [String] The exon ID.
  # @param seq [String] The exon sequence.
  # @param accesion [String] The gene accession.
  # @param position [String] The position information of the exon.
  def initialize(id, seq, accesion, position)
    @exon_id = id
    @sequence = Bio::Sequence.auto(seq)
    @gene_accesion = accesion
    @sequence.features = []
    @ctt_reapeats_array = []
    self.get_position(position)
  end

  # Parses the position information and sets the localization instance variable.
  #
  # @param position [String] The position information of the exon.
  def get_position(position)
    complement_match = position.match(/complement\((\d+)\.\.(\d+)\)/)
    if complement_match
      starting_coord = complement_match[1]
      ending_coord = complement_match[2]
      polarity = '-'
    else
      starting_coord = position.split('..')[0]
      ending_coord = position.split('..')[1]
      polarity = '+'
    end

    @localization = {
      'starting_position' => starting_coord.to_i,
      'ending_position' => ending_coord.to_i,
      'polarity' => polarity
    }
  end

  # Checks for the presence of the 'ctt' repeat in the sequence and updates the
  # ctt_reapeats_array accordingly.
  #
  # @param sequence [Bio::Sequence] The sequence to check for 'ctt' repeats.
  def check_ctt(sequence = @sequence)
    match = sequence.match(/(ctt){2,}/)

    if match
      repeat_stating_coord = @localization['starting_position'] + match.begin(0)
      repeat_ending_coord = @localization['starting_position'] + match.end(0) - 1
      ctt_id = "ctt_repeat_#{@exon_id.split('.')[0]}_#{repeat_stating_coord}_#{repeat_ending_coord}"

      unless @ctt_reapeats_array.include?(ctt_id)
        @ctt_reapeats_array << "#{@gene_accesion}\tcustom\tctt_repeat\t#{repeat_stating_coord}\t#{repeat_ending_coord}\t.\t+\t.\tID=#{ctt_id}"
      end
      sequence = sequence.sub('cttctt', 'aaaaaa')
      self.check_ctt(sequence)
    end
  end

  # Checks for the presence of the 'aag' repeat in the sequence and updates the
  # ctt_reapeats_array accordingly.
  #
  # @param sequence [Bio::Sequence] The sequence to check for 'aag' repeats.
  def check_aag(sequence = @sequence)
    match = sequence.match(/(aag){2,}/)

    if match
      repeat_stating_coord = @localization['starting_position'] + match.begin(0)
      repeat_ending_coord = @localization['starting_position'] + match.end(0) - 1
      ctt_id = "ctt_repeat_#{@exon_id.split('.')[0]}_#{repeat_stating_coord}_#{repeat_ending_coord}"

      unless @ctt_reapeats_array.include?(ctt_id)
        @ctt_reapeats_array << "#{@gene_accesion}\tcustom\tctt_repeat\t#{repeat_stating_coord}\t#{repeat_ending_coord}\t.\t-\t.\tID=#{ctt_id}"
      end
      sequence = sequence.sub('aagaag', 'aaaaaa')
      self.check_aag(sequence)
    else
      return @ctt_reapeats_array unless @ctt_reapeats_array.nil?
    end
  end
end

