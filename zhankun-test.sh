#!/bin/bash
# this function is called when Ctrl-C is sent
trap_ctrlc () {
    # perform cleanup here
    echo "Ctrl-C caught...performing clean up" 
    if [[ "$current_pid" -gt -1 ]];then
       echo "Killing spark-perf: $current_pid"
       kill $current_pid 
    fi
    # exit shell script with error code 2
    # if omitted, shell script will continue execution
    exit 2
}
runTest () {
arraylength=${#a_SPARKPERF_M[@]}
for (( p=1; p<${arraylength}+1; p++ ));
do
  export SPARKPERF_M=${a_SPARKPERF_M[$p-1]}
  export SPARKPERF_K=${a_SPARKPERF_K[$p-1]}
  export SPARKPERF_N=${a_SPARKPERF_N[$p-1]}
  let executor_memory="total_mem/SPARKPERF_EXECUTOR_NUM"
  executor_memory+="g"
  let executor_vcore="total_vcore/SPARKPERF_EXECUTOR_NUM"
  export ENV_EXECUTOR_MEM=$executor_memory
  export ENV_EXECUTOR_VCORE=$executor_vcore
  echo "----------M: $SPARKPERF_M"
  echo "----------K: $SPARKPERF_K"
  echo "----------N: $SPARKPERF_N"
  echo "----------EXECUTOR_MEM: $ENV_EXECUTOR_MEM"
  echo "----------EXECUTOR_VCORE: $ENV_EXECUTOR_VCORE"
  declare logfile="zhankun_results/DAAL_MODE:$DAAL_MODE-SPARKPERF_EXECUTOR_NUM:$SPARKPERF_EXECUTOR_NUM-SPARKPERF_BLOCK_SIZE:$SPARKPERF_BLOCK_SIZE-M:$SPARKPERF_M-K:$SPARKPERF_K-N:$SPARKPERF_N-EXECUTOR_MEM:$ENV_EXECUTOR_MEM-EXECUTOR_VCORE:$ENV_EXECUTOR_VCORE"
  touch $logfile
  ./test_script.sh > "$logfile" 2>&1 &
  current_pid=$!
  echo "waiting current pid: $current_pid"
  wait $current_pid
  echo "----------exit code: $?"
done
}

trap "trap_ctrlc" 2
declare current_pid=-1
declare total_vcore=24
declare total_mem=180
export ENV_DRIVER_MEM="128g"
source /home/lab/spark-DAAL/DAAL_setup.sh
declare -a a_SPARK_HOME=("/home/lab/spark-DAAL/spark-daal-dist/spark-1.6.3-bin-custom-spark" "/home/lab/spark-DAAL/spark-original/spark-1.6.3-bin-spark-vanilla")
declare -a a_SPARKPERF_M=("1024" "1024" "1024")
declare -a a_SPARKPERF_K=("10240" "10240" "10240")
declare -a a_SPARKPERF_N=("10240" "10240" "10240")
declare -a a_SPARKPERF_BLOCK_SIZE=("256" "512" "128")
declare -a a_ENV_EXECUTOR_NUM=("1" "4" "8" "16")
declare -a a_ENV_DAAL_MODE=("0" "1" "2")

echo "0: cpu only, 1: fpga balanced, 2: fpga maximum"

for i in "${a_SPARK_HOME[@]}"
do
   export SPARKPERF_SPARKHOME=$i
   echo "--SPARK_HOME: $SPARKPERF_SPARKHOME"
   for j in "${a_ENV_DAAL_MODE[@]}"
   do
      export DAAL_MODE=$j 
      echo "----DAAL_MODE: $DAAL_MODE"
      for z in "${a_ENV_EXECUTOR_NUM[@]}"
      do
         export SPARKPERF_EXECUTOR_NUM=$z
         echo "------EXECUTOR_NUM: $SPARKPERF_EXECUTOR_NUM"
         for o in "${a_SPARKPERF_BLOCK_SIZE[@]}"
         do
            export SPARKPERF_BLOCK_SIZE=$o
            echo "--------BLOCK_SIZE: $SPARKPERF_BLOCK_SIZE"
            runTest
         done
      done
   done
done


