echo "Deployment Started!!!"

docker build -t rj1608/nodejs-app-k8s .

docker push rj1608/nodejs-app-k8s

cd /k8s

kubectl apply -f namespace.yml -f deployment.yml -f service.yml

kubectl get pods -n nodejs-app

kubectl get deployments -n nodejs-app

kubectl get svc -n nodejs-app

kubectl port-forward service/nodejs-app-service -n nodejs-app 4000:6000 --address=0.0.0.0

# nohup kubectl port-forward service/nodejs-app-service -n nodejs-app 4000:6000 --address=0.0.0.0 > portforward.log 2>&1 &

# ps aux | grep kubectl

# pkill -f "kubectl port-forward"