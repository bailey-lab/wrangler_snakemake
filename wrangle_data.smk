configfile: 'wrangle_data.yaml'
output_folder=config['output_folder']
rule all:
	input:
		output_configfile=output_folder+'/snakemake_params/config.yaml',
		pop_clustering=output_folder+'/mip_pop_clustering_finished.txt'

rule copy_files:
	input:
		input_snakefile='wrangle_data.smk',
		input_configfile='wrangle_data.yaml',
		in_scripts='input_files/scripts'
	output:
		output_snakefile=output_folder+'/snakemake_params/wrangle_data.smk',
		output_configfile=output_folder+'/snakemake_params/wrangle_data.yaml',
		out_scripts=directory(output_folder+'/snakemake_params/scripts')
	shell:
		'''
		cp {input.input_snakefile} {output.output_snakefile}
		cp {input.input_configfile} {output.output_configfile}
		cp -r {input.in_scripts} {output.out_scripts}
		'''

rule generate_mip_files:
	'''
	given that I'm repackaging miptools wrangler (so wrangler.sh is not needed)
	and that the existing generate_wrangler_scripts.py seems unnecessarily
	convoluted and that only two files are needed by subsequent steps
	(mipArms.txt and allMipsSamplesNames.tab.txt) it's tempting to write my own
	script for this. Script needs:
	1. probe set being used
	2. file that contains mip_id, mip_family, extension_arm, ligation_arm,
	extension_barcode_length, ligation_barcode_length, gene_name, mipset of each
	probe
	3. names of samples being used (pulled from sample_sets column of sample
	sheet)
	mipArms.txt will have all components of part 2 as columns
	allMipsSamplesNames.tab.txt will have all mip_families and all samples as 2
	columns
	'''
	input:
		arms_file=config['project_resources']+'/mip_ids/mip_arms.txt',
		sample_sheet=config['input_sample_sheet']
	output:
		mip_arms=output_folder+'/mip_ids/mipArms.txt',
		sample_file=output_folder+'/mip_ids/allMipsSamplesNames.tab.txt',
		sample_sheet=output_folder+'/sample_sheet.tsv'
	script:
		'input_files/scripts/generate_mip_files.py'

#rule setup_and_extract_by_arm:
#	input:
#		mip_arms=config['output_folder']+'/mip_ids/mipArms.txt',
#		sample_file=config['output_folder']+'/mip_ids/allMipsSamplesNames.tab.txt'
#	params:
#		output_dir='/opt/analysis/'+config['analysis_dir'],
#		project_resources=config['project_resources'],
#		wrangler_dir=config['output_folder']+'/'+config['wrangler_dir'],
#		sif_file='miptools_dev.sif',
#		special_src='MIPTools-master/src',
#		fastq_dir=config['fastq_dir']
#	threads: config['cpu_count']
#	output:
#		extraction_finished=output_folder+'/extraction_finished.txt'
#	shell:
#		'''
#		singularity exec \
#		-B {params.special_src}:/opt/src \
#		-B output_files:/home/alfred/output_files \
#		-B {params.project_resources}:/opt/project_resources \
#		-B {params.wrangler_dir}:/opt/analysis \
#		-B {params.fastq_dir}:/opt/data \
#		{params.sif_file} \
#		MIPWrangler mipSetupAndExtractByArm --mipArmsFilename /opt/analysis/mip_ids/mipArms.txt --mipSampleFile /opt/analysis/mip_ids/allMipsSamplesNames.tab.txt --numThreads {threads} --masterDir {params.output_dir} --dir /opt/data --mipServerNumber 1 --minCaptureLength=30
#		touch {output.extraction_finished}
#		'''

#rule mip_barcode_correction_multiple:
#	input:
#		extraction_finished=output_folder+'/extraction_finished.txt'
#	output:
#		correction_finished=output_folder+'/correction_finished.txt'
#	params:
#		output_dir='/opt/analysis/'+config['analysis_dir'],
#		wrangler_dir=config['output_folder']+'/'+config['wrangler_dir'],
#		sif_file='miptools_dev.sif',
#		special_src='MIPTools-master/src'
#	threads: config['cpu_count']
#	shell:
#		'''
#		singularity exec \
#		-B {params.special_src}:/opt/src \
#		-B output_files:/home/alfred/output_files \
#		-B {params.wrangler_dir}:/opt/analysis \
#		{params.sif_file} \
#		MIPWrangler mipBarcodeCorrectionMultiple --masterDir {params.output_dir} --numThreads {threads} --overWriteDirs --overWriteLog --logFile mipBarcodeCorrecting_run1 --allowableErrors 6
#		touch {output.correction_finished}
#		'''

