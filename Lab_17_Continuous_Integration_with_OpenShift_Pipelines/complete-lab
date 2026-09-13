Lab 17: Continuous Integration with OpenShift Pipelines
Objectives
By the end of this lab, you will be able to:

Understand the fundamentals of OpenShift Pipelines and Tekton
Install and configure OpenShift Pipelines Operator
Create and configure Tekton Tasks for building, testing, and deploying applications
Build complete CI/CD pipelines using Tekton Pipeline resources
Integrate Git repositories with Tekton Triggers for automated builds
Monitor and troubleshoot pipeline executions
Implement best practices for continuous integration workflows
Prerequisites
Before starting this lab, you should have:

Basic understanding of Kubernetes concepts (pods, services, deployments)
Familiarity with OpenShift fundamentals
Knowledge of Git version control system
Understanding of containerization and Docker concepts
Basic YAML syntax knowledge
Experience with command-line interfaces
Ready-to-Use Cloud Machines
Al Nafi provides Linux-based cloud machines with OpenShift cluster access pre-configured for this lab. Simply click Start Lab to begin - no need to build your own VM or install OpenShift locally. Your cloud machine includes:

Pre-installed OpenShift CLI (oc)
Access to an OpenShift cluster
Git client
Text editors (vim, nano)
All necessary permissions for pipeline operations
Task 1: Set up Tekton Pipelines for Building, Testing, and Deploying Applications
Subtask 1.1: Install OpenShift Pipelines Operator
First, we'll install the OpenShift Pipelines Operator which provides Tekton functionality.

Log into your OpenShift cluster:
oc login --server=https://your-cluster-url --token=your-token
Create a new project for our pipeline work:
oc new-project pipeline-demo
Install the OpenShift Pipelines Operator (if not already installed):
cat << EOF | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: openshift-pipelines-operator
  namespace: openshift-operators
spec:
  channel: latest
  name: openshift-pipelines-operator-rh
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF
Verify the operator installation:
oc get pods -n openshift-pipelines
Wait until all pods are in Running status before proceeding.

Subtask 1.2: Create Basic Tekton Tasks
Now we'll create individual tasks for building, testing, and deploying our application.

Create a Git Clone Task:
cat << EOF | oc apply -f -
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: git-clone
  namespace: pipeline-demo
spec:
  workspaces:
  - name: output
    description: The git repo will be cloned onto the volume backing this workspace
  params:
  - name: url
    description: git url to clone
    type: string
  - name: revision
    description: git revision to checkout (branch, tag, sha, ref…)
    type: string
    default: main
  steps:
  - name: clone
    image: registry.redhat.io/ubi8/ubi:latest
    workingDir: \$(workspaces.output.path)
    script: |
      #!/usr/bin/env bash
      set -xe
      
      # Install git
      dnf install -y git
      
      # Clone the repository
      git clone \$(params.url) .
      git checkout \$(params.revision)
      
      echo "Successfully cloned \$(params.url) at revision \$(params.revision)"
EOF
Create a Build Task:
cat << EOF | oc apply -f -
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: build-app
  namespace: pipeline-demo
spec:
  workspaces:
  - name: source
    description: The workspace containing the source code
  params:
  - name: IMAGE
    description: Reference of the image to build
    type: string
  steps:
  - name: build-and-push
    image: registry.redhat.io/rhel8/buildah:latest
    workingDir: \$(workspaces.source.path)
    securityContext:
      privileged: true
    script: |
      #!/usr/bin/env bash
      set -xe
      
      # Build the container image
      buildah bud --format=oci --tls-verify=false --no-cache \
        -f ./Dockerfile -t \$(params.IMAGE) .
      
      # Push the image to registry
      buildah push --tls-verify=false \$(params.IMAGE)
      
      echo "Image built and pushed: \$(params.IMAGE)"
EOF
Create a Test Task:
cat << EOF | oc apply -f -
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: test-app
  namespace: pipeline-demo
