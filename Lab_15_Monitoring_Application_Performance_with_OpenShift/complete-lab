Lab 15: Monitoring Application Performance with OpenShift
Objectives
By the end of this lab, you will be able to:

Configure Prometheus and Grafana for comprehensive OpenShift metrics collection
Set up automated alerts for application performance issues and system anomalies
Utilize the OpenShift dashboard effectively for monitoring application health and performance
Implement monitoring best practices for containerized applications
Troubleshoot performance issues using monitoring data and metrics
Prerequisites
Before starting this lab, you should have:

Basic understanding of OpenShift concepts (pods, services, deployments)
Familiarity with Kubernetes fundamentals
Basic knowledge of YAML configuration files
Understanding of containerized applications
Experience with command-line interface operations
Basic knowledge of monitoring concepts (metrics, alerts, dashboards)
Ready-to-Use Cloud Machines
Al Nafi provides pre-configured Linux-based cloud machines with OpenShift cluster access. Simply click Start Lab to begin - no need to build your own virtual machine or install OpenShift from scratch. Your lab environment includes:

OpenShift cluster with administrative access
Pre-installed command-line tools (oc, kubectl)
Sample applications for monitoring
Network connectivity to external repositories
Task 1: Configure Prometheus and Grafana for OpenShift Metrics
Subtask 1.1: Verify OpenShift Monitoring Stack
First, let's check if the monitoring stack is already installed in your OpenShift cluster.

Login to OpenShift cluster:
oc login --server=https://api.your-cluster.com:6443 --username=admin
Check monitoring namespace:
oc get namespaces | grep monitoring
Verify Prometheus installation:
oc get pods -n openshift-monitoring
Check if user workload monitoring is enabled:
oc get configmap cluster-monitoring-config -n openshift-monitoring -o yaml
Subtask 1.2: Enable User Workload Monitoring
If user workload monitoring is not enabled, we need to configure it.

Create monitoring configuration:
cat << EOF | oc apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: cluster-monitoring-config
  namespace: openshift-monitoring
data:
  config.yaml: |
    enableUserWorkload: true
    prometheusK8s:
      retention: 7d
      volumeClaimTemplate:
        spec:
          storageClassName: gp2
          resources:
            requests:
              storage: 10Gi
EOF
Wait for monitoring pods to restart:
oc get pods -n openshift-monitoring -w
Verify user workload monitoring namespace:
oc get pods -n openshift-user-workload-monitoring
Subtask 1.3: Deploy Sample Application for Monitoring
Let's deploy a sample application that we can monitor.

Create a new project:
oc new-project monitoring-demo
Deploy a sample web application:
cat << EOF | oc apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-app
  namespace: monitoring-demo
  labels:
    app: sample-app
spec:
  replicas: 3
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
        image: quay.io/prometheus/node-exporter:latest
        ports:
        - containerPort: 9100
          name: metrics
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
---
apiVersion: v1
kind: Service
metadata:
  name: sample-app-service
  namespace: monitoring-demo
  labels:
    app: sample-app
spec:
  selector:
    app: sample-app
  ports:
  - port: 9100
    targetPort: 9100
    name: metrics
EOF
Verify deployment:
oc get pods -n monitoring-demo
oc get svc -n monitoring-demo
Subtask 1.4: Configure ServiceMonitor for Prometheus
Create a ServiceMonitor to tell Prometheus to scrape metrics from our application.

Create ServiceMonitor configuration:
cat << EOF | oc apply -f -
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: sample-app-monitor
  namespace: monitoring-demo
  labels:
    app: sample-app
spec:
  selector:
    matchLabels:
      app: sample-app
  endpoints:
  - port: metrics
    interval: 30s
    path: /metrics
EOF
Verify ServiceMonitor creation:
oc get servicemonitor -n monitoring-demo
Subtask 1.5: Access Prometheus Web Interface
Get Prometheus route:
oc get routes -n openshift-monitoring
Create route if not exists:
oc expose service prometheus-k8s -n openshift-monitoring
Get the Prometheus URL:
echo "https://$(oc get route prometheus-k8s -n openshift-monitoring -o jsonpath='{.spec.host}')"
Access Prometheus and verify targets:
Open the URL in your browser
Navigate to Status → Targets
Look for your sample-app targets
Subtask 1.6: Configure Grafana Dashboard
Check if Grafana is available:
oc get pods -n openshift-monitoring | grep grafana
Access Grafana through OpenShift console:

Go to OpenShift web console
Navigate to Monitoring → Dashboards
Or access directly via route if available
Create custom dashboard configuration:

cat << EOF | oc apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: custom-dashboard
  namespace: monitoring-demo
  labels:
    grafana_dashboard: "1"
