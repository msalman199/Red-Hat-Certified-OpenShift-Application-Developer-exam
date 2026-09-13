Lab 18: Application Deployment with Kubernetes Resources
Objectives
By the end of this lab, you will be able to:

Create and manage Kubernetes ConfigMaps for application configuration
Implement Kubernetes Secrets for sensitive data management
Deploy applications using Persistent Volumes for data persistence
Configure applications to use external configuration and storage resources
Understand the relationship between Pods, ConfigMaps, Secrets, and Persistent Volumes
Apply best practices for application deployment in Kubernetes environments
Prerequisites
Before starting this lab, you should have:

Basic understanding of Kubernetes concepts (Pods, Deployments, Services)
Familiarity with YAML syntax and file structure
Basic Linux command-line knowledge
Understanding of containerization concepts
Knowledge of text editors like vi, nano, or similar
Lab Environment Setup
Ready-to-Use Cloud Machines: Al Nafi provides Linux-based cloud machines with Kubernetes pre-installed. Simply click Start Lab to access your environment - no need to build your own VM or install Kubernetes manually.

Your lab environment includes:

Ubuntu 20.04 LTS with kubectl pre-configured
Minikube cluster ready for use
All necessary tools and dependencies installed
Task 1: Create Kubernetes Resources for Application Configuration
Subtask 1.1: Start Your Kubernetes Cluster
First, let's ensure your Kubernetes cluster is running and ready.

Start Minikube cluster:
minikube start --driver=docker
Verify cluster status:
kubectl cluster-info
kubectl get nodes
Check available namespaces:
kubectl get namespaces
Subtask 1.2: Create a ConfigMap for Application Configuration
ConfigMaps allow you to store non-sensitive configuration data that can be consumed by your applications.

Create a directory for lab files:
mkdir ~/k8s-lab18
cd ~/k8s-lab18
Create a ConfigMap using imperative commands:
kubectl create configmap app-config \
  --from-literal=database_host=mysql.example.com \
  --from-literal=database_port=3306 \
  --from-literal=app_mode=production \
  --from-literal=log_level=info
Verify the ConfigMap creation:
kubectl get configmaps
kubectl describe configmap app-config
Create a ConfigMap from a file. First, create a configuration file:
cat > app.properties << EOF
# Application Configuration
server.port=8080
server.host=0.0.0.0
cache.enabled=true
cache.ttl=3600
feature.new_ui=enabled
feature.analytics=disabled
EOF
Create ConfigMap from the file:
kubectl create configmap app-properties --from-file=app.properties
Create a declarative ConfigMap YAML file:
cat > configmap-declarative.yaml << EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: web-config
  labels:
    app: webapp
data:
  nginx.conf: |
    server {
        listen 80;
        server_name localhost;
        location / {
            root /usr/share/nginx/html;
            index index.html;
        }
        location /api {
            proxy_pass http://backend:8080;
        }
    }
  index.html: |
    <!DOCTYPE html>
    <html>
    <head>
        <title>My Web App</title>
    </head>
    <body>
        <h1>Welcome to My Kubernetes Web App</h1>
        <p>This page is served from a ConfigMap!</p>
    </body>
    </html>
EOF
Apply the declarative ConfigMap:
kubectl apply -f configmap-declarative.yaml
List all ConfigMaps:
kubectl get configmaps
Subtask 1.3: Create Kubernetes Secrets for Sensitive Data
Secrets are used to store sensitive information like passwords, tokens, and keys.

Create a Secret using imperative commands:
kubectl create secret generic database-secret \
  --from-literal=username=dbadmin \
  --from-literal=password=SecureP@ssw0rd123 \
  --from-literal=root-password=RootP@ssw0rd456
Verify Secret creation:
kubectl get secrets
kubectl describe secret database-secret
Create a Secret for TLS certificates. First, generate sample certificates:
# Generate a private key
openssl genrsa -out tls.key 2048

# Generate a certificate signing request
openssl req -new -key tls.key -out tls.csr -subj "/CN=myapp.example.com/O=myapp"

# Generate a self-signed certificate
openssl x509 -req -in tls.csr -signkey tls.key -out tls.crt -days 365
Create TLS Secret:
kubectl create secret tls tls-secret --cert=tls.crt --key=tls.key
Create a declarative Secret YAML file:
cat > secret-declarative.yaml << EOF
apiVersion: v1
kind: Secret
metadata:
  name: api-keys
  labels:
    app: webapp
type: Opaque
data:
  api-key: $(echo -n "sk-1234567890abcdef" | base64)
  jwt-secret: $(echo -n "my-super-secret-jwt-key" | base64)
  oauth-client-id: $(echo -n "oauth-client-12345" | base64)
  oauth-client-secret: $(echo -n "oauth-secret-67890" | base64)
