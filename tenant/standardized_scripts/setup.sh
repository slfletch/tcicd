echo "Running my setup"

cat <<EOF | kubectl apply -f -
apiVersion: helm.fluxcd.io/v1
kind: HelmRelease
metadata:
  name: rabbitmq
  namespace: demo
spec:
  chart:
    repository: https://github.com/openstack/openstack-helm-infra
    name: rabbitmq
    version: 0.1.0
EOF