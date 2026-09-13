Lab 7: Managing ImageStreams and BuildConfigs
Objectives
By the end of this lab, you will be able to:

Understand the concepts of ImageStreams and BuildConfigs in OpenShift
Create and configure ImageStreams for container image management
Set up BuildConfigs to build container images from source code
Configure and trigger automated builds using webhooks
Implement continuous integration workflows using OpenShift build capabilities
Troubleshoot common build and deployment issues
Prerequisites
Before starting this lab, you should have:

Basic understanding of containers and container images
Familiarity with Git version control system
Knowledge of OpenShift/Kubernetes fundamentals
Experience with command-line interface operations
Understanding of YAML configuration files
Completion of previous OpenShift labs or equivalent experience
Lab Environment Setup
Ready-to-Use Cloud Machines: Al Nafi provides pre-configured Linux-based cloud machines with OpenShift installed and ready to use. Simply click Start Lab to access your environment - no need to build your own VM or install software.

Your lab environment includes:

OpenShift cluster with administrative access
Pre-installed oc command-line tool
Git client for source code management
Text editor for configuration file editing
Task 1: Understanding and Creating ImageStreams
Subtask 1.1: Understanding ImageStreams Concept
ImageStreams are OpenShift resources that provide a stable pointer to container images. They act as an abstraction layer that allows you to reference images without knowing their exact registry location or tag.

Key benefits of ImageStreams:

Version Management: Track different versions of the same image
Automatic Updates: Trigger deployments when new images are available
Security: Control which images can be used in your projects
Abstraction: Decouple applications from specific image registries
Subtask 1.2: Login to OpenShift Cluster
First, let's log in to your OpenShift cluster and create a new project for this lab.

# Login to OpenShift (replace with your cluster URL)
oc login https://api.your-cluster.com:6443

# Create a new project for this lab
oc new-project imagestream-lab

# Verify you're in the correct project
oc project
Subtask 1.3: Examine Existing ImageStreams
Let's explore the ImageStreams that are already available in OpenShift.

# List ImageStreams in the current project
oc get imagestreams

# List ImageStreams in the openshift namespace (system-provided)
oc get imagestreams -n openshift

# Get detailed information about a specific ImageStream
oc describe imagestream nodejs -n openshift
Subtask 1.4: Create a Custom ImageStream
Now let's create our own ImageStream that points to a public container image.

Create a file named custom-imagestream.yaml:

apiVersion: image.openshift.io/v1
kind: ImageStream
metadata:
  name: my-nodejs-app
  namespace: imagestream-lab
  labels:
    app: nodejs-demo
spec:
  lookupPolicy:
    local: false
  tags:
  - name: "latest"
    from:
      kind: DockerImage
      name: registry.access.redhat.com/ubi8/nodejs-16:latest
    importPolicy:
      scheduled: true
    referencePolicy:
      type: Source
Apply the ImageStream configuration:

# Create the ImageStream
oc apply -f custom-imagestream.yaml

# Verify the ImageStream was created
oc get imagestreams

# Check the ImageStream details
oc describe imagestream my-nodejs-app
Subtask 1.5: Import External Images to ImageStream
Let's import an external image into our ImageStream:

# Import an image from Docker Hub
oc import-image my-nodejs-app:16 --from=node:16-alpine --confirm

# Check the imported image
oc describe imagestream my-nodejs-app

# List all tags in the ImageStream
oc get imagestream my-nodejs-app -o yaml
Task 2: Setting Up BuildConfigs
Subtask 2.1: Understanding BuildConfigs
BuildConfigs define how to build container images from source code. They specify:

Source: Where to get the source code (Git repository, binary, etc.)
Strategy: How to build the image (Source-to-Image, Docker, Custom)
Output: Where to store the built image (ImageStream, external registry)
Triggers: When to start a build (webhook, config change, image change)
Subtask 2.2: Create a Sample Application Repository
For this lab, we'll use a sample Node.js application. Let's create the necessary files:

Create a directory structure for our sample application:

# Create application directory
mkdir -p ~/nodejs-sample-app
cd ~/nodejs-sample-app

# Create package.json
cat > package.json << 'EOF'
{
  "name": "nodejs-sample-app",
  "version": "1.0.0",
  "description": "Sample Node.js application for OpenShift BuildConfig demo",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.0"
  }
}
EOF

