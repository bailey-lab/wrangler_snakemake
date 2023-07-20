import pandas as pd
import subprocess

arms_file=snakemake.input.arms_file
input_sample_sheet=snakemake.input.sample_sheet
mip_arms=snakemake.output.mip_arms
sample_file=open(snakemake.output.sample_file, 'w')
output_sample_sheet=snakemake.output.sample_sheet

subprocess.call(f'cp {input_sample_sheet} {output_sample_sheet}', shell=True)

#grab only selected columns from original arms file and output them to new arms file
arms_df=pd.read_table(arms_file)
arms_df=arms_df[['mip_id', 'mip_family', 'extension_arm', 'ligation_arm', 'extension_barcode_length', 'ligation_barcode_length', 'gene_name', 'mipset']]
arms_df.to_csv(mip_arms, index=False, sep='\t')

#grab sample names and mip_family info and output to a new file
family_df=arms_df[['mip_family']]
sample_df=pd.read_table(input_sample_sheet)
sample_df=sample_df[['sample_name', 'sample_set', 'replicate']]
family_dict=family_df.to_dict()
sample_dict=sample_df.to_dict()
bigger_size=max(len(sample_dict['sample_name']), len(family_dict['mip_family']))

sample_file.write('mips\tsamples\n')
for row in range(bigger_size):
	if row in family_dict['mip_family']:
		sample_file.write(family_dict['mip_family'][row]+'\t')
	else:
		sample_file.write('\t')
	if row in sample_dict['sample_name']:
		sample_file.write(f"{sample_dict['sample_name'][row]}-{sample_dict['sample_set'][row]}-{sample_dict['replicate'][row]}\n")
	else:
		sample_file.write('\n')

