+ Raspberry setup :
  + Manualy setup k3s on Raspberry
  + Reset raspberry
+ Ansible :
  + Test ansible localy over raspberry
  + Workflow livraison inventory ansible  
  Trouver un moyen de gérer l'inventory a la main ou via terraform.
  + Ansible via CI to setup k3s
+ Dashy
  + Setup Dashy repo
  + Dashy dockerimage with config  
  Configurer Dashy via fichier de conf puis les intégrer dans l'image au moment de la livraison via dockerfile
  + Dashi CI and terraforming  
    + Build image Dashy
    + Push to dockerhub repo
    + update k3s cluster to use new image
+ Setup orange DynDNS
  + home.ashudev.com to k8s cluster
+ Helm Setup
  + setup Helm pour k3s in infra main
  + Integrate Helm in Dashy CI job
+ Monitoring
  + Prometeus
  + Grafana
  + Log collector ?

LATER:
+ Ansible Inventory viewer
+ Ansible Dynamic Inventory Manager
+ Readme des projets mailing-signature, ashudev-website, infra-main
+ OVH ns management
+ Manage all github projects via terraform
+ Migrate ashudev signature with right name
+ test before apply ?
+ Terragrunt or terraspace ?