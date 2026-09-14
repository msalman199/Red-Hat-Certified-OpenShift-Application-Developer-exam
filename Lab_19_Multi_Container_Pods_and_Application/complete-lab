Lab 19: Multi-Container Pods and Application Management
Objectives
By the end of this lab, you will be able to:

Understand the concepts and benefits of multi-container pod architectures
Create and deploy multi-container pods using various design patterns
Configure sidecar containers to enhance application functionality
Implement init containers for application initialization tasks
Test inter-container communication within pods
Manage shared resources between containers in a pod
Troubleshoot common multi-container pod issues
Prerequisites
Before starting this lab, you should have:

Basic understanding of Kubernetes concepts (pods, containers, services)
Familiarity with YAML syntax and Kubernetes manifest files
Experience with kubectl command-line tool
Knowledge of container networking fundamentals
Understanding of Linux file systems and volume concepts
Lab Environment Setup
Ready-to-Use Cloud Machines: Al Nafi provides pre-configured Linux-based cloud machines with Kubernetes cluster already set up. Simply click Start Lab to access your environment - no need to build your own VM or install Kubernetes from scratch.

Your lab environment includes:

Kubernetes cluster (v1.28+)
kubectl configured and ready to use
Docker runtime for container operations
Text editor (nano/vim) for editing YAML files
Task 1: Create and Manage Multi-Container Pods
Subtask 1.1: Understanding Multi-Container Pod Patterns
Multi-container pods are useful when you need containers that work closely together and share resources. Common patterns include:

Sidecar Pattern: Helper container that extends the main application
Ambassador Pattern: Proxy container that handles external communications
Adapter Pattern: Container that transforms data for the main application
Let's start by examining the current cluster state:

kubectl get nodes
kubectl get pods --all-namespaces
Subtask 1.2: Create a Basic Multi-Container Pod
Create a simple multi-container pod with a web server and a log processor:

nano multi-container-basic.yaml
Add the following content:

apiVersion: v1
kind: Pod
metadata:
  name: multi-container-basic
  labels:
    app: multi-container-demo
spec:
  containers:
  - name: web-server
    image: nginx:1.21
    ports:
    - containerPort: 80
    volumeMounts:
    - name: shared-logs
      mountPath: /var/log/nginx
  - name: log-processor
    image: busybox:1.35
    command: ['sh', '-c']
    args:
    - |
      while true; do
        echo "Processing logs at $(date)" >> /var/log/app/processed.log
        if [ -f /var/log/nginx/access.log ]; then
          tail -n 5 /var/log/nginx/access.log >> /var/log/app/processed.log
        fi
        sleep 30
      done
    volumeMounts:
    - name: shared-logs
      mountPath: /var/log/nginx
    - name: processed-logs
      mountPath: /var/log/app
  volumes:
  - name: shared-logs
    emptyDir: {}
  - name: processed-logs
    emptyDir: {}
Deploy the pod:

kubectl apply -f multi-container-basic.yaml
Verify the pod is running:

kubectl get pods multi-container-basic
kubectl describe pod multi-container-basic
Subtask 1.3: Inspect Container Logs
Check logs from both containers:

# Check web server logs
kubectl logs multi-container-basic -c web-server

# Check log processor logs
kubectl logs multi-container-basic -c log-processor

# Follow logs in real-time
kubectl logs -f multi-container-basic -c log-processor
Subtask 1.4: Execute Commands in Specific Containers
Access each container individually:

# Execute command in web server container
kubectl exec -it multi-container-basic -c web-server -- /bin/bash

# Inside the container, check nginx status
nginx -t
ps aux | grep nginx
exit

# Execute command in log processor container
kubectl exec -it multi-container-basic -c log-processor -- /bin/sh

# Inside the container, check shared volume
ls -la /var/log/nginx/
ls -la /var/log/app/
exit
Task 2: Configure Sidecar Containers for Application Functionality
Subtask 2.1: Create a Web Application with Monitoring Sidecar
Create a more complex example with a web application and a monitoring sidecar:

nano web-app-with-sidecar.yaml
Add the following content:

apiVersion: v1
kind: Pod
metadata:
  name: web-app-with-sidecar
  labels:
    app: web-monitoring-demo
