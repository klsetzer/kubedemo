# CoreOS Demo

## Kubernetes Step-by-step

### My Kubernetes start instructions
1. Install kube-aws
1. Create KMS key
1. Clone kubedemo and cd into it
  1. git clone https://github.com/klsetzer/kubedemo.git
  1. cd kubedemo
1. Configure environment and create helpers
  1. source env_kube.sh
  1. cluster_name frodo
1. Create Kubernetes cluster
  1. ./kube-creator
1. Check cluster status
  1. kubectl cluster-info
  1. May take a few minutes for cluster to finish configuring
1. Start kube proxy
  1. kubectl start proxy
1. Launch dashboard
  1. kubectl create -f kubernetes/cluster/addons/dashboard
1. Connect to proxy URL
  1. URL: http://localhost:8001/api/v1/proxy/namespaces/kube-system/services/kubernetes-dashboard
1. Start guestbook/all-in-one
  1. kubectl create -f kubernetes/examples/guestbook/all-in-one/guestbook-all-in-one.yamlles/guestbook/all-in-one/guestbook-all-in-one.yaml

### Talk about navigation/status commands

### Demo cleanup
1. cd $KUBEDEMO_HOME/<cluster_name>
1. kube-aws destroy
1. kill kubectl proxy process
1. Remove kms key

## TODO
1. Create in multiple AZs
1. Integrate with VPC
1. Integrate with datadog
1. Create CFN template for VPC, subnets, and route tables
1. Need jenkins for this
1. Get web based services
  1. HA
  1. Loadbalacner
  1. Autoscaling
1. Understand Cloud-Config
1. Understand discovery service
  1. For new clusters
1. Spot pricing
  1. https://gist.github.com/danieldreier/e5685e77f9727bf93b18
  1. http://jake.ai/coreos-and-spot-instances-just-for-funzies/
  1. Cheaper demo


### CoreOS + Fleet Industrialization
1. Launching without using the bootstrap discover service
1. Running fleetctl from dev workstation instead of logging into cluster
   https://coreos.com/fleet/docs/latest/using-the-client.html#remote-fleet-access


## I Did
1. Installed CoreOS cluster from CFN launch button on coreos website
  * https://coreos.com/os/docs/latest/booting-on-ec2.html
1. uninstalled boot2docker
1. installed OS X Docker Toolbox: https://docs.docker.com/engine/installation/mac/
1. Ran docker "hello world" test: $ docker run hello-world
1. Installed fleetctl: $ brew install fleetctl
1. Experimented with fleet: https://coreos.com/fleet/docs/latest/launching-containers-fleet.html
  1. Found this error: 
  ip-10-16-183-155 bin # fleetctl list-machines
  Error retrieving list of active machines: googleapi: Error 503: fleet server unable to communicate with etcd
  1. Tried starting etcd:
  ip-10-16-183-155 bin # /bin/etcd
  [etcd] May 30 17:09:08.487 WARNING   | Using the directory ip-10-16-183-155.ec2.internal.etcd as the etcd curation directory because a directory was not specified.
  [etcd] May 30 17:09:08.487 CRITICAL  | Unable to create path: mkdir ip-10-16-183-155.ec2.internal.etcd: read-only file system
  1. Tried restarting with customized CFN template.  Got new error:
  The specified instance type can only be used in a VPC. A subnet ID or network interface ID is required to carry out the request. Launching EC2 instance failed.
  This was because t2.* instance types can only be used in a VPC.  Modified CFN template to include SubnetIds.  Create VPC and subnets through web console.
  Got error: Launching a new EC2 instance. Status Reason: The parameter groupName cannot be used with the parameter subnet. Launching EC2 instance failed.
  1. Fixed CFN networking issues by changing CFN template to GroupIds instead of GroupNames.
  1. Now 'etcdctl  cluster-health' and 'fleetctl list-machines' show a healthy cluster'
  1. Specifically had to add a default (Internet) route to the subnets in the coreos-demo-vpc
  1. Had to add a call to get a new discovery service endpoint for each new stack
  1. Figured out how to run fleetctl from local workstation
  1. Submitted unit hello.service with 'fleetctl submit units/hello.service'
  1. Checked with fleetctl list-unit-files
  1. Started hello.service: fleetctl start hello.service
1. Experimenting with services: https://coreos.com/fleet/docs/latest/using-the-client.html

### Kubernetes
1. Worked through https://coreos.com/kubernetes/docs/latest/kubernetes-on-aws.html
  1. got gpg keys
  1. downloaded kube-aws and installed in /usr/local
  1. Created an KMS key
    1. aws kms --region=<your-region> create-key --description="kube-aws assets"
  1. Download kubectl from curl -O https://storage.googleapis.com/kubernetes-release/release/v1.2.4/bin/darwin/amd64/kubectl
  1. kubectl --kubeconfig=kubeconfig get nodes
  1. The certificate management is complex.  PKI integration will be interesting.
  1. Service load balancing seems too simple: "Services are automatically configured to load balance traffic to pods matching the label query. A random algorithm is used and is currently the only option. Session affinity can be configured to send traffic to pods by client IP." (https://coreos.com/kubernetes/docs/latest/services.html)
  1. Start dashboard: kubectl create -f cluster/addons/dashboard
    1. run 'kubectl proxy' in a term window
    1. Go to 'http://localhost:8001/api/v1/proxy/namespaces/kube-system/services/kubernetes-dashboard' in a browser
  1. Fire up guestbook demo
    1. Works with kubectl: kubectl create -f examples/guestbook/all-in-one/guestbook-all-in-one.yaml
    1. Delete with kubectl delete -f examples/guestbook/all-in-one/guestbook-all-in-one.yaml
    1. kubectl get svc
  1. Tried deploying through the dashboard
    1. Failed with  Node didn't have enough resource: CPU, requested: 100, used: 960


## Getting into docker
* Run 'Docker Quickstart Terminal' after installing Docker Toolbox

## Logging into CoreOS instances
1. eval $(ssh-agent)
1. ssh-add ~/.ssh/lc-us-east-1.pem
1. ssh -A core@ec2-dns-name

## Running fleetctl commands from the local workstation
FLEETCTL_TUNNEL=54.175.226.58:22 fleetctl list-units

## Good docs:
Kubernetes User Guide: http://kubernetes.io/docs/user-guide/
Calico: http://docs.projectcalico.org/en/latest/index.html#

