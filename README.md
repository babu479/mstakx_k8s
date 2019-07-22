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

###################### create namespaces called staging and production ######################
### file1: staging-namespace.yaml
using this yaml file, we can create staging namespace

### #kubectl create -f staging-namespace.yaml

### file2: 
