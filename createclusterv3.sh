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

# Prompt user to enter location
echo "Enter the location (e.g. westeurope):"
read location

# Prompt user to enable private cluster
echo "Do you want to enable private cluster? (y/n)"
read privateCluster

# Set variables
nodeCount=3
nodeSize="Standard_D2_v2"

# Create resource group
if az group create --name $resourceGroup --location $location; then
  echo "Resource group created successfully"
else
  echo "Failed to create resource group"
  exit 1
fi

# Create AKS cluster
if [ "$privateCluster" == "y" ]; then
  if az aks create \
      --resource-group $resourceGroup \
      --name $clusterName \
      --node-count $nodeCount \
      --node-vm-size $nodeSize \
      --location $location \
      --generate-ssh-keys \
      --enable-private-cluster; then
    echo "Private AKS cluster created successfully"
  else
    echo "Failed to create private AKS cluster"
    exit 1
  fi
else
  if az aks create \
      --resource-group $resourceGroup \
      --name $clusterName \
      --node-count $nodeCount \
      --node-vm-size $nodeSize \
      --location $location \
      --generate-ssh-keys; then
    echo "AKS cluster created successfully"
  else
    echo "Failed to create AKS cluster"
    exit 1
  fi
fi

# Get cluster credentials
if az aks get-credentials --resource-group $resourceGroup --name $clusterName; then
  echo "Cluster credentials retrieved successfully"
else
  echo "Failed to retrieve cluster credentials"
  exit 1
fi

# Verify kubectl connectivity
if [ "$privateCluster" == "y" ]; then
  if az aks command invoke \
      --resource-group $resourceGroup \
      --name $clusterName \
      --command "kubectl get pods -n kube-system"; then
    echo "kubectl connectivity verified successfully for private cluster"
  else
    echo "Failed to verify kubectl connectivity for private cluster"
    exit 1
  fi
else
  if kubectl get nodes; then
    echo "kubectl connectivity verified successfully for non-private cluster"
  else
    echo "Failed to verify kubectl connectivity for non-private cluster"
    exit 1
  fi
fi
