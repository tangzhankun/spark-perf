#!/bin/bash
yarn logs -applicationId $1 | grep "\[DAALgemm\]\ TID" | python ./analysis.py