# Create server.js
cat > server.js << 'EOF'
const express = require('express');
const app = express();
const port = process.env.PORT || 8080;

app.get('/', (req, res) => {
  res.send(`
    <h1>Hello from OpenShift BuildConfig Demo!</h1>
    <p>This application was built using OpenShift BuildConfig.</p>
    <p>Build version: ${process.env.BUILD_VERSION || 'development'}</p>
    <p>Current time: ${new Date().toISOString()}</p>
  `);
});

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy', timestamp: new Date().toISOString() });
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
EOF

# Create .s2i directory for Source-to-Image configuration
mkdir -p .s2i
cat > .s2i/environment << 'EOF'
NODE_ENV=production
NPM_CONFIG_PRODUCTION=false
EOF
Subtask 2.3: Initialize Git Repository
# Initialize git repository
git init

# Add files to git
git add .

# Commit files
git commit -m "Initial commit - Node.js sample application"

# Check git status
git status
Subtask 2.4: Create BuildConfig with Source-to-Image Strategy
Create a BuildConfig that uses the Source-to-Image (S2I) strategy:

# Create buildconfig-s2i.yaml
cat > buildconfig-s2i.yaml << 'EOF'
apiVersion: build.openshift.io/v1
kind: BuildConfig
metadata:
  name: nodejs-sample-build
  labels:
    app: nodejs-sample
spec:
  source:
    type: Git
    git:
      uri: https://github.com/sclorg/nodejs-ex.git
      ref: master
  strategy:
    type: Source
    sourceStrategy:
      from:
        kind: ImageStreamTag
        namespace: openshift
        name: nodejs:16-ubi8
      env:
      - name: NODE_ENV
        value: production
  output:
    to:
      kind: ImageStreamTag
      name: nodejs-sample:latest
  triggers:
  - type: ConfigChange
  - type: ImageChange
    imageChange:
      from:
        kind: ImageStreamTag
        namespace: openshift
        name: nodejs:16-ubi8
EOF
Apply the BuildConfig:

# Create the BuildConfig
oc apply -f buildconfig-s2i.yaml

# Verify BuildConfig creation
oc get buildconfigs

# Check BuildConfig details
oc describe buildconfig nodejs-sample-build
Subtask 2.5: Create BuildConfig with Docker Strategy
Now let's create a BuildConfig using Docker strategy. First, create a Dockerfile:

# Create Dockerfile
cat > Dockerfile << 'EOF'
FROM registry.access.redhat.com/ubi8/nodejs-16:latest

# Set working directory
WORKDIR /opt/app-root/src

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install --only=production

# Copy application code
COPY . .

# Set environment variables
ENV NODE_ENV=production
ENV PORT=8080

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

# Start application
CMD ["npm", "start"]
EOF
Create a BuildConfig with Docker strategy:

# Create buildconfig-docker.yaml
cat > buildconfig-docker.yaml << 'EOF'
apiVersion: build.openshift.io/v1
kind: BuildConfig
metadata:
  name: nodejs-docker-build
  labels:
    app: nodejs-docker
spec:
  source:
    type: Git
    git:
      uri: https://github.com/sclorg/nodejs-ex.git
      ref: master
    contextDir: "."
  strategy:
    type: Docker
    dockerStrategy:
      from:
        kind: ImageStreamTag
        namespace: openshift
        name: nodejs:16-ubi8
      env:
      - name: BUILD_VERSION
        value: "1.0.0"
  output:
    to:
      kind: ImageStreamTag
      name: nodejs-docker:latest
  triggers:
  - type: ConfigChange
  - type: ImageChange
    imageChange:
      from:
        kind: ImageStreamTag
        namespace: openshift
        name: nodejs:16-ubi8
EOF
Apply the Docker BuildConfig:

# Create the Docker BuildConfig
oc apply -f buildconfig-docker.yaml

# List all BuildConfigs
oc get buildconfigs

# Check the Docker BuildConfig details
oc describe buildconfig nodejs-docker-build
Subtask 2.6: Start Manual Builds
Let's trigger builds manually to test our BuildConfigs:

# Start a build from the S2I BuildConfig
oc start-build nodejs-sample-build

# Start a build from the Docker BuildConfig
oc start-build nodejs-docker-build

# Monitor build progress
oc get builds

# Watch build logs (replace build-name with actual build name)
oc logs -f build/nodejs-sample-build-1

