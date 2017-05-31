#!/bin/bash
declare program="./bin/run"
declare total_vcore=24
declare total_mem=120
export SPARKPERF_DRIVER_MEM="60g"
source /home/lab/spark-DAAL/DAAL_setup.sh
declare -a a_SPARK_HOME=("/home/lab/spark-DAAL/spark-daal-dist/spark-1.6.3-bin-custom-spark")
declare -a a_SPARKPERF_M=("8192")
declare -a a_SPARKPERF_K=("32768")
declare -a a_SPARKPERF_N=("32768")
declare -a a_SPARKPERF_BLOCK_SIZE=("8192")
declare -a a_ENV_EXECUTOR_NUM=("1")
declare -a a_ENV_DAAL_MODE=("0")

echo "0: cpu only, 1: fpga balanced, 2: fpga maximum"

# this function is called when Ctrl-C is sent
trap_ctrlc () {
    # perform cleanup here
    echo "Ctrl-C caught...performing clean up" 
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
  export SPARKPERF_EXECUTOR_MEM=$executor_memory
  export SPARKPERF_EXECUTOR_VCORE=$executor_vcore
  echo "----------M: $SPARKPERF_M"
  echo "----------K: $SPARKPERF_K"
  echo "----------N: $SPARKPERF_N"
  echo "----------EXECUTOR_MEM: $SPARKPERF_EXECUTOR_MEM"
  echo "----------EXECUTOR_VCORE: $SPARKPERF_EXECUTOR_VCORE"
  declare timestamp=`date +%s`
  declare prefix="zhankun_results/$spark_version-MODE-$DAAL_MODE-EXECUTOR_NUM-$SPARKPERF_EXECUTOR_NUM-B_SIZE-$SPARKPERF_BLOCK_SIZE-M-$SPARKPERF_M-K-$SPARKPERF_K-N-$SPARKPERF_N-EXECUTOR_MEM-$SPARKPERF_EXECUTOR_MEM-EXECUTOR_VCORE-$SPARKPERF_EXECUTOR_VCORE-"
  declare filename=$prefix$timestamp
  touch $filename
  $program > "$filename" 2>&1
  echo "----------exit code: $?"
done
}

trap "trap_ctrlc" 2
export spark_version="daal"
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
   #spark-daal test is done, vanilla don't need to set DAAL_MODE
   a_ENV_DAAL_MODE=("0")
   export spark_version="vanilla"
done


