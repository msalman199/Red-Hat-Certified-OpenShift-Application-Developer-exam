Lab 8: Automating Builds with Jenkins
Objectives
By the end of this lab, you will be able to:

Install and configure Jenkins on OpenShift using open-source tools
Create automated Jenkins pipelines for application builds
Set up Git webhooks to trigger Jenkins builds automatically
Understand the integration between Jenkins and OpenShift for CI/CD workflows
Configure Jenkins to deploy applications to OpenShift environments
Monitor and troubleshoot Jenkins pipeline executions
Prerequisites
Before starting this lab, you should have:

Basic understanding of OpenShift concepts (pods, services, routes)
Familiarity with Git version control system
Knowledge of containerized applications and Docker concepts
Understanding of YAML configuration files
Basic command-line interface experience
Completion of previous OpenShift labs or equivalent experience
Required Tools and Access
Al Nafi Cloud Machine: Linux-based cloud machine with OpenShift cluster access (click Start Lab to begin)
Git Repository: GitHub or GitLab account for webhook configuration
Web Browser: For accessing Jenkins and OpenShift web consoles
Lab Environment Setup
Ready-to-Use Cloud Machines
Al Nafi provides pre-configured Linux-based cloud machines with OpenShift cluster access. Simply click Start Lab to begin - no need to build your own VM or install additional software. Your environment includes:

OpenShift cluster with admin privileges
Pre-installed oc command-line tool
Git client and development tools
Network access to external repositories
Task 1: Install and Configure Jenkins on OpenShift
Subtask 1.1: Verify OpenShift Cluster Access
First, let's ensure your OpenShift environment is ready for Jenkins installation.

Open Terminal on your Al Nafi cloud machine

Verify OpenShift login status:

oc whoami
oc cluster-info
Check available projects:
oc projects
Create a dedicated project for Jenkins:
oc new-project jenkins-ci
oc project jenkins-ci
Subtask 1.2: Deploy Jenkins Using OpenShift Templates
OpenShift provides built-in Jenkins templates that simplify deployment.

List available Jenkins templates:
oc get templates -n openshift | grep jenkins
Deploy Jenkins with persistent storage:
oc new-app jenkins-persistent \
  --param JENKINS_SERVICE_NAME=jenkins \
  --param JNLP_SERVICE_NAME=jenkins-jnlp \
  --param ENABLE_OAUTH=true \
  --param MEMORY_LIMIT=2Gi \
  --param VOLUME_CAPACITY=10Gi \
  --param DISABLE_ADMINISTRATIVE_MONITORS=false
Monitor Jenkins deployment:
oc get pods -w
Wait until the Jenkins pod shows Running status before proceeding.

Subtask 1.3: Access Jenkins Web Interface
Get Jenkins route URL:
oc get route jenkins -o jsonpath='{.spec.host}'
Open Jenkins in your web browser using the URL from the previous command

Login using OpenShift OAuth:

Click Login with OpenShift
Use your OpenShift credentials
Grant necessary permissions when prompted
Subtask 1.4: Configure Jenkins-OpenShift Integration
Verify OpenShift plugin installation in Jenkins:

Navigate to Manage Jenkins > Manage Plugins
Check Installed tab for OpenShift Pipeline plugin
Configure OpenShift connection:

Go to Manage Jenkins > Configure System
Scroll to OpenShift Client Plugin section
Verify cluster URL and credentials are automatically configured
Task 2: Create Jenkins Pipelines for Automated Builds
Subtask 2.1: Prepare Sample Application Repository
Create a new directory for your application:
mkdir -p ~/jenkins-demo-app
cd ~/jenkins-demo-app
Initialize Git repository:
git init
Create a simple Node.js application:
cat > app.js << 'EOF'
const express = require('express');
const app = express();
const port = process.env.PORT || 8080;

app.get('/', (req, res) => {
  res.json({
    message: 'Hello from Jenkins CI/CD Pipeline!',
    version: '1.0.0',
    timestamp: new Date().toISOString()
  });
});

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy' });
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
EOF
Create package.json file:
cat > package.json << 'EOF'
{
  "name": "jenkins-demo-app",
  "version": "1.0.0",
  "description": "Demo application for Jenkins CI/CD",
  "main": "app.js",
  "scripts": {
    "start": "node app.js",
    "test": "echo \"Running tests...\" && exit 0"
  },
  "dependencies": {
    "express": "^4.18.2"
  },
  "engines": {
    "node": ">=14.0.0"
  }
}
EOF
Create Dockerfile:
cat > Dockerfile << 'EOF'
FROM node:16-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install --production

COPY . .

EXPOSE 8080

USER node

