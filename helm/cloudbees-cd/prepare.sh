#!/usr/bin/env bash

helm repo add cloudbees https://charts.cloudbees.com/public/cloudbees
helm repo update
# helm pull cloudbees/cloudbees-flow --untar

helm template cloudbees-cd cloudbees/cloudbees-flow --release-name --namespace cloudbees-cd --output-dir ../../manifests -f cloudbees-cd-demo.yaml -f values.yaml

