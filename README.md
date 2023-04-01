# create-a-cluster-with-the-option-to-make-it-private

Is you enable the private cluster take in consideration that you will have to go to a virtual machine within the same cluster VNET in order to run commands

else run invoke commands to test

I.E
az aks command invoke \
  --resource-group myResourceGroup \
  --name myAKSCluster \
  --command "kubectl get pods -n kube-system"
