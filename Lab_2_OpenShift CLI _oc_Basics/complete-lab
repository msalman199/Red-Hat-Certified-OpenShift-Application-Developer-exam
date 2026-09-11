Lab 2: OpenShift CLI (oc) Basics
Objectives
By the end of this lab, you will be able to:

Install and configure the OpenShift CLI (oc) tool
Authenticate and connect to an OpenShift cluster
Create and manage OpenShift projects using the CLI
Deploy applications and interact with pods using oc commands
Create and manage services to expose applications
Configure routes to provide external access to applications
Use essential oc commands for troubleshooting and monitoring
Prerequisites
Before starting this lab, you should have:

Basic understanding of containerization concepts
Familiarity with Linux command line operations
Basic knowledge of Kubernetes concepts (pods, services, deployments)
Understanding of YAML file structure
Access to a web browser for accessing the OpenShift web console
Ready-to-Use Cloud Machines
Al Nafi provides pre-configured Linux-based cloud machines for this lab. Simply click Start Lab to access your environment. No need to build your own VM or install additional software - everything is ready to use.

Your cloud machine includes:

CentOS/RHEL-based Linux distribution
Internet connectivity for downloading OpenShift CLI
Text editors (vi, nano)
Web browser access for OpenShift console
Lab Environment Setup
Task 1: Install OpenShift CLI Tools
Subtask 1.1: Download the OpenShift CLI
Open a terminal on your cloud machine

Create a directory for OpenShift tools:

mkdir -p ~/openshift-tools
cd ~/openshift-tools
Download the latest OpenShift CLI for Linux:
wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/openshift-client-linux.tar.gz
Extract the downloaded archive:
tar -xzf openshift-client-linux.tar.gz
Verify the extraction:
ls -la
You should see the oc and kubectl binaries.

Subtask 1.2: Install the CLI Tools
Move the binaries to a directory in your PATH:
sudo mv oc kubectl /usr/local/bin/
Make the binaries executable:
sudo chmod +x /usr/local/bin/oc /usr/local/bin/kubectl
Verify the installation:
oc version --client
Expected output should show the OpenShift client version information.

Subtask 1.3: Set Up OpenShift Cluster Access
For this lab, we'll use the Red Hat Developer Sandbox or a local OpenShift cluster.

Access the OpenShift Developer Sandbox:

Go to https://developers.redhat.com/developer-sandbox
Sign up for a free account if you don't have one
Launch your sandbox environment
Get your login command from the OpenShift web console:

Click on your username in the top-right corner
Select Copy login command
Click Display Token
Copy the login command
Login to your OpenShift cluster:

oc login --token=YOUR_TOKEN --server=YOUR_SERVER_URL
Replace YOUR_TOKEN and YOUR_SERVER_URL with the values from your sandbox.

Verify your connection:
oc whoami
oc cluster-info
Task 2: Create a New Project
Subtask 2.1: Understanding OpenShift Projects
OpenShift projects are similar to Kubernetes namespaces but with additional features like access control and resource quotas.

List existing projects:
oc get projects
View current project context:
oc project
Subtask 2.2: Create Your First Project
Create a new project called my-first-app:
oc new-project my-first-app --display-name="My First Application" --description="Learning OpenShift CLI basics"
Verify project creation:
oc get projects | grep my-first-app
Check that you're working in the correct project:
oc project
View project details:
oc describe project my-first-app
Subtask 2.3: Project Management Commands
Switch between projects (if you have multiple):
oc project my-first-app
View project status:
oc status
Get project resource quotas and limits:
oc describe quota
oc describe limits
Task 3: Deploy an Application and Interact with Pods
Subtask 3.1: Deploy a Sample Application
Deploy a simple web application using the oc new-app command:
oc new-app --name=hello-world --docker-image=quay.io/redhattraining/hello-world-nginx:v1.0
Check the deployment status:
oc status
Watch the deployment progress:
oc get pods -w
Press Ctrl+C to stop watching when the pod is running.

Subtask 3.2: Interact with Pods
List all pods in your project:
oc get pods
Get detailed information about a specific pod:
oc describe pod <pod-name>
Replace with the actual pod name from the previous command.

View pod logs:
oc logs <pod-name>
Follow logs in real-time:
oc logs -f <pod-name>
Press Ctrl+C to stop following logs.

Execute commands inside a running pod:
oc exec <pod-name> -- ls -la /usr/share/nginx/html
Open an interactive shell in the pod:
oc rsh <pod-name>
Inside the pod, try these commands:

whoami
ps aux
cat /usr/share/nginx/html/index.html
exit
Subtask 3.3: Pod Management Operations
Get pods with additional information:
oc get pods -o wide
View pods in YAML format:
oc get pod <pod-name> -o yaml
View pods in JSON format:
oc get pod <pod-name> -o json
Label a pod:
oc label pod <pod-name> environment=development
View pods with labels:
oc get pods --show-labels
Task 4: Working with Services
Subtask 4.1: Understanding OpenShift Services
Services provide stable network endpoints for accessing pods.

List existing services:
oc get services
oc get svc
Check if a service was automatically created for your application:
oc get svc hello-world
Subtask 4.2: Create a Service Manually
If no service exists, create one manually:

Create a service for your application:
oc expose deployment hello-world --port=8080 --target-port=8080
Verify service creation:
oc get svc hello-world
Describe the service:
oc describe svc hello-world
Subtask 4.3: Service Configuration and Testing
View service endpoints:
oc get endpoints hello-world
Test service connectivity from within the cluster:
oc run test-pod --image=curlimages/curl --rm -it --restart=Never -- curl hello-world:8080
View service in YAML format:
oc get svc hello-world -o yaml
Edit service configuration:
oc edit svc hello-world
This opens the service configuration in your default editor. You can modify settings like ports or selectors.

