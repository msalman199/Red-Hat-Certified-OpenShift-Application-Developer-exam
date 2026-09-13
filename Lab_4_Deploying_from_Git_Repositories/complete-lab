Lab 4: Deploying from Git Repositories
Objectives
By the end of this lab, you will be able to:

Link a Git repository to an OpenShift project
Configure automatic deployments triggered by code commits
Understand the source-to-image (S2I) build process
Monitor and manage Git-based deployments
Troubleshoot common deployment issues from Git repositories
Prerequisites
Before starting this lab, you should have:

Basic understanding of Git version control system
Familiarity with OpenShift concepts (projects, pods, services)
Knowledge of containerized applications
Experience with command-line interfaces
Completion of previous OpenShift labs or equivalent knowledge
Required Tools
OpenShift CLI (oc) - pre-installed on your lab machine
Git client - pre-installed on your lab machine
Web browser for accessing OpenShift web console
Text editor (vim, nano, or VS Code)
Lab Environment Setup
Al Nafi Cloud Machines: Your Linux-based cloud machine is ready to use with all necessary tools pre-installed. Simply click Start Lab to begin - no VM setup required.

Your lab environment includes:

OpenShift cluster access
Pre-configured Git client
Sample application repositories
All required CLI tools
Task 1: Link a Git Repository to an OpenShift Project
Subtask 1.1: Create a New OpenShift Project
First, let's create a dedicated project for our Git-based deployments.

Login to OpenShift cluster:
oc login --server=https://api.your-cluster.com:6443
Create a new project:
oc new-project git-deployment-lab --display-name="Git Deployment Lab" --description="Lab for Git-based deployments"
Verify project creation:
oc project
oc get projects | grep git-deployment-lab
Subtask 1.2: Prepare Sample Application Repository
We'll use a sample Node.js application for this lab.

Clone the sample repository:
cd /home/student
git clone https://github.com/sclorg/nodejs-ex.git
cd nodejs-ex
Examine the repository structure:
ls -la
cat package.json
cat server.js
Create your own Git repository (using a local Git server for lab purposes):
# Initialize a bare repository to simulate remote Git server
mkdir -p /opt/git-repos
cd /opt/git-repos
git init --bare nodejs-app.git

# Configure the sample app to use our local repository
cd /home/student/nodejs-ex
git remote remove origin
git remote add origin file:///opt/git-repos/nodejs-app.git
git push -u origin master
Subtask 1.3: Deploy Application from Git Repository
Now we'll create an OpenShift application directly from the Git repository.

Create new application from Git source:
oc new-app nodejs~file:///opt/git-repos/nodejs-app.git --name=nodejs-git-app
Monitor the build process:
oc get builds
oc logs -f bc/nodejs-git-app
Check deployment status:
oc get pods
oc get deployments
oc get services
Expose the service to create a route:
oc expose service nodejs-git-app
oc get routes
Subtask 1.4: Verify Application Deployment
Get the application URL:
ROUTE_URL=$(oc get route nodejs-git-app -o jsonpath='{.spec.host}')
echo "Application URL: http://$ROUTE_URL"
Test the application:
curl http://$ROUTE_URL
Access via web browser (if available):
Open the URL in your browser to see the running application
Task 2: Trigger Automatic Deployments on Code Commits
Subtask 2.1: Configure Webhooks for Automatic Builds
OpenShift can automatically trigger new builds when code is pushed to the Git repository.

Get the webhook URL:
oc describe bc nodejs-git-app | grep -A 5 "Webhook"
Extract the webhook URL:
WEBHOOK_URL=$(oc describe bc nodejs-git-app | grep "URL:" | head -1 | awk '{print $2}')
echo "Webhook URL: $WEBHOOK_URL"
Subtask 2.2: Set Up Git Hooks for Automatic Deployment
Since we're using a local Git repository, we'll configure a post-receive hook to simulate webhook functionality.

Create a post-receive hook:
cat > /opt/git-repos/nodejs-app.git/hooks/post-receive << 'EOF'
#!/bin/bash
echo "Git push received, triggering OpenShift build..."

# Trigger build using webhook
curl -X POST -k "$(oc describe bc nodejs-git-app | grep 'URL:' | head -1 | awk '{print $2}')"

echo "Build triggered successfully"
EOF
Make the hook executable:
chmod +x /opt/git-repos/nodejs-app.git/hooks/post-receive
Subtask 2.3: Test Automatic Deployment
Now let's test the automatic deployment by making changes to our application.

