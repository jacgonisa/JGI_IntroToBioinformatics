### WRITTEN BY NICOLÁS ROIG AND JACOB GONZÁLEZ
require './interactome_builder.rb'
require './interactome_annotator.rb'
require './interactome_processor.rb'


filename = ARGV[0]


puts "FINAL REPORT"
puts "\n\n################################\n\n\n"

puts "RETRIEVING THE SWISSPROT ID..."
puts
# Create an instance of the InteractomeBuilder
builder = InteractomeBuilder.new(filename)
puts "\n\nFINISHED SUCCESSFULLY"

puts "\n\n################################\n\n\n"


puts "LOOKING FOR GENE INTERACTIONS ON INTACT DATABASE \n.\n.\n.\n"


# Create the interactome
interactome = builder.build_interactome


puts "FINISHED SUCCESSFULLY"

puts "\n\n################################\n\n\n"



# Create an instance of InteractomeProcessor
processor = InteractomeProcessor.new(interactome)

puts "LOOKING FOR NETWORKS..."
# Merge the networks from the processor
networks = processor.merge_interactomes(builder.gene_list)

puts "FINISHED SUCCESSFULLY"
puts "\n\n################################\n\n\n"


puts "LOOKING FOR GO AND KEGG ANNOTATIONS\n\n"
# Create an instance of InteractomeAnnotator
annotator = InteractomeAnnotator.new(networks)

# Annotate and print the network report
annotator.annotate_with_go_and_kegg


puts "END OF REPORT"
puts "################################"
