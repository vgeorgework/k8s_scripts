#!/bin/bash
# chmod 777 jobstatus.sh
# Usage  #./jobstatus.sh <namespacename>

echo "Fetching jobs from namespace $1"
for res in $(kubectl get --no-headers=true jobs -n $1 | awk '{print $1}');do # job loop
    status=$(kubectl get job $res -n demo -o jsonpath='{.status.succeeded}')
    if [[ $status -eq '1' ]] # Pass condition
        then
        echo "Job Name: $res                Status: Success"
        # exit 0
    elif [[ $status -eq '0' ]] # Failed condition
        then
        echo "Job Name: $res                Status: Failed"
        # exit 0 # will break and exit from the loop.
        # while :
        # do
        #     status=$(kubectl get job $res -n demo -o jsonpath='{.status.succeeded}')
        #     if [[ $status -eq '1' ]]
        #         then
        #         echo "Job Name: $res                Status: Success"
        #     fi
        # done    
        
    fi
done
