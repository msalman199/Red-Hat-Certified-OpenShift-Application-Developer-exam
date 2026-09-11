Lab 5: ConfigMaps and Secrets for Configuration
Objectives
By the end of this lab, you will be able to:

Create and manage ConfigMaps for application configuration data
Store and manage sensitive information using OpenShift Secrets
Inject ConfigMaps and Secrets into containers as environment variables and mounted volumes
Understand the differences between ConfigMaps and Secrets
Apply configuration management best practices in OpenShift applications
Prerequisites
Before starting this lab, you should have:

Basic understanding of OpenShift/Kubernetes concepts
Familiarity with YAML syntax
Knowledge of container fundamentals
Experience with command-line interfaces
Completion of previous OpenShift labs or equivalent knowledge
Lab Environment
Ready-to-Use Cloud Machines: Al Nafi provides Linux-based cloud machines with OpenShift pre-installed. Simply click Start Lab to access your environment - no need to build your own VM or install software.

Your lab environment includes:

OpenShift cluster with CLI access
Pre-configured user account with appropriate permissions
Sample applications for testing
Task 1: Create ConfigMaps for Application Configuration
Subtask 1.1: Understanding ConfigMaps
ConfigMaps are Kubernetes objects that store non-confidential configuration data in key-value pairs. They help separate configuration from application code, making applications more portable and easier to manage.

Subtask 1.2: Create a Simple ConfigMap
First, let's create a basic ConfigMap using the command line:

# Create a ConfigMap with literal values
oc create configmap app-config \
  --from-literal=database_host=mysql.example.com \
  --from-literal=database_port=3306 \
  --from-literal=app_mode=production \
  --from-literal=log_level=info
Verify the ConfigMap was created:

# List ConfigMaps
oc get configmaps

# View the ConfigMap details
oc describe configmap app-config
Subtask 1.3: Create ConfigMap from File
Create a configuration file for a web application:

# Create a configuration file
cat > app.properties << EOF
# Application Configuration
server.port=8080
server.host=0.0.0.0
database.url=jdbc:mysql://mysql:3306/myapp
database.pool.size=10
cache.enabled=true
cache.ttl=3600
logging.level=INFO
feature.new_ui=true
EOF
Create a ConfigMap from this file:

# Create ConfigMap from file
oc create configmap app-properties --from-file=app.properties

# View the ConfigMap content
oc get configmap app-properties -o yaml
Subtask 1.4: Create ConfigMap Using YAML Manifest
Create a more complex ConfigMap using a YAML file:

cat > nginx-config.yaml << EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
  labels:
    app: web-server
data:
  nginx.conf: |
    server {
        listen 80;
        server_name localhost;
        
        location / {
            root /usr/share/nginx/html;
            index index.html index.htm;
        }
        
        location /api {
            proxy_pass http://backend-service:8080;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
        }
        
        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
            root /usr/share/nginx/html;
        }
    }
  index.html: |
    <!DOCTYPE html>
    <html>
    <head>
        <title>Welcome to OpenShift</title>
    </head>
    <body>
        <h1>Hello from ConfigMap!</h1>
        <p>This content is served from a ConfigMap.</p>
    </body>
    </html>
EOF
Apply the ConfigMap:

# Create the ConfigMap
oc apply -f nginx-config.yaml

# Verify creation
oc get configmap nginx-config -o yaml
Task 2: Store Sensitive Data in OpenShift Secrets
Subtask 2.1: Understanding Secrets
Secrets are similar to ConfigMaps but are specifically designed to hold sensitive information such as passwords, OAuth tokens, SSH keys, and TLS certificates. Data in Secrets is base64 encoded.

Subtask 2.2: Create Generic Secrets
Create a Secret with database credentials:

# Create a Secret with literal values
oc create secret generic database-credentials \
  --from-literal=username=dbuser \
  --from-literal=password=mySecurePassword123 \
  --from-literal=root-password=rootPassword456
Verify the Secret:

# List Secrets
oc get secrets

# View Secret details (note that values are base64 encoded)
oc describe secret database-credentials

