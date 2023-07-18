# wrangler_snakemake

This program takes the C++ functions written by Nick Hathaway for miptools
wrangler and runs them as independent rules in snakemake. This allows us to
benchmark which steps take what amounts of resources, and to run separate steps
to see their output instead of everything all at once. For failed jobs, it also
allows us to re-run only the parts that fail rather than everything.

The program consists of the following components:
  - generate_mip_files: python script written by me to replace generate_wrangler
  _scripts.py
  - setup_and_extract_by_arm: implemented as Nick implements it
  - mip_barcode_correction_multiple: implemented as Nick implements it
  - mip_correct_for_contam_with_same_barcodes_multiple: implemented as Nick implements it
  - wrangler_downsample_umi: implemented as Aris implements it
  - mip_clustering_multiple: implemented as Nick implements it
  - mip_population_clustering_multiple: produces final output (in output_dir/
  analysis/populationClustering/allInfo.tab.txt)


The program is currently a little rough around the edges. I'm providing it here
mostly to organize my own files, but I hope others might find it useful as well.


## Instructions for running

 - Download this repository to a folder of your choosing
 - Edit the wrangle_data.yaml file using instructions in the file
 - Obtain snakemake as a conda environment and activate it
 - run snakemake, e.g. snakemake -s wrangle_data.smk
