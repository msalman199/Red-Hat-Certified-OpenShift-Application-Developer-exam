Lab 9: Deploying Applications with DeploymentConfigs
Objectives
By the end of this lab, you will be able to:

Understand the purpose and structure of DeploymentConfigs in OpenShift
Create and configure DeploymentConfigs for application deployment
Implement rolling deployments to update applications with zero downtime
Configure DeploymentConfigs for horizontal scaling
Monitor and manage application deployments effectively
Troubleshoot common deployment issues
Prerequisites
Before starting this lab, you should have:

Basic understanding of containerization concepts (Docker)
Familiarity with Kubernetes/OpenShift fundamentals
Knowledge of YAML syntax and structure
Experience with command-line interface operations
Understanding of web application deployment concepts
Required Tools
OpenShift CLI (oc) - pre-installed on your lab machine
Access to an OpenShift cluster
Text editor (nano, vim, or VS Code)
Web browser for accessing OpenShift web console
Lab Environment Setup
Good News! Al Nafi provides you with ready-to-use Linux-based cloud machines with all necessary tools pre-installed. Simply click Start Lab to begin - no need to build your own VM or install software.

Your lab environment includes:

OpenShift cluster access
Pre-configured CLI tools
Sample application code
All required permissions and access rights
Task 1: Create a DeploymentConfig for a Sample Application
Subtask 1.1: Login to OpenShift and Create Project
First, let's establish our working environment by logging into OpenShift and creating a dedicated project.

Login to OpenShift cluster:
oc login --server=https://your-openshift-cluster:6443
When prompted, enter your credentials provided in the lab environment.

Create a new project for this lab:
oc new-project deploymentconfig-lab
Verify project creation:
oc project
You should see output confirming you're working in the deploymentconfig-lab project.

Subtask 1.2: Create Your First DeploymentConfig
Now we'll create a DeploymentConfig for a simple web application using the nginx image.

Create a DeploymentConfig YAML file:
cat > nginx-deploymentconfig.yaml << 'EOF'
apiVersion: apps.openshift.io/v1
kind: DeploymentConfig
metadata:
  name: nginx-app
  labels:
    app: nginx-app
spec:
  replicas: 2
  selector:
    app: nginx-app
  template:
    metadata:
      labels:
        app: nginx-app
    spec:
      containers:
      - name: nginx
        image: nginx:1.20
        ports:
        - containerPort: 80
          protocol: TCP
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
  triggers:
  - type: ConfigChange
  - type: ImageChange
    imageChangeParams:
      automatic: true
      containerNames:
      - nginx
      from:
        kind: ImageStreamTag
        name: nginx:1.20
  strategy:
    type: Rolling
    rollingParams:
      updatePeriodSeconds: 1
      intervalSeconds: 1
      timeoutSeconds: 600
      maxUnavailable: 25%
      maxSurge: 25%
EOF
Apply the DeploymentConfig:
oc apply -f nginx-deploymentconfig.yaml
Verify the DeploymentConfig was created:
oc get dc
Check the deployment status:
oc status
Subtask 1.3: Create Supporting Resources
To make our application accessible, we need to create a Service and Route.

Create a Service:
cat > nginx-service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
  labels:
    app: nginx-app
spec:
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
  selector:
    app: nginx-app
  type: ClusterIP
EOF
Apply the Service:
oc apply -f nginx-service.yaml
Create a Route to expose the service:
oc expose service nginx-service
Get the route URL:
oc get route nginx-service
Test the application:
curl $(oc get route nginx-service -o jsonpath='{.spec.host}')
You should see the default nginx welcome page HTML.

Task 2: Roll Out Application Updates with Rolling Deployments
Subtask 2.1: Prepare for Rolling Update
Rolling deployments allow you to update your application with zero downtime by gradually replacing old instances with new ones.

Check current deployment version:
oc get dc nginx-app -o wide
Monitor current pods:
oc get pods -l app=nginx-app
Note the current pod names and their creation timestamps.

Subtask 2.2: Perform Rolling Update
Now we'll update our nginx application to a newer version using a rolling deployment strategy.

Update the DeploymentConfig to use nginx version 1.21:
oc patch dc nginx-app -p '{"spec":{"template":{"spec":{"containers":[{"name":"nginx","image":"nginx:1.21"}]}}}}'
Watch the rolling deployment in action:
oc rollout status dc/nginx-app
Monitor pods during the update:
watch oc get pods -l app=nginx-app
Press Ctrl+C to stop watching once the update is complete.

Verify the update:
oc describe dc nginx-app | grep Image
You should see the image has been updated to nginx:1.21.

Subtask 2.3: Create a Custom Application for More Visible Updates
Let's create a more interactive example where we can see the changes more clearly.

Create a simple web application with version information:
cat > webapp-v1.yaml << 'EOF'
apiVersion: apps.openshift.io/v1
kind: DeploymentConfig
metadata:
  name: webapp
  labels:
    app: webapp
