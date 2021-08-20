#!/bin/bash
# Usage  #./looper.sh <namespacename>
# while : # for inifinity loop
# do
echo "Fetching details for namespace $1"
for res in $(kubectl get --no-headers=true jobs -n $1 | awk '{print $1}');do # job loop
    status=$(kubectl get job $res -n demo -o jsonpath='{.status.succeeded}')
    if [[ $status -eq '1' ]]
        then
        echo "Job Name: $res                Status: Success"
        # exit 0
    elif [[ $status -eq '0' ]]
        then
        echo "Job Name: $res                Status: Failed"
    fi
done
# done