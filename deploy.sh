# cd /home/ubuntu/kind-cluster/kube-in-one-shot/nodejs-k8s-aws/k8s

# kubectl delete -f namespace.yml -f deployment.yml -f service.yml

# echo "Deployment Started!!!"

# cd /home/ubuntu/kind-cluster/kube-in-one-shot/nodejs-k8s-aws

# docker build -t rj1608/nodejs-app-k8s .

# docker push rj1608/nodejs-app-k8s

# cd /home/ubuntu/kind-cluster/kube-in-one-shot/nodejs-k8s-aws/k8s

# kubectl apply -f namespace.yml -f deployment.yml -f service.yml

# kubectl get pods -n nodejs-app

# kubectl get deployments -n nodejs-app

# kubectl get svc -n nodejs-app

# sleep 20

# # kubectl port-forward service/nodejs-app-service -n nodejs-app 4000:6000 --address=0.0.0.0

# nohup kubectl port-forward service/nodejs-app-service -n nodejs-app 4000:6000 --address=0.0.0.0 > portforward.log 2>&1 &

# ps aux | grep kubectl

# # pkill -f "kubectl port-forward"

#!/bin/bash
# ====================================================================================
# # Exit on any error
# set -e

# # Define paths
# APP_DIR="/home/ubuntu/kind-cluster/kube-in-one-shot/nodejs-k8s-aws"
# K8S_DIR="$APP_DIR/k8s"
# IMAGE_NAME="rj1608/nodejs-app-k8s"
# NAMESPACE="nodejs-app"
# PORT_FORWARD_LOG="portforward.log"

# echo "===================================="
# echo "🚀 Starting Node.js App Deployment"
# echo "===================================="

# echo "📁 Changing directory to Kubernetes manifests folder..."
# cd "$K8S_DIR"

# echo "🧹 Cleaning up existing Kubernetes resources (namespace, deployment, service)..."
# kubectl delete -f namespace.yml -f deployment.yml -f service.yml || echo "⚠️ Some resources may not have existed. Continuing..."

# echo "🛠️ Building Docker image: $IMAGE_NAME"
# cd "$APP_DIR"
# docker build -t "$IMAGE_NAME" .

# echo "📤 Pushing Docker image to Docker Hub..."
# docker push "$IMAGE_NAME"

# echo "📁 Switching back to Kubernetes manifests folder..."
# cd "$K8S_DIR"

# echo "📦 Applying Kubernetes manifests..."
# kubectl apply -f namespace.yml -f deployment.yml -f service.yml

# echo "⏳ Waiting for 20 seconds for pods to initialize..."
# sleep 20

# echo "🔍 Checking pod status..."
# kubectl get pods -n "$NAMESPACE"

# echo "🔍 Checking deployment status..."
# kubectl get deployments -n "$NAMESPACE"

# echo "🔍 Checking service status..."
# kubectl get svc -n "$NAMESPACE"

# echo "🌐 Setting up port forwarding on port 4000 -> 6000..."
# nohup kubectl port-forward service/nodejs-app-service -n "$NAMESPACE" 4000:6000 --address=0.0.0.0 > "$PORT_FORWARD_LOG" 2>&1 &

# echo "📋 Running processes with 'kubectl'..."
# ps aux | grep "[k]ubectl"

# echo "✅ Deployment completed successfully!"
# echo "💡 Access your app at http://<your-ec2-ip>:4000"

# # Uncomment to stop port-forwarding in the future
# # echo "❌ Stopping port-forwarding..."
# # pkill -f "kubectl port-forward"

# ============================================================================================

#!/bin/bash
set -e

# ----------------------
# Default configuration
# ----------------------
IMAGE_NAME="rj1608/nodejs-app-k8s"
NAMESPACE="nodejs-app"
APP_DIR="/home/ubuntu/kind-cluster/kube-in-one-shot/nodejs-k8s-aws"
K8S_DIR="$APP_DIR/k8s"
PORT_FORWARD_LOG="portforward.log"

# ----------------------
# CLI Argument Parsing
# ----------------------
for ARG in "$@"; do
  case $ARG in
    --image-name=*)
      IMAGE_NAME="${ARG#*=}"
      ;;
    --namespace=*)
      NAMESPACE="${ARG#*=}"
      ;;
    *)
      echo "❌ Unknown argument: $ARG"
      exit 1
      ;;
  esac
done

echo "===================================="
echo "🚀 Starting Deployment"
echo "===================================="
echo "🔧 Image Name   : $IMAGE_NAME"
echo "📦 Namespace    : $NAMESPACE"
echo "📁 App Directory: $APP_DIR"
echo ""

# ----------------------
# Kubernetes Cleanup
# ----------------------
echo "📁 Changing to K8s directory..."
cd "$K8S_DIR"

echo "🧹 Deleting old Kubernetes resources (if any)..."
kubectl delete -f namespace.yml -f deployment.yml -f service.yml || echo "⚠️ Continue even if delete fails."

# ----------------------
# Docker Image Build & Push
# ----------------------
echo "🛠️ Building Docker image..."
cd "$APP_DIR"
docker build -t "$IMAGE_NAME" .

echo "📤 Pushing Docker image to Docker Hub..."
docker push "$IMAGE_NAME"

# ----------------------
# Apply Kubernetes Resources
# ----------------------
echo "📁 Applying new Kubernetes resources..."
cd "$K8S_DIR"
kubectl apply -f namespace.yml -f deployment.yml -f service.yml

# ----------------------
# Wait for Pods to be Ready
# ----------------------
echo -n "⏳ Waiting for pods to be ready in namespace [$NAMESPACE] "
kubectl wait --for=condition=ready pod --all -n "$NAMESPACE" --timeout=60s &

# Spinner while waiting
spin='-\|/'
while kill -0 $! 2>/dev/null; do
  for i in $(seq 0 3); do
    printf "\b${spin:$i:1}"
    sleep 0.1
  done
done
echo -e "\n✅ All pods are ready!"

# ----------------------
# Status Check
# ----------------------
echo "🔍 Getting pod status..."
kubectl get pods -n "$NAMESPACE"

echo "🔍 Getting deployment status..."
kubectl get deployments -n "$NAMESPACE"

echo "🔍 Getting service status..."
kubectl get svc -n "$NAMESPACE"

# ----------------------
# Port Forwarding
# ----------------------
echo "🌐 Starting port-forwarding: 4000 -> 6000"
nohup kubectl port-forward service/nodejs-app-service -n "$NAMESPACE" 4000:6000 --address=0.0.0.0 > "$PORT_FORWARD_LOG" 2>&1 &

echo "📋 Running processes using kubectl:"
ps aux | grep "[k]ubectl"

echo "===================================="
echo "✅ Deployment Complete!"
echo "🌍 Access your app at: http://<your-ec2-ip>:4000"
echo "📝 Logs: $PORT_FORWARD_LOG"
echo "===================================="

# Uncomment below line to stop port-forwarding manually
# pkill -f "kubectl port-forward"