data:
  dashboard.json: |
    {
      "dashboard": {
        "id": null,
        "title": "Sample App Monitoring",
        "tags": ["openshift"],
        "timezone": "browser",
        "panels": [
          {
            "id": 1,
            "title": "CPU Usage",
            "type": "graph",
            "targets": [
              {
                "expr": "rate(process_cpu_seconds_total[5m])",
                "legendFormat": "CPU Usage"
              }
            ]
          }
        ],
        "time": {
          "from": "now-1h",
          "to": "now"
        },
        "refresh": "5s"
      }
    }
EOF
Task 2: Set Up Alerts for Application Performance Issues
Subtask 2.1: Create PrometheusRule for Alerts
Create alert rules configuration:
cat << EOF | oc apply -f -
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: sample-app-alerts
  namespace: monitoring-demo
  labels:
    app: sample-app
spec:
  groups:
  - name: sample-app.rules
    rules:
    - alert: HighCPUUsage
      expr: rate(process_cpu_seconds_total[5m]) > 0.8
      for: 2m
      labels:
        severity: warning
        service: sample-app
      annotations:
        summary: "High CPU usage detected"
        description: "CPU usage is above 80% for more than 2 minutes"
    
    - alert: PodCrashLooping
      expr: rate(kube_pod_container_status_restarts_total[15m]) > 0
      for: 5m
      labels:
        severity: critical
        service: sample-app
      annotations:
        summary: "Pod is crash looping"
        description: "Pod {{ $labels.pod }} is restarting frequently"
    
    - alert: HighMemoryUsage
      expr: (container_memory_usage_bytes / container_spec_memory_limit_bytes) > 0.9
      for: 5m
      labels:
        severity: warning
        service: sample-app
      annotations:
        summary: "High memory usage detected"
        description: "Memory usage is above 90% for pod {{ $labels.pod }}"
    
    - alert: PodNotReady
      expr: kube_pod_status_ready{condition="false"} == 1
      for: 10m
      labels:
        severity: critical
        service: sample-app
      annotations:
        summary: "Pod not ready"
        description: "Pod {{ $labels.pod }} has been not ready for more than 10 minutes"
EOF
Verify PrometheusRule creation:
oc get prometheusrule -n monitoring-demo
Check rule status in Prometheus:
Access Prometheus web interface
Navigate to Status → Rules
Verify your rules are loaded
Subtask 2.2: Configure AlertManager
Check AlertManager configuration:
oc get pods -n openshift-monitoring | grep alertmanager
Create AlertManager configuration for notifications:
cat << EOF | oc apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: alertmanager-main
  namespace: openshift-monitoring
type: Opaque
stringData:
  alertmanager.yaml: |
    global:
      smtp_smarthost: 'localhost:587'
      smtp_from: 'alerts@example.com'
    
    route:
      group_by: ['alertname', 'cluster', 'service']
      group_wait: 10s
      group_interval: 10s
      repeat_interval: 1h
      receiver: 'web.hook'
      routes:
      - match:
          severity: critical
        receiver: 'critical-alerts'
      - match:
          severity: warning
        receiver: 'warning-alerts'
    
    receivers:
    - name: 'web.hook'
      webhook_configs:
      - url: 'http://localhost:5001/'
    
    - name: 'critical-alerts'
      webhook_configs:
      - url: 'http://localhost:5001/critical'
        send_resolved: true
    
    - name: 'warning-alerts'
      webhook_configs:
      - url: 'http://localhost:5001/warning'
        send_resolved: true
EOF
Subtask 2.3: Test Alert Generation
Create a resource-intensive pod to trigger alerts:
cat << EOF | oc apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: stress-test
  namespace: monitoring-demo
  labels:
    app: stress-test
spec:
  containers:
  - name: stress
    image: progrium/stress
    command: ["stress"]
    args: ["--cpu", "2", "--timeout", "300s"]
    resources:
      requests:
        memory: "100Mi"
        cpu: "100m"
      limits:
        memory: "200Mi"
        cpu: "200m"
EOF
Monitor alert status:
# Check pod status
oc get pods -n monitoring-demo -w

# Access Prometheus alerts page
# Navigate to Alerts in Prometheus web interface
Clean up stress test:
oc delete pod stress-test -n monitoring-demo
Task 3: Use OpenShift Dashboard for Monitoring Application Health
Subtask 3.1: Access OpenShift Monitoring Dashboard
Login to OpenShift web console:

Open your browser and navigate to the OpenShift console URL
Login with your credentials
Navigate to monitoring section:

Click on Monitoring in the left navigation
Explore the following sections:
Metrics: Query and visualize metrics
Alerts: View active and firing alerts
Dashboards: Pre-built monitoring dashboards
Subtask 3.2: Create Custom Queries and Dashboards
Access the Metrics page:
Go to Monitoring → Metrics
Try these sample queries:
# CPU usage by pod
rate(container_cpu_usage_seconds_total[5m])

