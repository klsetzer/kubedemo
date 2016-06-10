# Source this

KUBEDEMO_HOME=$HOME/Projects/kubedemo

cluster_name() {
  if [[ -n $1  ]]; then
    export KUBE_CLUSTER_NAME="$1"
  fi
  echo "KUBE_CLUSTER_NAME: $KUBE_CLUSTER_NAME"
  export kubeconfig=$KUBEDEMO_HOME/$KUBE_CLUSTER_NAME/kubeconfig
}

kubectl() {
  if [[ ! -r $kubeconfig ]]; then
    >&2 echo "Could not read kubeconfig file: $kubeconfig"
    return
  fi
  /usr/local/bin/kubectl --kubeconfig=$kubeconfig $@
}
