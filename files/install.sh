#!/bin/sh

yum check-update

curl -fsSL https://get.docker.com/ | sh

mkdir -p /etc/docker

cat > /etc/docker/daemon.json <<EOF
{
   "insecure-registries": [
     "172.17.0.0/16"
   ]
}
EOF

systemctl daemon-reload \
 && systemctl enable docker \
 && systemctl start docker

wget https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz \
  && tar -xvf openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz \
  && rm -rf openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz \
  && mv open* openshift

export PATH=$PATH:`pwd`/openshift

oc cluster up --skip-registry-check=true

cp -p ./openshift.local.clusterup/openshift-apiserver/master-config.yaml ./openshift.local.clusterup/openshift-apiserver/master-config.yaml.prepatch
cp -p ./openshift.local.clusterup/kube-apiserver/master-config.yaml ./openshift.local.clusterup/kube-apiserver/master-config.yaml.prepatch
cp -p ./openshift.local.clusterup/openshift-controller-manager/master-config.yaml ./openshift.local.clusterup/openshift-controller-manager/master-config.yaml.prepatch

oc ex config patch ./openshift.local.clusterup/openshift-apiserver/master-config.yaml.prepatch -p "$(cat /tmp/files/master-config.patch)" > ./openshift.local.clusterup/openshift-apiserver/master-config.yaml
oc ex config patch ./openshift.local.clusterup/kube-apiserver/master-config.yaml.prepatch -p "$(cat /tmp/files/master-config.patch)" > ./openshift.local.clusterup/kube-apiserver/master-config.yaml
oc ex config patch ./openshift.local.clusterup/openshift-controller-manager/master-config.yaml.prepatch -p "$(cat /tmp/files/master-config.patch)" > ./openshift.local.clusterup/openshift-controller-manager/master-config.yaml

oc cluster down

oc cluster up --skip-registry-check=true

oc login -u system:admin

oc new-project istio-operator

oc apply -f /tmp/files/operator.yaml

oc new-project istio-system

oc apply -f /tmp/files/cp.yaml

oc policy add-role-to-user admin developer -n istio-system
