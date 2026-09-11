Lab 3: Developing Applications with S2I
Objectives
By the end of this lab, you will be able to:

Understand the Source-to-Image (S2I) process and its benefits
Create a simple web application suitable for S2I deployment
Set up a Git repository and push application code
Deploy applications using OpenShift's S2I build process
Monitor and manage S2I builds and deployments
Troubleshoot common S2I deployment issues
Prerequisites
Before starting this lab, you should have:

Basic understanding of containerization concepts
Familiarity with Git version control
Basic knowledge of web application development
Understanding of OpenShift fundamentals
Access to command-line interface (CLI)
Note: Al Nafi provides pre-configured Linux-based cloud machines with all necessary tools installed. Simply click Start Lab to begin - no need to build your own VM or install additional software.

Lab Environment Setup
Your cloud machine comes pre-installed with:

OpenShift CLI (oc)
Git
Node.js and npm
Python 3
Text editors (nano, vim)
Docker (for understanding container concepts)
Task 1: Understanding S2I and Creating a Sample Application
Subtask 1.1: Understanding Source-to-Image (S2I)
Source-to-Image (S2I) is a build tool that creates container images from application source code without requiring a Dockerfile. It combines source code with a builder image to produce a ready-to-run container image.

Key Benefits of S2I:

Security: Prevents arbitrary code execution during build
Speed: Incremental builds for faster deployment
Patchability: Easy to update base images
Efficiency: Optimized layering for smaller images
Subtask 1.2: Create a Simple Node.js Application
Let's create a simple Node.js web application that we'll deploy using S2I.

Create a project directory:
mkdir ~/s2i-nodejs-app
cd ~/s2i-nodejs-app
Initialize a Node.js project:
npm init -y
Install Express.js framework:
npm install express --save
Create the main application file:
nano app.js
Add the following code to app.js:
const express = require('express');
const app = express();
const port = process.env.PORT || 8080;

// Middleware to parse JSON
app.use(express.json());

// Root route
app.get('/', (req, res) => {
    res.json({
        message: 'Welcome to S2I Node.js Application!',
        version: '1.0.0',
        timestamp: new Date().toISOString(),
        environment: process.env.NODE_ENV || 'development'
    });
});

// Health check endpoint
app.get('/health', (req, res) => {
    res.status(200).json({
        status: 'healthy',
        uptime: process.uptime(),
        timestamp: new Date().toISOString()
    });
});

// API endpoint
app.get('/api/info', (req, res) => {
    res.json({
        application: 'S2I Demo App',
        technology: 'Node.js with Express',
        build_method: 'Source-to-Image (S2I)',
        author: 'OpenShift Developer'
    });
});

// Start server
app.listen(port, () => {
    console.log(`Server running on port ${port}`);
    console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
});
Save and exit the editor (Ctrl+X, then Y, then Enter for nano)

Update package.json with start script:

