#!/bin/bash
echo "=== OpenShift Application Debug Checklist ==="
echo "1. Checking project status..."
oc status

echo -e "\n2. Checking pod status..."
oc get pods -o wide

echo -e "\n3. Checking recent events..."
oc get events --sort-by='.lastTimestamp' | tail -10

echo -e "\n4. Checking services and endpoints..."
oc get svc,endpoints

echo -e "\n5. Checking resource quotas..."
oc describe quota

echo -e "\n6. Checking limit ranges..."
oc describe limitrange

echo "=== Debug checklist complete ==="
