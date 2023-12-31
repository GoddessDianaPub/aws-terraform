# AWS EKS Terraform Module

Terraform module which creates EKS resources

## Requirements

- In order to grant admin cluster permissions to jenkins user, you need to add the "mapUsers" section (see details in scripts/aws_aut_conf.yaml file)
- Update the cluster name in this variable: CLUSTER_NAME, for all Jenkinsfiles
- Update the coredns configmap with the consul service ip address (see details in scripts/manifests/consul-manifests/consul_cm.yaml file)
- Ingress with private NLB: follow this article for [instructions](https://kubernetes.github.io/ingress-nginx/deploy/#aws):
  - Change this to your VPC CIDR: proxy-real-ip-cidr: y.y.y.y/yy
  - Change this to your certificate arn: service.beta.kubernetes.io/aws-load-balancer-ssl-cert: <certificate-arn>
  - This will create NLB type: service.beta.kubernetes.io/aws-load-balancer-type: nlb
  - This will create a private NLB: service.beta.kubernetes.io/aws-load-balancer-internal: "true"

## Notes

- After the cluster creation, it should be updated in the kubeconfig file:
  - aws eks --region=us-east-1 update-kubeconfig --name <cluster_name>
- To get the cluster name run this command: aws eks list-clusters
- To test if the environemet is up, run the following command: kubectl get nodes -o wide
- Update the repo name in this variable: REPO_URL, for all Jenkinsfiles if you choose to use a different repo)
- To access grafana UI use these credentials: username: admin password: prom-operator
- To get the consul secret info: kubectl get secret consul-gossip-encryption-key -n consul -o jsonpath='{.data.key}' | base64 --decode






