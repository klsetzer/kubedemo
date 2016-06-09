# Source this

cluster_name() {
  if [[ -n $1  ]]; then
    export KUBE_CLUSTER_NAME="$1"
  fi
  echo "KUBE_CLUSTER_NAME: $KUBE_CLUSTER_NAME"
  export kubeconfig=/Users/ksetzer/Projects/pe/kube/$KUBE_CLUSTER_NAME/kubeconfig
}


kubectl() {
  if [[ ! -r $kubeconfig ]]; then
    >&2 echo "Could not read kubeconfig file: $kubeconfig"
    exit 1
  fi
  /usr/local/bin/kubectl --kubeconfig=$kubeconfig $@
}
