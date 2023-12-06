require './database.rb'


filename = ARGV[0]
gff_output = ARGV[1]
chromosome_gff_output = ARGV[2]

prueba = DataBase.new(filename)
prueba.check_repeats
prueba.write_gff(gff_output)
prueba.write_chromosome_gff(chromosome_gff_output)