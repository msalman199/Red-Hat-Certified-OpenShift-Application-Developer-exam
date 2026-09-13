Lab 14: Automating Deployments with OpenShift Templates
Objectives
By the end of this lab, you will be able to:

Understand the concept and benefits of OpenShift Templates
Create reusable OpenShift Templates for application deployments
Customize templates with parameters for different environments
Deploy applications using templates across development, staging, and production environments
Manage template parameters and environment-specific configurations
Implement best practices for template-based deployments
Prerequisites
Before starting this lab, you should have:

Basic understanding of OpenShift concepts (pods, services, deployments)
Familiarity with YAML syntax and Kubernetes resources
Experience with command-line interface operations
Knowledge of containerized applications and Docker concepts
Understanding of environment-based deployment strategies
Lab Environment Setup
Ready-to-Use Cloud Machines: Al Nafi provides Linux-based cloud machines with OpenShift pre-installed. Simply click Start Lab to access your environment - no need to build your own VM or install OpenShift locally.

Your lab environment includes:

OpenShift cluster with administrative access
Pre-configured oc command-line tool
Sample application source code
All necessary development tools
Task 1: Understanding OpenShift Templates
Subtask 1.1: Explore Existing Templates
First, let's examine the templates already available in your OpenShift cluster.

Login to OpenShift cluster:
oc login -u developer -p developer
List available templates in the openshift namespace:
oc get templates -n openshift
Examine a specific template structure:
oc get template nodejs-mongodb-example -n openshift -o yaml
Create a new project for our lab:
oc new-project template-lab-dev
Subtask 1.2: Understand Template Components
Templates consist of several key components:

Parameters: Variables that can be customized during deployment
Objects: Kubernetes/OpenShift resources to be created
Labels: Metadata for organizing and selecting resources
Annotations: Additional metadata for documentation
Task 2: Create OpenShift Templates for Reusable Deployment Configurations
Subtask 2.1: Create a Basic Web Application Template
Let's create a template for a simple web application that can be reused across different environments.

Create the template directory structure:
mkdir -p ~/templates
cd ~/templates
Create a basic web application template:
cat > web-app-template.yaml << 'EOF'
apiVersion: template.openshift.io/v1
kind: Template
metadata:
  name: web-app-template
  annotations:
    description: "Template for deploying a web application with configurable parameters"
    tags: "web,application,template"
    iconClass: "icon-nodejs"
labels:
  template: web-app-template
objects:
- apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: ${APP_NAME}
    labels:
      app: ${APP_NAME}
      environment: ${ENVIRONMENT}
  spec:
    replicas: ${{REPLICA_COUNT}}
    selector:
      matchLabels:
        app: ${APP_NAME}
    template:
      metadata:
        labels:
          app: ${APP_NAME}
          environment: ${ENVIRONMENT}
      spec:
        containers:
        - name: ${APP_NAME}
          image: ${IMAGE_NAME}:${IMAGE_TAG}
          ports:
          - containerPort: ${{CONTAINER_PORT}}
          env:
          - name: ENVIRONMENT
            value: ${ENVIRONMENT}
          - name: DATABASE_URL
            value: ${DATABASE_URL}
          resources:
            requests:
              memory: ${MEMORY_REQUEST}
              cpu: ${CPU_REQUEST}
            limits:
              memory: ${MEMORY_LIMIT}
              cpu: ${CPU_LIMIT}
- apiVersion: v1
  kind: Service
  metadata:
    name: ${APP_NAME}-service
    labels:
      app: ${APP_NAME}
      environment: ${ENVIRONMENT}
  spec:
    selector:
      app: ${APP_NAME}
    ports:
    - port: ${{SERVICE_PORT}}
      targetPort: ${{CONTAINER_PORT}}
      protocol: TCP
- apiVersion: route.openshift.io/v1
  kind: Route
  metadata:
    name: ${APP_NAME}-route
    labels:
      app: ${APP_NAME}
      environment: ${ENVIRONMENT}
  spec:
    to:
      kind: Service
      name: ${APP_NAME}-service
    port:
      targetPort: ${{CONTAINER_PORT}}
