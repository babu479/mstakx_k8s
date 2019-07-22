# mstakx_k8s
# TASK 1
## step 1: 
Created a kubernetes cluster in aws cloud using kops utility, I have written one shell script code to create kubernetes cluster by using your inputs
#### #bash cluster_creation.sh --action createCluster

## Step 2: 
Configuring Nginx ingress controller, I have written two yaml files one for nginx ingress deployment and another is to create service for nginx ingress deployment 

########################## INGRESS-CONTROLLER ######################
### file1: nginx-ingress-controller.yaml 
it contains namespace creation,deployment,Service,ConfigMap,serviceAccount,CluserRole,Role,RoleBinding,ClusterRoleBinding and Deployment of ingress controller

### file2: nginx-controller-service.yaml
it contains service creation of nginx controller with loadBalancer
#### #kubectl create -f nginx-ingress-controller.yaml,nginx-controller-service.yaml

## step3:
###################### create namespaces staging and production ######################
### file1: staging-namespace.yaml
using this yaml file, we can create staging namespace

#### #kubectl create -f staging-namespace.yaml

### file2: production-namespace.yaml
using this yaml file, we can create production namespace

#### #kubectl create -f production-namespace.yaml

## step4:
##################### Install guest-book Application on staging and production namespaces ################
## Namespace : staging
#### file1: frontend-deployment-staging.yaml
This file help you to create frontend deployment on staging namespace
#### #kubectl create -f frontend-deployment-staging.yaml
#### file2: frontend-service-staging.yaml
this yaml file is used to create service to the frontend deployment and we are not expose this with any type like NodePort,LoadBalancer,clusterIP
#### #kubectl create -f frontend-service-staging.yaml

#### file3: redis-master-deployment-staging.yaml
Creating the Redis Master Deployment on staging namespace
#### #kubectl create -f redis-master-deployment-staging.yaml

#### file4: redis-master-service-staging.yaml
Creating the Redis Master Service for redis master deployment on staging namespace
#### #kubectl create -f redis-master-service-staging.yaml
#### file5: redis-slave-deployment-staging.yaml
Creating the Redis Slave Deployment on staging namespace
#### #kubectl create -f redis-slave-deployment-staging.yaml
#### file6: redis-slave-service-staging.yaml
creating the redis slave service for redis slave deployment on staging namespace
#### #kubectl create -f redis-slave-service-staging.yaml

## Namespace : Production
#### file1: frontend-deployment-production.yaml
This file help you to create frontend deployment on production namespace
#### #kubectl create -f frontend-deployment-production.yaml
#### file2: frontend-service-production.yaml
this yaml file is used to create service to the frontend deployment and we are not expose this with any type like NodePort,LoadBalancer,clusterIP
#### #kubectl create -f frontend-service-production.yaml

#### file3: redis-master-deployment-production.yaml
Creating the Redis Master Deployment on production namespace
#### #kubectl create -f redis-master-deployment-production.yaml

#### file4: redis-master-service-production.yaml
Creating the Redis Master Service for redis master deployment on production namespace
#### #kubectl create -f redis-master-service-production.yaml
#### file5: redis-slave-deployment-production.yaml
Creating the Redis Slave Deployment on production namespace
#### #kubectl create -f redis-slave-deployment-production.yaml
#### file6: redis-slave-service-production.yaml
creating the redis slave service for redis slave deployment on production namespace
#### #kubectl create -f redis-slave-service-production.yaml

## Step 5:
############# Expose staging application on hostname staging-guestbook.mstakx.io ##########
#### file1: ingress-staging.yaml
Exposing frontend deployment on hostname staging-guestbook.mstakx.io on staging namespace
#### #kubectl create -f ingress-staging.yaml

## Step6:
############ Expose production application on hostname guestbook.mstakx.io #########
#### file1: ingress-prod.yaml
Exposing frontend deployment on hostname guestbook.mstakx.io on production namespace
#### #kubectl create -f ingress-prod.yaml

## Step7:
################# Heapster Controller for get metrics from Pods ##################
#### file1: heapster-controller-service.yaml
Using this file we can install heapster deployment and service for deployment
#### #kubectl create -f heapster-controller-service.yaml

we have to be in same network while writing horizontal pod autoscaler

#### #kubectl create -f   "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

## Step8:
########### Implementing a pod autoscaler on both namespaces ##########
## Namespace: Staging
#### file1: HPA-staging.yaml
Horizontal Pod autoscaler has been configured to the frontend application, we kept target to 75% once the CPU current metrics reached to 75%, automatically pod will increse on staging namespace
#### #kubectl create -f HPA-staging.yaml

## Namespace: Production
#### file2: HPA-production.yaml
Horizontal Pod autoscaler has been configured to the frontend application, we kept target to 75% once the CPU  current metrics reached to 75%, automatically pod will increse on production namespace
#### #kubectl create -f HPA-production.yaml

## Step9:
########## wrapper script for POD autoscaler ############
#### file1: wrapper_script_to_check_pod_autoscaler.sh
you can run this script to check pod autoscaler, it will store the output on logfile
#### bash wrapper_script_to_check_pod_autoscaler.sh --help --> this command will suggest you , how to pass arguments to the script

Logfile: /var/log/kube-deploy/kube-$DEPLOYMENT-$TODAY.log  