EOF
Apply the declarative Secret:
kubectl apply -f secret-declarative.yaml
View Secret data (base64 encoded):
kubectl get secret api-keys -o yaml
Decode Secret values:
kubectl get secret api-keys -o jsonpath='{.data.api-key}' | base64 --decode
echo
Task 2: Implement Persistent Storage with Persistent Volumes
Subtask 2.1: Create Persistent Volumes and Persistent Volume Claims
Persistent Volumes provide durable storage that persists beyond the lifecycle of individual Pods.

Create a Persistent Volume YAML file:
cat > persistent-volume.yaml << EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: app-pv
  labels:
    type: local
spec:
  storageClassName: manual
  capacity:
    storage: 2Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/data"
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: database-pv
  labels:
    type: local
spec:
  storageClassName: manual
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/database"
EOF
Apply the Persistent Volume configuration:
kubectl apply -f persistent-volume.yaml
Verify Persistent Volume creation:
kubectl get pv
kubectl describe pv app-pv
Create Persistent Volume Claims:
cat > persistent-volume-claims.yaml << EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-pvc
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: database-pvc
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 3Gi
EOF
Apply the PVC configuration:
kubectl apply -f persistent-volume-claims.yaml
Check PVC status:
kubectl get pvc
kubectl describe pvc app-pvc
Subtask 2.2: Deploy Applications Using ConfigMaps, Secrets, and Persistent Volumes
Now let's create applications that use all the resources we've created.

Create a database deployment with persistent storage:
cat > mysql-deployment.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql-database
  labels:
    app: mysql
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:8.0
        ports:
        - containerPort: 3306
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: database-secret
              key: root-password
        - name: MYSQL_USER
          valueFrom:
            secretKeyRef:
              name: database-secret
              key: username
        - name: MYSQL_PASSWORD
          valueFrom:
            secretKeyRef:
              name: database-secret
              key: password
        - name: MYSQL_DATABASE
          value: "webapp"
        volumeMounts:
        - name: mysql-storage
          mountPath: /var/lib/mysql
      volumes:
      - name: mysql-storage
        persistentVolumeClaim:
          claimName: database-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: mysql-service
spec:
  selector:
    app: mysql
  ports:
  - port: 3306
    targetPort: 3306
  type: ClusterIP
EOF
Apply the MySQL deployment:
kubectl apply -f mysql-deployment.yaml
Create a web application deployment using ConfigMaps and Secrets:
cat > webapp-deployment.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
  labels:
    app: webapp
spec:
  replicas: 2
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
    spec:
      containers:
      - name: webapp
        image: nginx:1.21
        ports:
        - containerPort: 80
        env:
        - name: DATABASE_HOST
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: database_host
        - name: DATABASE_PORT
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: database_port
        - name: APP_MODE
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: app_mode
        - name: API_KEY
          valueFrom:
            secretKeyRef:
              name: api-keys
              key: api-key
        - name: JWT_SECRET
          valueFrom:
            secretKeyRef:
              name: api-keys
              key: jwt-secret
        volumeMounts:
        - name: nginx-config
          mountPath: /etc/nginx/conf.d
        - name: web-content
          mountPath: /usr/share/nginx/html
        - name: app-properties
          mountPath: /etc/config
        - name: app-storage
          mountPath: /var/www/uploads
      volumes:
      - name: nginx-config
        configMap:
          name: web-config
          items:
          - key: nginx.conf
            path: default.conf
      - name: web-content
        configMap:
          name: web-config
          items:
          - key: index.html
            path: index.html
      - name: app-properties
        configMap:
          name: app-properties
      - name: app-storage
        persistentVolumeClaim:
          claimName: app-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: webapp-service
spec:
  selector:
    app: webapp
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
  type: NodePort
EOF
Apply the web application deployment:
kubectl apply -f webapp-deployment.yaml
Verify all deployments are running:
kubectl get deployments
kubectl get pods
kubectl get services
Check pod logs to verify configuration:
# Get pod names
kubectl get pods -l app=webapp

# Check logs (replace <pod-name> with actual pod name)
kubectl logs <pod-name>

# Execute into a pod to verify mounted volumes
kubectl exec -it <pod-name> -- /bin/bash
Subtask 2.3: Test and Verify Application Configuration
Test the web application:
# Get the Minikube IP
minikube ip

# Test the application (replace <minikube-ip> with actual IP)
curl http://<minikube-ip>:30080
Verify ConfigMap data is accessible inside the pod:
# Execute into webapp pod
kubectl exec -it $(kubectl get pods -l app=webapp -o jsonpath='{.items[0].metadata.name}') -- /bin/bash