nano package.json
Modify the scripts section to include:
{
  "name": "s2i-nodejs-app",
  "version": "1.0.0",
  "description": "",
  "main": "app.js",
  "scripts": {
    "start": "node app.js",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
Test the application locally:
npm start
Open another terminal and test the endpoints:
# Test main endpoint
curl http://localhost:8080

# Test health endpoint
curl http://localhost:8080/health

# Test API endpoint
curl http://localhost:8080/api/info
Stop the local server (Ctrl+C in the first terminal)
Subtask 1.3: Create Application Documentation
Create a README.md file:
nano README.md
Add the following content:
# S2I Node.js Demo Application

This is a simple Node.js application designed to demonstrate OpenShift's Source-to-Image (S2I) build process.

## Features

- Express.js web server
- Health check endpoint
- JSON API responses
- Environment-aware configuration

## Endpoints

- `GET /` - Main application info
- `GET /health` - Health check
- `GET /api/info` - Application details

## Local Development

```bash
npm install
npm start
OpenShift Deployment
This application is designed to be deployed using OpenShift's S2I process with the Node.js builder image.


3. **Save and exit the editor**

## Task 2: Setting Up Git Repository and Pushing Code

### Subtask 2.1: Initialize Git Repository

1. **Initialize Git in your project directory:**

```bash
git init
Configure Git (if not already configured):
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
Create a .gitignore file:
nano .gitignore
Add the following content:
node_modules/
npm-debug.log*
.env
.DS_Store
*.log
Save and exit the editor
Subtask 2.2: Commit Code to Local Repository
Add files to Git:
git add .
Create initial commit:
git commit -m "Initial commit: S2I Node.js application"
Verify the commit:
git log --oneline
Subtask 2.3: Create Remote Repository and Push Code
For this lab, we'll use a local Git server that's already set up on your cloud machine.

Create a bare repository (simulating a remote Git server):
mkdir -p ~/git-repos
cd ~/git-repos
git init --bare s2i-nodejs-app.git
Return to your application directory:
cd ~/s2i-nodejs-app
Add the remote repository:
git remote add origin ~/git-repos/s2i-nodejs-app.git
Push code to the remote repository:
git push -u origin master
Verify the push was successful:
git remote -v
git branch -a
Task 3: Deploying Application Using OpenShift S2I
Subtask 3.1: Login to OpenShift and Create Project
Login to your OpenShift cluster:
oc login --server=https://api.crc.testing:6443 --username=developer --password=developer
Note: If using a different OpenShift environment, your instructor will provide the correct login details.

Create a new project:
oc new-project s2i-demo --display-name="S2I Demo Project" --description="Learning S2I with Node.js"
Verify project creation:
oc project
oc get projects
Subtask 3.2: Deploy Application Using S2I
Create a new application using S2I:
oc new-app nodejs~file://~/git-repos/s2i-nodejs-app.git --name=s2i-nodejs-app
Command Breakdown:

nodejs~ - Specifies the Node.js S2I builder image
file://~/git-repos/s2i-nodejs-app.git - Local Git repository path
--name=s2i-nodejs-app - Application name
Monitor the build process:
oc get builds
oc logs -f bc/s2i-nodejs-app
Check build status:
oc get builds
oc describe build s2i-nodejs-app-1
Subtask 3.3: Expose the Application
Create a service (if not automatically created):
oc get services
Expose the service to create a route:
oc expose service s2i-nodejs-app
Get the application URL:
oc get routes
Test the deployed application:
# Get the route URL
ROUTE_URL=$(oc get route s2i-nodejs-app -o jsonpath='{.spec.host}')
echo "Application URL: http://$ROUTE_URL"

# Test the endpoints
curl http://$ROUTE_URL
curl http://$ROUTE_URL/health
curl http://$ROUTE_URL/api/info
Subtask 3.4: Monitor and Manage the Deployment
Check deployment status:
oc get deployments
oc get pods
oc get all
View application logs:
# Get pod name
POD_NAME=$(oc get pods -l app=s2i-nodejs-app -o jsonpath='{.items[0].metadata.name}')
echo "Pod name: $POD_NAME"

# View logs
oc logs $POD_NAME
Scale the application:
oc scale deployment s2i-nodejs-app --replicas=2
oc get pods
Check resource usage:
oc describe deployment s2i-nodejs-app
oc top pods
Task 4: Making Changes and Triggering New Builds
Subtask 4.1: Update Application Code
Navigate to your application directory:
cd ~/s2i-nodejs-app
Update the application version:
nano app.js
Modify the root route response:
// Root route
app.get('/', (req, res) => {
    res.json({
        message: 'Welcome to S2I Node.js Application - Updated Version!',
        version: '2.0.0',
        timestamp: new Date().toISOString(),
        environment: process.env.NODE_ENV || 'development',
        update: 'Added new features and improved performance'
    });
});
Save and exit the editor
Subtask 4.2: Commit and Push Changes
Commit the changes:
git add .
git commit -m "Version 2.0.0: Updated welcome message and version"
Push changes to remote repository:
git push origin master
Subtask 4.3: Trigger New Build in OpenShift
Start a new build:
oc start-build s2i-nodejs-app
Monitor the new build:
oc get builds
oc logs -f bc/s2i-nodejs-app
Wait for deployment to complete:
oc get pods -w
Test the updated application:
ROUTE_URL=$(oc get route s2i-nodejs-app -o jsonpath='{.spec.host}')
curl http://$ROUTE_URL
Task 5: Advanced S2I Configuration
Subtask 5.1: Using Environment Variables
Set environment variables for the application:
oc set env deployment/s2i-nodejs-app NODE_ENV=production
oc set env deployment/s2i-nodejs-app APP_MESSAGE="Production S2I Application"
Verify environment variables:
oc set env deployment/s2i-nodejs-app --list
Test the application with new environment:
curl http://$ROUTE_URL
Subtask 5.2: Configure Resource Limits
Set resource limits:
oc set resources deployment s2i-nodejs-app --limits=cpu=200m,memory=256Mi --requests=cpu=100m,memory=128Mi
Verify resource configuration:
oc describe deployment s2i-nodejs-app
Subtask 5.3: Configure Health Checks
Add readiness probe:
oc set probe deployment/s2i-nodejs-app --readiness --get-url=http://:8080/health --initial-delay-seconds=10 --period-seconds=5
Add liveness probe:
oc set probe deployment/s2i-nodejs-app --liveness --get-url=http://:8080/health --initial-delay-seconds=30 --period-seconds=10
Verify probe configuration:
oc describe deployment s2i-nodejs-app
Troubleshooting Common Issues
Build Failures
Check build logs:
oc get builds
oc logs build/s2i-nodejs-app-1
Common issues and solutions:
Missing package.json: Ensure package.json is in the root directory
Port binding issues: Use process.env.PORT || 8080
Dependencies not found: Check npm install process in build logs
Deployment Issues
Check pod status:
oc get pods
oc describe pod <pod-name>
Check application logs:
oc logs <pod-name>
Common issues:
ImagePullBackOff: Build may have failed
CrashLoopBackOff: Application startup issues
Port conflicts: Ensure application listens on correct port
Networking Issues
Verify service and route:
oc get services
oc get routes
oc describe route s2i-nodejs-app
Test internal connectivity:
oc rsh <pod-name>
curl localhost:8080
Lab Cleanup
Delete the project:
oc delete project s2i-demo
Clean up local files (optional):
rm -rf ~/s2i-nodejs-app
rm -rf ~/git-repos
Conclusion
Congratulations! You have successfully completed Lab 3: Developing Applications with S2I. In this lab, you have:

Key Accomplishments:

Mastered S2I Concepts: Learned how Source-to-Image streamlines the build process by automatically creating container images from source code without requiring Dockerfiles
Built a Real Application: Created a functional Node.js web application with multiple endpoints, proper error handling, and production-ready features
Implemented Git Workflow: Set up version control, committed code changes, and managed application updates through Git repositories
Deployed with OpenShift S2I: Successfully used OpenShift's S2I process to build and deploy applications automatically from source code
Configured Production Features: Implemented environment variables, resource limits, and health checks for production-ready deployments
Managed Application Lifecycle: Learned to monitor builds, scale applications, and troubleshoot common deployment issues
Why This Matters:

S2I is a powerful feature that bridges the gap between development and deployment, making it easier for developers to focus on code while OpenShift handles the containerization process. This approach:

Increases Developer Productivity: Eliminates the need to write and maintain Dockerfiles
Enhances Security: Provides controlled build environments with security best practices
Enables Rapid Iteration: Supports quick code-to-deployment cycles essential for modern development
Standardizes Deployments: Ensures consistent application packaging across different environments
The skills you've learned in this lab are essential for the Red Hat Certified OpenShift Application Developer exam and will serve you well in real-world OpenShift development scenarios. You're now equipped to leverage S2I for efficient, secure, and scalable application deployments in enterprise environments.

Next Steps: Consider exploring advanced S2I features such as custom builder images, webhook triggers for automated builds, and integration with CI/CD pipelines to further enhance your OpenShift development workflow.