# View the actual Secret content
oc get secret database-credentials -o yaml
Subtask 2.3: Create Secret from Files
Create certificate files for demonstration:

# Create a mock certificate and key
mkdir -p certs
cat > certs/tls.crt << EOF
-----BEGIN CERTIFICATE-----
MIICljCCAX4CCQDAOxKQlRlmBzANBgkqhkiG9w0BAQsFADCBjTELMAkGA1UEBhMC
VVMxCzAJBgNVBAgMAkNBMRYwFAYDVQQHDA1TYW4gRnJhbmNpc2NvMRMwEQYDVQQK
DApNeUNvbXBhbnkxEzARBgNVBAsMCk15RGl2aXNpb24xKTAnBgNVBAMMIGV4YW1w
bGUuY29tIChTZWxmLVNpZ25lZCBDZXJ0aWZpY2F0ZSkwHhcNMjMwMTAxMDAwMDAw
WhcNMjQwMTAxMDAwMDAwWjCBjTELMAkGA1UEBhMCVVMxCzAJBgNVBAgMAkNBMRYw
FAYDVQQHDA1TYW4gRnJhbmNpc2NvMRMwEQYDVQQKDApNeUNvbXBhbnkxEzARBgNV
BAsMCk15RGl2aXNpb24xKTAnBgNVBAMMIGV4YW1wbGUuY29tIChTZWxmLVNpZ25l
ZCBDZXJ0aWZpY2F0ZSkwXDANBgkqhkiG9w0BAQEFAAOCAQkAMIIBBAKCAQEA
-----END CERTIFICATE-----
EOF

cat > certs/tls.key << EOF
-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDAOxKQlRlmBzAN
BgkqhkiG9w0BAQsFADCBjTELMAkGA1UEBhMCVVMxCzAJBgNVBAgMAkNBMRYwFAYD
VQQHDA1TYW4gRnJhbmNpc2NvMRMwEQYDVQQKDApNeUNvbXBhbnkxEzARBgNVBAsM
Ck15RGl2aXNpb24xKTAnBgNVBAMMIGV4YW1wbGUuY29tIChTZWxmLVNpZ25lZCBD
ZXJ0aWZpY2F0ZSkwHhcNMjMwMTAxMDAwMDAwWhcNMjQwMTAxMDAwMDAwWjCBjTEL
MAkGA1UEBhMCVVMxCzAJBgNVBAgMAkNBMRYwFAYDVQQHDA1TYW4gRnJhbmNpc2Nv
-----END PRIVATE KEY-----
EOF
Create a TLS Secret from the certificate files:

# Create TLS Secret from files
oc create secret tls web-tls-secret \
  --cert=certs/tls.crt \
  --key=certs/tls.key

# Verify the TLS Secret
oc describe secret web-tls-secret
Subtask 2.4: Create Secret Using YAML Manifest
Create an API key Secret using YAML:

cat > api-secrets.yaml << EOF
apiVersion: v1
kind: Secret
metadata:
  name: api-keys
  labels:
    app: web-app
type: Opaque
data:
  # Base64 encoded values
  # Original: api-key-123456789
  api-key: YXBpLWtleS0xMjM0NTY3ODk=
  # Original: webhook-secret-abc
  webhook-secret: d2ViaG9vay1zZWNyZXQtYWJj
  # Original: jwt-signing-key-xyz
  jwt-secret: and0LXNpZ25pbmcta2V5LXh5eg==
EOF
Apply the Secret:

# Create the Secret
oc apply -f api-secrets.yaml

# Verify creation
oc get secret api-keys -o yaml
Task 3: Inject ConfigMaps and Secrets into Containers
Subtask 3.1: Create a Test Application
First, create a simple application that will use our ConfigMaps and Secrets:

cat > test-app-deployment.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: config-test-app
  labels:
    app: config-test
