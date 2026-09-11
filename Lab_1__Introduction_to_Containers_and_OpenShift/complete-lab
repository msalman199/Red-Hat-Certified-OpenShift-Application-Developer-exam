Lab 1: Introduction to Containers and OpenShift
Lab Objectives
By the end of this lab, you will be able to:

Understand the fundamental differences between containers and virtual machines
Identify and explain core OpenShift components including Projects, Pods, Deployments, and Routes
Set up and configure a basic OpenShift cluster using open-source tools
Navigate the OpenShift web console and command-line interface
Deploy a simple application to demonstrate container orchestration concepts
Prerequisites
Before starting this lab, you should have:

Basic understanding of Linux command line operations
Familiarity with basic networking concepts
Understanding of virtualization concepts
No prior container or OpenShift experience required
Lab Environment Setup
Ready-to-Use Cloud Machines: Al Nafi provides pre-configured Linux-based cloud machines for this lab. Simply click Start Lab to access your environment. No need to build or configure your own virtual machine.

Your lab environment includes:

CentOS/RHEL 8 or 9 based system
Pre-installed Docker and Podman
OpenShift CLI (oc) tools
CodeReady Containers (CRC) for local OpenShift development
8GB RAM and 4 CPU cores minimum
Task 1: Understanding Containers vs Virtual Machines
Subtask 1.1: Explore Virtual Machine Architecture
First, let's understand what we're comparing containers against.

Open a terminal in your lab environment

Check system resources to understand the current VM:

# Check CPU information
lscpu

# Check memory usage
free -h

# Check disk usage
df -h

# Check running processes
ps aux | head -20
Document your observations:
Note the CPU cores, memory, and disk space allocated
Observe the number of running processes
This represents the overhead of a full virtual machine
Subtask 1.2: Explore Container Architecture
Now let's examine how containers work differently.

Check if Docker/Podman is installed:
# Check Docker version
docker --version

# Check Podman version (Red Hat's container engine)
podman --version

# If not installed, install Podman
sudo dnf install -y podman
Run your first container:
# Pull and run a lightweight container
podman run --rm -it alpine:latest /bin/sh
Inside the container, explore the environment:
# Check the operating system
cat /etc/os-release

# Check running processes (notice how few there are)
ps aux

# Check memory usage
free -h

# Exit the container
exit
Compare resource usage:
# Check host processes before running container
ps aux | wc -l

# Run container in background
podman run -d --name test-container alpine:latest sleep 300

# Check processes again
ps aux | wc -l

# Check container-specific processes
podman exec test-container ps aux

# Clean up
podman stop test-container
podman rm test-container
Subtask 1.3: Key Differences Analysis
Create a comparison table in your notes:

Aspect	Virtual Machines	Containers
OS Kernel	Each VM has its own kernel	Share host kernel
Resource Overhead	High (full OS per VM)	Low (shared kernel)
Startup Time	Minutes	Seconds
Isolation	Complete hardware isolation	Process-level isolation
Portability	Limited by hypervisor	High portability
Use Case	Different OS requirements	Microservices, scaling
Task 2: Understanding Core OpenShift Components
Subtask 2.1: OpenShift Architecture Overview
OpenShift is built on Kubernetes and adds enterprise features. Let's understand the core components:

Install OpenShift CLI tools:
# Download and install oc CLI
curl -LO https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/openshift-client-linux.tar.gz

# Extract the tools
tar -xzf openshift-client-linux.tar.gz

# Move to system path
sudo mv oc kubectl /usr/local/bin/

# Verify installation
oc version --client
Subtask 2.2: Understanding Projects
Projects in OpenShift are like namespaces in Kubernetes but with additional security and resource management features.

Learn about Projects:

Projects provide isolation between different teams or applications
Each project has its own set of resources, policies, and constraints
Projects help organize and secure your applications
Key Project characteristics:

Unique namespace for resources
Role-based access control (RBAC)
Resource quotas and limits
Network policies
Subtask 2.3: Understanding Pods
Pods are the smallest deployable units in OpenShift.

Pod characteristics:

