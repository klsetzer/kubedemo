#!/bin/bash
cluster_name='frodo'

runcmd() {
  cmd=$1; shift
  echo "CMD: $cmd, ARGS: $@"
  $cmd $@
}

cd $PROJECTS_HOME/pe/kube
source env_kube.sh
cluster_name $cluster_name
./create_kube_cluster.sh
cd $cluster_name
echo "Fix ASG max in stack-template.json (Change ASG max to 10)"
echo "Fix the following in kubeconfig
  1. externalDNSName: frodo-endpoint.aws.liquidchicken.org
  2. createRecordSet: true
  3. hostedZone: aws.liquidchicken.org
  4. recordSetTTL: 60"
echo "Press <enter> to proceed"
read x

echo
echo "VALIDATION PHASE"
runcmd kube-aws validate
runcmd kube-aws up
runcmd kube-aws status

echo "Review validation, press <enter> to proceed."
read x

echo
echo "Launch dashboard!"
echo "Start proxy!"
echo "Connect to proxy URL!"
echo "Start guestbook/all-in-one!"
