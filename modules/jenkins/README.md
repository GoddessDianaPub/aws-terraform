# AWS Jenkins Terraform Module

Terraform module which creates jenkins resources

## Requirements

Update Jenkins credentials manager:
  - Create ssh username with private key, enter the username according to the agent OS distribution you deployed and the agent     
    privae key you have configured
  - Create Secret text with "database_password" id, use the password you chose for your DB
  - Create Username with password for github with "Github_token" id, use your github token
  - Create Secret text with "slack.integration" id, use the slack token
  - Create GitHub App with "github.jenkins.app" id, use the github app token
  - Create AWS Credentials with "jenkins" id, use the aws access key created in the next step

More steps to do:
- Create nodes with private ip address on Jenkins > Manage Jenkins > Nodes > agents, and update the credentials id you have created 
  in the previous step
- In aws create iam user "jenkins" with admin access, use it in jenkins credential manager
- Create github app token, [you can follow this article](https://docs.github.com/en/apps/creating-github-apps/authenticating-with-a-github-app/generating-a-user-access-token-for-a-github-app)
- Create a slack chanel named "jenkins-notifications" and integrate it with jenkins [you can follow this article](https://plugins.jenkins.io/slack/)
- 



## Notes
- Ingress port 8080 is opened for jenkins UI
- Ingress ports 8300-8301 is opened for the agents
- There is an A record and alb configured for this subdomain: https://jenkins.dianatop.lat
- This server has 2 tags related to installing consul agent with ansible: OSType: ubuntu and Consul: agent
- The agents are looking for the servers when they are joining consul with this tags: Consul: server
