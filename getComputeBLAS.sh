#!/bin/bash
yarn logs -applicationId $1 | grep "\[OpenBlasgemm\]\ TID" | python ./analysis.py
