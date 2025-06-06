#!/bin/sh

NAMESPACE=$1  # Namespace passato come argomento

# Controllo se il namespace è stato dichiarato
if [ -z "$NAMESPACE" ]; then
    echo "Comando: $0 <namespace>"
    exit 1
fi

OUTPUT_DIR="./logs/$NAMESPACE"

# Crea la cartella per salvare i manifest
mkdir -p "$OUTPUT_DIR"

# Ottengo la lista dei pod e ne scarico i log
for POD in $(oc get pods -o custom-columns=POD:.metadata.name --no-headers -n $NAMESPACE); do
    oc logs -n $NAMESPACE $POD > "$OUTPUT_DIR/pod-$POD.log"
done

echo "Tutti i logs dei pods sono stati salvati in $OUTPUT_DIR"
