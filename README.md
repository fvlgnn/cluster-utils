# cluster-utils

Strumenti e script utili per eseguire operazioni su cluster OpenShift (OCP) / Kubernetes (K8S)

Nasce come Openshift / Kubernetes resource dumper.

## Descrizione

### `cluster_download_resources.sh`

Questo script Bash automatizza il download delle principali risorse di un namespace OpenShift Container Platform (OCP) / Kubernetes (K8S) in formato YAML, salvandole in file separati.  Utilizza lo strumento `oc` per interagire con OCP e `yq` per filtrare ed estrarre le informazioni rilevanti, rimuovendo campi non necessari come status, annotazioni e metadati vari. L'output è una serie di file YAML, uno per tipo di risorsa, contenenti le definizioni delle risorse nel namespace specificato. I file vengono salvati nella cartella `$CLUSTER-$NAMESPACE-resources`.


### `cluster_list_resources.sh`

Questo script Bash recupera e stampa una lista delle principali risorse di un dato namespace in OpenShift Container Platform (OCP) / Kubernetes (K8S). Per ogni tipo di risorsa (Pods, Deployments, ecc.), esegue il comando `oc get` e reindirizza l'output (incluso l'eventuale errore "No resources found") verso un file di testo, formattato con un titolo per ciascuna risorsa. Il risultato è un file di testo contenente l'elenco di tutte le risorse presenti nel namespace specificato, o un messaggio che indica l'assenza di risorse per un determinato tipo. Il file generato è denominato con la seguente convenzione `$CLUSTER-$NAMESPACE-resources-list.txt`.


### `helm_export_manifests.sh`

Questo script Bash esporta i manifest di tutte le release Helm presenti in un determinato namespace Openshift (OCP) / Kubernetes (K8S) e li salva in file YAML separati utilizzando gli strumenti `helm` e `jq`. In questo modo, si ottiene una copia di backup di tutte le configurazioni delle tue applicazioni Helm. I file vengono salvati nella cartella `helm-$NAMESPACE-manifests`.


### `pods_get_logs.sh`

Questo script Bash scarica i log di tutti i pod presenti all'intenro di un determinato namespace Openshift (OCP) / Kubernetes (K8S) e li salva all'interno di una cartella `logs/$NAMESPACE` con i file denominati come `pod-$NOME_POD.log`.
È possibile eseguire il comando seguente direttamente da terminale bash/sh.

```bash
NAMESPACE=foo-bar
for POD in $(oc get pods -o custom-columns=POD:.metadata.name --no-headers -n $NAMESPACE); do oc logs -n $NAMESPACE $POD > ./logs/pod-$POD.log; done
```


## TODO

- [x] aggiungi a script selettore automatico ocp/k8s
- [x] + script scarica i log di tutti i pod di un namespace