Navigate to the application directory:
cd /home/student/nodejs-ex
Modify the application:
# Edit the main server file
cp server.js server.js.backup
sed -i 's/Welcome to your Node.js application on OpenShift/Welcome to your UPDATED Node.js application on OpenShift - Auto Deploy Test/' server.js
Verify the change:
grep -n "Welcome" server.js
Commit and push the changes:
git add server.js
git commit -m "Update welcome message for auto-deploy test"
git push origin master
Monitor the automatic build:
# Watch for new builds
oc get builds -w
In a new terminal, monitor the build logs:
# Get the latest build
BUILD_NAME=$(oc get builds --sort-by=.metadata.creationTimestamp | tail -1 | awk '{print $1}')
oc logs -f build/$BUILD_NAME
Subtask 2.4: Verify Automatic Deployment
Wait for the build to complete:
oc get builds
Check if new pods are deployed:
oc get pods
Test the updated application:
ROUTE_URL=$(oc get route nodejs-git-app -o jsonpath='{.spec.host}')
curl http://$ROUTE_URL
Verify the changes are reflected:
The response should show the updated welcome message
Subtask 2.5: Configure Build Triggers and Strategies
Let's explore different build trigger configurations.

View current build configuration:
oc get bc nodejs-git-app -o yaml | grep -A 10 triggers
Add additional trigger types:
# Add config change trigger
oc set triggers bc/nodejs-git-app --from-config
Configure build strategy options:
# View build strategy
oc get bc nodejs-git-app -o jsonpath='{.spec.strategy}'
Set environment variables for builds:
oc set env bc/nodejs-git-app NODE_ENV=production
Subtask 2.6: Monitor and Manage Deployments
View deployment history:
oc rollout history dc/nodejs-git-app
Check deployment status:
oc rollout status dc/nodejs-git-app
View build history:
oc get builds --sort-by=.metadata.creationTimestamp
Clean up old builds (keep last 3):
oc get builds --sort-by=.metadata.creationTimestamp | head -n -3 | awk '{print $1}' | xargs -r oc delete build
Advanced Configuration
Setting Up Branch-Specific Deployments
Create a development branch:
cd /home/student/nodejs-ex
git checkout -b development
echo "console.log('Development mode enabled');" >> server.js
git add server.js
git commit -m "Add development logging"
git push origin development
Create a separate application for the development branch:
oc new-app nodejs~file:///opt/git-repos/nodejs-app.git#development --name=nodejs-git-app-dev
Configuring Build Resources
Set build resource limits:
oc patch bc nodejs-git-app -p '{"spec":{"resources":{"limits":{"cpu":"500m","memory":"512Mi"}}}}'
Configure build timeout:
oc patch bc nodejs-git-app -p '{"spec":{"completionDeadlineSeconds":1800}}'
Troubleshooting Common Issues
Build Failures
Check build logs for errors:
oc logs bc/nodejs-git-app
Verify Git repository accessibility:
git ls-remote file:///opt/git-repos/nodejs-app.git
Check build configuration:
oc describe bc nodejs-git-app
Deployment Issues
Check pod status and logs:
oc get pods
oc logs deployment/nodejs-git-app
Verify service and route configuration:
oc get svc,routes
Check resource quotas:
oc describe quota
Webhook Problems
Test webhook manually:
curl -X POST -k "$WEBHOOK_URL"
Check build trigger configuration:
oc get bc nodejs-git-app -o yaml | grep -A 20 triggers
Lab Cleanup
To clean up the resources created in this lab:

# Delete the project (removes all resources)
oc delete project git-deployment-lab

# Clean up local Git repository
rm -rf /home/student/nodejs-ex
rm -rf /opt/git-repos/nodejs-app.git
Conclusion
In this lab, you have successfully:

Linked a Git repository to OpenShift: You learned how to deploy applications directly from Git repositories using the oc new-app command with Git sources
Configured automatic deployments: You set up webhook-triggered builds that automatically deploy your application when code changes are pushed to the repository
Implemented CI/CD practices: You experienced how OpenShift's source-to-image (S2I) process enables continuous integration and deployment workflows
Managed build and deployment lifecycle: You learned to monitor builds, manage deployment history, and troubleshoot common issues
Key Takeaways
Why Git-based deployments matter:

Developer Productivity: Developers can deploy applications simply by pushing code changes
Automation: Reduces manual deployment steps and human errors
Traceability: Every deployment is tied to a specific Git commit, providing clear audit trails
Rollback Capability: Easy to revert to previous versions using Git history
Real-world Applications:

Microservices Architecture: Each service can be deployed independently from its own Git repository
Multi-environment Deployments: Different branches can be deployed to different environments (dev, staging, production)
Team Collaboration: Multiple developers can contribute to the same application with automatic deployments
This knowledge is essential for the Red Hat Certified OpenShift Application Developer exam and provides practical skills for modern DevOps practices in enterprise environments.
