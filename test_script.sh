#!/bin/bash
trap_ctrlc () {
    # perform cleanup here
    echo "I was told to stop!" 
    # exit shell script with error code 2
    # if omitted, shell script will continue execution
    exit 2
}
trap "trap_ctrlc" 2
echo "hahahaha"
sleep 80
