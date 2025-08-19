#!/bin/bash

set -e

echo "Logging into EKS cluster..."
aws eks update-kubeconfig --region ap-south-1 --name my-cluster

echo "Installing kubectl..."
chmod +x ./kubectl && sudo mv ./kubectl /usr/local/bin/kubectl

echo "Applying Kubernetes manifests..."
kubectl apply -f deployment.yaml -f service.yaml
