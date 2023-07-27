# AWS EKS Terraform Module

Terraform module which creates EKS resources

## Requirements

- Update the cluster name in this variable: CLUSTER_NAME, for all Jenkinsfiles
- 

## Notes

- After the cluster creation, it should be updated in the kubeconfig file:
  - aws eks --region=us-east-1 update-kubeconfig --name <cluster_name>
- To get the cluster name run this command: aws eks list-clusters
- To test if the environemet is up, run the following command: kubectl get nodes -o wide
- Update the repo name in this variable: REPO_URL, for all Jenkinsfiles if you choose to use a different repo)






