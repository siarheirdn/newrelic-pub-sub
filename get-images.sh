#!/bin/bash
helm_out=$(helm upgrade --install newrelic-bundle newrelic/nri-bundle \
 --set global.licenseKey=none \
 --set global.cluster=none \
 --namespace=newrelic \
 --set newrelic-infrastructure.privileged=true \
 --set global.lowDataMode=true \
 --set kube-state-metrics.image.tag=v2.10.0 \
 --set kube-state-metrics.enabled=true \
 --set kubeEvents.enabled=true \
 --set newrelic-prometheus-agent.enabled=true \
 --set newrelic-prometheus-agent.lowDataMode=true \
 --set newrelic-prometheus-agent.config.kubernetes.integrations_filter.enabled=false \ 
 )
 echo $helm_out | grep 'image: ' | grep -i "newrelic\|prometheus" | sort -u | awk '{print $2}' | sed 's/"//g'| while read -r image; do
  docker pull "$image"
  docker tag 
done