# Check build status
oc describe build nodejs-sample-build-1
Subtask 2.7: Verify Built Images
After the builds complete, verify that images were created:

# Check ImageStreams for built images
oc get imagestreams

# Describe the ImageStream to see tags
oc describe imagestream nodejs-sample

# Check image details
oc get images | grep nodejs-sample
Task 3: Configuring Webhook Triggers
Subtask 3.1: Understanding Webhook Triggers
Webhooks allow external systems (like Git repositories) to automatically trigger builds when code changes occur. OpenShift supports:

Generic webhooks: Triggered by any HTTP POST request
GitHub webhooks: Specifically designed for GitHub integration
GitLab webhooks: Specifically designed for GitLab integration
Bitbucket webhooks: Specifically designed for Bitbucket integration
Subtask 3.2: Add Webhook Triggers to BuildConfig
Let's modify our BuildConfig to include webhook triggers:

# Create buildconfig-with-webhooks.yaml
cat > buildconfig-with-webhooks.yaml << 'EOF'
apiVersion: build.openshift.io/v1
kind: BuildConfig
metadata:
  name: nodejs-webhook-build
  labels:
    app: nodejs-webhook
spec:
  source:
    type: Git
    git:
      uri: https://github.com/sclorg/nodejs-ex.git
      ref: master
  strategy:
    type: Source
    sourceStrategy:
      from:
        kind: ImageStreamTag
        namespace: openshift
        name: nodejs:16-ubi8
  output:
    to:
      kind: ImageStreamTag
      name: nodejs-webhook:latest
  triggers:
  - type: ConfigChange
  - type: ImageChange
    imageChange:
      from:
        kind: ImageStreamTag
        namespace: openshift
        name: nodejs:16-ubi8
  - type: Generic
    generic:
      secret: "my-generic-secret"
      allowEnv: true
  - type: GitHub
    github:
      secret: "my-github-secret"
EOF
Apply the webhook-enabled BuildConfig:

# Create the BuildConfig with webhooks
oc apply -f buildconfig-with-webhooks.yaml

# Verify the BuildConfig
oc describe buildconfig nodejs-webhook-build
Subtask 3.3: Retrieve Webhook URLs
Get the webhook URLs that can be used to trigger builds:

# Get webhook URLs
oc describe buildconfig nodejs-webhook-build | grep -A 5 "Webhook"

# Get the generic webhook URL
GENERIC_WEBHOOK=$(oc describe buildconfig nodejs-webhook-build | grep "Webhook Generic" -A 1 | tail -1 | awk '{print $2}')
echo "Generic Webhook URL: $GENERIC_WEBHOOK"

# Get the GitHub webhook URL
GITHUB_WEBHOOK=$(oc describe buildconfig nodejs-webhook-build | grep "Webhook GitHub" -A 1 | tail -1 | awk '{print $2}')
echo "GitHub Webhook URL: $GITHUB_WEBHOOK"
Subtask 3.4: Test Generic Webhook
Let's test the generic webhook by triggering it manually:

# Get the generic webhook URL (replace with your actual URL)
WEBHOOK_URL=$(oc describe buildconfig nodejs-webhook-build | grep "Webhook Generic" -A 1 | tail -1 | awk '{print $2}')

# Trigger the webhook using curl
curl -X POST $WEBHOOK_URL

# Monitor the triggered build
oc get builds

# Watch the build logs
oc logs -f build/nodejs-webhook-build-1
Subtask 3.5: Configure Webhook with Environment Variables
Create a BuildConfig that accepts environment variables through webhooks:

# Create buildconfig-webhook-env.yaml
cat > buildconfig-webhook-env.yaml << 'EOF'
apiVersion: build.openshift.io/v1
kind: BuildConfig
metadata:
  name: nodejs-env-build
  labels:
    app: nodejs-env
spec:
  source:
    type: Git
    git:
      uri: https://github.com/sclorg/nodejs-ex.git
      ref: master
  strategy:
    type: Source
    sourceStrategy:
      from:
        kind: ImageStreamTag
        namespace: openshift
        name: nodejs:16-ubi8
      env:
      - name: BUILD_ENV
        value: "development"
      - name: BUILD_VERSION
        value: "1.0.0"
  output:
    to:
      kind: ImageStreamTag
      name: nodejs-env:latest
  triggers:
  - type: ConfigChange
  - type: Generic
    generic:
      secret: "env-webhook-secret"
      allowEnv: true