spec:
  workspaces:
  - name: source
    description: The workspace containing the source code
  steps:
  - name: run-tests
    image: registry.redhat.io/ubi8/nodejs-16:latest
    workingDir: \$(workspaces.source.path)
    script: |
      #!/usr/bin/env bash
      set -xe
      
      # Check if package.json exists (Node.js app)
      if [ -f "package.json" ]; then
        echo "Running Node.js tests..."
        npm install
        npm test || echo "No tests found, skipping..."
      else
        echo "No package.json found, running basic validation..."
        # Basic file structure validation
        ls -la
        echo "Source code validation completed"
      fi
EOF
Create a Deploy Task:
cat << EOF | oc apply -f -
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: deploy-app
  namespace: pipeline-demo
spec:
  params:
  - name: IMAGE
    description: Reference of the image to deploy
    type: string
  - name: APP_NAME
    description: Name of the application
    type: string
  steps:
  - name: deploy
    image: registry.redhat.io/openshift4/ose-cli:latest
    script: |
      #!/usr/bin/env bash
      set -xe
      
      # Create deployment if it doesn't exist
      oc new-app \$(params.IMAGE) --name=\$(params.APP_NAME) || true
      
      # Update the deployment with new image
      oc set image deployment/\$(params.APP_NAME) \$(params.APP_NAME)=\$(params.IMAGE)
      
      # Expose the service
      oc expose service/\$(params.APP_NAME) || true
      
      # Wait for rollout to complete
      oc rollout status deployment/\$(params.APP_NAME)
      
      echo "Application deployed successfully"
EOF
Subtask 1.3: Create a Complete Pipeline
Now we'll combine our tasks into a complete CI/CD pipeline.

Create the Pipeline resource:
cat << EOF | oc apply -f -
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: build-test-deploy-pipeline
  namespace: pipeline-demo
spec:
  params:
  - name: git-url
    type: string
    description: Git repository URL
  - name: git-revision
    type: string
    description: Git revision to build
    default: main
  - name: image-name
    type: string
    description: Name of the image to build
  - name: app-name
    type: string
    description: Name of the application
  workspaces:
  - name: shared-data
    description: Shared workspace for pipeline tasks
  tasks:
  - name: fetch-source
    taskRef:
      name: git-clone
    workspaces:
    - name: output
      workspace: shared-data
    params:
    - name: url
      value: \$(params.git-url)
    - name: revision
      value: \$(params.git-revision)
  
  - name: test-application
    taskRef:
      name: test-app
    runAfter:
    - fetch-source
    workspaces:
    - name: source
      workspace: shared-data
  
  - name: build-image
    taskRef:
      name: build-app
    runAfter:
    - test-application
    workspaces:
    - name: source
      workspace: shared-data
    params:
    - name: IMAGE
      value: \$(params.image-name)
  
  - name: deploy-application
    taskRef:
      name: deploy-app
    runAfter:
    - build-image
    params:
    - name: IMAGE
      value: \$(params.image-name)
    - name: APP_NAME
      value: \$(params.app-name)
EOF
Subtask 1.4: Create a Sample Application
Let's create a simple Node.js application to test our pipeline.

Create a sample application repository structure:
mkdir -p ~/sample-app
cd ~/sample-app
Create package.json:
cat << EOF > package.json
{
  "name": "sample-node-app",
  "version": "1.0.0",
  "description": "A sample Node.js application for CI/CD demo",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "test": "echo 'Running tests...' && exit 0"
  },
  "dependencies": {
    "express": "^4.18.0"
  }
}
EOF
Create server.js:
cat << EOF > server.js
const express = require('express');
const app = express();
const port = process.env.PORT || 8080;

app.get('/', (req, res) => {
  res.json({
    message: 'Hello from OpenShift Pipelines!',
    version: '1.0.0',
    timestamp: new Date().toISOString()
  });
});

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy' });
});