parameters:
- name: APP_NAME
  description: "Name of the application"
  value: "my-web-app"
  required: true
- name: ENVIRONMENT
  description: "Deployment environment"
  value: "development"
  required: true
- name: IMAGE_NAME
  description: "Container image name"
  value: "nginx"
  required: true
- name: IMAGE_TAG
  description: "Container image tag"
  value: "latest"
  required: true
- name: REPLICA_COUNT
  description: "Number of replicas"
  value: "1"
  required: true
- name: CONTAINER_PORT
  description: "Container port"
  value: "8080"
  required: true
- name: SERVICE_PORT
  description: "Service port"
  value: "80"
  required: true
- name: DATABASE_URL
  description: "Database connection URL"
  value: "postgresql://localhost:5432/mydb"
  required: false
- name: MEMORY_REQUEST
  description: "Memory request"
  value: "128Mi"
  required: true
- name: MEMORY_LIMIT
  description: "Memory limit"
  value: "256Mi"
  required: true
- name: CPU_REQUEST
  description: "CPU request"
  value: "100m"
  required: true
- name: CPU_LIMIT
  description: "CPU limit"
  value: "200m"
  required: true
EOF
Load the template into OpenShift:
oc create -f web-app-template.yaml
Verify the template was created:
oc get templates
Subtask 2.2: Create a Database Template
Now let's create a template for a database that our web application can use.

Create a PostgreSQL database template:
cat > database-template.yaml << 'EOF'
apiVersion: template.openshift.io/v1
kind: Template
metadata:
  name: postgresql-template
  annotations:
    description: "Template for deploying PostgreSQL database"
    tags: "database,postgresql,template"
    iconClass: "icon-postgresql"
labels:
  template: postgresql-template
objects:
- apiVersion: v1
  kind: Secret
  metadata:
    name: ${DATABASE_NAME}-secret
    labels:
      app: ${DATABASE_NAME}
      environment: ${ENVIRONMENT}
  stringData:
    database-user: ${POSTGRESQL_USER}
    database-password: ${POSTGRESQL_PASSWORD}
    database-name: ${POSTGRESQL_DATABASE}
- apiVersion: v1
  kind: PersistentVolumeClaim
  metadata:
    name: ${DATABASE_NAME}-pvc
    labels:
      app: ${DATABASE_NAME}
      environment: ${ENVIRONMENT}
  spec:
    accessModes:
    - ReadWriteOnce
    resources:
      requests:
        storage: ${VOLUME_CAPACITY}
- apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: ${DATABASE_NAME}
    labels:
      app: ${DATABASE_NAME}
      environment: ${ENVIRONMENT}
  spec:
    replicas: 1
    selector:
      matchLabels:
        app: ${DATABASE_NAME}
    template:
      metadata:
        labels:
          app: ${DATABASE_NAME}
          environment: ${ENVIRONMENT}
      spec:
        containers:
        - name: postgresql
          image: ${POSTGRESQL_IMAGE}:${POSTGRESQL_VERSION}
          ports:
          - containerPort: 5432
          env:
          - name: POSTGRESQL_USER
            valueFrom:
              secretKeyRef:
                name: ${DATABASE_NAME}-secret
                key: database-user
          - name: POSTGRESQL_PASSWORD
            valueFrom:
              secretKeyRef:
                name: ${DATABASE_NAME}-secret
                key: database-password
          - name: POSTGRESQL_DATABASE
            valueFrom:
              secretKeyRef:
                name: ${DATABASE_NAME}-secret
                key: database-name
          volumeMounts:
          - name: postgresql-data
            mountPath: /var/lib/pgsql/data
          resources:
            requests:
              memory: ${MEMORY_REQUEST}
              cpu: ${CPU_REQUEST}
            limits:
              memory: ${MEMORY_LIMIT}
              cpu: ${CPU_LIMIT}
        volumes:
        - name: postgresql-data
          persistentVolumeClaim:
            claimName: ${DATABASE_NAME}-pvc