EOF
Apply and test the environment-enabled BuildConfig:

# Create the BuildConfig
oc apply -f buildconfig-webhook-env.yaml

# Get the webhook URL
ENV_WEBHOOK_URL=$(oc describe buildconfig nodejs-env-build | grep "Webhook Generic" -A 1 | tail -1 | awk '{print $2}')

# Trigger webhook with environment variables
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"env":[{"name":"BUILD_ENV","value":"production"},{"name":"BUILD_VERSION","value":"2.0.0"}]}' \
  $ENV_WEBHOOK_URL

# Monitor the build
oc get builds
oc logs -f build/nodejs-env-build-1
Subtask 3.6: Create Secure Webhook Configuration
Let's create a more secure webhook configuration using secrets:

# Create a secret for webhook authentication
oc create secret generic webhook-secret \
  --from-literal=WebHookSecretKey=super-secret-key-123

# Create BuildConfig that references the secret
cat > buildconfig-secure-webhook.yaml << 'EOF'
apiVersion: build.openshift.io/v1
kind: BuildConfig
metadata:
  name: nodejs-secure-build
  labels:
    app: nodejs-secure
spec:
  source:
    type: Git
    git:
      uri: https://github.com/sclorg/nodejs-ex.git
      ref: master
  strategy:
    type: Source
    sourceStrategy:
      from:
        kind: ImageStreamTag
        namespace: openshift
        name: nodejs:16-ubi8
  output:
    to:
      kind: ImageStreamTag
      name: nodejs-secure:latest
  triggers:
  - type: ConfigChange
  - type: Generic
    generic:
      secretReference:
        name: webhook-secret
      allowEnv: true
EOF

# Apply the secure BuildConfig
oc apply -f buildconfig-secure-webhook.yaml

# Verify the configuration
oc describe buildconfig nodejs-secure-build
Task 4: Advanced BuildConfig Features
Subtask 4.1: Configure Build Resources and Limits
Create a BuildConfig with resource constraints:

# Create buildconfig-resources.yaml
cat > buildconfig-resources.yaml << 'EOF'
apiVersion: build.openshift.io/v1
kind: BuildConfig
metadata:
  name: nodejs-resource-build
  labels:
    app: nodejs-resource
spec:
  source:
    type: Git
    git:
      uri: https://github.com/sclorg/nodejs-ex.git
      ref: master
  strategy:
    type: Source
    sourceStrategy:
      from:
        kind: ImageStreamTag
        namespace: openshift
        name: nodejs:16-ubi8
  output:
    to:
      kind: ImageStreamTag
      name: nodejs-resource:latest
  resources:
    limits:
      cpu: "1"
      memory: "1Gi"
    requests:
      cpu: "500m"
      memory: "512Mi"
  triggers:
  - type: ConfigChange
EOF
Apply the resource-constrained BuildConfig:

# Create the BuildConfig
oc apply -f buildconfig-resources.yaml

# Start a build and monitor resource usage
oc start-build nodejs-resource-build

# Check build pod resource usage
oc get pods | grep nodejs-resource-build
oc describe pod nodejs-resource-build-1-build
Subtask 4.2: Configure Build Timeout and Retry
Create a BuildConfig with timeout and completion deadline:

# Create buildconfig-timeout.yaml
cat > buildconfig-timeout.yaml << 'EOF'
apiVersion: build.openshift.io/v1
kind: BuildConfig
metadata:
  name: nodejs-timeout-build
  labels:
    app: nodejs-timeout
spec:
  source:
    type: Git
    git:
      uri: https://github.com/sclorg/nodejs-ex.git
      ref: master
  strategy:
    type: Source
    sourceStrategy:
      from:
        kind: ImageStreamTag
        namespace: openshift
        name: nodejs:16-ubi8
  output:
    to:
      kind: ImageStreamTag
      name: nodejs-timeout:latest
  completionDeadlineSeconds: 600  # 10 minutes
  successfulBuildsHistoryLimit: 5
  failedBuildsHistoryLimit: 3
  triggers:
  - type: ConfigChange
EOF
Apply and test the timeout configuration:

# Create the BuildConfig
oc apply -f buildconfig-timeout.yaml

# Start a build
oc start-build nodejs-timeout-build

# Monitor build completion
oc get builds --watch
Subtask 4.3: Configure Post-Commit Hooks
Create a BuildConfig with post-commit hooks for testing:

