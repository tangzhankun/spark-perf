import subprocess

daal_vanilla_result_log_dict = dict()

abprefix = "/home/lab/spark-DAAL/spark-perf/"
cmd = 'grep -o "results/mllib_perf_output__.*.out " /home/lab/spark-DAAL/spark-perf/zhankun_results/*MODE*'
ss = subprocess.check_output(cmd, shell=True).rstrip().split("\n")
for line in ss:
    try:
        tmp_str = line.split(":")
        #get application id from spark-perf log
        #sparkperf_out = './results/mllib_perf_output__2017-06-03_16-55-13_logs/block-matrix-mult.out'
        sparkperf_out = abprefix + tmp_str[1].rstrip()
        daal_vanilla_result_log = tmp_str[0].split("/")[-1]
        print("daal_vanilla_result_log:%s" % daal_vanilla_result_log)
        print('spark-perf log:%s' % sparkperf_out)
        cmd = ['grep', '-o', 'application_[0-9]*_[0-9]*', sparkperf_out]
        applicationID = subprocess.check_output(cmd).split('\n', 1)[0]
        print('applicationID:%s' % applicationID)
        #get gemm compute log
        mode = daal_vanilla_result_log.split("-")[0]
        if(mode == 'vanilla'):
            cmd = 'yarn logs -applicationId %s | grep "\[OpenBlasgemm\]\ TID" | python ./analysis.py' % applicationID
        else:
	    cmd = 'yarn logs -applicationId %s | grep "\[DAALgemm\]\ TID" | python ./analysis.py' % applicationID 
        compute_result = subprocess.check_output(cmd, shell=True)
        compute_average = compute_result.split(":")[-1].rstrip()
        daal_vanilla_result_log_dict[daal_vanilla_result_log] = compute_average
    except: 
        pass
#open res.log from zhankun-test.sh and add gemm timestamp
f = open('./final.data', 'w')
lines = [line.rstrip('\n') for line in open('./zhankun_results/res.log')]
for line in lines:
    key = line.split("/")[1].split(":")[0]
    if key in daal_vanilla_result_log_dict:
        newline = line + ":gemmFunction:" + daal_vanilla_result_log_dict[key] + '\n'
        f.write(newline)
    else:
        f.write(line+":gemmFunction:unknown\n")
f.close()
