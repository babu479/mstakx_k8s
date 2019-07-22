# mstakx_k8s
# TASK 1
step 1: Created a kubernetes cluster in aws cloud using kops utility, I have written one shell script code to create kubernetes cluster by using your inputs
### #bash cluster_creation.sh --action createCluster
Step 2: Configuring Nginx ingress controller, I have written two yaml files one for nginx ingress deployment and another is to create service for nginx ingress deployment 

########################## INGRESS-CONTROLLER ######################
### file1: nginx-ingress-controller.yaml 
it contains namespace creation,deployment,Service,ConfigMap,serviceAccount,CluserRole,Role,RoleBinding,ClusterRoleBinding and Deployment of ingress controller

### file2: nginx-controller-service.yaml
it contains service creation of nginx controller with loadBalancer
### #kubectl create -f nginx-ingress-controller.yaml,nginx-controller-service.yaml

###################### create namespaces staging and production ######################
### file1: staging-namespace.yaml
using this yaml file, we can create staging namespace

### #kubectl create -f staging-namespace.yaml

### file2: production-namespace.yaml
using this yaml file, we can create production namespace

### #kubectl create -f production-namespace.yaml


##################### Install guest-book Application on staging and production namespaces ################
## Namespace : staging
### file1: frontend-deployment-staging.yaml
This file help you to create frontend deployment on staging namespace
### #kubectl create -f frontend-deployment-staging.yaml
### file2: frontend-service-staging.yaml
this yaml file is used to create service to the frontend deployment and we are not expose this with any type like NodePort,LoadBalancer,clusterIP
### #kubectl create -f frontend-service-staging.yaml

### file3: redis-master-deployment-staging.yaml
Creating the Redis Master Deployment on staging namespace
### #kubectl create -f redis-master-deployment-staging.yaml

### file4: redis-master-service-staging.yaml
Creating the Redis Master Service for redis master deployment on staging namespace




