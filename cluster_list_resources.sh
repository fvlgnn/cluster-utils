#!/bin/sh

NAMESPACE=$1  # Namespace passato come argomento

# Lista delle risorse principali di OpenShift
RESOURCES=("Pods" "Deployments" "DeploymentConfigs" "StatefulSets" "Secrets" "ConfigMaps" "CronJobs" "Jobs" "ReplicaSets" "ReplicationControllers" "PodDisruptionBudgets"  "Services" "Routes" "Ingresses" "NetworkPolicies" "PersistentVolumes" "PersistentVolumeClaims" "BuildConfigs" "Builds" "ImageStreams" "ServiceAccounts")

# Controllo se il namespace è stato dichiarato
if [ -z "$NAMESPACE" ]; then
	echo "Nessun namespace specificato."
    echo "Uso: sh $0 <namespace>"
    exit 1
fi

# Controllo se è OpenShift (oc get clusterversion funziona solo su OCP)
if oc get clusterversion > /dev/null 2>&1; then
    CLI="oc"
    CLUSTER="ocp"
    echo "Rilevato OpenShift: uso 'oc'"
else
    CLI="kubectl"
    CLUSTER="k8s"
    echo "Rilevato Kubernetes: uso 'kubectl'"
fi

echo "Lettura ed esportazione delle risorse per namespace $NAMESPACE ..."

echo "╔════════════════════════════════════════════════════════════╗" > $CLUSTER-$NAMESPACE-resources-list.txt
echo "║          Lista risorse per namespace: $NAMESPACE           " >> $CLUSTER-$NAMESPACE-resources-list.txt
echo "╚════════════════════════════════════════════════════════════╝" >> $CLUSTER-$NAMESPACE-resources-list.txt
echo "" >> $CLUSTER-$NAMESPACE-resources-list.txt

# Funzione per stampare le risorse con titolo
function get_resources() {
    RESOURCE_TYPE=$1
    echo "════════════════════════ $RESOURCE_TYPE ════════════════════════" >> $CLUSTER-$NAMESPACE-resources-list.txt
	RESULT=$($CLI get $RESOURCE_TYPE -n $NAMESPACE 2>/dev/null)
    if [[ -z "$RESULT" || "$RESULT" == "No resources found in"* ]]; then
        echo "║ Nessuna risorsa disponibile per $RESOURCE_TYPE.              " >> $CLUSTER-$NAMESPACE-resources-list.txt
    else
        echo "$RESULT" >> $CLUSTER-$NAMESPACE-resources-list.txt
    fi
    echo "══════════════════════════════════════════════════════════════" >> $CLUSTER-$NAMESPACE-resources-list.txt
    echo "" >> $CLUSTER-$NAMESPACE-resources-list.txt
}

# Ciclo per stampare tutte le risorse
for RESOURCE in "${RESOURCES[@]}"; do
    get_resources $RESOURCE
done

echo "Lettura ed esportazione completata!"