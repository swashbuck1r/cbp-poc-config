#!/usr/bin/env bash

helm repo add external-secrets https://external-secrets.github.io/kubernetes-external-secrets/
helm pull external-secrets/kubernetes-external-secrets --version 1.3.0 --untar

helm template external-secrets external-secrets/kubernetes-external-secrets --namespace secret-infra --include-crds --output-dir ../../manifests 

