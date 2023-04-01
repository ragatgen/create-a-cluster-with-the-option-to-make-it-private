#!/bin/bash

echo "Enter the subscription where you want to create the cluster on:"
read subscription
echo "*********************************************"


echo "Hi, welcome, let's start creating the cluster!"
echo "*********************************************"

# Prompt user to enter resource group name
echo "Enter the name of the resource group:"
read resourceGroup

# Prompt user to enter AKS cluster name
echo "Enter the name of the AKS cluster:"
read clusterName

# Prompt user to choose whether to enable private cluster
echo "Do you want to enable private cluster? (y/n)"
read enablePrivateCluster

if [[ "$enablePrivateCluster" == "y" ]]; then
  # Set variables for private cluster
  nodeCount=3
  nodeSize="Standard_D2_v2"
  enablePrivateCluster="--enable-private-cluster --enable-private-dns"
else
  # Set variables for regular cluster
  nodeCount=1
  nodeSize="Standard_B2s"
  enablePrivateCluster=""
fi

# Prompt user to enter location
echo "Enter the location (e.g. westeurope):"
read location

# Create resource group
if az group create --name $resourceGroup --location $location; then
  echo "Resource group created successfully"
else
  echo "Failed to create resource group"
  exit 1
fi

# Create AKS cluster
if az aks create \
    --resource-group $resourceGroup \
    --name $clusterName \
    --node-count $nodeCount \
    --node-vm-size $nodeSize \
    --location $location \
    $enablePrivateCluster \
    --generate-ssh-keys; then
  echo "AKS cluster created successfully"
else
  echo "Failed to create AKS cluster"
  exit 1
fi

# Get cluster credentials
if az aks get-credentials --resource-group $resourceGroup --name $clusterName; then
  echo "Cluster credentials retrieved successfully"
else
  echo "Failed to retrieve cluster credentials"
  exit 1
fi

# Verify kubectl connectivity
if kubectl get nodes; then
  echo "kubectl connectivity verified successfully"
else
  echo "Failed to verify kubectl connectivity"
  exit 1
fi
