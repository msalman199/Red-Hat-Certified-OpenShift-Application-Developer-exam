Lab 16: Configuring Network Policies
Objectives
By the end of this lab, you will be able to:

Understand the fundamentals of Kubernetes Network Policies
Implement network policies to secure pod-to-pod communication
Configure ingress policies to control incoming traffic to pods
Configure egress policies to control outgoing traffic from pods
Test and validate network policy configurations using sample applications
Troubleshoot common network policy issues
Prerequisites
Before starting this lab, you should have:

Basic understanding of Kubernetes concepts (pods, services, namespaces)
Familiarity with YAML syntax and Kubernetes manifests
Basic knowledge of networking concepts (IP addresses, ports, protocols)
Experience with kubectl command-line tool
Understanding of Linux command line operations
Lab Environment Setup
Ready-to-Use Cloud Machines: Al Nafi provides Linux-based cloud machines with Kubernetes pre-installed. Simply click Start Lab to begin - no need to build your own VM or install additional software.

Your lab environment includes:

Kubernetes cluster with network policy support enabled
kubectl configured and ready to use
Text editor (nano/vim) for creating YAML files
All necessary networking components pre-configured
Task 1: Understanding and Defining Network Policies
Subtask 1.1: Verify Network Policy Support
First, let's verify that your Kubernetes cluster supports Network Policies.

Check if your cluster has a network plugin that supports Network Policies:
kubectl get nodes -o wide
Verify that the network plugin supports Network Policies by checking for existing policies:
kubectl get networkpolicies --all-namespaces
Create a dedicated namespace for this lab:
kubectl create namespace netpol-lab
Set the namespace as your default context:
kubectl config set-context --current --namespace=netpol-lab
Subtask 1.2: Deploy Sample Applications
Let's create sample applications that we'll use to test our network policies.

Create a frontend application deployment:
cat << EOF > frontend-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: netpol-lab
  labels:
    app: frontend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
        tier: frontend
    spec:
      containers:
      - name: frontend
        image: nginx:1.21
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
  namespace: netpol-lab
spec:
  selector:
    app: frontend
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
EOF
Apply the frontend deployment:
kubectl apply -f frontend-deployment.yaml
Create a backend application deployment:
cat << EOF > backend-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: netpol-lab
  labels:
    app: backend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
        tier: backend
    spec:
      containers:
      - name: backend
        image: nginx:1.21
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: backend-service
  namespace: netpol-lab
spec:
  selector:
    app: backend
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
EOF
Apply the backend deployment:
kubectl apply -f backend-deployment.yaml
Create a database simulation deployment:
cat << EOF > database-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: database
  namespace: netpol-lab
  labels:
    app: database
spec:
  replicas: 1
  selector:
    matchLabels:
      app: database
  template:
    metadata:
      labels:
        app: database
        tier: database
    spec:
      containers:
      - name: database
        image: nginx:1.21
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: database-service
  namespace: netpol-lab
spec:
  selector:
    app: database
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
EOF
Apply the database deployment:
kubectl apply -f database-deployment.yaml
Verify all pods are running:
kubectl get pods -o wide
Subtask 1.3: Test Initial Connectivity
Before applying network policies, let's test the current connectivity between pods.

Get the IP addresses of your pods:
kubectl get pods -o wide
Create a test pod to check connectivity:
kubectl run test-pod --image=busybox --rm -it --restart=Never -- sh
From inside the test pod, test connectivity to each service:
# Test frontend service
wget -qO- --timeout=2 frontend-service

# Test backend service  
wget -qO- --timeout=2 backend-service

# Test database service
wget -qO- --timeout=2 database-service

# Exit the test pod
exit
Note: All connections should succeed at this point since no network policies are applied.

Task 2: Configuring Ingress and Egress Policies
Subtask 2.1: Create a Default Deny-All Policy
Let's start by creating a default deny-all policy to secure our namespace.

Create a default deny-all ingress policy:
cat << EOF > default-deny-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: netpol-lab
spec:
  podSelector: {}
  policyTypes:
  - Ingress
EOF
Apply the default deny policy:
kubectl apply -f default-deny-ingress.yaml
Test connectivity after applying the deny-all policy:
kubectl run test-pod --image=busybox --rm -it --restart=Never -- sh
From inside the test pod, try to connect to services:
# These should now fail or timeout
wget -qO- --timeout=2 frontend-service
wget -qO- --timeout=2 backend-service
wget -qO- --timeout=2 database-service
exit
Subtask 2.2: Configure Ingress Policies
Now let's create specific ingress policies to allow controlled access.