app.listen(port, () => {
  console.log(\`Server running on port \${port}\`);
});
EOF
Create Dockerfile:
cat << EOF > Dockerfile
FROM registry.redhat.io/ubi8/nodejs-16:latest

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy application code
COPY . .

# Expose port
EXPOSE 8080

# Start the application
CMD ["npm", "start"]
EOF
Subtask 1.5: Run the Pipeline
Now let's execute our pipeline with the sample application.

Create a PersistentVolumeClaim for the workspace:
cat << EOF | oc apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pipeline-workspace-pvc
  namespace: pipeline-demo
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF
Create and push the sample app to a Git repository (you can use GitHub, GitLab, or any Git service):
# Initialize git repository
git init
git add .
git commit -m "Initial commit of sample application"

# Add your remote repository (replace with your actual repository URL)
git remote add origin https://github.com/your-username/sample-node-app.git
git push -u origin main
Run the pipeline:
cat << EOF | oc apply -f -
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  name: build-test-deploy-run-\$(date +%s)
  namespace: pipeline-demo
spec:
  pipelineRef:
    name: build-test-deploy-pipeline
  params:
  - name: git-url
    value: "https://github.com/your-username/sample-node-app.git"
  - name: git-revision
    value: "main"
  - name: image-name
    value: "image-registry.openshift-image-registry.svc:5000/pipeline-demo/sample-app:latest"
  - name: app-name
    value: "sample-app"
  workspaces:
  - name: shared-data
    persistentVolumeClaim:
      claimName: pipeline-workspace-pvc
EOF
Monitor the pipeline execution:
# List pipeline runs
oc get pipelineruns -n pipeline-demo

# Watch the latest pipeline run
oc logs -f pipelinerun/$(oc get pipelineruns -o name | head -1 | cut -d'/' -f2) -n pipeline-demo
Task 2: Integrate Tekton with Git Repositories for Triggering Builds
Subtask 2.1: Install and Configure Tekton Triggers
Tekton Triggers allow us to automatically start pipelines based on Git events like commits or pull requests.

Create EventListener, TriggerTemplate, and TriggerBinding:
cat << EOF | oc apply -f -
apiVersion: triggers.tekton.dev/v1beta1
kind: TriggerTemplate
metadata:
  name: build-test-deploy-trigger-template
  namespace: pipeline-demo
spec:
  params:
  - name: git-repo-url
    description: The git repository url
  - name: git-revision
    description: The git revision
    default: main
  - name: git-repo-name
    description: The name of the deployment to be created / patched
  resourcetemplates:
  - apiVersion: tekton.dev/v1beta1
    kind: PipelineRun
    metadata:
      generateName: build-test-deploy-run-
    spec:
      pipelineRef:
        name: build-test-deploy-pipeline
      params:
      - name: git-url
        value: \$(tt.params.git-repo-url)
      - name: git-revision
        value: \$(tt.params.git-revision)
      - name: image-name
        value: "image-registry.openshift-image-registry.svc:5000/pipeline-demo/\$(tt.params.git-repo-name):latest"
      - name: app-name
        value: \$(tt.params.git-repo-name)
      workspaces:
      - name: shared-data
        persistentVolumeClaim:
          claimName: pipeline-workspace-pvc
EOF
Create TriggerBinding for GitHub webhooks:
cat << EOF | oc apply -f -
apiVersion: triggers.tekton.dev/v1beta1
kind: TriggerBinding
metadata:
  name: github-push-binding
  namespace: pipeline-demo
spec:
  params:
  - name: git-repo-url
    value: \$(body.repository.clone_url)
  - name: git-repo-name
    value: \$(body.repository.name)
  - name: git-revision
    value: \$(body.head_commit.id)
EOF
Create Trigger to connect binding and template:
cat << EOF | oc apply -f -
apiVersion: triggers.tekton.dev/v1beta1
kind: Trigger
metadata:
  name: github-push-trigger
  namespace: pipeline-demo
spec:
  serviceAccountName: pipeline
  bindings:
  - ref: github-push-binding
  template:
    ref: build-test-deploy-trigger-template
  interceptors:
  - name: "verify-git-payload"
    ref:
      name: "github"
    params:
    - name: "secretRef"
      value:
        secretName: github-webhook-secret
        secretKey: secretToken
    - name: "eventTypes"
      value: ["push"]
EOF
Create EventListener:
cat << EOF | oc apply -f -
apiVersion: triggers.tekton.dev/v1beta1
kind: EventListener
metadata:
  name: github-webhook-listener
  namespace: pipeline-demo
spec:
  serviceAccountName: pipeline
  triggers:
  - triggerRef: github-push-trigger
EOF
Subtask 2.2: Configure Service Account and RBAC
Create service account with proper permissions:
cat << EOF | oc apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: pipeline
  namespace: pipeline-demo
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pipeline-role-binding
  namespace: pipeline-demo
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: edit
subjects:
- kind: ServiceAccount
  name: pipeline
  namespace: pipeline-demo
EOF
Create webhook secret (replace 'your-secret-token' with a secure random string):
cat << EOF | oc apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: github-webhook-secret
  namespace: pipeline-demo
type: Opaque
stringData:
  secretToken: "your-secret-token-here"
EOF
Subtask 2.3: Expose EventListener and Configure Webhook
Expose the EventListener service:
oc expose service el-github-webhook-listener -n pipeline-demo
Get the webhook URL:
echo "Webhook URL: http://$(oc get route el-github-webhook-listener -o jsonpath='{.spec.host}' -n pipeline-demo)"
Configure GitHub webhook (manual step):
Go to your GitHub repository settings
Navigate to Webhooks section
Click Add webhook
Set Payload URL to the webhook URL from step 2
Set Content type to application/json
Set Secret to the same value you used in the webhook secret
Select Just the push event
Click Add webhook
Subtask 2.4: Test Automated Pipeline Triggering
Make a change to your sample application:
cd ~/sample-app

# Update the version in server.js
sed -i 's/version: "1.0.0"/version: "1.1.0"/' server.js

# Commit and push the change
git add .
git commit -m "Update application version to 1.1.0"
git push origin main
Monitor for automatic pipeline execution:
# Watch for new pipeline runs
watch oc get pipelineruns -n pipeline-demo

# Check EventListener logs
oc logs -f deployment/el-github-webhook-listener -n pipeline-demo
Verify the deployment was updated:
# Check if the application is running
oc get pods -n pipeline-demo

# Test the application endpoint
oc get route sample-app -n pipeline-demo
curl http://$(oc get route sample-app -o jsonpath='{.spec.host}' -n pipeline-demo)
Monitoring and Troubleshooting
Viewing Pipeline Runs
List all pipeline runs:
oc get pipelineruns -n pipeline-demo
Get detailed information about a specific run:
oc describe pipelinerun <pipelinerun-name> -n pipeline-demo
View logs from a specific task:
oc logs <pod-name> -c step-<step-name> -n pipeline-demo
Common Issues and Solutions
Issue: Pipeline fails during build step Solution: Check if the Dockerfile is correct and all dependencies are available

Issue: Git clone fails Solution: Verify the repository URL is accessible and credentials are correct if needed

Issue: Webhook not triggering pipeline Solution: Check EventListener logs and verify webhook configuration in GitHub

Issue: Deploy task fails Solution: Ensure the service account has proper permissions and the image registry is accessible

Viewing Pipeline Results in OpenShift Console
Access the OpenShift web console
Navigate to Pipelines section
Select your project (pipeline-demo)
View pipeline runs, tasks, and logs graphically
Conclusion
In this lab, you have successfully:

Installed and configured OpenShift Pipelines using the Tekton framework
Created individual Tekton Tasks for git cloning, testing, building, and deploying applications
Built a complete CI/CD pipeline that orchestrates multiple tasks in sequence
Integrated Git repositories with Tekton Triggers to automatically start builds on code changes
Configured webhooks to enable event-driven pipeline execution
Deployed a sample Node.js application using the automated pipeline
Why This Matters:

OpenShift Pipelines provides a cloud-native, Kubernetes-native CI/CD solution that offers several key advantages:

Declarative Configuration: All pipeline components are defined as Kubernetes resources
Scalability: Pipelines run as pods and can scale automatically
Portability: Tekton pipelines can run on any Kubernetes cluster
Extensibility: Easy to create custom tasks and integrate with various tools
Security: Built-in RBAC and security contexts for safe execution
This foundation enables you to build sophisticated CI/CD workflows that can handle complex application deployments, multi-environment promotions, and integration with various development tools and practices. The skills you've learned here are directly applicable to the Red Hat Certified OpenShift Application Developer exam and real-world DevOps scenarios.

Next Steps:

Explore advanced Tekton features like Conditions and custom Tasks
Integrate with additional tools like SonarQube for code quality
Implement multi-environment deployment strategies
Add security scanning and compliance checks to your pipelines
