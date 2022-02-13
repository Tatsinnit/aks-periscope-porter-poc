#!/usr/bin/env bash
set -euo pipefail

install() {
  echo "========================================================================"
  echo Prepare the periscope deployment file
  echo "========================================================================"

  sed -r 's/PORTER_AZURE_BLOB_ACCOUNT_NAME/'"$PORTER_AZURE_BLOB_ACCOUNT_NAME"'/g' -i "/cnab/app/manifests/aks-periscope.yaml"
  sed -r 's/PORTER_AZURE_BLOB_CONTAINER_NAME/'"$PORTER_AZURE_BLOB_CONTAINER_NAME"'/g' -i "/cnab/app/manifests/aks-periscope.yaml"
  sed -r 's/PORTER_AZURE_BLOB_SAS_KEY/'"$PORTER_AZURE_BLOB_SAS_KEY"'/g' -i "/cnab/app/manifests/aks-periscope.yaml"
 
  echo Done
}

cleanup() {
  echo "========================================================================"
  echo Prepare the periscope deployment file cleanup
  echo "========================================================================"
  # kubectl get pods --no-headers -o custom-columns=":metadata.name" -n aks-periscope
  #  kubectl logs aks-periscope-kvg8r -n aks-periscope | grep "Append blob file: networkoutbound"
  sleep 30s
  for variable_name in $(kubectl get pods --no-headers -o custom-columns=":metadata.name" -n aks-periscope); 
	do
    echo "$variable_name"
    sleep 30s
    check_return=`kubectl logs  "$variable_name" -n aks-periscope | grep "Append blob file: networkoutbound"`
    echo "$check_return"
    if [ "$check_return" ] 
    then
       echo found succeful upload
       sleep 15s
       echo initiate pod delete
       kubectl delete pod "$variable_name" -n aks-periscope
       echo "$variable_name" pod deleted
    else
       echo not-found
    fi
	done 

  echo Done cleaning up
}

upgrade() {
  echo World 2.0
}

uninstall() {
  echo Goodbye World
  kubectl delete -f '/cnab/app/manifests/aks-periscope.yaml'
}

# Call the requested function and pass the arguments as-is
"$@"
