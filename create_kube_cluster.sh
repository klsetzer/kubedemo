#!/bin/bash

if [[ -z $KUBE_CLUSTER_NAME ]]; then
  echo 'set cluster name with cluster_name <name>'
  exit 1
fi

mkdir $KUBE_CLUSTER_NAME && cd $KUBE_CLUSTER_NAME

#kms_key=$(aws kms --region=us-east-1 create-key --description="kube-aws assets")
#{
#    "KeyMetadata": {
#        "KeyId": "819a0470-5371-4217-942e-86abd5e3c979",
#        "Description": "kube-aws assets",
#        "Enabled": true,
#        "KeyUsage": "ENCRYPT_DECRYPT",
#        "CreationDate": 1464908713.482,
#        "Arn": "arn:aws:kms:us-east-1:437443400885:key/819a0470-5371-4217-942e-86abd5e3c979",
#        "AWSAccountId": "437443400885"
#    }
#}


kube-aws init --cluster-name=$KUBE_CLUSTER_NAME \
  --external-dns-name=${KUBE_CLUSTER_NAME}-endpoint.aws.liquidchicken.org \
  --region=us-east-1 \
  --availability-zone=us-east-1c \
  --key-name=lc-us-east-1 \
  --kms-key-arn="arn:aws:kms:us-east-1:437443400885:key/819a0470-5371-4217-942e-86abd5e3c979"


kube-aws render


