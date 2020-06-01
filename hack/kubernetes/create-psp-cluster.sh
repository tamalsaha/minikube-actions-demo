#!/bin/bash
set -xeou pipefail

K8S_VERSION=${1:-v1.18.3}

minikube start \
  --driver=none \
  --kubernetes-version=$K8S_VERSION \
  --wait=none \
  --extra-config=apiserver.enable-admission-plugins="NamespaceLifecycle,LimitRanger,ServiceAccount,TaintNodesByCondition,Priority,DefaultTolerationSeconds,DefaultStorageClass,StorageObjectInUseProtection,PersistentVolumeClaimResize,RuntimeClass,CertificateApproval,CertificateSigning,CertificateSubjectRestriction,DefaultIngressClass,MutatingAdmissionWebhook,ValidatingAdmissionWebhook,ResourceQuota,PodSecurityPolicy"

echo "Waiting kubernetes to launch on 8443..."
while ! nc -z localhost 8443; do
  sleep 0.1 # wait for 1/10 of the second before check again
done
sleep 5

kubectl apply -f https://raw.githubusercontent.com/kubernetes/website/master/content/en/examples/policy/privileged-psp.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/website/master/content/en/examples/policy/baseline-psp.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/website/master/content/en/examples/policy/restricted-psp.yaml

kubectl apply -f https://github.com/tamalsaha/minikube-actions-demo/raw/master/hack/kubernetes/psp-rbac.yaml

# kubectl wait --for=condition=Ready pods -n kube-system --timeout=5m --all

echo "waiting for nodes to be ready ..."
kubectl wait --for=condition=Ready nodes --all --timeout=5m
kubectl get nodes
echo
kubectl version --short
