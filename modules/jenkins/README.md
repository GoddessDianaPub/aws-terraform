# AWS Jenkins Terraform Module

Terraform module which creates jenkins resources

## Requirements

Plugins to install:
  - Credentials
  - SSH Credentials
  - AWS Credentials
  - Plain Credentials
  - Credentials Binding
  - SSH Agent
  - SSH Build Agents
  - CloudBees AWS Credentials
  - Slack Notification
  - Blue Ocean


Update Jenkins credentials manager:
  - Create SSH Username with private key with the jenkins's server private key, ubuntu username and "agent.ubuntu" id
  - Create Secret text with "database_password" id, use the password you chose for your DB
  - Create Username with password for github with "github_token" id, use your github username and token
  - Create Secret text with "slack.integration" id, use the slack token
  - Create GitHub App with "github.jenkins.app" id, use the github app token
  - Create AWS Credentials with "jenkins" id, use the aws access key created in the next step


More steps to do:
- Create nodes with private ip address on Jenkins > Manage Jenkins > Nodes > agents, and update the credentials id you    
  have created in the previous step, with the label "linux" and jenkins_home as "Remote root directory"
- In aws create iam user "jenkins" with admin access, use it in jenkins credential manager
- Create github app token, [you can follow this article](https://docs.github.com/en/apps/creating-github-apps/authenticating-with-a-github-app/generating-a-user-access-token-for-a-github-app)
- Create a slack chanel named "jenkins-notifications" and integrate it with jenkins [you can follow this article](https://plugins.jenkins.io/slack/)
- Create jenkins-notifications channel on slack
- Install Jenkins CI app in slack and integrate it with this channel: jenkins-notifications



## Notes
- Ingress port 8080 is opened for jenkins UI
- Ingress ports 8300-8301 is opened for the agents
- There is an A record and alb configured for this subdomain: https://jenkins.dianatop.lat
- This server has 2 tags related to installing consul agent with ansible: OSType: ubuntu and Consul: agent
- The agents are looking for the servers when they are joining consul with this tags: Consul: server
- I have changed "Git Host Key Verification Configuration" to "No verification" in Security section
- I have changed the "Number of executors" to 0 on Nodes > Built-In Node > Configure
- 
