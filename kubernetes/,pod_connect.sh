 #!/bin/bash

kubectl run busybox --image=busybox --restart=Never --tty -i --generator=run-pod/v1 --env "POD_IP=$(kubectl get pod nginx -o go-template={{.status.podIP}})"
# u@busybox$ wget -qO- http://$POD_IP # Run in the busybox container
# u@busybox$ exit # Exit the busybox container
# $ kubectl delete pod busybox # Clean up the pod we created with "kubectl run"

