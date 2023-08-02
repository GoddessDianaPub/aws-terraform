# AWS EKS Terraform Module

Terraform module which creates EKS resources

## Requirements

- In order to grant admin cluster permissions to jenkins user, you need to add the "mapUsers" section (see details in aws_aut_conf.yaml file)
- Update the cluster name in this variable: CLUSTER_NAME, for all Jenkinsfiles
- Update the coredns configmap with the consul service ip address (see details in consul_cm.yaml file)
- 

## Notes

- After the cluster creation, it should be updated in the kubeconfig file:
  - aws eks --region=us-east-1 update-kubeconfig --name <cluster_name>
- To get the cluster name run this command: aws eks list-clusters
- To test if the environemet is up, run the following command: kubectl get nodes -o wide
- Update the repo name in this variable: REPO_URL, for all Jenkinsfiles if you choose to use a different repo)






