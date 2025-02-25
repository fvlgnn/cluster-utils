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

OUTPUT_DIR="./$CLUSTER-$NAMESPACE-resources"

# Crea la cartella per salvare gli yaml
mkdir -p "$OUTPUT_DIR"

echo "Namespace: $NAMESPACE"
echo "-----------------------------------------"

# Funzione yq per scaricare le risorse in formato YAML
function download_resources() {
    RESOURCE_TYPE=$1
    $CLI get $RESOURCE_TYPE -o yaml | yq '
        del (
        .items.[].status, 
        .items.[].metadata.annotations, 
        .items.[].metadata.managedFields, 
        .items.[].metadata.resourceVersion, 
        .items.[].metadata.resourceVersion, 
        .items.[].metadata.uid,
        .items.[].metadata.generation,
        .items.[].metadata.creationTimestamp 
        )  
        | .items.[] 
        | split_doc
    ' - > "$OUTPUT_DIR/$RESOURCE_TYPE.yaml"
    echo "-----------------------------------------"
}

# Ciclo per stampare tutte le risorse
for RESOURCE in "${RESOURCES[@]}"; do
    echo "Download risorsa: $RESOURCE" 
    download_resources $RESOURCE
done

echo "Download completato!"
