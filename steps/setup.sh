#Install packages 
sudo apt-get -y install nfs-common curl make docker.io
#Install Kubernetes
lsmod | grep br_netfilter
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system
sudo apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
#Install Helm
curl -LO https://git.io/get_helm.sh
chmod 700 get_helm.sh
./get_helm.sh

kubectl create -n kube-system serviceaccount helm-tiller
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: helm-tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: helm-tiller
    namespace: kube-system
EOF

# Set up local helm server
sudo -E tee /etc/systemd/system/helm-serve.service << EOF
[Unit]
Description=Helm Server
After=network.target
[Service]
User=$(id -un 2>&1)
Restart=always
ExecStart=/usr/local/bin/helm serve
[Install]
WantedBy=multi-user.target
EOF

sudo chmod 0640 /etc/systemd/system/helm-serve.service

sudo systemctl daemon-reload
sudo systemctl restart helm-serve
sudo systemctl enable helm-serve

# Remove stable repo, if present, to improve build time
helm repo remove stable || true

#Install nfs-provisioner
git clone https://github.com/slfletch/tcicd
cd charts
make
#Add fluxcd repo to helm
helm repo add fluxcd https://charts.fluxcd.io
#Add helm operator crd
kubectl apply -f https://raw.githubusercontent.com/fluxcd/helm-operator/1.2.0/deploy/crds.yaml

#Make sure helm operator can do helm 2 and helm 3
helm upgrade -i helm-operator fluxcd/helm-operator     --namespace flux
## Deploy nfs using openstack-helm-infra w/some tweaks
## Deploy harbor, nginx, notary, portal, redis, registry, trivy, clair, chartmuseum, database
cat <<EOF | kubectl apply -f -
apiVersion: helm.fluxcd.io/v1
kind: HelmRelease
metadata:
  name: harbor
  namespace: harbor
spec:
  chart:
    repository: https://helm.goharbor.io/
    name: harbor
    version: 1.4.0
  values:
    expose:
      type: nodePort
      tls:
        commonName: harbor
      ingress:
        hosts:
          core: stacey-1.localdomain
    externalURL: https://stacey-1.localdomain:30003
    trivy:
      securityContext:
        runAsNonRoot: false
    persistence:
      persistentVolumeClaim:
        registry:
          storageClass: nfs-provisioner
        chartmuseum:
          storageClass: nfs-provisioner
        jobservice:
          storageClass: nfs-provisioner
        database:
          storageClass: nfs-provisioner
        redis:
          storageClass: nfs-provisioner
        trivy:
          storageClass: nfs-provisioner
EOF
cat <<EOF | kubectl apply -f -
apiVersion: helm.fluxcd.io/v1
kind: HelmRelease
metadata:
  name: nfs-provisioner
  namespace: harbor
spec:
  chart:
    repository: https://review.opendev.org/openstack/openstack-helm-infra
    name: nfs-provisioner
    version: 0.1.0
EOF

#Install tekton
git clone https://github.com/slfletch/pipeline
git checkout release-v0.15.x

kubectl create clusterrolebinding cluster-admin-binding \
--clusterrole=cluster-admin \
--user=ubuntu

kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml

kubectl apply -f tekton-pv.yaml

sudo apt update;sudo apt install -y gnupg
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3EFE0E0A2F2F60AA
echo "deb http://ppa.launchpad.net/tektoncd/cli/ubuntu eoan main"|sudo tee /etc/apt/sources.list.d/tektoncd-ubuntu-cli.list
sudo apt update && sudo apt install -y tektoncd-cli