Create a policy to allow frontend to receive traffic from anywhere:
cat << EOF > frontend-ingress-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: frontend-ingress
  namespace: netpol-lab
spec:
  podSelector:
    matchLabels:
      app: frontend
  policyTypes:
  - Ingress
  ingress:
  - from: []
    ports:
    - protocol: TCP
      port: 80
EOF
Apply the frontend ingress policy:
kubectl apply -f frontend-ingress-policy.yaml
Create a policy to allow backend to receive traffic only from frontend:
cat << EOF > backend-ingress-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-ingress
  namespace: netpol-lab
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 80
EOF
Apply the backend ingress policy:
kubectl apply -f backend-ingress-policy.yaml
Create a policy to allow database to receive traffic only from backend:
cat << EOF > database-ingress-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: database-ingress
  namespace: netpol-lab
spec:
  podSelector:
    matchLabels:
      app: database
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: backend
    ports:
    - protocol: TCP
      port: 80
EOF
Apply the database ingress policy:
kubectl apply -f database-ingress-policy.yaml
Subtask 2.3: Configure Egress Policies
Now let's add egress policies to control outbound traffic.

Create an egress policy for frontend pods:
cat << EOF > frontend-egress-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: frontend-egress
  namespace: netpol-lab
spec:
  podSelector:
    matchLabels:
      app: frontend
  policyTypes:
  - Egress
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: backend
    ports:
    - protocol: TCP
      port: 80
  - to: []
    ports:
    - protocol: UDP
      port: 53
EOF
Apply the frontend egress policy:
kubectl apply -f frontend-egress-policy.yaml
Create an egress policy for backend pods:
cat << EOF > backend-egress-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-egress
  namespace: netpol-lab
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Egress
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: database
    ports:
    - protocol: TCP
      port: 80
  - to: []
    ports:
    - protocol: UDP
      port: 53
EOF
Apply the backend egress policy:
kubectl apply -f backend-egress-policy.yaml
Create an egress policy for database pods (minimal external access):
cat << EOF > database-egress-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: database-egress
  namespace: netpol-lab
spec:
  podSelector:
    matchLabels:
      app: database
  policyTypes:
  - Egress
  egress:
  - to: []
    ports:
    - protocol: UDP
      port: 53
EOF
Apply the database egress policy:
kubectl apply -f database-egress-policy.yaml
Task 3: Testing Network Policies with Sample Applications
Subtask 3.1: Verify Applied Policies
List all network policies in the namespace:
kubectl get networkpolicies
Describe each policy to understand its configuration:
kubectl describe networkpolicy frontend-ingress
kubectl describe networkpolicy backend-ingress
kubectl describe networkpolicy database-ingress
Subtask 3.2: Test Allowed Connections
Let's test that allowed connections work as expected.

Test direct access to frontend (should work):
kubectl run test-pod --image=busybox --rm -it --restart=Never -- sh
From the test pod:
# This should work - frontend allows ingress from anywhere
wget -qO- --timeout=5 frontend-service
exit
Test frontend to backend communication:
kubectl exec -it deployment/frontend -- sh
From inside the frontend pod:
# This should work - backend allows ingress from frontend
curl -s --connect-timeout 5 backend-service
exit
Test backend to database communication:
kubectl exec -it deployment/backend -- sh
From inside the backend pod:
# This should work - database allows ingress from backend
curl -s --connect-timeout 5 database-service
exit
Subtask 3.3: Test Blocked Connections
Now let's verify that unauthorized connections are blocked.

Test direct access to backend (should fail):
kubectl run test-pod --image=busybox --rm -it --restart=Never -- sh
From the test pod:
# This should fail - backend only allows ingress from frontend
wget -qO- --timeout=5 backend-service
exit
Test direct access to database (should fail):
kubectl run test-pod --image=busybox --rm -it --restart=Never -- sh
From the test pod:
# This should fail - database only allows ingress from backend
wget -qO- --timeout=5 database-service
exit
Test frontend to database direct access (should fail):
kubectl exec -it deployment/frontend -- sh
From inside the frontend pod:
# This should fail - database doesn't allow ingress from frontend
curl -s --connect-timeout 5 database-service
exit
Subtask 3.4: Advanced Policy Testing
Let's create more sophisticated policies to demonstrate advanced features.

