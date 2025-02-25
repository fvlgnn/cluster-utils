#!/bin/sh

NAMESPACE=$1  # Namespace passato come argomento

# Controllo se il namespace è stato dichiarato
if [ -z "$NAMESPACE" ]; then
    echo "Uso: $0 <namespace>"
    exit 1
fi

OUTPUT_DIR="./helm-$NAMESPACE-manifests"

# Crea la cartella per salvare i manifest
mkdir -p "$OUTPUT_DIR"

# Ottengo la lista delle release Helm nel namespace con un ciclo
helm list -n $NAMESPACE -o json | jq -r '.[].name' | while read -r RELEASE; do
    if [ -n "$RELEASE" ]; then
        echo "Esporto manifest per la release: $RELEASE"
		CLEAN_RELEASE=$(echo "$RELEASE" | tr -d '[:cntrl:]' | tr -d '[:space:]')
        helm get manifest $CLEAN_RELEASE -n $NAMESPACE > "$OUTPUT_DIR/$CLEAN_RELEASE.yaml"
    fi
done

echo "Tutti i manifest sono stati salvati in $OUTPUT_DIR"
