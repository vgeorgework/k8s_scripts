#!/bin/bash
RESSOURCE_IGNORE="^(events|nodes|clusters|storageclasses|thirdpartyresources|clusterrolebindings|clusterroles|componentstatuses|persistentvolumes)$"
echo "-> Getting namespaces ..."
kubectl get  -o=json ns | \
jq '.items[] |
	select(.metadata.name=="default") |
	del(.status,
        .metadata.uid,
        .metadata.selfLink,
        .metadata.resourceVersion,
        .metadata.creationTimestamp,
        .metadata.generation
    )' > ./backup-namespaces.json
echo "=> Namespaces saved."

echo "-> Saving every namespaced objects"
for ns in $(jq -r '.metadata.name' < ./backup-namespaces.json); do
    echo "--> Currently saving namespace: $ns"
	mkdir "backup-$ns"
	for ressource in $(kubectl api-resources --verbs=list --namespaced -o name |awk '{print $1}' | cut -d'/' -f 1| sort | uniq); do
		echo "---> Saving ressource: $ressource"
        EXPORT="$(kubectl get "$ressource" --namespace="default"  -o json  | \
			jq '.items[] |
				select(.type!="kubernetes.io/service-account-token") |
                del(
                    .spec.clusterIP,
                    .spec.clusterIPs,
                    .metadata.uid,
                    .metadata.selfLink,
                    .metadata.resourceVersion,
                    .metadata.creationTimestamp,
                    .metadata.generation,
                    .status,                    
                    .spec.template.spec.securityContext,
                    .spec.template.spec.dnsPolicy,
                    .spec.template.spec.terminationGracePeriodSeconds,
                    .spec.template.spec.restartPolicy
                )')"
		if [ -n "$EXPORT" ]; then
        	echo "$EXPORT" >> "./backup-$ns/$ressource.json"
	    fi
		echo "---> Saved ressource: $ressource"
	done
	echo "--> Namespace saved: $ns"
done
echo "=> Namespaced objects saved."
EXPORT="$(kubectl get "pv" --namespace="default"  -o json  | \
			jq '.items[] |
				select(.type!="kubernetes.io/service-account-token") |
                del(
                    .spec.clusterIP,
                    .spec.claimRef,
                    .metadata.uid,
                    .metadata.selfLink,
                    .metadata.resourceVersion,
                    .metadata.creationTimestamp,
                    .metadata.generation,
                    .status,
                    .spec.template.spec.securityContext,
                    .spec.template.spec.dnsPolicy,
                    .spec.template.spec.terminationGracePeriodSeconds,
                    .spec.template.spec.restartPolicy
                )')"
		if [ -n "$EXPORT" ]; then
        	echo "$EXPORT" >> "./backup-default/pv.json"
	    fi
		echo "---> Saved ressource: $ressource"

echo "-> Saving non-namespaced objects..."
kubectl --namespace="${ns}" get  -o=json clusterrolebindings,clusterroles,componentstatuses,storageclasses,thirdpartyresources,persistentvolumes | \
jq '.items[] |
	select(.type!="kubernetes.io/service-account-token") |
	del(
		.spec.clusterIP,
		.metadata.uid,
		.metadata.selfLink,
		.metadata.resourceVersion,
		.metadata.creationTimestamp,
		.metadata.generation,
		.status,
		.spec.template.spec.securityContext,
		.spec.template.spec.dnsPolicy,
		.spec.template.spec.terminationGracePeriodSeconds,
		.spec.template.spec.restartPolicy
	)' >> "./backup-non-namespaced.json"
echo "=> Saved non-namespaced objects."

echo "Completed."