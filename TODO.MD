+ Setup orange DynDNS
  + home.ashudev.com to k8s cluster
+ k3s
  + Add namespaces management
+ Terraform
  + Job to apply kubectl commands via terraform
  + Job to apply Helm via terraform
+ Traefik
  + Export traefik ingress route to terraform
  + Activate Prometheus support
  + Activate Password protection
+ Root
  + Drop simple text file for all roots with link to dashy and how to modify host file with correct values.
+ SSL
  + Implement cert manager solution for web and local domain.
+ Dashy
  + Config :
    + Login and guest accounts
    + Define Themes and design
    + Links to Saas Solutions and local network ressources.
  + Build config and sources into static nginx image
  + Dashi CI and terraforming  
    + Build image Dashy
    + Push to dockerhub repo
    + update k3s cluster to use new image
+ Monitoring
  + Prometeus
  + Grafana
  + Log collector ?

LATER:
+ Helm Setup
  + setup Helm pour k3s in infra main
  + Integrate Helm in Dashy CI job
+ Ansible
  + Ansible Inventory viewer
  + Ansible Dynamic Inventory Manager
+ Readme des projets mailing-signature, ashudev-website, infra-main
+ OVH ns management
+ Manage all github projects via terraform
+ Migrate ashudev signature with right name
+ test before apply ?
+ Terragrunt or terraspace ?