- apiVersion: v1
  kind: Service
  metadata:
    name: ${DATABASE_NAME}-service
    labels:
      app: ${DATABASE_NAME}
      environment: ${ENVIRONMENT}
  spec:
    selector:
      app: ${DATABASE_NAME}
    ports:
    - port: 5432
      targetPort: 5432
      protocol: TCP
parameters:
- name: DATABASE_NAME
  description: "Name of the database application"
  value: "postgresql"
  required: true
- name: ENVIRONMENT
  description: "Deployment environment"
  value: "development"
  required: true
- name: POSTGRESQL_IMAGE
  description: "PostgreSQL container image"
  value: "registry.redhat.io/rhel8/postgresql-13"
  required: true
- name: POSTGRESQL_VERSION
  description: "PostgreSQL version tag"
  value: "latest"
  required: true
- name: POSTGRESQL_USER
  description: "PostgreSQL user name"
  generate: expression
  from: "user[A-Z0-9]{3}"
  required: true
- name: POSTGRESQL_PASSWORD
  description: "PostgreSQL password"
  generate: expression
  from: "[a-zA-Z0-9]{16}"
  required: true
- name: POSTGRESQL_DATABASE
  description: "PostgreSQL database name"
  value: "sampledb"
  required: true
- name: VOLUME_CAPACITY
  description: "Volume space available for data"
  value: "1Gi"
  required: true
- name: MEMORY_REQUEST
  description: "Memory request"
  value: "256Mi"
  required: true
- name: MEMORY_LIMIT
  description: "Memory limit"
  value: "512Mi"
  required: true
- name: CPU_REQUEST
  description: "CPU request"
  value: "200m"
  required: true
- name: CPU_LIMIT
  description: "CPU limit"
  value: "500m"
  required: true
EOF
Load the database template:
oc create -f database-template.yaml
Verify both templates are available:
oc get templates
Task 3: Customize Templates for Different Environments
Subtask 3.1: Create Environment-Specific Parameter Files
Let's create parameter files for different environments to customize our template deployments.

Create development environment parameters:
cat > dev-params.env << 'EOF'
APP_NAME=webapp-dev
ENVIRONMENT=development
IMAGE_NAME=nginx
IMAGE_TAG=1.21-alpine
REPLICA_COUNT=1
CONTAINER_PORT=80
SERVICE_PORT=80
DATABASE_URL=postgresql://postgresql-service:5432/sampledb
MEMORY_REQUEST=128Mi
MEMORY_LIMIT=256Mi
CPU_REQUEST=100m
CPU_LIMIT=200m
EOF
Create staging environment parameters:
cat > staging-params.env << 'EOF'
APP_NAME=webapp-staging
ENVIRONMENT=staging
IMAGE_NAME=nginx
IMAGE_TAG=1.21-alpine
REPLICA_COUNT=2
CONTAINER_PORT=80
SERVICE_PORT=80
DATABASE_URL=postgresql://postgresql-service:5432/sampledb
MEMORY_REQUEST=256Mi
MEMORY_LIMIT=512Mi
CPU_REQUEST=200m
CPU_LIMIT=400m
EOF
Create production environment parameters:
cat > prod-params.env << 'EOF'
APP_NAME=webapp-prod
ENVIRONMENT=production
IMAGE_NAME=nginx
IMAGE_TAG=1.21-alpine
REPLICA_COUNT=3
CONTAINER_PORT=80
SERVICE_PORT=80
DATABASE_URL=postgresql://postgresql-service:5432/sampledb
MEMORY_REQUEST=512Mi
MEMORY_LIMIT=1Gi
CPU_REQUEST=500m
CPU_LIMIT=1000m
EOF
Subtask 3.2: Create Environment-Specific Projects
Create projects for different environments:
oc new-project webapp-dev
oc new-project webapp-staging
oc new-project webapp-prod
Switch to development project:
oc project webapp-dev
Subtask 3.3: Deploy Database Using Template
Deploy PostgreSQL database in development environment:
oc process postgresql-template \
  -p DATABASE_NAME=postgresql-dev \
  -p ENVIRONMENT=development \
  -p POSTGRESQL_DATABASE=devdb \
  -p VOLUME_CAPACITY=2Gi | oc create -f -