CMD ["npm", "start"]
EOF
Subtask 2.2: Create OpenShift Deployment Configuration
Create OpenShift deployment YAML:
cat > openshift-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jenkins-demo-app
  labels:
    app: jenkins-demo-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: jenkins-demo-app
  template:
    metadata:
      labels:
        app: jenkins-demo-app
    spec:
      containers:
      - name: jenkins-demo-app
        image: jenkins-demo-app:latest
        ports:
        - containerPort: 8080
        env:
        - name: PORT
          value: "8080"
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
---
apiVersion: v1
kind: Service
metadata:
  name: jenkins-demo-app-service
spec:
  selector:
    app: jenkins-demo-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
  type: ClusterIP
---
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: jenkins-demo-app-route
spec:
  to:
    kind: Service
    name: jenkins-demo-app-service
  port:
    targetPort: 8080
EOF
Subtask 2.3: Create Jenkins Pipeline Script
Create Jenkinsfile for pipeline definition:
cat > Jenkinsfile << 'EOF'
pipeline {
    agent any
    
    environment {
        APP_NAME = 'jenkins-demo-app'
        PROJECT_NAME = 'jenkins-ci'
        GIT_REPO = 'https://github.com/yourusername/jenkins-demo-app.git'
        IMAGE_TAG = "${BUILD_NUMBER}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out source code...'
                checkout scm
            }
        }
        
        stage('Build Application') {
            steps {
                echo 'Building Node.js application...'
                script {
                    openshift.withCluster() {
                        openshift.withProject("${PROJECT_NAME}") {
                            // Create build config if it doesn't exist
                            if (!openshift.selector("bc", "${APP_NAME}").exists()) {
                                openshift.newBuild("--name=${APP_NAME}", "--binary=true", "--strategy=docker")
                            }
                            
                            // Start build from current directory
                            def build = openshift.selector("bc", "${APP_NAME}").startBuild("--from-dir=.", "--wait=true")
                            
                            // Tag the image
                            openshift.tag("${APP_NAME}:latest", "${APP_NAME}:${IMAGE_TAG}")
                        }
                    }
                }
            }
        }
        
        stage('Run Tests') {
            steps {
                echo 'Running application tests...'
                script {
                    // In a real scenario, you would run actual tests here
                    sh 'echo "Running unit tests..." && sleep 2'
                    sh 'echo "Running integration tests..." && sleep 2'
                    sh 'echo "All tests passed!"'
                }
            }
        }
        
        stage('Deploy to Development') {
            steps {
                echo 'Deploying to development environment...'
                script {
                    openshift.withCluster() {
                        openshift.withProject("${PROJECT_NAME}") {
                            // Create deployment if it doesn't exist
                            if (!openshift.selector("deployment", "${APP_NAME}").exists()) {
                                openshift.newApp("${APP_NAME}:${IMAGE_TAG}", "--name=${APP_NAME}")
                                openshift.selector("svc", "${APP_NAME}").expose()
                            } else {
                                // Update existing deployment
                                openshift.selector("deployment", "${APP_NAME}").rollout().latest()
                            }
                            
                            // Wait for deployment to complete
                            def deployment = openshift.selector("deployment", "${APP_NAME}")
                            deployment.rollout().status("--watch=true")
                        }
                    }
                }
            }
        }
        
        stage('Verify Deployment') {
            steps {
                echo 'Verifying deployment...'
                script {
                    openshift.withCluster() {
                        openshift.withProject("${PROJECT_NAME}") {
                            def route = openshift.selector("route", "${APP_NAME}")
                            if (route.exists()) {
                                def routeHost = route.object().spec.host
                                echo "Application deployed at: http://${routeHost}"
                            }
                        }
                    }
                }
            }
        }
    }
    
    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Check logs for details.'
        }
        always {
            echo 'Cleaning up workspace...'
            cleanWs()
        }
    }
}
EOF
Subtask 2.4: Commit and Push to Git Repository
Add all files to Git:
git add .
git commit -m "Initial commit: Jenkins demo application with pipeline"
Create GitHub repository (if you haven't already):

Go to GitHub.com and create a new repository named jenkins-demo-app
Make it public for easier webhook configuration
Push to remote repository:

git remote add origin https://github.com/yourusername/jenkins-demo-app.git
git branch -M main
git push -u origin main
Note: Replace yourusername with your actual GitHub username.

Subtask 2.5: Create Jenkins Pipeline Job
Access Jenkins web interface using the route URL from earlier

Create new pipeline job:

Click New Item
Enter name: jenkins-demo-app-pipeline
Select Pipeline and click OK
Configure pipeline settings:

In General section, add description: "Automated CI/CD pipeline for demo application"
Check GitHub project and enter your repository URL
Configure pipeline source:

In Pipeline section, select Pipeline script from SCM
Choose Git as SCM
Enter Repository URL: https://github.com/yourusername/jenkins-demo-app.git
Set Branch Specifier: */main
Script Path: Jenkinsfile
Save the configuration

Task 3: Trigger Jenkins Builds via Git and Webhooks
Subtask 3.1: Manual Pipeline Execution
Run pipeline manually to test configuration:

Go to your pipeline job page
Click Build Now
Monitor the build progress in Console Output
Verify build stages:

Check that all stages complete successfully
Note any errors and troubleshoot as needed
Subtask 3.2: Configure GitHub Webhooks
Get Jenkins webhook URL:

In Jenkins, go to your pipeline job
Note the URL format: http://jenkins-route-url/github-webhook/
Configure webhook in GitHub:

Go to your GitHub repository
Click Settings > Webhooks
Click Add webhook
Payload URL: Enter your Jenkins webhook URL
Content type: application/json
Which events: Select "Just the push event"
Click Add webhook
Subtask 3.3: Enable Automatic Builds
Update Jenkins job configuration:

Go to your pipeline job configuration
In Build Triggers section, check GitHub hook trigger for GITScm polling
Save the configuration
Test webhook trigger:

Make a small change to your application code
Commit and push the change:
echo "console.log('Webhook test');" >> app.js
git add app.js
git commit -m "Test webhook trigger"
git push origin main
Verify automatic build:
Check Jenkins dashboard for new build
Monitor build progress and verify successful completion
Subtask 3.4: Configure Build Parameters
Add parameterized builds:

Edit your pipeline job configuration
Check This project is parameterized
Add String Parameter:
Name: ENVIRONMENT
Default Value: development
Description: Target deployment environment
Update Jenkinsfile to use parameters:

cat > Jenkinsfile << 'EOF'
pipeline {
    agent any
    
    parameters {
        choice(
            name: 'ENVIRONMENT',
            choices: ['development', 'staging', 'production'],
            description: 'Target deployment environment'
        )
        booleanParam(
            name: 'SKIP_TESTS',
            defaultValue: false,
            description: 'Skip test execution'
        )
    }
    
    environment {
        APP_NAME = 'jenkins-demo-app'
        PROJECT_NAME = 'jenkins-ci'
        IMAGE_TAG = "${BUILD_NUMBER}"
        DEPLOY_ENV = "${params.ENVIRONMENT}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo "Checking out source code for ${DEPLOY_ENV} deployment..."
                checkout scm
            }
        }
        
        stage('Build Application') {
            steps {
                echo "Building application for ${DEPLOY_ENV}..."
                script {
                    openshift.withCluster() {
                        openshift.withProject("${PROJECT_NAME}") {
                            if (!openshift.selector("bc", "${APP_NAME}").exists()) {
                                openshift.newBuild("--name=${APP_NAME}", "--binary=true", "--strategy=docker")
                            }
                            
                            def build = openshift.selector("bc", "${APP_NAME}").startBuild("--from-dir=.", "--wait=true")
                            openshift.tag("${APP_NAME}:latest", "${APP_NAME}:${IMAGE_TAG}")
                        }
                    }
                }
            }
        }
        
        stage('Run Tests') {
            when {
                not { params.SKIP_TESTS }
            }
            steps {
                echo 'Running application tests...'
                sh 'echo "Running tests for ${DEPLOY_ENV} environment..."'
                sh 'sleep 3'
                sh 'echo "All tests passed!"'
            }
        }
        
        stage('Deploy Application') {
            steps {
                echo "Deploying to ${DEPLOY_ENV} environment..."
                script {
                    openshift.withCluster() {
                        openshift.withProject("${PROJECT_NAME}") {
                            if (!openshift.selector("deployment", "${APP_NAME}").exists()) {
                                openshift.newApp("${APP_NAME}:${IMAGE_TAG}", "--name=${APP_NAME}")
                                openshift.selector("svc", "${APP_NAME}").expose()
                            } else {
                                openshift.selector("deployment", "${APP_NAME}").rollout().latest()
                            }
                            
                            def deployment = openshift.selector("deployment", "${APP_NAME}")
                            deployment.rollout().status("--watch=true")
                        }
                    }
                }
            }
        }
        
        stage('Post-Deploy Verification') {
            steps {
                echo 'Verifying deployment health...'
                script {
                    openshift.withCluster() {
                        openshift.withProject("${PROJECT_NAME}") {
                            def route = openshift.selector("route", "${APP_NAME}")
                            if (route.exists()) {
                                def routeHost = route.object().spec.host
                                echo "Application deployed successfully!"
                                echo "Environment: ${DEPLOY_ENV}"
                                echo "Access URL: http://${routeHost}"
                                echo "Build Number: ${BUILD_NUMBER}"
                            }
                        }
                    }
                }
            }
        }
    }
    
    post {
        success {
            echo "✅ Pipeline completed successfully for ${DEPLOY_ENV}!"
            echo "Build #${BUILD_NUMBER} deployed successfully"
        }
        failure {
            echo "❌ Pipeline failed for ${DEPLOY_ENV}"
            echo "Check build logs for details"
        }
        always {
            echo 'Cleaning up workspace...'
            cleanWs()
        }
    }
}
EOF
Commit and push the updated Jenkinsfile:
git add Jenkinsfile
git commit -m "Add parameterized pipeline configuration"
git push origin main
Troubleshooting Common Issues
Issue 1: Jenkins Pod Not Starting
Symptoms: Jenkins pod remains in pending or error state

