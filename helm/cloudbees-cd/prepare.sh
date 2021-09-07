#!/usr/bin/env bash

helm repo add cloudbees https://charts.cloudbees.com/public/cloudbees
helm repo update
helm pull cloudbees/cloudbees-flow --version 2.10.2 --untar

helm -n cloudbees-cd template cloudbees-cd ./cloudbees-flow --release-name --output-dir ../../manifests -f cloudbees-cd-demo.yaml -f values.yaml