spec:
  replicas: 3
  selector:
    app: webapp
  template:
    metadata:
      labels:
        app: webapp
        version: v1
    spec:
      containers:
      - name: webapp
        image: httpd:2.4
        ports:
        - containerPort: 80
        env:
        - name: APP_VERSION
          value: "v1.0"
        volumeMounts:
        - name: html-content
          mountPath: /usr/local/apache2/htdocs
      volumes:
      - name: html-content
        configMap:
          name: webapp-content
  triggers:
  - type: ConfigChange
  strategy:
    type: Rolling
    rollingParams:
      updatePeriodSeconds: 2
      intervalSeconds: 1
      timeoutSeconds: 600
      maxUnavailable: 1
      maxSurge: 1
EOF
Create content for version 1:
cat > webapp-content-v1.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: webapp-content
data:
  index.html: |
    <!DOCTYPE html>
    <html>
    <head>
        <title>Web Application</title>
        <style>
            body { font-family: Arial, sans-serif; text-align: center; margin-top: 50px; }
            .version { color: blue; font-size: 24px; }
            .container { background-color: #f0f0f0; padding: 20px; border-radius: 10px; }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>Welcome to Our Web Application</h1>
            <p class="version">Version: 1.0</p>
            <p>This is the initial version of our application.</p>
            <p>Hostname: $(hostname)</p>
        </div>
    </body>
    </html>
EOF
Apply the resources:
oc apply -f webapp-content-v1.yaml
oc apply -f webapp-v1.yaml
Create service and route:
oc expose dc webapp --port=80
oc expose service webapp
Test the application:
curl $(oc get route webapp -o jsonpath='{.spec.host}')
Subtask 2.4: Perform Rolling Update with Visible Changes
Now let's update to version 2 and observe the rolling deployment.

Create version 2 content:
cat > webapp-content-v2.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: webapp-content
data:
  index.html: |
    <!DOCTYPE html>
    <html>
    <head>
        <title>Web Application v2</title>
        <style>
            body { font-family: Arial, sans-serif; text-align: center; margin-top: 50px; }
            .version { color: red; font-size: 24px; }
            .container { background-color: #e0ffe0; padding: 20px; border-radius: 10px; }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>Welcome to Our Updated Web Application</h1>
            <p class="version">Version: 2.0</p>
            <p>This is the updated version with new features!</p>
            <p>Hostname: $(hostname)</p>
        </div>
    </body>
    </html>
EOF
Apply the updated content:
oc apply -f webapp-content-v2.yaml
Trigger a new deployment:
oc rollout latest dc/webapp
Monitor the rolling update:
oc rollout status dc/webapp -w
Test during the update (in another terminal):
# Run this command multiple times during the update
for i in {1..10}; do
  echo "Request $i:"
  curl -s $(oc get route webapp -o jsonpath='{.spec.host}') | grep "Version:"
  sleep 2
done
You should see both versions responding during the rolling update.

Task 3: Configure DeploymentConfig for Scalability
Subtask 3.1: Manual Scaling
Learn how to manually scale your application up and down based on demand.

Check current replica count:
oc get dc webapp -o wide
Scale up the application to 5 replicas:
oc scale dc webapp --replicas=5
Watch the scaling process:
oc get pods -l app=webapp -w
Press Ctrl+C to stop watching once all pods are running.

Verify the scaling:
oc get dc webapp
oc get pods -l app=webapp
Scale down to 2 replicas:
oc scale dc webapp --replicas=2
Monitor the scale-down:
oc get pods -l app=webapp -w
Subtask 3.2: Configure Resource Limits and Requests
Proper resource configuration is crucial for scalability and cluster efficiency.

Update the DeploymentConfig with resource specifications:
oc patch dc webapp -p '{
  "spec": {
    "template": {
      "spec": {
        "containers": [{
          "name": "webapp",
          "resources": {
            "requests": {
              "memory": "128Mi",
              "cpu": "100m"
            },
            "limits": {
              "memory": "256Mi",
              "cpu": "200m"
            }
          }
        }]
      }
    }
  }
}'
Verify the resource configuration:
oc describe dc webapp | grep -A 10 "Limits\|Requests"
Subtask 3.3: Configure Horizontal Pod Autoscaler
Set up automatic scaling based on CPU utilization.

Create a Horizontal Pod Autoscaler:
oc autoscale dc webapp --min=2 --max=10 --cpu-percent=70
Verify the HPA creation:
oc get hpa
Check HPA status:
oc describe hpa webapp
Monitor HPA (this may take a few minutes to show metrics):
oc get hpa webapp -w
Subtask 3.4: Load Testing and Observing Auto-scaling
Let's generate some load to test the auto-scaling functionality.

Create a load testing pod:
cat > load-test-pod.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: load-test
spec:
  containers:
  - name: load-test
    image: busybox
    command: ["/bin/sh"]
    args: ["-c", "while true; do wget -q -O- http://webapp/; done"]
  restartPolicy: Never
EOF
Apply the load test:
oc apply -f load-test-pod.yaml
Monitor the HPA during load:
watch oc get hpa webapp
Check if new pods are being created:
watch oc get pods -l app=webapp
Clean up the load test:
oc delete pod load-test
Advanced Configuration and Best Practices
Subtask 3.5: Configure Deployment Hooks
Deployment hooks allow you to run custom logic during deployments.

Add pre and post deployment hooks:
cat > webapp-with-hooks.yaml << 'EOF'
apiVersion: apps.openshift.io/v1
kind: DeploymentConfig
metadata:
  name: webapp-hooks
spec:
  replicas: 2
  selector:
    app: webapp-hooks
  template:
    metadata:
      labels:
        app: webapp-hooks
    spec:
      containers:
      - name: webapp
        image: httpd:2.4
        ports:
        - containerPort: 80
  triggers:
  - type: ConfigChange
  strategy:
    type: Rolling
    rollingParams:
      pre:
        failurePolicy: Abort
        execNewPod:
          command:
          - /bin/sh
          - -c
          - echo "Pre-deployment hook executed at $(date)"
          containerName: webapp
      post:
        failurePolicy: Ignore
        execNewPod:
          command:
          - /bin/sh
          - -c
          - echo "Post-deployment hook executed at $(date)"
          containerName: webapp
EOF
Apply the configuration with hooks:
oc apply -f webapp-with-hooks.yaml
Trigger a deployment to see hooks in action:
oc rollout latest dc/webapp-hooks
Check the deployment logs to see hook execution:
oc logs -f dc/webapp-hooks
Monitoring and Troubleshooting
Common Commands for Monitoring Deployments
Check deployment history:
oc rollout history dc/webapp
Get detailed deployment information:
oc describe dc webapp
View deployment logs:
oc logs -f dc/webapp
Check events related to deployments:
oc get events --sort-by=.metadata.creationTimestamp
Rollback Procedures
Rollback to previous version:
oc rollout undo dc/webapp
Rollback to specific revision:
oc rollout undo dc/webapp --to-revision=1
Check rollback status:
oc rollout status dc/webapp
Troubleshooting Common Issues
Issue 1: Deployment Stuck in Pending State
Symptoms: Pods remain in Pending state Solution:

# Check resource availability
oc describe nodes
# Check pod events
oc describe pod <pod-name>
# Verify resource requests don't exceed node capacity
Issue 2: Rolling Update Fails
Symptoms: New pods fail to start during rolling update Solution:

# Check deployment events
oc describe dc <deployment-name>
# Review pod logs
oc logs <failing-pod-name>
# Verify image availability
oc describe pod <pod-name> | grep -i image
Issue 3: Auto-scaling Not Working
Symptoms: HPA doesn't scale pods despite high CPU Solution:

# Ensure metrics server is running
oc get pods -n openshift-monitoring
# Check HPA status
oc describe hpa <hpa-name>
# Verify resource requests are set
oc describe dc <deployment-name> | grep -A 5 Requests
Cleanup
Before finishing the lab, let's clean up the resources we created:

# Delete all resources in the project
oc delete all --all

# Delete the project (optional)
oc delete project deploymentconfig-lab
Conclusion
Congratulations! You have successfully completed Lab 9: Deploying Applications with DeploymentConfigs.

What You Accomplished
In this lab, you have:

Created DeploymentConfigs - You learned how to define and deploy applications using OpenShift's DeploymentConfig resource, understanding its structure and key components.

Implemented Rolling Deployments - You successfully performed zero-downtime updates using rolling deployment strategies, ensuring continuous application availability during updates.

Configured Scalability - You explored both manual and automatic scaling options, including Horizontal Pod Autoscaler configuration for dynamic scaling based on resource utilization.

Applied Best Practices - You implemented resource limits, deployment hooks, and monitoring strategies that are essential for production deployments.

Why This Matters
DeploymentConfigs are fundamental to modern application deployment and management in OpenShift environments. The skills you've developed in this lab are directly applicable to:

Production Application Management - Rolling deployments ensure your applications can be updated without service interruption
Resource Optimization - Proper scaling and resource configuration help optimize cluster utilization and costs
Reliability Engineering - Understanding deployment strategies and troubleshooting helps maintain high availability
DevOps Practices - These skills are essential for implementing CI/CD pipelines and automated deployment processes
Next Steps
To further enhance your OpenShift deployment skills, consider exploring:

Advanced deployment strategies (Blue-Green, Canary)
Integration with CI/CD pipelines
Monitoring and observability tools
Security best practices for deployments
Multi-environment deployment strategies
This knowledge directly supports your preparation for the Red Hat Certified OpenShift Application Developer exam and provides practical skills for real-world OpenShift application deployment scenarios.
