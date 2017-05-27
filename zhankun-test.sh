#!/bin/bash
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
done
}

declare total_vcore=24
declare total_mem=200
export ENV_DRIVER_MEM="128g"

declare -a a_SPARK_HOME=("/home/lab/spark-DAAL/spark-daal-dist/spark-1.6.3-bin-custom-spark" "/home/lab/spark-DAAL/spark-original/spark-1.6.3-bin-spark-vanilla")
declare -a a_SPARKPERF_M=("1024" "4096" "8192")
declare -a a_SPARKPERF_K=("10240" "16384" "65536")
declare -a a_SPARKPERF_N=("10240" "16384" "32768")
declare -a a_SPARKPERF_BLOCK_SIZE=("1024" "2048" "4096")
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


