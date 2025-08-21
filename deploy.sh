#!/bin/bash
set -e

echo "🔑 Logging into EKS cluster..."
aws eks update-kubeconfig --region ap-south-1 --name trend

echo "✅ Connected to EKS. Testing..."
kubectl get nodes || true
kubectl get svc || true

echo "🚀 Applying Kubernetes manifests..."
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

echo "✅ Deployment complete!"