#rule mip_correct_for_contam_with_same_barcodes_multiple:
#	input:
#		correction_finished=output_folder+'/correction_finished.txt'
#	output:
#		correction_contam_finished=output_folder+'/correction_contam_finished.txt'
#	threads: config['cpu_count']
#	params:
#		output_dir='/opt/analysis/'+config['analysis_dir'],
#		wrangler_dir=config['output_folder']+'/'+config['wrangler_dir'],
#		sif_file='miptools_dev.sif',
#		special_src='MIPTools-master/src'
#	shell:
#		'''
#		singularity exec \
#		-B {params.special_src}:/opt/src \
#		-B output_files:/home/alfred/output_files \
#		-B {params.wrangler_dir}:/opt/analysis \
#		{params.sif_file} \
#		MIPWrangler mipCorrectForContamWithSameBarcodesMultiple --masterDir {params.output_dir} --numThreads {threads} --overWriteDirs --overWriteLog --logFile mipCorrectForContamWithSameBarcodes_run1
#		touch {output.correction_contam_finished}
#		'''

#rule wrangler_downsample_umi:
#	input:
#		correction_contam_finished=output_folder+'/correction_contam_finished.txt'
#	output:
#		downsampling_finished=output_folder+'/downsampling_finished.txt'
#	threads: config['cpu_count']
#	params:
#		output_dir='/opt/analysis/'+config['analysis_dir'],
#		wrangler_dir=config['output_folder']+'/'+config['wrangler_dir'],
#		sif_file='miptools_dev.sif',
#		special_src='MIPTools-master/src',
#		downsample_threshold=config['umi_threshold']
#	shell:
#		'''
#		singularity exec \
#		-B {params.special_src}:/opt/src \
#		-B output_files:/home/alfred/output_files \
#		-B {params.wrangler_dir}:/opt/analysis \
#		{params.sif_file} \
#		find {params.output_dir} -type f -path '*mipBarcodeCorrection/*.fastq.gz' -exec python /opt/src/wrangler_downsample_umi.py --cpu-count {threads} --downsample-threshold {params.downsample_threshold} '' {{}} +
#		touch {output.downsampling_finished}
#		'''

#rule mip_clustering_multiple:
#	input:
#		downsampling_finished=output_folder+'/downsampling_finished.txt'
#	output:
#		mip_clustering=output_folder+'/mip_clustering_finished.txt'
#	threads: config['cpu_count']
#	params:
#		output_dir='/opt/analysis/'+config['analysis_dir'],
#		wrangler_dir=config['output_folder']+'/'+config['wrangler_dir'],
#		sif_file='miptools_dev.sif',
#		special_src='MIPTools-master/src'
#	shell:
#		'''
#		singularity exec \
#		-B {params.special_src}:/opt/src \
#		-B output_files:/home/alfred/output_files \
#		-B {params.wrangler_dir}:/opt/analysis \
#		{params.sif_file} \
#		MIPWrangler mipClusteringMultiple --masterDir {params.output_dir} --numThreads {threads} --overWriteDirs --overWriteLog --logFile mipClustering_run1 --par /opt/resources/clustering_pars/illumina_collapseHomoploymers.pars.txt --countEndGaps
#		touch {output.mip_clustering}
#		'''

#rule mip_population_clustering_multiple:
#	input:
#		mip_clustering=output_folder+'/mip_clustering_finished.txt'
#	output:
#		pop_clustering=output_folder+'/mip_pop_clustering_finished.txt'
#	threads: config['cpu_count']
#	params:
#		output_dir='/opt/analysis/'+config['analysis_dir'],
#		wrangler_dir=config['output_folder']+'/'+config['wrangler_dir'],
#		sif_file='miptools_dev.sif',
#		special_src='MIPTools-master/src'
#	shell:
#		'''
#		singularity exec \
#		-B {params.special_src}:/opt/src \
#		-B output_files:/home/alfred/output_files \
#		-B {params.wrangler_dir}:/opt/analysis \
#		{params.sif_file} \
#		MIPWrangler mipPopulationClusteringMultiple --masterDir {params.output_dir} --numThreads {threads} --overWriteDirs --overWriteLog --logFile mipPopClustering_run1 --cutoff 0 --countEndGaps --fraccutoff 0.005
#		touch {output.pop_clustering}
#		'''

#rule remove_analysis:
#	input:
#		wrangled=config['output_folder']+'/wrangled.txt',
#	params:
#		analysis=config['output_folder']+'/analysis'
#	resources:
#		time_min=2880
#	output:
#		deleted=config['output_folder']+'/analysis_deleted.txt'
#	shell:
#		'''
#		rm -r {params.analysis}
#		touch {output.deleted}
#		'''
