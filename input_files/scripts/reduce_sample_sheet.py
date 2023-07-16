'''
reduces the number of samples to a manageable number, preferentially choosing
the largest samples first. Assumes sample_name, sample_set, and replicate are
first 3 columns, and that fastq format is name-set-replicate_R{read}_001.fastq.gz
'''
import os
fastq_folder=snakemake.input['fastq_folder']
input_sample_sheet=open(snakemake.input['in_ss'])
output_sample_sheet=open(snakemake.output['out_ss'], 'w')
count=snakemake.params['size']

if count=='all':
	for line in input_sample_sheet:
		output_sample_sheet.write(line)
else:
	sample_list=[]
	for line_number, line in enumerate(input_sample_sheet):
		if line_number==0:
			title=line
		else:
			split_line=line.strip().split('\t')
			sample, sample_set, replicate=split_line[0:3]
			first_name='-'.join([sample, sample_set, replicate])+'_'+'R1_001.fastq.gz'
			second_name='-'.join([sample, sample_set, replicate])+'_'+'R2_001.fastq.gz'
			if os.path.exists(fastq_folder+'/'+first_name):
				first_size=os.path.getsize(fastq_folder+'/'+first_name)
				second_size=os.path.getsize(fastq_folder+'/'+second_name)
				sample_list.append([first_size+second_size, line])
			else:
				sample_list.append([0, line])
	sample_list.sort(reverse=True)
	output_sample_sheet.write(title)
	for sample in sample_list[:count]:
		output_sample_sheet.write(sample[1])