spec:
  replicas: 1
  selector:
    matchLabels:
      app: config-test
  template:
    metadata:
      labels:
        app: config-test
    spec:
      containers:
      - name: app-container
        image: registry.access.redhat.com/ubi8/ubi:latest
        command: ["/bin/bash"]
        args: ["-c", "while true; do echo 'App running...'; sleep 30; done"]
        env:
        # Environment variables from ConfigMap
        - name: DATABASE_HOST
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: database_host
        - name: DATABASE_PORT
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: database_port
        - name: APP_MODE
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: app_mode
        # Environment variables from Secret
        - name: DB_USERNAME
          valueFrom:
            secretKeyRef:
              name: database-credentials
              key: username
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: database-credentials
              key: password
        - name: API_KEY
          valueFrom:
            secretKeyRef:
              name: api-keys
              key: api-key
        volumeMounts:
        # Mount ConfigMap as volume
        - name: app-properties-volume
          mountPath: /etc/config
          readOnly: true
        # Mount Secret as volume
        - name: tls-certs-volume
          mountPath: /etc/ssl/certs
          readOnly: true
      volumes:
      # ConfigMap volume
      - name: app-properties-volume
        configMap:
          name: app-properties
      # Secret volume
      - name: tls-certs-volume
        secret:
          secretName: web-tls-secret
EOF
Deploy the application:

# Deploy the test application
oc apply -f test-app-deployment.yaml

# Wait for the pod to be ready
oc get pods -l app=config-test

# Check pod status
oc describe pod -l app=config-test
Subtask 3.2: Verify Environment Variable Injection
Test that environment variables from ConfigMaps and Secrets are properly injected:

# Get the pod name
POD_NAME=$(oc get pods -l app=config-test -o jsonpath='{.items[0].metadata.name}')

# Check environment variables
oc exec $POD_NAME -- env | grep -E "(DATABASE_|APP_MODE|DB_|API_KEY)"

# Verify specific values
echo "Checking ConfigMap environment variables:"
oc exec $POD_NAME -- bash -c 'echo "Database Host: $DATABASE_HOST"'
oc exec $POD_NAME -- bash -c 'echo "Database Port: $DATABASE_PORT"'
oc exec $POD_NAME -- bash -c 'echo "App Mode: $APP_MODE"'

echo "Checking Secret environment variables:"
oc exec $POD_NAME -- bash -c 'echo "DB Username: $DB_USERNAME"'
oc exec $POD_NAME -- bash -c 'echo "API Key: $API_KEY"'
Subtask 3.3: Verify Volume Mount Injection
Check that ConfigMaps and Secrets are properly mounted as volumes:

# Check mounted ConfigMap files
echo "ConfigMap files in /etc/config:"
oc exec $POD_NAME -- ls -la /etc/config/

# View ConfigMap file content
echo "Content of app.properties:"
oc exec $POD_NAME -- cat /etc/config/app.properties

# Check mounted Secret files
echo "Secret files in /etc/ssl/certs:"
oc exec $POD_NAME -- ls -la /etc/ssl/certs/

# View Secret file (certificate)
echo "TLS Certificate:"
oc exec $POD_NAME -- head -5 /etc/ssl/certs/tls.crt
Subtask 3.4: Advanced Configuration with envFrom
Create a deployment that uses envFrom to inject all ConfigMap and Secret values:

cat > advanced-config-app.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: advanced-config-app
  labels:
    app: advanced-config
spec:
  replicas: 1
  selector:
    matchLabels:
      app: advanced-config
  template:
    metadata:
      labels:
        app: advanced-config
    spec:
      containers:
      - name: app-container
        image: registry.access.redhat.com/ubi8/ubi:latest
        command: ["/bin/bash"]
        args: ["-c", "while true; do echo 'Advanced app running...'; sleep 30; done"]
        envFrom:
        # Import all keys from ConfigMap as environment variables
        - configMapRef:
            name: app-config
        # Import all keys from Secret as environment variables
        - secretRef:
            name: database-credentials
        env:
        # Override or add specific environment variables
        - name: CUSTOM_MESSAGE
          value: "Hello from Advanced Config App"
EOF
Deploy the advanced configuration app:

# Deploy the advanced app
oc apply -f advanced-config-app.yaml

# Wait for pod to be ready
oc get pods -l app=advanced-config

# Get the pod name
ADVANCED_POD=$(oc get pods -l app=advanced-config -o jsonpath='{.items[0].metadata.name}')

