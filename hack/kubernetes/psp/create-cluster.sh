#!/bin/bash
set -xeou pipefail

minikube start \
  --driver=none \
  --kubernetes-version=v1.18.3 \
  --wait=none \
  --extra-config=apiserver.enable-admission-plugins="NamespaceLifecycle,LimitRanger,ServiceAccount,TaintNodesByCondition,Priority,DefaultTolerationSeconds,DefaultStorageClass,StorageObjectInUseProtection,PersistentVolumeClaimResize,RuntimeClass,CertificateApproval,CertificateSigning,CertificateSubjectRestriction,DefaultIngressClass,MutatingAdmissionWebhook,ValidatingAdmissionWebhook,ResourceQuota,PodSecurityPolicy"

echo "Waiting kubernetes to launch on 8443..."
while ! nc -z localhost 8443; do
  sleep 1 # wait for 1/10 of the second before check again
  echo ">>>>>>>>>>>>>>>>>>> L 12"
done
sleep 5

kubectl version --short

echo ">>>>>>>>>>>>>>>>>>> L 18"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/website/master/content/en/examples/policy/privileged-psp.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/website/master/content/en/examples/policy/baseline-psp.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/website/master/content/en/examples/policy/restricted-psp.yaml

echo ">>>>>>>>>>>>>>>>>>> L 23"
kubectl apply -f ./hack/kubernetes/psp/cluster-roles.yaml
echo ">>>>>>>>>>>>>>>>>>> L 25"
kubectl apply -f ./hack/kubernetes/psp/role-bindings.yaml