# Create buildconfig-hooks.yaml
cat > buildconfig-hooks.yaml << 'EOF'
apiVersion: build.openshift.io/v1
kind: BuildConfig
metadata:
  name: nodejs-hooks-build
  labels:
    app: nodejs-hooks
spec:
  source:
    type: Git
    git:
      uri: https://github.com/sclorg/nodejs-ex.git
      ref: master
  strategy:
    type: Source
    sourceStrategy:
      from:
        kind: ImageStreamTag
        namespace: openshift
        name: nodejs:16-ubi8
  output:
    to:
      kind: ImageStreamTag
      name: nodejs-hooks:latest
  postCommit:
    script: |
      echo "Running post-commit tests..."
      npm test || echo "No tests found, skipping..."
      echo "Build completed successfully!"
  triggers:
  - type: ConfigChange
EOF
Apply and test the post-commit hooks:

# Create the BuildConfig
oc apply -f buildconfig-hooks.yaml

# Start a build
oc start-build nodejs-hooks-build

# Watch the build logs to see post-commit execution
oc logs -f build/nodejs-hooks-build-1
Task 5: Deploying and Testing Built Images
Subtask 5.1: Deploy Application from Built Image
Create a deployment using one of our built images:

# Create a new application from the built image
oc new-app nodejs-sample:latest --name=nodejs-sample-app

# Expose the service
oc expose service nodejs-sample-app

# Check deployment status
oc get deployments
oc get pods
oc get routes
Subtask 5.2: Test the Deployed Application
# Get the route URL
ROUTE_URL=$(oc get route nodejs-sample-app -o jsonpath='{.spec.host}')
echo "Application URL: http://$ROUTE_URL"

# Test the application
curl http://$ROUTE_URL

# Test the health endpoint
curl http://$ROUTE_URL/health
Subtask 5.3: Configure Automatic Deployment Triggers
Create a DeploymentConfig that automatically deploys when new images are built:

# Create deploymentconfig-auto.yaml
cat > deploymentconfig-auto.yaml << 'EOF'
apiVersion: apps.openshift.io/v1
kind: DeploymentConfig
metadata:
  name: nodejs-auto-deploy
  labels:
    app: nodejs-auto
spec:
  replicas: 2
  selector:
    app: nodejs-auto
  template:
    metadata:
      labels:
        app: nodejs-auto
    spec:
      containers:
      - name: nodejs-app
        image: nodejs-sample:latest
        ports:
        - containerPort: 8080
        env:
        - name: NODE_ENV
          value: production
        resources:
          limits:
            cpu: 500m
            memory: 512Mi
          requests:
            cpu: 100m
            memory: 128Mi
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
  triggers:
  - type: ConfigChange
  - type: ImageChange
    imageChangeParams:
      automatic: true
      containerNames:
      - nodejs-app
      from:
        kind: ImageStreamTag
        name: nodejs-sample:latest
EOF
Apply the automatic deployment configuration:

# Create the DeploymentConfig
oc apply -f deploymentconfig-auto.yaml

# Create a service for the deployment
oc expose deploymentconfig nodejs-auto-deploy --port=8080

# Expose the service as a route
oc expose service nodejs-auto-deploy

# Check the deployment
oc get deploymentconfigs
oc get pods
Task 6: Monitoring and Troubleshooting
Subtask 6.1: Monitor Build Status and Logs
# List all builds with their status
oc get builds

# Get detailed information about a specific build
oc describe build nodejs-sample-build-1

# View build logs
oc logs build/nodejs-sample-build-1

# Follow build logs in real-time
oc logs -f build/nodejs-sample-build-1

# Check build events
oc get events --field-selector involvedObject.kind=Build
Subtask 6.2: Debug Failed Builds
Let's create a BuildConfig that might fail and learn how to debug it:

# Create buildconfig-debug.yaml with intentional issues
cat > buildconfig-debug.yaml << 'EOF'
apiVersion: build.openshift.io/v1
kind: BuildConfig
metadata:
  name: nodejs-debug-build
  labels:
    app: nodejs-debug
spec:
  source:
    type: Git
    git:
      uri: https://github.com/invalid-repo/does-not-exist.git
      ref: master
  strategy:
    type: Source
    sourceStrategy:
      from:
        kind: ImageStreamTag
        namespace: openshift
        name: nodejs:16-ubi8
  output:
    to:
      kind: ImageStreamTag
      name: nodejs-debug:latest
  triggers:
  - type: ConfigChange