spec:
  containers:
  - name: web-app
    image: httpd:2.4
    ports:
    - containerPort: 80
    volumeMounts:
    - name: app-logs
      mountPath: /usr/local/apache2/logs
    - name: shared-data
      mountPath: /usr/local/apache2/htdocs/data
  - name: monitoring-sidecar
    image: busybox:1.35
    command: ['sh', '-c']
    args:
    - |
      while true; do
        # Generate monitoring data
        echo "{\"timestamp\": \"$(date -Iseconds)\", \"status\": \"healthy\", \"requests\": $((RANDOM % 100))}" > /shared/metrics.json
        
        # Monitor log file size
        if [ -f /logs/access_log ]; then
          LOG_SIZE=$(wc -l < /logs/access_log)
          echo "{\"timestamp\": \"$(date -Iseconds)\", \"log_lines\": $LOG_SIZE}" > /shared/log_stats.json
        fi
        
        sleep 15
      done
    volumeMounts:
    - name: app-logs
      mountPath: /logs
    - name: shared-data
      mountPath: /shared
  - name: log-shipper
    image: busybox:1.35
    command: ['sh', '-c']
    args:
    - |
      while true; do
        if [ -f /logs/access_log ]; then
          echo "Shipping logs at $(date)"
          tail -n 10 /logs/access_log > /shipped/latest_access.log
        fi
        if [ -f /logs/error_log ]; then
          tail -n 5 /logs/error_log > /shipped/latest_errors.log
        fi
        sleep 20
      done
    volumeMounts:
    - name: app-logs
      mountPath: /logs
    - name: shipped-logs
      mountPath: /shipped
  volumes:
  - name: app-logs
    emptyDir: {}
  - name: shared-data
    emptyDir: {}
  - name: shipped-logs
    emptyDir: {}
Deploy the sidecar pod:

kubectl apply -f web-app-with-sidecar.yaml
Verify all containers are running:

kubectl get pod web-app-with-sidecar
kubectl describe pod web-app-with-sidecar
Subtask 2.2: Test Sidecar Functionality
Generate some traffic to create logs:

# Get pod IP
POD_IP=$(kubectl get pod web-app-with-sidecar -o jsonpath='{.status.podIP}')
echo "Pod IP: $POD_IP"

# Create a temporary pod to generate traffic
kubectl run traffic-generator --image=busybox:1.35 --rm -it --restart=Never -- sh

# Inside the traffic generator pod, run:
for i in {1..20}; do
  wget -q -O- http://$POD_IP/ && echo " - Request $i completed"
  sleep 2
done
exit
Check the monitoring data generated by sidecars:

# Check monitoring metrics
kubectl exec web-app-with-sidecar -c monitoring-sidecar -- cat /shared/metrics.json

# Check log statistics
kubectl exec web-app-with-sidecar -c monitoring-sidecar -- cat /shared/log_stats.json

# Check shipped logs
kubectl exec web-app-with-sidecar -c log-shipper -- cat /shipped/latest_access.log
Subtask 2.3: Create an Init Container Example
Create a pod with init containers that prepare the environment:

nano init-container-example.yaml
Add the following content:

apiVersion: v1
kind: Pod
metadata:
  name: app-with-init
  labels:
    app: init-container-demo
spec:
  initContainers:
  - name: init-database
    image: busybox:1.35
    command: ['sh', '-c']
    args:
    - |
      echo "Initializing database..."
      mkdir -p /data/db
      echo "CREATE TABLE users (id INT, name VARCHAR(50));" > /data/db/init.sql
      echo "INSERT INTO users VALUES (1, 'John Doe');" >> /data/db/init.sql
      echo "Database initialization completed"
    volumeMounts:
    - name: app-data
      mountPath: /data
  - name: init-config
    image: busybox:1.35
    command: ['sh', '-c']
    args:
    - |
      echo "Setting up configuration..."
      mkdir -p /config
      cat > /config/app.conf << EOF
      server_port=8080
      database_path=/data/db/init.sql
      log_level=info
      EOF
      echo "Configuration setup completed"
    volumeMounts:
    - name: app-config
      mountPath: /config
  containers:
  - name: main-app
    image: busybox:1.35
    command: ['sh', '-c']
    args:
    - |
      echo "Starting main application..."
      echo "Loading configuration from /config/app.conf"
      cat /config/app.conf
      echo "Loading database from /data/db/init.sql"
      cat /data/db/init.sql
      echo "Application started successfully"
      while true; do
        echo "Application running... $(date)"
        sleep 30
      done
    volumeMounts:
    - name: app-data
      mountPath: /data
    - name: app-config
      mountPath: /config
  volumes:
  - name: app-data
    emptyDir: {}
  - name: app-config
    emptyDir: {}
Deploy the init container example:

kubectl apply -f init-container-example.yaml
Watch the pod initialization process:

