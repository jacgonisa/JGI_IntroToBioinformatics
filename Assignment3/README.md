
Authors: 
* González Isa, Jacob (jacobgisa17@gmail.com) [![Twitter URL](https://img.shields.io/twitter/url/https/twitter.com/jacobgisa.svg?style=social&label=Follow%20%40JacobGIsa)](https://twitter.com/jacobgisa)
* Roig Cárdenas, Nicolás (nico.c.roig@gmail.com)

## Usage

```sh
ruby main.rb ArabidopsisSubNetwork_GeneList.txt output.gff output_chromosome_coord.gff > output_report.txt
```
output.gff is the coordinates of repeats within genes and output_chromosome_coord.gff is the chromosome-based coordinates.

You can find documentation YARD documentation in  **`doc/`:**

This work consists of one main script (`main.rb`) and three classes:
* `database.rb`.
* `gene.rb`.
* `sequence.rb`.