Contains one or more containers
Containers in a pod share storage and network
Pods are ephemeral (temporary)
Each pod gets its own IP address
Create a sample pod definition:

# Create a directory for our lab files
mkdir ~/openshift-lab
cd ~/openshift-lab

# Create a simple pod YAML file
cat > simple-pod.yaml << EOF
apiVersion: v1
kind: Pod
metadata:
  name: hello-pod
  labels:
    app: hello-world
spec:
  containers:
  - name: hello-container
    image: registry.access.redhat.com/ubi8/ubi:latest
    command: ["/bin/bash"]
    args: ["-c", "while true; do echo 'Hello from Pod'; sleep 30; done"]
EOF
Subtask 2.4: Understanding Deployments
Deployments manage the lifecycle of your applications.

Deployment characteristics:

Manages replica sets and pods
Provides rolling updates and rollbacks
Ensures desired number of pod replicas
Self-healing capabilities
Create a sample deployment definition:

# Create a deployment YAML file
cat > simple-deployment.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-deployment
  labels:
    app: hello-world
spec:
  replicas: 3
  selector:
    matchLabels:
      app: hello-world
  template:
    metadata:
      labels:
        app: hello-world
    spec:
      containers:
      - name: hello-container
        image: registry.access.redhat.com/ubi8/httpd-24:latest
        ports:
        - containerPort: 8080
EOF
Subtask 2.5: Understanding Routes
Routes expose your applications to external traffic.

Route characteristics:

Provides external access to services
Supports HTTP, HTTPS, and TLS termination
Load balancing capabilities
Custom domain support
Create a sample route definition:

# Create a service first (routes connect to services)
cat > simple-service.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: hello-service
spec:
  selector:
    app: hello-world
  ports:
  - protocol: TCP
    port: 8080
    targetPort: 8080
  type: ClusterIP
EOF

# Create a route definition
cat > simple-route.yaml << EOF
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: hello-route
spec:
  to:
    kind: Service
    name: hello-service
  port:
    targetPort: 8080
EOF
Task 3: Setting Up a Basic OpenShift Cluster
Subtask 3.1: Install CodeReady Containers (CRC)
CodeReady Containers provides a minimal OpenShift cluster for development.

Download and install CRC:
# Create directory for CRC
mkdir ~/crc-install
cd ~/crc-install

# Download CRC (check for latest version)
curl -LO https://mirror.openshift.com/pub/openshift-v4/clients/crc/latest/crc-linux-amd64.tar.xz

# Extract CRC
tar -xf crc-linux-amd64.tar.xz

# Move to system path
sudo mv crc-linux-*/crc /usr/local/bin/

# Verify installation
crc version
Set up CRC:
# Setup CRC (this configures the environment)
crc setup

# Check system requirements
crc config view
Subtask 3.2: Start Your OpenShift Cluster
Start the cluster:
# Start CRC cluster (this may take 10-15 minutes)
crc start

# Note: You'll be prompted for a pull secret
# For this lab, you can get a free pull secret from:
# https://console.redhat.com/openshift/create/local
Access cluster information:
# Get cluster information
crc status

# Get console URL and credentials
crc console --credentials
Subtask 3.3: Connect to Your Cluster
Login via CLI:
# Get login command (use the token provided by crc console --credentials)
oc login -u developer -p developer https://api.crc.testing:6443

# Verify connection
oc whoami
oc cluster-info
Explore the cluster:
# List all projects
oc get projects

# Get cluster nodes
oc get nodes

# Check cluster operators
oc get clusteroperators
Subtask 3.4: Create Your First Project
Create a new project:
# Create project via CLI
oc new-project my-first-project --description="My first OpenShift project" --display-name="First Project"

# Verify project creation
oc project
oc get projects
Switch between projects:
# List available projects
oc projects

# Switch to default project
oc project default

# Switch back to your project
oc project my-first-project
Subtask 3.5: Deploy Your First Application
Deploy the sample resources we created earlier:
# Navigate to your lab files
cd ~/openshift-lab

# Deploy the deployment
oc apply -f simple-deployment.yaml

# Deploy the service
oc apply -f simple-service.yaml