kubectl get pod app-with-init -w
Check the init container logs:

kubectl logs app-with-init -c init-database
kubectl logs app-with-init -c init-config
kubectl logs app-with-init -c main-app
Task 3: Test Multi-Container Pod Communication and Inter-Container Networking
Subtask 3.1: Create a Communication Test Pod
Create a pod to test inter-container communication:

nano communication-test.yaml
Add the following content:

apiVersion: v1
kind: Pod
metadata:
  name: communication-test
  labels:
    app: communication-demo
spec:
  containers:
  - name: server
    image: python:3.9-slim
    command: ['python', '-c']
    args:
    - |
      import http.server
      import socketserver
      import json
      from datetime import datetime
      
      class CustomHandler(http.server.SimpleHTTPRequestHandler):
          def do_GET(self):
              self.send_response(200)
              self.send_header('Content-type', 'application/json')
              self.end_headers()
              response = {
                  'message': 'Hello from server container',
                  'timestamp': datetime.now().isoformat(),
                  'path': self.path
              }
              self.wfile.write(json.dumps(response).encode())
      
      with socketserver.TCPServer(("", 8080), CustomHandler) as httpd:
          print("Server running on port 8080")
          httpd.serve_forever()
    ports:
    - containerPort: 8080
  - name: client
    image: python:3.9-slim
    command: ['python', '-c']
    args:
    - |
      import time
      import urllib.request
      import json
      
      while True:
          try:
              with urllib.request.urlopen('http://localhost:8080/api/status') as response:
                  data = json.loads(response.read().decode())
                  print(f"Client received: {data}")
          except Exception as e:
              print(f"Client error: {e}")
          time.sleep(10)
  - name: monitor
    image: busybox:1.35
    command: ['sh', '-c']
    args:
    - |
      while true; do
        echo "=== Network Status at $(date) ==="
        netstat -tuln 2>/dev/null || echo "netstat not available"
        echo "=== Process Status ==="
        ps aux
        echo "========================"
        sleep 30
      done
Deploy the communication test pod:

kubectl apply -f communication-test.yaml
Subtask 3.2: Monitor Inter-Container Communication
Check the communication between containers:

# Check server logs
kubectl logs communication-test -c server

# Check client logs
kubectl logs communication-test -c client

# Check monitor logs
kubectl logs communication-test -c monitor

# Follow all logs simultaneously (in separate terminals)
kubectl logs -f communication-test -c server &
kubectl logs -f communication-test -c client &
kubectl logs -f communication-test -c monitor &
Subtask 3.3: Test Network Connectivity
Test network connectivity from within the pod:

# Access the server container
kubectl exec -it communication-test -c server -- /bin/bash

# Inside the container, test local connectivity
curl http://localhost:8080/test
exit

# Access the client container
kubectl exec -it communication-test -c client -- /bin/bash

# Test connectivity to server
python3 -c "
import urllib.request
try:
    with urllib.request.urlopen('http://localhost:8080/health') as response:
        print('Response:', response.read().decode())
except Exception as e:
    print('Error:', e)
"
exit
Subtask 3.4: Create a Shared Volume Communication Example
Create a pod where containers communicate through shared volumes:

nano volume-communication.yaml
Add the following content:

apiVersion: v1
kind: Pod
metadata:
  name: volume-communication
  labels:
    app: volume-comm-demo
spec:
  containers:
  - name: producer
    image: busybox:1.35
    command: ['sh', '-c']
    args:
    - |
      counter=1
      while true; do
        message="Message $counter from producer at $(date)"
        echo "$message" >> /shared/messages.txt
        echo "Produced: $message"
        counter=$((counter + 1))
        sleep 5
      done
    volumeMounts:
    - name: shared-volume
      mountPath: /shared
  - name: consumer
    image: busybox:1.35
    command: ['sh', '-c']
    args:
    - |
      last_line=0
      while true; do
        if [ -f /shared/messages.txt ]; then
          current_lines=$(wc -l < /shared/messages.txt)
          if [ $current_lines -gt $last_line ]; then
            echo "=== New messages detected ==="
            tail -n +$((last_line + 1)) /shared/messages.txt | while read line; do
              echo "Consumed: $line"
            done
            last_line=$current_lines
          fi
        fi
        sleep 3
      done
    volumeMounts:
    - name: shared-volume
      mountPath: /shared
  - name: processor
    image: busybox:1.35
    command: ['sh', '-c']
    args:
    - |
      while true; do
        if [ -f /shared/messages.txt ]; then
          message_count=$(wc -l < /shared/messages.txt)
          echo "Processed $message_count total messages" > /shared/stats.txt
          echo "Last processed at $(date)" >> /shared/stats.txt
        fi
        sleep 10
      done
    volumeMounts:
    - name: shared-volume
      mountPath: /shared
  volumes:
  - name: shared-volume
    emptyDir: {}
