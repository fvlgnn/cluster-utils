#!/bin/bash

# --- CONFIGURAZIONE ---
BACKUP_DIR="./docker_images_backup_$(date +%Y%m%d_%H%M%S)"

# Lista delle immagini nel formato "repository/nome:tag"
IMMAGINI=(
    "image-registry.me/immagine-uno:0.0.1"
    "image-registry.me/immagine-due:0.0.2"
    "image-registry.me/immagine-tre:0.0.3"
    # Aggiungi qui le altre immagini...
)

# Creazione cartella di backup
mkdir -p "$BACKUP_DIR"
echo "Cartella di backup creata: $BACKUP_DIR"

# --- ESECUZIONE ---
for IMG in "${IMMAGINI[@]}"; do
    echo "----------------------------------------------------------"

    echo "Controllo immagine: $IMG"
    
    # Prova a fare il pull dell'immagine dal registry
    if docker pull "$IMG"; then
        echo "Backup dell'immagine: $IMG"
    
        # Pulizia del nome per il file (sostituisce / e : con _)
        # Esempio: repo/img:tag -> repo_img_tag.tar.gz
        FILE_NAME=$(echo "$IMG" | sed 's/[\/:]/_/g')
        
        echo "Destinazione: $BACKUP_DIR/$FILE_NAME.tar.gz"

        # Esegue il docker save e passa il flusso direttamente a gzip
        # Questo evita di creare file intermedi giganti non compressi
        docker save "$IMG" | gzip > "$BACKUP_DIR/$FILE_NAME.tar.gz"
        # Oppure: usa tutte le CPU disponibili per la compressione
        # docker save "$IMG" | pigz > backup.tar.gz 
        # Oppure: senza compressione
        # docker save "$IMG" > "$BACKUP_DIR/$FILE_NAME.tar"

        # Controllo se il comando è andato a buon fine
        if [ ${PIPESTATUS[0]} -eq 0 ]; then
            echo "Backup completato con successo."
            docker rmi "$IMG"
        else
            echo "Errore durante il backup di $IMG. Verifica che l'immagine esista localmente."
            # Rimuove il file corrotto se presente
            rm -f "$BACKUP_DIR/$FILE_NAME.tar.gz"
        fi
    else
        echo "Errore nel Pull. Verificare connessione o login al registry."
    fi
done

echo "----------------------------------------------------------"
echo "Procedura terminata! I file si trovano in: $BACKUP_DIR"