# Inside the pod, check environment variables
env | grep DATABASE
env | grep APP_MODE

# Check mounted configuration files
cat /etc/config/app.properties
cat /etc/nginx/conf.d/default.conf

# Check persistent volume mount
ls -la /var/www/uploads
df -h /var/www/uploads

# Exit the pod
exit
Verify Secret data is accessible:
kubectl exec -it $(kubectl get pods -l app=webapp -o jsonpath='{.items[0].metadata.name}') -- /bin/bash

# Inside the pod, check secret environment variables
env | grep API_KEY
env | grep JWT_SECRET

exit
Test persistent storage:
# Create a test file in the persistent volume
kubectl exec -it $(kubectl get pods -l app=webapp -o jsonpath='{.items[0].metadata.name}') -- /bin/bash

# Inside the pod
echo "This is persistent data" > /var/www/uploads/test.txt
cat /var/www/uploads/test.txt
exit

# Delete the pod to test persistence
kubectl delete pod $(kubectl get pods -l app=webapp -o jsonpath='{.items[0].metadata.name}')

# Wait for new pod to start
kubectl get pods -l app=webapp

# Check if data persists in new pod
kubectl exec -it $(kubectl get pods -l app=webapp -o jsonpath='{.items[0].metadata.name}') -- cat /var/www/uploads/test.txt
Subtask 2.4: Update and Manage Resources
Update a ConfigMap:
kubectl patch configmap app-config --patch '{"data":{"log_level":"debug","new_feature":"enabled"}}'
Verify the update:
kubectl describe configmap app-config
Update a Secret:
kubectl patch secret api-keys --patch '{"data":{"new-api-key":"'$(echo -n "new-secret-key-123" | base64)'"}}'
Scale the application:
kubectl scale deployment webapp --replicas=3
kubectl get pods -l app=webapp
View resource usage:
kubectl top nodes
kubectl top pods
Troubleshooting Tips
Common Issues and Solutions
Persistent Volume not binding:

Check if the storage class matches between PV and PVC
Verify the access modes are compatible
Ensure sufficient storage capacity
ConfigMap or Secret not mounting:

Verify the resource exists: kubectl get configmaps or kubectl get secrets
Check the volume mount paths in the deployment
Ensure correct key names in the volume definition
Pod stuck in Pending state:

Check node resources: kubectl describe nodes
Verify PVC is bound: kubectl get pvc
Check for scheduling constraints
Environment variables not set:

Verify ConfigMap/Secret key names match the deployment specification
Check if the resources exist in the same namespace
Restart pods after updating ConfigMaps or Secrets
Application not accessible:

Verify service configuration: kubectl get svc
Check if pods are running: kubectl get pods
Test internal connectivity: kubectl exec -it <pod> -- curl <service-name>
Cleanup
To clean up all resources created in this lab:

# Delete deployments and services
kubectl delete -f webapp-deployment.yaml
kubectl delete -f mysql-deployment.yaml

# Delete PVCs (this will also release PVs)
kubectl delete -f persistent-volume-claims.yaml

# Delete PVs
kubectl delete -f persistent-volume.yaml

# Delete ConfigMaps
kubectl delete configmap app-config app-properties web-config

# Delete Secrets
kubectl delete secret database-secret tls-secret api-keys

# Remove local files
rm -f tls.key tls.csr tls.crt app.properties
rm -f *.yaml

# Stop Minikube (optional)
minikube stop
Conclusion
In this comprehensive lab, you have successfully:

Created and managed ConfigMaps to store non-sensitive application configuration data, learning both imperative and declarative approaches
Implemented Secrets for secure storage of sensitive information like passwords, API keys, and certificates
Deployed Persistent Volumes and Persistent Volume Claims to provide durable storage that persists beyond pod lifecycles
Built complete application deployments that integrate ConfigMaps, Secrets, and Persistent Volumes
Tested and verified that configurations are properly mounted and accessible within running containers
Learned troubleshooting techniques for common issues with Kubernetes resources
These skills are essential for the Red Hat Certified OpenShift Application Developer exam and real-world Kubernetes application deployment. You now understand how to:

Separate configuration from application code using ConfigMaps
Securely manage sensitive data with Secrets
Provide persistent storage for stateful applications
Create robust, production-ready application deployments
Follow Kubernetes best practices for resource management
This knowledge forms the foundation for deploying scalable, maintainable applications in Kubernetes environments, whether in development, testing, or production scenarios. The techniques you've learned apply directly to OpenShift environments and other Kubernetes distributions, making you well-prepared for enterprise container orchestration challenges.
