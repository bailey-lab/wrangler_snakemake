import yaml
import pandas as pd
import plotly.express as px
database=yaml.safe_load(open(snakemake.input['database']))
memory_graphs=snakemake.output['memory_graph']
time_graphs=snakemake.output['time_graph']
storage_graphs=snakemake.output['storage_graph']

print(database)
for cpu_number, cpu_count in enumerate(database):
	current_dict={}
	for sample_count in database[cpu_count]:
		int_sample=int(sample_count.split('_')[0])
		for step in database[cpu_count][sample_count]:
			current_dict.setdefault('step', [])
			current_dict['step'].append(step)
			current_dict.setdefault('sample_counts', [])
			current_dict.setdefault('memory_usage_GB', [])
			current_dict.setdefault('storage_usage_GB', [])
			current_dict.setdefault('runtime_seconds', [])
			current_dict['sample_counts'].append(int_sample)
			current_dict['memory_usage_GB'].append(database[cpu_count][sample_count][step]['memory_usage'])
			current_dict['storage_usage_GB'].append(database[cpu_count][sample_count][step]['storage_usage'])
			current_dict['runtime_seconds'].append(database[cpu_count][sample_count][step]['elapsed_time'])
	df=pd.DataFrame(current_dict)
	runtime=px.line(df, x='sample_counts', y='runtime_seconds', color='step')
	runtime.write_html(time_graphs[cpu_number])
	memory=px.line(df, x='sample_counts', y='memory_usage_GB', color='step')
	memory.write_html(memory_graphs[cpu_number])
	storage=px.line(df, x='sample_counts', y='storage_usage_GB', color='step')
	storage.write_html(storage_graphs[cpu_number])
