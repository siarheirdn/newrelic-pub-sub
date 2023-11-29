#!/bin/bash

prefix="europe-west1-docker.pkg.dev/dh-container-images/media-dev/media-portal-apps/infrastructure"

echo "updating helm repo"
helm repo add newrelic https://helm-charts.newrelic.com && helm repo update

echo "creating newrelic helm template to get list of images"
helm_out=$(helm template --dry-run newrelic-bundle newrelic/nri-bundle \
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
 --set newrelic-prometheus-agent.config.kubernetes.integrations_filter.enabled=false)

 echo "$helm_out" | grep 'image: ' | grep -i "newrelic\|prometheus" | sort -u | awk '{print $2}' | sed 's/"//g'| while read -r image; do
  echo "from: $image"
  dest_image=$(echo "$prefix/newrelic/"$(echo "$image" | sed "s/newrelic\///"))
  echo "to: $dest_image"
  docker pull "$image"
  docker tag "$image" "$dest_image"
  echo "$dest_image"
  docker push "$dest_image"
  echo ""
done
