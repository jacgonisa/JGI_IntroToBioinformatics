Authors: 
* González Isa, Jacob (jacobgisa17@gmail.com) [![Twitter URL](https://img.shields.io/twitter/url/https/twitter.com/jacobgisa.svg?style=social&label=Follow%20%40JacobGIsa)](https://twitter.com/jacobgisa)
* Roig Cárdenas, Nicolás (nico.c.roig@gmail.com)

## Usage

```sh
ruby main.rb 
```
* This exercise has no classes.

* In `results/orthologs_pairs.tsv` you can find all the orthologs inferred in this analysis.

## DISCUSSION (extra score)

- Regarding the choice of e-value as a filter, we implemented a threshold of e-value < 10^(-6) since it is widely used.
This website (https://help.ezbiocloud.net/ortholog-and-its-detection/) suggest threshold based on Ward & Moreno-Hagelsieb, 2014 
(https://pubmed.ncbi.nlm.nih.gov/25013894/).
However, we recognize that other threshold (for instance 10-3, 10-5, 10-10) could have been implemeted as well.

- Regarding the next steps to confidently show that two genes are orthologs, we would opt for a **phylogeny-based** method.
      - These are more accurate methods and consist in analysing phylogenetic trees that have been constructed from MSA (Multiple Sequence Alignment) created with putative homolog and ortholog sequences. In a phylogenetic tree, speciation events can be detected and if two genes of different species are in the same clade, they can be annotated as orthologs more confidently.
   However, this approach can also lead to wrong predictions when Horizontal Gene Transfers (HGTs) have taken place, for instance.
