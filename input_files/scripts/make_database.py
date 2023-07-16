import yaml
step_times=snakemake.input['step_times']
benchmarks=snakemake.input['benchmarks']
basal_memory=snakemake.params['basal_memory']
database=snakemake.output['database']
ordered_steps=['setup_and_extract_by_arm', 'mip_barcode_correction_multiple',
'mip_correct_for_contam_with_same_barcodes_multiple', 'wrangler_downsample_umi',
'mip_clustering_multiple', 'mip_population_clustering_multiple']

def get_benchmarks(benchmark_file, step_dict, ordered_steps, basal_memory):
	benchmark_dict={}
	for step in ordered_steps:
		start, end=step_dict[step]['start'], step_dict[step]['end']
		print(step, start, end)
		mem_list, storage_list, iowait_list=[basal_memory],[],[0.0]
		for line_number, line in enumerate(open(benchmark_file)):
			if line_number>0:
				time, elapsed, mem,	storage, iowait=line.strip().split()
				elapsed, mem, storage, iowait=float(elapsed), float(mem[:-1]), float(storage[:-1]), float(iowait)
				if elapsed>start and elapsed<end:
					mem_list.append(mem)
					storage_list.append(storage)
					iowait_list.append(iowait)
		print(mem_list)
		benchmark_dict.setdefault(step, {})
		benchmark_dict[step]['elapsed_time']=end-start
		if len(storage_list)>0:
			benchmark_dict[step]['storage_usage']=max(storage_list)-min(storage_list)
		else:
			benchmark_dict[step]['storage_usage']=0
		benchmark_dict[step]['max_iowait']=max(iowait_list)
		benchmark_dict[step]['memory_usage']=basal_memory-min(mem_list)
	return benchmark_dict
				
def make_step_dict(step_file, ordered_steps):	
	step_dict={}
	print(step_file)
	for line in open(step_file):
		step, time=line.strip().split()
		step_dict[step]=float(time)
	total_time=0
	for step in ordered_steps:
		step_start=total_time
		total_time+=step_dict[step]
		step_end=total_time
		step_dict[step]={'start':step_start, 'end':step_end}
	return step_dict

final_database={}
step_dict={}
for sample_number, sample in enumerate(step_times):
	split_sample=sample.split('_')
	sample_count=split_sample[3][:-1]+'_samples'
	cpu_count=split_sample[5][:-3]+'_cpus'
	step_dict=make_step_dict(sample, ordered_steps)
	benchmark_dict=get_benchmarks(benchmarks[sample_number], step_dict, ordered_steps, basal_memory)
	final_database.setdefault(cpu_count, {})
	final_database[cpu_count].setdefault(sample_count, benchmark_dict)
print(final_database)
yaml.dump(final_database, open(database, 'w'), sort_keys=False)