# Memory usage by pod
container_memory_usage_bytes

# Network I/O by pod
rate(container_network_receive_bytes_total[5m])

# Pod restart count
kube_pod_container_status_restarts_total
Create custom dashboard queries:
# Application availability
up{job="sample-app-service"}

# Request rate
rate(http_requests_total[5m])

# Error rate
rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m])

# Response time percentiles
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))
Subtask 3.3: Monitor Application Health Metrics
Check pod health status:
oc get pods -n monitoring-demo -o wide
View pod logs for troubleshooting:
oc logs -f deployment/sample-app -n monitoring-demo
Check resource usage:
oc top pods -n monitoring-demo
oc top nodes
Monitor events:
oc get events -n monitoring-demo --sort-by='.lastTimestamp'
Subtask 3.4: Set Up Application Health Checks
Add health check endpoints to deployment:
cat << EOF | oc apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp-with-health
  namespace: monitoring-demo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: webapp-with-health
  template:
    metadata:
      labels:
        app: webapp-with-health
    spec:
      containers:
      - name: webapp
        image: quay.io/redhat-training/hello-world-nginx:v1.0
        ports:
        - containerPort: 8080
        livenessProbe:
          httpGet:
            path: /
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
---
apiVersion: v1
kind: Service
metadata:
  name: webapp-with-health
  namespace: monitoring-demo
spec:
  selector:
    app: webapp-with-health
  ports:
  - port: 8080
    targetPort: 8080
EOF
Monitor health check status:
oc describe pod -l app=webapp-with-health -n monitoring-demo
Subtask 3.5: Create Monitoring Dashboard Summary
Create a comprehensive monitoring script:
cat << 'EOF' > monitoring-summary.sh
#!/bin/bash

echo "=== OpenShift Monitoring Summary ==="
echo "Date: $(date)"
echo

echo "=== Cluster Nodes Status ==="
oc get nodes
echo

echo "=== Monitoring Pods Status ==="
oc get pods -n openshift-monitoring
echo

echo "=== User Workload Monitoring ==="
oc get pods -n openshift-user-workload-monitoring
echo

echo "=== Application Pods Status ==="
oc get pods -n monitoring-demo
echo

echo "=== Active Alerts ==="
oc get prometheusrule -n monitoring-demo
echo

echo "=== Service Monitors ==="
oc get servicemonitor -n monitoring-demo
echo

echo "=== Resource Usage ==="
oc top pods -n monitoring-demo 2>/dev/null || echo "Metrics server not available"
echo

echo "=== Recent Events ==="
oc get events -n monitoring-demo --sort-by='.lastTimestamp' | tail -10
EOF

chmod +x monitoring-summary.sh
./monitoring-summary.sh
Troubleshooting Tips
Common Issues and Solutions
Prometheus targets not showing up:

Verify ServiceMonitor labels match service labels
Check if user workload monitoring is enabled
Ensure proper RBAC permissions
Alerts not firing:

Verify PrometheusRule syntax
Check if metrics are being collected
Confirm alert thresholds are appropriate
Grafana dashboards not loading:

Check ConfigMap labels
Verify JSON syntax in dashboard configuration
Ensure proper data source configuration
High resource usage:

# Check resource limits
oc describe limits -n monitoring-demo

# Adjust resource requests/limits
oc patch deployment sample-app -n monitoring-demo -p '{"spec":{"template":{"spec":{"containers":[{"name":"sample-app","resources":{"requests":{"memory":"128Mi","cpu":"100m"},"limits":{"memory":"256Mi","cpu":"200m"}}}]}}}}'
Monitoring stack issues:
# Restart monitoring pods
oc delete pods -l app=prometheus -n openshift-monitoring

# Check monitoring configuration
oc get configmap cluster-monitoring-config -n openshift-monitoring -o yaml
Conclusion
In this lab, you have successfully:

Configured a comprehensive monitoring stack using Prometheus and Grafana within OpenShift, enabling real-time metrics collection and visualization
Implemented automated alerting with PrometheusRule and AlertManager to proactively detect and respond to application performance issues
Mastered the OpenShift monitoring dashboard for effective application health monitoring and troubleshooting
Set up application health checks and custom metrics to ensure robust application monitoring
Created monitoring best practices that can be applied to production environments
This monitoring setup is crucial for maintaining application reliability and performance in production environments. The skills you've learned enable you to:

Proactively identify performance bottlenecks before they impact users
Set up automated alerting to reduce mean time to detection (MTTD)
Use data-driven insights for capacity planning and optimization
Implement monitoring as code practices for consistent deployments
These monitoring capabilities are essential for the Red Hat Certified OpenShift Application Developer exam and real-world OpenShift operations. Continue practicing with different alert conditions and dashboard configurations to deepen your expertise in OpenShift monitoring and observability.
