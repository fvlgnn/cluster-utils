#!/bin/bash

# --- CONFIGURAZIONE ---
NAMESPACE="namespace"
BACKUP_DIR="./backups_$(date +%Y%m%d_%H%M%S)"

# Lista dei volumi nel formato "NOME_POD:PERCORSO_REMOTA NOME_LOCALE"
# Aggiungi qui tutti i tuoi 12 volumi
VOLUMI=(
    "nome-pod-0:/path/volume/montato/foo backup-volume-pod-0-foo"
    "nome-pod-0:/path/volume/montato/bar backup-volume-pod-0-bar"
    "nome-pod-1:/path/volume/montato/foobar backup-volume-pod-1-foobar"
    # Aggiungi gli altri qui...
)

# Creazione cartella di backup
mkdir -p "$BACKUP_DIR"
echo "Cartella di backup creata: $BACKUP_DIR"

# --- ESECUZIONE ---
for voce in "${VOLUMI[@]}"; do
    # Divide la stringa in sorgente e destinazione locale
    read -r SRC DEST <<< "$voce"
    
    echo "----------------------------------------------------------"
    echo "Scaricamento di $SRC in corso..."
    
    # 1. Download della cartella
    # Usiamo una sottocartella temporanea per non sporcare la root
    oc cp -n "$NAMESPACE" "$SRC" "$BACKUP_DIR/$DEST"
    
    if [ $? -eq 0 ]; then
        echo "Download completato. Compressione in corso..."
        
        # 2. Compressione tar.gz
        tar -czf "$BACKUP_DIR/$DEST.tar.gz" -C "$BACKUP_DIR" "$DEST"
        
        # 3. Pulizia della cartella non compressa (opzionale)
        rm -rf "$BACKUP_DIR/$DEST"
        
        echo "Archivio $DEST.tar.gz creato con successo."
    else
        echo "Errore durante il download di $SRC. Salto la compressione."
    fi
done

echo "----------------------------------------------------------"
echo "Backup completato! Trovi tutto in: $BACKUP_DIR"