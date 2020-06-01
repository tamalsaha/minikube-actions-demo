#!/bin/bash
set -xeou pipefail

minikube start \
  --driver=none \
  --kubernetes-version=v1.18.3 \
  --extra-config=apiserver.enable-admission-plugins="NamespaceLifecycle,LimitRanger,ServiceAccount,TaintNodesByCondition,Priority,DefaultTolerationSeconds,DefaultStorageClass,StorageObjectInUseProtection,PersistentVolumeClaimResize,RuntimeClass,CertificateApproval,CertificateSigning,CertificateSubjectRestriction,DefaultIngressClass,MutatingAdmissionWebhook,ValidatingAdmissionWebhook,ResourceQuota,PodSecurityPolicy"

echo "Waiting kubernetes to launch on 8443..."
while ! nc -z localhost 8443; do
  sleep 1 # wait for 1/10 of the second before check again
done
sleep 5

kubectl version --short

kubectl apply -f https://raw.githubusercontent.com/kubernetes/website/master/content/en/examples/policy/privileged-psp.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/website/master/content/en/examples/policy/baseline-psp.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/website/master/content/en/examples/policy/restricted-psp.yaml

kubectl apply -f ./cluster-roles.yaml
kubectl apply -f ./role-bindings.yaml