Task 5: Working with Routes
Subtask 5.1: Understanding OpenShift Routes
Routes provide external access to services by creating a publicly accessible URL.

List existing routes:
oc get routes
Check if a route exists for your service:
oc get route hello-world
Subtask 5.2: Create a Route
Expose your service with a route:
oc expose service hello-world
Verify route creation:
oc get routes
Get the route URL:
oc get route hello-world -o jsonpath='{.spec.host}'
Test the route:
curl http://$(oc get route hello-world -o jsonpath='{.spec.host}')
Subtask 5.3: Route Management
Describe the route:
oc describe route hello-world
View route in YAML format:
oc get route hello-world -o yaml
Create a secure HTTPS route:
oc create route edge hello-world-secure --service=hello-world
List all routes:
oc get routes
Test the secure route:
curl -k https://$(oc get route hello-world-secure -o jsonpath='{.spec.host}')
Task 6: Advanced CLI Operations
Subtask 6.1: Resource Management
View all resources in your project:
oc get all
Get resource usage:
oc adm top pods
oc adm top nodes
Scale your application:
oc scale deployment hello-world --replicas=3
Watch the scaling process:
oc get pods -w
Subtask 6.2: Troubleshooting Commands
View events in your project:
oc get events --sort-by='.lastTimestamp'
Debug a pod:
oc debug <pod-name>
Port forward to access a pod directly:
oc port-forward <pod-name> 8080:8080
Open another terminal and test:

curl localhost:8080
Copy files to/from a pod:
echo "Hello from local machine" > test.txt
oc cp test.txt <pod-name>:/tmp/test.txt
oc cp <pod-name>:/usr/share/nginx/html/index.html ./downloaded-index.html
Subtask 6.3: Configuration and Secrets
Create a ConfigMap:
oc create configmap my-config --from-literal=database_url=postgresql://localhost:5432/mydb
View the ConfigMap:
oc get configmap my-config -o yaml
Create a Secret:
oc create secret generic my-secret --from-literal=username=admin --from-literal=password=secret123
View secrets (note that values are base64 encoded):
oc get secret my-secret -o yaml
Use ConfigMap in a deployment:
oc set env deployment/hello-world --from=configmap/my-config
Task 7: Cleanup and Resource Management
Subtask 7.1: Clean Up Resources
Delete the route:
oc delete route hello-world hello-world-secure
Delete the service:
oc delete service hello-world
Delete the deployment:
oc delete deployment hello-world
Delete ConfigMap and Secret:
oc delete configmap my-config
oc delete secret my-secret
Verify cleanup:
oc get all
Subtask 7.2: Project Management
Create another project for testing:
oc new-project test-project
Switch back to your original project:
oc project my-first-app
Delete the test project:
oc delete project test-project
List remaining projects:
oc get projects
Common Troubleshooting Tips
Authentication Issues
If login fails, verify your token hasn't expired
Check that you're using the correct server URL
Ensure your network can reach the OpenShift cluster
Pod Issues
Use oc describe pod to see detailed error messages
Check oc get events for cluster-level issues
Verify image names and availability with oc get pods -o wide
Service Connectivity
Ensure pod labels match service selectors
Check that target ports match container ports
Use oc get endpoints to verify service discovery
Route Problems
Verify the service exists before creating a route
Check DNS resolution for route hostnames
For HTTPS routes, verify certificate configuration
Key Commands Reference
Basic Commands
oc login                    # Login to cluster
oc logout                   # Logout from cluster
oc whoami                   # Show current user
oc project                  # Show current project
oc status                   # Show project status
Project Management
oc new-project <name>       # Create new project
oc get projects             # List projects
oc project <name>           # Switch to project
oc delete project <name>    # Delete project
Application Deployment
oc new-app <image>          # Deploy application
oc get all                  # Show all resources
oc delete all --all         # Delete all resources
Pod Operations
oc get pods                 # List pods
oc describe pod <name>      # Describe pod
oc logs <pod-name>          # View logs
oc exec <pod> -- <command>  # Execute command
oc rsh <pod-name>           # Remote shell
Service and Route Management
oc expose deployment <name> # Create service
oc expose service <name>    # Create route
oc get svc                  # List services
oc get routes               # List routes
Conclusion
Congratulations! You have successfully completed Lab 2: OpenShift CLI (oc) Basics. In this lab, you have accomplished the following:

Key Achievements:

Installed and configured the OpenShift CLI (oc) tool on a Linux system
Successfully authenticated and connected to an OpenShift cluster
Created and managed OpenShift projects using command-line operations
Deployed applications and learned to interact with pods using various oc commands
Created services to provide stable network endpoints for your applications
Configured routes to enable external access to your services
Gained hands-on experience with troubleshooting and monitoring commands
Why This Matters: The OpenShift CLI is an essential tool for developers and system administrators working with OpenShift clusters. The skills you've learned in this lab form the foundation for:

DevOps Automation: CLI commands can be scripted for automated deployments and management
Troubleshooting: Understanding how to diagnose and resolve issues in containerized applications
Scalability: Managing applications across different environments and scaling requirements
Professional Development: These skills are directly applicable to the Red Hat Certified OpenShift Application Developer exam and real-world OpenShift projects
Next Steps:

Practice these commands regularly to build muscle memory
Explore more advanced oc commands and options
Learn about OpenShift templates and operators
Study application lifecycle management in OpenShift environments
You now have the fundamental CLI skills needed to work effectively with OpenShift clusters and are well-prepared to tackle more advanced OpenShift development topics.