Create a policy that allows access based on namespace labels:
# First, create a new namespace with labels
kubectl create namespace allowed-namespace
kubectl label namespace allowed-namespace access=allowed

# Create a policy that allows ingress from labeled namespaces
cat << EOF > namespace-based-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: namespace-based-access
  namespace: netpol-lab
spec:
  podSelector:
    matchLabels:
      app: frontend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          access: allowed
    ports:
    - protocol: TCP
      port: 80
  - from: []
    ports:
    - protocol: TCP
      port: 80
EOF
Apply the namespace-based policy:
kubectl apply -f namespace-based-policy.yaml
Test access from the allowed namespace:
kubectl run test-pod -n allowed-namespace --image=busybox --rm -it --restart=Never -- sh
From the test pod in allowed-namespace:
# This should work due to namespace label
wget -qO- --timeout=5 frontend-service.netpol-lab.svc.cluster.local
exit
Subtask 3.5: Monitor and Troubleshoot Network Policies
Check network policy events:
kubectl get events --field-selector reason=NetworkPolicyViolation
View detailed information about pod network interfaces:
kubectl get pods -o wide
kubectl describe pod <frontend-pod-name>
Use network troubleshooting tools:
# Create a network troubleshooting pod
kubectl run netshoot --image=nicolaka/netshoot --rm -it --restart=Never -- bash
From inside the netshoot pod, perform network diagnostics:
# Test DNS resolution
nslookup frontend-service.netpol-lab.svc.cluster.local

# Test connectivity with detailed output
curl -v --connect-timeout 5 frontend-service.netpol-lab.svc.cluster.local

# Check network routes
ip route

# Exit the troubleshooting pod
exit
Troubleshooting Common Issues
Issue 1: Network Policies Not Taking Effect
Symptoms: Connections that should be blocked are still working.

Solutions:

Verify your cluster supports Network Policies:
kubectl get nodes -o jsonpath='{.items[*].status.nodeInfo.containerRuntimeVersion}'
Check if the network plugin supports policies:
kubectl describe node | grep -i network
Issue 2: DNS Resolution Failing
Symptoms: Pods cannot resolve service names.

Solutions:

Ensure DNS egress is allowed in your policies:
# Add this to your egress rules
- to: []
  ports:
  - protocol: UDP
    port: 53
Issue 3: Policies Too Restrictive
Symptoms: Legitimate traffic is being blocked.

Solutions:

Review policy selectors:
kubectl describe networkpolicy <policy-name>
Check pod labels:
kubectl get pods --show-labels
Cleanup
To clean up the lab environment:

Delete all network policies:
kubectl delete networkpolicies --all -n netpol-lab
Delete the lab namespace:
kubectl delete namespace netpol-lab
kubectl delete namespace allowed-namespace
Reset kubectl context:
kubectl config set-context --current --namespace=default
Conclusion
In this lab, you have successfully:

Implemented Network Policies: You learned how to create and apply Kubernetes Network Policies to control pod-to-pod communication, establishing a foundation for network security in your cluster.

Configured Ingress Policies: You created policies that control incoming traffic to pods, implementing a layered security approach where frontend pods accept traffic from anywhere, backend pods only accept traffic from frontend pods, and database pods only accept traffic from backend pods.

Configured Egress Policies: You established outbound traffic controls, ensuring that pods can only communicate with authorized destinations while maintaining necessary access for DNS resolution.

Tested Policy Effectiveness: You validated that your network policies work correctly by testing both allowed and blocked connections, confirming that unauthorized access attempts are properly denied.

Implemented Advanced Features: You explored namespace-based policies and learned troubleshooting techniques for network policy issues.

Why This Matters: Network Policies are crucial for implementing Zero Trust networking principles in Kubernetes environments. They provide:

Microsegmentation: Isolating workloads to limit the blast radius of potential security breaches
Compliance: Meeting regulatory requirements for network security controls
Defense in Depth: Adding an additional layer of security beyond application-level controls
Operational Security: Preventing accidental or malicious lateral movement within your cluster
These skills are essential for the Red Hat Certified OpenShift Application Developer exam and for implementing production-ready security controls in container orchestration platforms. Network Policies are a fundamental component of Kubernetes security architecture and are widely used in enterprise environments to maintain secure, compliant, and well-architected container deployments.