# Deploy the route
oc apply -f simple-route.yaml
Verify your deployment:
# Check pods
oc get pods

# Check deployment
oc get deployments

# Check services
oc get services

# Check routes
oc get routes

# Get detailed information
oc describe deployment hello-deployment
Access your application:
# Get the route URL
oc get route hello-route -o jsonpath='{.spec.host}'

# Test the application (replace URL with your actual route)
curl http://$(oc get route hello-route -o jsonpath='{.spec.host}')
Subtask 3.6: Explore the Web Console
Access the web console:
# Get console URL
crc console
Navigate through the console:
Login with developer/developer credentials
Explore the Developer perspective
View your project and applications
Check the Topology view
Examine pod logs and metrics
Subtask 3.7: Scale Your Application
Scale using CLI:
# Scale deployment to 5 replicas
oc scale deployment hello-deployment --replicas=5

# Watch pods being created
oc get pods -w

# Press Ctrl+C to stop watching

# Verify scaling
oc get deployment hello-deployment
Scale using web console:
Navigate to your deployment in the web console
Use the scaling controls to change replica count
Observe the changes in real-time
Troubleshooting Common Issues
Issue 1: CRC Won't Start
Problem: CRC fails to start with resource errors

Solution:

# Check system resources
free -h
df -h

# Increase CRC resources if needed
crc config set memory 8192
crc config set cpus 4

# Delete and recreate if necessary
crc delete
crc start
Issue 2: Cannot Access Applications
Problem: Route URL returns connection refused

Solution:

# Check if pods are running
oc get pods

# Check service endpoints
oc get endpoints

# Check route configuration
oc describe route hello-route

# Test service directly
oc port-forward service/hello-service 8080:8080
Issue 3: Pull Secret Issues
Problem: Cannot pull images due to authentication

Solution:

Obtain a valid pull secret from Red Hat Console
Ensure the pull secret is properly configured during CRC setup
For lab purposes, use publicly available images
Lab Validation
Verify your lab completion by running these commands:

# Check cluster status
crc status

# Verify project exists
oc get project my-first-project

# Verify application is running
oc get pods -l app=hello-world

# Verify route is accessible
curl -I http://$(oc get route hello-route -o jsonpath='{.spec.host}')

# Check scaling worked
oc get deployment hello-deployment -o jsonpath='{.status.replicas}'
Expected outputs:

CRC status should show "Running"
Project should exist and be active
Pods should be in "Running" state
Route should return HTTP 200 status
Deployment should show 5 replicas
Conclusion
Congratulations! You have successfully completed Lab 1: Introduction to Containers and OpenShift.

What You Accomplished
Container Understanding: You learned the fundamental differences between containers and virtual machines, understanding how containers provide lightweight, portable application packaging.

OpenShift Components: You explored the core OpenShift components:

Projects: Learned how they provide isolation and organization
Pods: Understood the smallest deployable units
Deployments: Discovered how they manage application lifecycle
Routes: Explored how external access is provided
Hands-On Experience: You successfully:

Set up a local OpenShift cluster using CodeReady Containers
Created your first project
Deployed a multi-replica application
Exposed the application through routes
Scaled the application dynamically
Why This Matters
This foundational knowledge is crucial for modern application development and deployment. Containers and OpenShift provide:

Consistency: Applications run the same way across different environments
Scalability: Easy horizontal scaling based on demand
Efficiency: Better resource utilization compared to traditional VMs
DevOps Integration: Streamlined CI/CD pipelines and deployment processes
Next Steps
You're now ready to:

Explore more advanced OpenShift features
Learn about persistent storage and ConfigMaps
Dive into OpenShift networking and security
Practice with real-world application deployments
This lab provides the foundation for the Red Hat Certified OpenShift Application Developer exam and real-world container orchestration scenarios.

Clean Up (Optional)
If you want to clean up your environment:

# Delete your project
oc delete project my-first-project

# Stop CRC cluster
crc stop

# Delete CRC cluster (if you want to start fresh)
crc delete
Keep your environment running if you plan to continue with additional OpenShift labs!