Check the deployment status:
oc get pods
oc get services
oc get pvc
Wait for the database to be ready:
oc wait --for=condition=available --timeout=300s deployment/postgresql-dev
Subtask 3.4: Deploy Web Application Using Template with Parameters
Deploy web application in development using parameter file:
oc process web-app-template --param-file=dev-params.env | oc create -f -
Check the deployment:
oc get pods
oc get services
oc get routes
Get the application URL:
oc get route webapp-dev-route -o jsonpath='{.spec.host}'
Subtask 3.5: Deploy to Staging Environment
Switch to staging project:
oc project webapp-staging
Deploy database for staging:
oc process postgresql-template \
  -p DATABASE_NAME=postgresql-staging \
  -p ENVIRONMENT=staging \
  -p POSTGRESQL_DATABASE=stagingdb \
  -p VOLUME_CAPACITY=5Gi \
  -p MEMORY_REQUEST=512Mi \
  -p MEMORY_LIMIT=1Gi | oc create -f -
Deploy web application for staging:
oc process web-app-template --param-file=staging-params.env | oc create -f -
Verify staging deployment:
oc get pods
oc get routes
Subtask 3.6: Deploy to Production Environment
Switch to production project:
oc project webapp-prod
Deploy database for production:
oc process postgresql-template \
  -p DATABASE_NAME=postgresql-prod \
  -p ENVIRONMENT=production \
  -p POSTGRESQL_DATABASE=proddb \
  -p VOLUME_CAPACITY=10Gi \
  -p MEMORY_REQUEST=1Gi \
  -p MEMORY_LIMIT=2Gi \
  -p CPU_REQUEST=500m \
  -p CPU_LIMIT=1000m | oc create -f -
Deploy web application for production:
oc process web-app-template --param-file=prod-params.env | oc create -f -
Verify production deployment:
oc get pods
oc get routes
Task 4: Advanced Template Features
Subtask 4.1: Create Template with Conditional Objects
Let's create an advanced template that includes conditional objects based on environment.

Create an advanced template with conditions:
cat > advanced-web-template.yaml << 'EOF'
apiVersion: template.openshift.io/v1
kind: Template
metadata:
  name: advanced-web-template
  annotations:
    description: "Advanced template with conditional objects"
    tags: "web,application,advanced,template"
objects:
- apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: ${APP_NAME}
    labels:
      app: ${APP_NAME}
      environment: ${ENVIRONMENT}
  spec:
    replicas: ${{REPLICA_COUNT}}
    selector:
      matchLabels:
        app: ${APP_NAME}
    template:
      metadata:
        labels:
          app: ${APP_NAME}
          environment: ${ENVIRONMENT}
      spec:
        containers:
        - name: ${APP_NAME}
          image: ${IMAGE_NAME}:${IMAGE_TAG}
          ports:
          - containerPort: ${{CONTAINER_PORT}}
          env:
          - name: ENVIRONMENT
            value: ${ENVIRONMENT}
          resources:
            requests:
              memory: ${MEMORY_REQUEST}
              cpu: ${CPU_REQUEST}
            limits:
              memory: ${MEMORY_LIMIT}
              cpu: ${CPU_LIMIT}
          livenessProbe:
            httpGet:
              path: /health
              port: ${{CONTAINER_PORT}}
            initialDelaySeconds: 30
            periodSeconds: 10
          readinessProbe:
            httpGet:
              path: /ready
              port: ${{CONTAINER_PORT}}
            initialDelaySeconds: 5
            periodSeconds: 5
