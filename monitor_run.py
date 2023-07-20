import time
import subprocess
import yaml
elapsed_time=0
config=yaml.safe_load(open('wrangle_data.yaml'))
output_dir=config['output_folder']+'/'+config['analysis_dir']+'_run_stats'
subprocess.call(['mkdir', '-p', output_dir])
start_time=time.time()
still_running=True
output_path=output_dir+'/run_stats.txt'
output_file=open(output_path, 'w')
output_file.write(f'local_time\telapsed_time\tmemory_avail\tstorage_avail\t%cpu_iowait\n')

def get_storage():
	test=subprocess.check_output(['df', '-h']).decode()
	test=test.split('\n')
	for line in test:
		line=line.split()
		if len(line)>1 and line[-1]=='/':
			storage=line[-3]
			print('available storage is', storage)
			return(storage)
	return 'storage not retrievable'

def get_memory():
	test=subprocess.check_output(['free', '-g']).decode()
	test=test.split('\n')
	for line in test:
		line=line.split()
		if len(line)>2 and line[0]=='Mem:':
			memory=line[-1]+'G'
			print('available memory is', memory)
			return(memory)
	return 'memory not retrievable'

def get_io():
	test=subprocess.check_output(['iostat']).decode()
	test=test.split('\n')
	if len(test)>3:
		iowait=test[3].strip().split()[3]
		print('percent of CPU time spent waiting for io is currently', iowait)
		return iowait
	return 'iowait not retrievable'

while still_running:
	local=time.ctime().replace(' ', '_')
	current=time.time()
	elapsed_time=current-start_time
	try:
		output_file=open(output_path, 'a')
		subprocess.check_output('pgrep -u '+'asimkin'+' snakemake', shell=True)
		memory=get_memory()
		storage=get_storage()
		iowait=get_io()
		output_file.write(f'{local}\t{elapsed_time}\t{memory}\t{storage}\t{iowait}\n')
		output_file.close()
	except Exception:
		print('not running')
		still_running=False
	time.sleep(60)