# Check all environment variables
echo "All environment variables from ConfigMap and Secret:"
oc exec $ADVANCED_POD -- env | sort
Subtask 3.5: Update ConfigMaps and Secrets
Demonstrate how to update configuration:

# Update the ConfigMap
oc patch configmap app-config -p '{"data":{"log_level":"debug","app_mode":"development"}}'

# Update the Secret
oc patch secret database-credentials -p '{"data":{"username":"'$(echo -n "newdbuser" | base64)'"}}'

# Verify updates
echo "Updated ConfigMap:"
oc get configmap app-config -o yaml | grep -A 10 "data:"

echo "Updated Secret:"
oc get secret database-credentials -o yaml | grep -A 10 "data:"
Restart the deployment to pick up changes:

# Restart the deployment to pick up new configuration
oc rollout restart deployment/config-test-app
oc rollout restart deployment/advanced-config-app

# Wait for rollout to complete
oc rollout status deployment/config-test-app
oc rollout status deployment/advanced-config-app

# Verify new configuration is loaded
NEW_POD=$(oc get pods -l app=config-test -o jsonpath='{.items[0].metadata.name}')
oc exec $NEW_POD -- bash -c 'echo "Updated App Mode: $APP_MODE"'
oc exec $NEW_POD -- bash -c 'echo "Updated Log Level: $LOG_LEVEL"'
Troubleshooting Tips
Common Issues and Solutions
Issue 1: ConfigMap or Secret not found

# Check if the ConfigMap/Secret exists
oc get configmaps
oc get secrets

# Check the correct namespace
oc get configmaps -n <namespace>
Issue 2: Environment variables not appearing in container

# Check pod events for errors
oc describe pod <pod-name>

# Verify the ConfigMap/Secret key names match
oc describe configmap <configmap-name>
oc describe secret <secret-name>
Issue 3: Volume mount failures

# Check pod logs
oc logs <pod-name>

# Verify volume mount paths don't conflict
oc describe pod <pod-name>
Issue 4: Base64 encoding issues with Secrets

# Properly encode values for Secrets
echo -n "your-secret-value" | base64

# Decode to verify
echo "encoded-value" | base64 -d
Best Practices
Separation of Concerns: Use ConfigMaps for non-sensitive configuration and Secrets for sensitive data
Naming Conventions: Use descriptive names for ConfigMaps and Secrets
Version Control: Store ConfigMap and Secret YAML files in version control (excluding sensitive values)
Environment-Specific: Create separate ConfigMaps/Secrets for different environments
Minimal Permissions: Grant only necessary permissions to access Secrets
Regular Updates: Implement a process for updating and rotating secrets
Monitoring: Monitor for configuration changes and their impact on applications
Cleanup
Remove all resources created in this lab:

# Delete deployments
oc delete deployment config-test-app advanced-config-app

# Delete ConfigMaps
oc delete configmap app-config app-properties nginx-config

# Delete Secrets
oc delete secret database-credentials web-tls-secret api-keys

# Remove local files
rm -f app.properties nginx-config.yaml api-secrets.yaml
rm -f test-app-deployment.yaml advanced-config-app.yaml
rm -rf certs/
Conclusion
In this lab, you have successfully learned how to manage configuration data and secrets in OpenShift. You accomplished the following key tasks:

What You Learned:

Created ConfigMaps using multiple methods (command line, from files, and YAML manifests)
Stored sensitive information securely using OpenShift Secrets
Injected configuration data into containers as environment variables and mounted volumes
Updated configuration dynamically and restarted applications to pick up changes
Applied best practices for configuration management
Why This Matters: Configuration management is crucial for building scalable, maintainable applications. By separating configuration from code, you can:

Deploy the same application across different environments
Update configuration without rebuilding container images
Maintain security by properly handling sensitive data
Enable easier troubleshooting and debugging
Follow cloud-native best practices
These skills are essential for the Red Hat Certified OpenShift Application Developer exam and for real-world application development in OpenShift environments. The ability to properly manage configuration and secrets is fundamental to building production-ready applications that are secure, scalable, and maintainable.