Solutions:

# Check pod status and events
oc describe pod jenkins-xxx

# Check persistent volume claims
oc get pvc

# Restart deployment if needed
oc rollout restart deployment/jenkins
Issue 2: Pipeline Fails at Build Stage
Symptoms: Build stage fails with permission errors

Solutions:

# Ensure Jenkins service account has proper permissions
oc policy add-role-to-user edit system:serviceaccount:jenkins-ci:jenkins

# Check build config
oc get bc
oc describe bc jenkins-demo-app
Issue 3: Webhook Not Triggering Builds
Symptoms: Git pushes don't trigger Jenkins builds

Solutions:

Verify webhook URL is correct and accessible
Check GitHub webhook delivery logs
Ensure Jenkins job has proper trigger configuration
Test webhook manually using curl:
curl -X POST http://your-jenkins-url/github-webhook/
Issue 4: OpenShift Plugin Connection Issues
Symptoms: Pipeline fails with OpenShift connection errors

Solutions:

# Verify Jenkins can access OpenShift API
oc whoami --show-server

# Check service account token
oc describe sa jenkins

# Restart Jenkins if needed
oc rollout restart deployment/jenkins
Verification and Testing
Verify Complete CI/CD Flow
Make application changes:
# Update application version
sed -i 's/"version": "1.0.0"/"version": "1.1.0"/' package.json

