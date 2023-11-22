
Authors: 
* González Isa, Jacob (jacobgisa17@gmail.com) [![Twitter URL](https://img.shields.io/twitter/url/https/twitter.com/jacobgisa.svg?style=social&label=Follow%20%40JacobGIsa)](https://twitter.com/jacobgisa)
* Roig Cárdenas, Nicolás (nico.c.roig@gmail.com)

## Usage

```sh
ruby main.rb ArabidopsisSubNetwork_GeneList.txt
```

You can find documentation YARD documentation in  **`doc/`:**

This work consists of one main script (`main.rb`) and three classes:
* `interactome_builder.rb`, which transforms AGI gene names into UniProtKB/Swiss-Prot ID and retrieves interactions from [IntAct](https://www.ebi.ac.uk/intact/home).
* `interactome_processor.rb`, which merges the detected interactions into networks and tells you the number of genes -present in those networks- that were in the input list.
* `interactome_annotator.rb`, which includes GO and KEGG annotations, counting the number of total occurrences of each GO and KEGG ID among all networks.
