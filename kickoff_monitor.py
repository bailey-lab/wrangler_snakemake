from tqdm.contrib.concurrent import thread_map #faster if disk bound
# from tqdm.contrib.concurrent import process_map #faster if CPU bound - need to set chunk size

def kickoff_job(string):
	import subprocess
	subprocess.call(string, shell=True)

string_list=['snakemake -s wrangle_data.smk --cores 24', 'python3 monitor_run.py']

thread_map(kickoff_job, string_list)