- apiVersion: v1
  kind: Service
  metadata:
    name: ${APP_NAME}-service
    labels:
      app: ${APP_NAME}
      environment: ${ENVIRONMENT}
  spec:
    selector:
      app: ${APP_NAME}
    ports:
    - port: ${{SERVICE_PORT}}
      targetPort: ${{CONTAINER_PORT}}
      protocol: TCP
- apiVersion: route.openshift.io/v1
  kind: Route
  metadata:
    name: ${APP_NAME}-route
    labels:
      app: ${APP_NAME}
      environment: ${ENVIRONMENT}
  spec:
    to:
      kind: Service
      name: ${APP_NAME}-service
    port:
      targetPort: ${{CONTAINER_PORT}}
    tls:
      termination: edge
      insecureEdgeTerminationPolicy: Redirect
- apiVersion: autoscaling/v2
  kind: HorizontalPodAutoscaler
  metadata:
    name: ${APP_NAME}-hpa
    labels:
      app: ${APP_NAME}
      environment: ${ENVIRONMENT}
  spec:
    scaleTargetRef:
      apiVersion: apps/v1
      kind: Deployment
      name: ${APP_NAME}
    minReplicas: ${{MIN_REPLICAS}}
    maxReplicas: ${{MAX_REPLICAS}}
    metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: ${{CPU_TARGET_PERCENTAGE}}
parameters:
- name: APP_NAME
  description: "Name of the application"
  required: true
- name: ENVIRONMENT
  description: "Deployment environment"
  value: "development"
  required: true
- name: IMAGE_NAME
  description: "Container image name"
  value: "nginx"
  required: true
- name: IMAGE_TAG
  description: "Container image tag"
  value: "latest"
  required: true
- name: REPLICA_COUNT
  description: "Number of replicas"
  value: "1"
  required: true
- name: MIN_REPLICAS
  description: "Minimum number of replicas for autoscaling"
  value: "1"
  required: true
- name: MAX_REPLICAS
  description: "Maximum number of replicas for autoscaling"
  value: "5"
  required: true
- name: CPU_TARGET_PERCENTAGE
  description: "Target CPU utilization percentage for autoscaling"
  value: "70"
  required: true
- name: CONTAINER_PORT
  description: "Container port"
  value: "8080"
  required: true
- name: SERVICE_PORT
  description: "Service port"
  value: "80"
  required: true
- name: MEMORY_REQUEST
  description: "Memory request"
  value: "128Mi"
  required: true
- name: MEMORY_LIMIT
  description: "Memory limit"
  value: "256Mi"
  required: true
- name: CPU_REQUEST
  description: "CPU request"
  value: "100m"
  required: true
- name: CPU_LIMIT
  description: "CPU limit"
  value: "200m"
  required: true
EOF
Load the advanced template:
oc create -f advanced-web-template.yaml
Subtask 4.2: Test Template Processing Without Deployment
Process template to see generated objects without creating them:
oc process advanced-web-template \
  -p APP_NAME=test-app \
  -p ENVIRONMENT=testing \
  -p REPLICA_COUNT=2 \
  -p MAX_REPLICAS=10
Save processed template to file for review:
oc process advanced-web-template \
  -p APP_NAME=test-app \
  -p ENVIRONMENT=testing \
  -p REPLICA_COUNT=2 \
  -p MAX_REPLICAS=10 > processed-template.yaml
Review the generated objects:
cat processed-template.yaml
Task 5: Template Management and Best Practices
Subtask 5.1: Export and Share Templates
Export a template for sharing:
oc get template web-app-template -o yaml > exported-web-template.yaml
Create a template library directory:
mkdir -p ~/template-library
cp *.yaml ~/template-library/
Create a template catalog:
cat > ~/template-library/README.md << 'EOF'
# Template Library

## Available Templates

### web-app-template
- **Description**: Basic web application template
- **Parameters**: APP_NAME, ENVIRONMENT, IMAGE_NAME, etc.
- **Use Case**: Simple web applications with configurable resources