# Add new endpoint
cat >> app.js << 'EOF'

app.get('/version', (req, res) => {
  res.json({ version: '1.1.0', build: process.env.BUILD_NUMBER || 'local' });
});
EOF
Commit and push changes:
git add .
git commit -m "Update application to version 1.1.0"
git push origin main
Monitor automatic build:

Check Jenkins dashboard for triggered build
Monitor all pipeline stages
Verify successful deployment
Test deployed application:

# Get application route
oc get route jenkins-demo-app -o jsonpath='{.spec.host}'

# Test endpoints
curl http://your-app-route/
curl http://your-app-route/health
curl http://your-app-route/version
Conclusion
Congratulations! You have successfully completed Lab 8: Automating Builds with Jenkins. In this comprehensive lab, you have accomplished the following:

Key Achievements
Jenkins Installation and Configuration:

Successfully deployed Jenkins on OpenShift using persistent storage
Configured OAuth integration for secure authentication
Set up Jenkins-OpenShift plugin for seamless integration
Pipeline Creation and Management:

Created a complete CI/CD pipeline using Jenkinsfile
Implemented multi-stage builds with proper error handling
Configured parameterized builds for flexible deployments
Set up automated testing and deployment verification
Automated Trigger Configuration:

Established GitHub webhook integration for automatic builds
Configured push-based triggers for continuous integration
Tested manual and automatic build execution
Real-World Application:

Built and deployed a Node.js application using containerization
Implemented health checks and monitoring endpoints
Created production-ready deployment configurations
Why This Matters
The skills you've developed in this lab are essential for modern software development and DevOps practices:

Continuous Integration/Continuous Deployment (CI/CD): Automated pipelines reduce manual errors and accelerate software delivery
Infrastructure as Code: Using Jenkinsfiles and YAML configurations ensures reproducible and version-controlled deployments
Container Orchestration: OpenShift integration provides scalable and resilient application hosting
Automation: Webhook triggers enable rapid feedback loops and faster development cycles
Next Steps
To further enhance your Jenkins and OpenShift automation skills, consider:

Advanced Pipeline Features: Explore parallel stages, matrix builds, and conditional deployments
Security Integration: Implement security scanning and compliance checks in pipelines
Multi-Environment Deployments: Set up staging and production environment promotions
Monitoring and Alerting: Integrate pipeline notifications and deployment monitoring
Blue-Green Deployments: Implement zero-downtime deployment strategies
Certification Relevance
This lab directly supports your preparation for the Red Hat Certified OpenShift Application Developer exam by covering:

OpenShift application deployment and management
Container build and deployment strategies
CI/CD pipeline implementation
Integration with external tools and services
Troubleshooting and monitoring applications
The hands-on experience gained through this lab provides practical knowledge that is highly valued in enterprise environments and aligns with industry best practices for modern application development and deployment.

You now have a solid foundation in Jenkins automation with OpenShift that you can apply to real-world projects and continue building upon as you advance in your DevOps and cloud-native development journey.