EOF
Apply and debug the failing BuildConfig:

# Create the problematic BuildConfig
oc apply -f buildconfig-debug.yaml

# The build will fail - let's debug it
oc get builds
oc describe build nodejs-debug-build-1
oc logs build/nodejs-debug-build-1

# Fix the BuildConfig by updating the Git URL
oc patch buildconfig nodejs-debug-build -p '{"spec":{"source":{"git":{"uri":"https://github.com/sclorg/nodejs-ex.git"}}}}'

# Start a new build
oc start-build nodejs-debug-build

# Monitor the fixed build
oc logs -f build/nodejs-debug-build-2
Subtask 6.3: Clean Up Build History
# View build history
oc get builds

# Delete old builds (keep only the latest 2)
oc delete builds --field-selector status.phase=Complete \
  --sort-by=.metadata.creationTimestamp | head -n -2

# Configure automatic cleanup in BuildConfig
oc patch buildconfig nodejs-sample-build -p '{"spec":{"successfulBuildsHistoryLimit":3,"failedBuildsHistoryLimit":2}}'
Troubleshooting Common Issues
Issue 1: Build Fails Due to Resource Constraints
Problem: Build pods are killed due to memory or CPU limits.

Solution:

# Check build pod resource usage
oc describe pod <build-pod-name>

# Increase resource limits in BuildConfig
oc patch buildconfig <buildconfig-name> -p '{"spec":{"resources":{"limits":{"memory":"2Gi","cpu":"1"}}}}'
Issue 2: Source Code Not Found
Problem: Git repository is not accessible or branch doesn't exist.

Solution:

# Verify Git repository URL
git ls-remote <repository-url>

# Update BuildConfig with correct URL/branch
oc patch buildconfig <buildconfig-name> -p '{"spec":{"source":{"git":{"uri":"<correct-url>","ref":"<correct-branch>"}}}}'
Issue 3: Base Image Not Found
Problem: The base image specified in the BuildConfig doesn't exist.

Solution:

# Check available ImageStreams
oc get imagestreams -n openshift

# Update BuildConfig with correct base image
oc patch buildconfig <buildconfig-name> -p '{"spec":{"strategy":{"sourceStrategy":{"from":{"name":"<correct-image>:latest"}}}}}'
Issue 4: Webhook Not Triggering Builds
Problem: External webhook calls are not triggering builds.

Solution:

# Verify webhook URL is correct
oc describe buildconfig <buildconfig-name> | grep Webhook

# Check webhook secret
oc get secrets | grep webhook

# Test webhook manually
curl -X POST <webhook-url>
Lab Summary and Cleanup
Summary
In this lab, you have successfully:

Created and managed ImageStreams to provide stable references to container images
Configured BuildConfigs using both Source-to-Image and Docker strategies
Implemented webhook triggers for automated builds from source code changes
Set up advanced build features including resource limits, timeouts, and post-commit hooks
Deployed applications from built images with automatic deployment triggers
Learned troubleshooting techniques for common build and deployment issues
Key Concepts Learned
ImageStreams provide version management and abstraction for container images
BuildConfigs automate the process of building container images from source code
Webhooks enable continuous integration by triggering builds on code changes
Build strategies (S2I, Docker, Custom) offer different approaches to image building
Resource management ensures builds don't consume excessive cluster resources
Monitoring and debugging are essential for maintaining reliable build pipelines
Cleanup Resources
To clean up the resources created in this lab:

# Delete all BuildConfigs
oc delete buildconfigs --all

# Delete all builds
oc delete builds --all

# Delete all ImageStreams (except system ones)
oc delete imagestreams --all

# Delete deployments and services
oc delete deploymentconfigs --all
oc delete services --all
oc delete routes --all

# Delete the project (optional)
oc delete project imagestream-lab
Next Steps
After completing this lab, you should:

Practice creating BuildConfigs for different types of applications (Java, Python, etc.)
Explore advanced build strategies and custom builders
Integrate BuildConfigs with external CI/CD systems
Learn about build security and image scanning
Study OpenShift Pipelines for more complex CI/CD workflows
This lab has provided you with the foundational knowledge needed for the Red Hat Certified OpenShift Application Developer exam and practical skills for managing application builds in OpenShift environments.
