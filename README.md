# wrangler_snakemake

This program takes the C++ functions written by Nick Hathaway for miptools
wrangler and runs them as independent rules in snakemake. This allows us to
benchmark which steps take what amounts of time, and to run separate steps
instead of everything all at once.

The program is currently a little rough around the edges. I'm providing it here
mostly to organize my own files, but I hope others might find it useful as well.

## Instructions for running

 - Download this repository to a folder of your choosing
 - Edit the wrangle_data.yaml file using instructions in the file
 - Obtain snakemake as a conda environment and activate it
 - run snakemake, e.g. snakemake -s wrangle_data.smk
