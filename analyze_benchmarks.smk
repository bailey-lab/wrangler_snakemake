'''
After all benchmarking steps have finished running, this workflow creates a
database out of all the run times, memory usages, and io wait times, and plots
the output in plotly.
'''
configfile: 'input_files/analyze_benchmarks.yaml'

rule all:
	input:
		time_graph=expand('output_files/Mikalayi_TES/{cpu_count}_CPU_time.html', cpu_count=config['cpu_counts']),
#		database='output_files/Mikalayi_TES/benchmark_database.yaml'

rule make_database:
	input:
		step_times=expand('output_files/Mikalayi_TES/{sample_count}s/wrangler/'
		'downsample_{sample_count}s_200000000000000000umi_{cpu_count}cpu_run_'
		'stats/step_profile.txt',
		cpu_count=config['cpu_counts'],
		sample_count=config['sample_counts']),

		benchmarks=expand('output_files/Mikalayi_TES/{sample_count}s/wrangler/'
		'downsample_{sample_count}s_200000000000000000umi_{cpu_count}cpu_run_'
		'stats/run_stats.txt',
		cpu_count=config['cpu_counts'],
		sample_count=config['sample_counts'])
	params:
		basal_memory=config['basal_memory']
	output:
		database='output_files/Mikalayi_TES/benchmark_database.yaml'
	script:
		'input_files/scripts/make_database.py'

rule graph_benchmarks:
	input:
		database='output_files/Mikalayi_TES/benchmark_database.yaml'
	output:
		memory_graph=expand('output_files/Mikalayi_TES/{cpu_count}_CPU_memory.html', cpu_count=config['cpu_counts']),
		time_graph=expand('output_files/Mikalayi_TES/{cpu_count}_CPU_time.html', cpu_count=config['cpu_counts']),
		storage_graph=expand('output_files/Mikalayi_TES/{cpu_count}_CPU_storage.html', cpu_count=config['cpu_counts'])
	script:
		'input_files/scripts/graph_benchmarks.py'
		
