
Authors: 
* González Isa, Jacob (jacobgisa17@gmail.com) [![Twitter URL](https://img.shields.io/twitter/url/https/twitter.com/jacobgisa.svg?style=social&label=Follow%20%40JacobGIsa)](https://twitter.com/jacobgisa)
* Roig Cárdenas, Nicolás (nico.c.roig@gmail.com)

## Usage

```sh
ruby main.rb ArabidopsisSubNetwork_GeneList.txt output.gff output_chromosome_coord.gff > output_report.txt
```
**`output.gff`** is the coordinates of repeats within genes and **`output_chromosome_coord.gff`** is the chromosome-based coordinates.

You can find documentation YARD documentation in  **`doc/`:**

This work consists of one main script (`main.rb`) and three classes:
* `database.rb`.
* `gene.rb`.
* `sequence.rb`.

* As well, find attached an image of AT2G46340 gene in ENSEMBL genome browser `AT2G46340.jpeg`.
* Also we attach an additional image showing in detail a highly repetitive region consisting of CTT arrays  `AT2G46340_curiosity.jpeg`.

The full genome can be visualised here:
https://plants.ensembl.org/Arabidopsis_thaliana/Share/cba88828d797bba6294e88005c0928af?redirect=no
