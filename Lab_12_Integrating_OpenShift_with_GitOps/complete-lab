Lab 12: Integrating OpenShift with GitOps
Objectives
By the end of this lab, you will be able to:

Install and configure ArgoCD in an OpenShift cluster
Connect ArgoCD to a Git repository for automated application deployment
Implement GitOps workflows for continuous deployment
Monitor and sync applications using ArgoCD's web interface
Understand the principles of GitOps and its benefits in container orchestration
Troubleshoot common GitOps deployment issues
Prerequisites
Before starting this lab, you should have:

Basic understanding of OpenShift concepts (pods, services, deployments)
Familiarity with Git version control system
Knowledge of YAML syntax and Kubernetes manifests
Experience with command-line interface operations
Understanding of container concepts and Docker basics
Access to a web browser for ArgoCD UI interaction
Note: Al Nafi provides pre-configured Linux-based cloud machines with OpenShift already installed. Simply click Start Lab to begin - no need to build your own virtual machine or install OpenShift manually.

Lab Environment Setup
Your cloud machine comes pre-configured with:

OpenShift cluster (single-node or multi-node)
oc command-line tool
Git client
Web browser access
All necessary networking configurations
Task 1: Install and Configure ArgoCD in OpenShift
Subtask 1.1: Create ArgoCD Namespace
First, we'll create a dedicated namespace for ArgoCD and install the operator.

Log in to your OpenShift cluster:
oc login -u admin -p admin https://api.crc.testing:6443
Create a new project for ArgoCD:
oc new-project argocd
Verify the project creation:
oc project argocd
oc get projects | grep argocd
Subtask 1.2: Install ArgoCD Operator
Create the ArgoCD Operator subscription:
cat << EOF | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: argocd-operator
  namespace: argocd
spec:
  channel: stable
  installPlanApproval: Automatic
  name: argocd-operator
  source: operatorhub
  sourceNamespace: openshift-marketplace
EOF
Wait for the operator to be installed:
oc get csv -n argocd
Wait until you see the ArgoCD operator with status "Succeeded".

Verify operator installation:
oc get pods -n argocd
Subtask 1.3: Create ArgoCD Instance
Create an ArgoCD instance:
cat << EOF | oc apply -f -
apiVersion: argoproj.io/v1alpha1
kind: ArgoCD
metadata:
  name: argocd-server
  namespace: argocd
spec:
  server:
    route:
      enabled: true
      tls:
        termination: edge
        insecureEdgeTerminationPolicy: Redirect
  dex:
    openShiftOAuth: true
  rbac:
    defaultPolicy: 'role:readonly'
    policy: |
      g, system:cluster-admins, role:admin
    scopes: '[groups]'
EOF
Wait for ArgoCD components to be ready:
oc get pods -n argocd -w
Press Ctrl+C when all pods are running.

Get the ArgoCD server route:
oc get route argocd-server-server -n argocd
Note the hostname for later use.

Subtask 1.4: Access ArgoCD Web Interface
Get the ArgoCD admin password:
oc get secret argocd-server-cluster -n argocd -o jsonpath='{.data.admin\.password}' | base64 -d
Access the ArgoCD web interface:
Open your web browser
Navigate to the route URL from the previous step
Login with username: admin and the password from step 1
Task 2: Connect ArgoCD to a Git Repository for Application Deployment
Subtask 2.1: Prepare Sample Application Repository
Create a sample application directory structure:
mkdir -p ~/gitops-demo/k8s-manifests
cd ~/gitops-demo
Initialize Git repository:
git init
git config user.name "Lab User"
git config user.email "user@example.com"
Create a sample application manifest:
cat << EOF > k8s-manifests/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-app
  labels:
    app: sample-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: sample-app
  template:
    metadata:
      labels:
        app: sample-app
    spec:
      containers:
      - name: sample-app
        image: nginx:1.21
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: sample-app-service
spec:
  selector:
    app: sample-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  type: ClusterIP
EOF
Create a route for the application:
cat << EOF > k8s-manifests/route.yaml
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: sample-app-route
spec:
  to:
    kind: Service
    name: sample-app-service
  port:
    targetPort: 80
EOF
Commit the files to Git:
git add .
git commit -m "Initial commit: Sample application manifests"
Subtask 2.2: Create Target Namespace
Create a namespace for the sample application:
oc new-project sample-app-ns
Grant ArgoCD permissions to manage the namespace:
oc policy add-role-to-user admin system:serviceaccount:argocd:argocd-server-application-controller -n sample-app-ns
Subtask 2.3: Configure Git Repository in ArgoCD
Access ArgoCD UI and navigate to Settings > Repositories

Add a new repository:

Click Connect Repo using HTTPS
Repository URL: file:///home/lab-user/gitops-demo (local path)
Leave username and password empty for local repository
Click Connect
Alternative CLI method:

cat << EOF | oc apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: private-repo
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: file:///home/lab-user/gitops-demo
EOF
Task 3: Sync and Monitor Applications with GitOps
Subtask 3.1: Create ArgoCD Application
Create an ArgoCD application via CLI:
cat << EOF | oc apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: sample-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: file:///home/lab-user/gitops-demo
    targetRevision: HEAD
    path: k8s-manifests
  destination:
    server: https://kubernetes.default.svc
    namespace: sample-app-ns
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
EOF
Verify application creation:
oc get applications -n argocd
Subtask 3.2: Monitor Application Sync
Check application status via CLI:
oc describe application sample-app -n argocd
Monitor in ArgoCD UI:

Navigate to Applications in the ArgoCD web interface
Click on the sample-app application
Observe the application topology and sync status
Verify deployed resources:

oc get all -n sample-app-ns
Get the application route:
oc get route sample-app-route -n sample-app-ns
Subtask 3.3: Test GitOps Workflow
Modify the application configuration:
cd ~/gitops-demo
sed -i 's/replicas: 2/replicas: 3/' k8s-manifests/deployment.yaml
Commit the changes:
git add k8s-manifests/deployment.yaml
git commit -m "Scale application to 3 replicas"
Trigger manual sync in ArgoCD UI:

Go to the sample-app in ArgoCD UI
Click Sync button
Select Synchronize
Verify the scaling:

oc get deployment sample-app -n sample-app-ns
oc get pods -n sample-app-ns
Subtask 3.4: Configure Automatic Sync
Update the application for automatic sync:
cat << EOF | oc apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: sample-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: file:///home/lab-user/gitops-demo
    targetRevision: HEAD
    path: k8s-manifests
  destination:
    server: https://kubernetes.default.svc
    namespace: sample-app-ns
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
    retry:
      limit: 5
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 3m
EOF
Test automatic sync:
cd ~/gitops-demo
sed -i 's/nginx:1.21/nginx:1.22/' k8s-manifests/deployment.yaml
git add k8s-manifests/deployment.yaml
git commit -m "Update nginx version to 1.22"
Monitor automatic sync in ArgoCD UI (refresh the page after a few moments)

Verify the image update:

oc describe deployment sample-app -n sample-app-ns | grep Image
Subtask 3.5: Application Health Monitoring
Check application health status:
oc get application sample-app -n argocd -o jsonpath='{.status.health.status}'
View detailed health information:
oc describe application sample-app -n argocd
Monitor resource status in ArgoCD UI:
Navigate to the application in ArgoCD UI
Review the Resource Tree view
Check individual resource health status
Troubleshooting Common Issues
Issue 1: ArgoCD Pods Not Starting
Symptoms: ArgoCD pods remain in pending or error state

Solution:

# Check pod events
oc describe pods -n argocd

# Check resource quotas
oc describe quota -n argocd

# Restart ArgoCD instance
oc delete argocd argocd-server -n argocd
# Then recreate using the manifest from Task 1
Issue 2: Application Sync Failures
Symptoms: Application shows "OutOfSync" status with errors

Solution:

# Check application events
oc describe application sample-app -n argocd

# Verify repository connectivity
oc logs deployment/argocd-server-repo-server -n argocd

# Manual sync with force option
oc patch application sample-app -n argocd --type merge -p '{"operation":{"sync":{"syncStrategy":{"force":true}}}}'
Issue 3: Permission Denied Errors
Symptoms: ArgoCD cannot deploy to target namespace

Solution:

# Grant necessary permissions
oc policy add-role-to-user admin system:serviceaccount:argocd:argocd-server-application-controller -n sample-app-ns

# Verify service account permissions
oc auth can-i create deployments --as=system:serviceaccount:argocd:argocd-server-application-controller -n sample-app-ns
Verification and Testing
Verify Complete GitOps Workflow
Test end-to-end workflow:
# Make a change to the application
cd ~/gitops-demo
echo "# Updated configuration" >> k8s-manifests/deployment.yaml
git add .
git commit -m "Test GitOps workflow"

# Wait for automatic sync (if enabled) or trigger manual sync
# Verify changes are applied
oc get events -n sample-app-ns --sort-by='.lastTimestamp'
Validate application accessibility:
# Get the route URL
ROUTE_URL=$(oc get route sample-app-route -n sample-app-ns -o jsonpath='{.spec.host}')
echo "Application URL: http://$ROUTE_URL"

# Test application response
curl -I http://$ROUTE_URL
Conclusion
Congratulations! You have successfully completed Lab 12: Integrating OpenShift with GitOps. In this lab, you accomplished the following:

Key Achievements:

Installed and configured ArgoCD in your OpenShift cluster using the operator model
Connected ArgoCD to a Git repository and configured it for automated application deployment
Implemented GitOps workflows with both manual and automatic synchronization
Monitored application health and sync status using both CLI and web interface
Tested the complete GitOps pipeline by making changes to your Git repository and observing automatic deployments
Why This Matters: GitOps represents a paradigm shift in how we manage application deployments and infrastructure. By treating Git as the single source of truth, you've learned to:

Increase deployment reliability through declarative configuration management
Improve security by eliminating direct cluster access for deployments
Enable better collaboration through Git-based workflows
Achieve faster recovery through automated drift detection and correction
Maintain audit trails of all changes through Git history
Real-World Applications: The skills you've developed in this lab are directly applicable to:

Enterprise CI/CD pipelines where multiple teams need to deploy applications safely
Multi-environment management (development, staging, production) with consistent processes
Compliance requirements where change tracking and approval workflows are mandatory
Disaster recovery scenarios where infrastructure can be quickly rebuilt from Git repositories
Next Steps: To further enhance your GitOps expertise, consider exploring:

Multi-cluster ArgoCD deployments for managing applications across different environments
Integration with CI/CD tools like Jenkins or Tekton for complete automation pipelines
Advanced ArgoCD features like ApplicationSets for managing multiple applications
Security best practices including RBAC, secrets management, and policy enforcement
This lab has provided you with foundational GitOps skills that are essential for the Red Hat Certified OpenShift Application Developer exam and modern DevOps practices in enterprise environments.
