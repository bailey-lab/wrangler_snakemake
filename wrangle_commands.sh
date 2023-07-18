experiment_id='Mikalayi_DR2_all_sites'
sample_list='sample_sheet.tsv'
probe_sets_used='DR2'
sample_sets_used='JJJ'
cpu_number=24
min_capture_length=30
sif_file='/home/alfred/test_miptools_SSD/miptools_dev.sif'
umi_threshold=200000000000000000

singularity run \
  -B /home/alfred/test_miptools_SSD/project_resources/DR2:/opt/project_resources \
  -B /home/alfred/test_miptools_SSD/seekdeep_mergedfastq:/opt/data \
  -B /home/alfred/big_data/Mikalayi_runs/all_study_sites_DR2_200000000000000000umi_22_cpu/all_study_sites_DR2_200000000000000000umi_22_cpu_wrangler_app:/opt/analysis \
  --app wrangler $sif_file \
  -e $experiment_id -l $sample_list -p $probe_sets_used \
  -s $sample_sets_used -t $umi_threshold -c $cpu_number -m $min_capture_length
