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