Deploy the volume communication pod:

kubectl apply -f volume-communication.yaml
Monitor the communication:

# Watch producer logs
kubectl logs -f volume-communication -c producer &

# Watch consumer logs
kubectl logs -f volume-communication -c consumer &

# Check shared files
kubectl exec volume-communication -c processor -- cat /shared/messages.txt
kubectl exec volume-communication -c processor -- cat /shared/stats.txt
Subtask 3.5: Test Resource Sharing and Limits
Create a pod with resource limits to understand resource sharing:

nano resource-sharing.yaml
Add the following content:

apiVersion: v1
kind: Pod
metadata:
  name: resource-sharing
  labels:
    app: resource-demo
spec:
  containers:
  - name: cpu-intensive
    image: busybox:1.35
    command: ['sh', '-c']
    args:
    - |
      echo "Starting CPU intensive task..."
      while true; do
        for i in {1..1000}; do
          echo "CPU task iteration $i" > /dev/null
        done
        sleep 1
      done
    resources:
      requests:
        cpu: "100m"
        memory: "64Mi"
      limits:
        cpu: "200m"
        memory: "128Mi"
  - name: memory-monitor
    image: busybox:1.35
    command: ['sh', '-c']
    args:
    - |
      while true; do
        echo "=== Resource Usage at $(date) ==="
        free -h
        echo "=== Process List ==="
        ps aux
        echo "========================"
        sleep 15
      done
    resources:
      requests:
        cpu: "50m"
        memory: "32Mi"
      limits:
        cpu: "100m"
        memory: "64Mi"
Deploy the resource sharing pod:

kubectl apply -f resource-sharing.yaml
Monitor resource usage:

kubectl top pod resource-sharing --containers
kubectl logs resource-sharing -c memory-monitor
Troubleshooting Common Issues
Issue 1: Container Startup Problems
If containers fail to start:

# Check pod events
kubectl describe pod <pod-name>

# Check specific container logs
kubectl logs <pod-name> -c <container-name>

# Check resource constraints
kubectl top pod <pod-name> --containers
Issue 2: Inter-Container Communication Issues
If containers can't communicate:

# Verify containers are in the same pod
kubectl get pod <pod-name> -o wide

# Check network configuration
kubectl exec <pod-name> -c <container-name> -- netstat -tuln

# Test localhost connectivity
kubectl exec <pod-name> -c <container-name> -- curl localhost:<port>
Issue 3: Volume Mount Problems
If shared volumes aren't working:

# Check volume mounts
kubectl describe pod <pod-name>

# Verify volume permissions
kubectl exec <pod-name> -c <container-name> -- ls -la /mount/path

# Check volume content
kubectl exec <pod-name> -c <container-name> -- find /mount/path -type f
Cleanup
Remove all created resources:

kubectl delete pod multi-container-basic
kubectl delete pod web-app-with-sidecar
kubectl delete pod app-with-init
kubectl delete pod communication-test
kubectl delete pod volume-communication
kubectl delete pod resource-sharing

# Verify cleanup
kubectl get pods
Conclusion
In this lab, you have successfully:

Created and managed multi-container pods using various architectural patterns including sidecar, init containers, and shared volume communication
Configured sidecar containers to enhance application functionality with monitoring, log processing, and data shipping capabilities
Tested inter-container communication through localhost networking and shared volume mechanisms
Implemented init containers for application initialization and environment preparation
Monitored resource sharing and understood how containers within a pod share network and storage resources
Why This Matters: Multi-container pods are essential for building robust, scalable applications in Kubernetes. The patterns you've learned - sidecar containers for auxiliary services, init containers for setup tasks, and shared volume communication - are fundamental building blocks for enterprise applications. These skills are crucial for the Red Hat Certified OpenShift Application Developer exam and real-world container orchestration scenarios.

Key Takeaways:

Containers in the same pod share network namespace (localhost communication)
Shared volumes enable data exchange between containers
Init containers ensure proper application initialization order
Sidecar patterns separate concerns while maintaining tight coupling
Resource limits apply to individual containers, not the entire pod
These multi-container patterns will help you design more maintainable, scalable, and resilient applications in your Kubernetes and OpenShift environments.