### postgresql-template
- **Description**: PostgreSQL database template
- **Parameters**: DATABASE_NAME, POSTGRESQL_USER, etc.
- **Use Case**: Database deployments with persistent storage

### advanced-web-template
- **Description**: Advanced web application with autoscaling
- **Parameters**: Includes HPA and health check configurations
- **Use Case**: Production-ready applications with scaling capabilities

## Usage Examples

```bash
# Deploy basic web app
oc process web-app-template -p APP_NAME=myapp | oc create -f -

# Deploy with parameter file
oc process web-app-template --param-file=dev-params.env | oc create -f -
EOF


### Subtask 5.2: Template Validation and Testing

1. **Validate template syntax**:
```bash
oc process web-app-template --dry-run=client -o yaml
Test template with different parameter combinations:
# Test with minimal parameters
oc process web-app-template -p APP_NAME=minimal-test --dry-run=client

# Test with all parameters
oc process web-app-template \
  -p APP_NAME=full-test \
  -p ENVIRONMENT=testing \
  -p IMAGE_NAME=httpd \
  -p IMAGE_TAG=2.4 \
  -p REPLICA_COUNT=3 \
  --dry-run=client
Subtask 5.3: Clean Up Resources
List all resources created from templates:
oc get all -l template=web-app-template
Clean up development environment:
oc project webapp-dev
oc delete all -l app=webapp-dev
oc delete all -l app=postgresql-dev
oc delete pvc -l app=postgresql-dev
oc delete secret -l app=postgresql-dev
Clean up staging environment:
oc project webapp-staging
oc delete all -l environment=staging
oc delete pvc -l environment=staging
oc delete secret -l environment=staging
Clean up production environment:
oc project webapp-prod
oc delete all -l environment=production
oc delete pvc -l environment=production
oc delete secret -l environment=production
Troubleshooting Common Issues
Template Processing Issues
Problem: Template parameters not being substituted correctly Solution:

Verify parameter names match exactly (case-sensitive)
Check for proper parameter syntax: ${PARAM_NAME} for strings, ${{PARAM_NAME}} for integers
Use oc process --dry-run to test parameter substitution
Problem: Template objects failing to create Solution:

Validate YAML syntax using oc process template-name --dry-run
Check resource quotas and limits in the target project
Verify image names and tags are accessible
Deployment Issues
Problem: Pods not starting after template deployment Solution:

Check pod logs: oc logs pod-name
Verify resource requests don't exceed project limits
Ensure container images are available and correct
Problem: Services not accessible Solution:

Verify service selectors match pod labels
Check if routes are created and configured correctly
Confirm firewall and network policies allow traffic
Conclusion
In this lab, you have successfully learned how to automate deployments using OpenShift Templates. You accomplished the following key tasks:

What You Learned:

Created reusable OpenShift Templates for both web applications and databases
Customized templates using parameters for different environments (development, staging, production)
Implemented environment-specific configurations using parameter files
Deployed applications consistently across multiple environments using templates
Applied advanced template features including autoscaling and health checks
Established best practices for template management and validation
Why This Matters: OpenShift Templates provide a powerful way to standardize and automate application deployments across different environments. By using templates, you can:

Ensure Consistency: Deploy identical application stacks across environments with environment-specific customizations
Reduce Errors: Eliminate manual configuration mistakes through parameterized templates
Save Time: Quickly deploy complex applications with a single command
Improve Maintainability: Centrally manage deployment configurations and easily update them
Enable Self-Service: Allow developers to deploy applications without deep OpenShift knowledge
Real-World Applications:

CI/CD Pipelines: Integrate templates into automated deployment pipelines
Multi-Environment Management: Maintain consistent deployments across dev, test, and production
Application Catalogs: Create service catalogs for developers to self-serve common application patterns
Disaster Recovery: Quickly recreate entire application stacks in new environments
The skills you've developed in this lab are essential for the Red Hat Certified OpenShift Application Developer exam and will serve you well in production OpenShift environments where consistent, automated deployments are critical for operational success.
