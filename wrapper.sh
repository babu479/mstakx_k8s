#!/bin/bash

podcpu=0
TODAY=`date +%F`
KUBECTL=/usr/local/bin/kubectl
SCRIPT_HOME=/var/log/kube-deploy
if [ ! -d $SCRIPT_HOME ]; then
  mkdir -p $SCRIPT_HOME
fi
#LOG_FILE=$SCRIPT_HOME/kube-$TODAY.log
#touch $LOG_FILE
RED='\033[01;31m'
YELLOW='\033[0;33m'
NONE='\033[00m'

print_help(){
  echo -e "${YELLOW}Use the following Command:"
  echo -e "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  echo -e "${RED}./<script-name> --action <action-name> --deployment <deployment-name> --scaleup <scaleupthreshold> --scaledown <scaledownthreshold>"
  echo -e "${YELLOW}+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  printf "Choose one of the available actions below:\n"
  printf " prerequisities-install\n kops-install\n kubectl-install\n aws_cli\n aws-configure\n aws-s3configure\n Kops-cluster-creation\n "
  echo -e "You can get the list of existing deployments using command: kubectl get deployments${NONE}"
}
ARG="$#"
if [[ $ARG -eq 0 ]]; then
  print_help
  exit
fi
while test -n "$1"; do
   case "$1" in

        --action)
            ACTION=$2
            shift
            ;;
       *)
            print_help
            exit
            ;;
   esac
    shift
done
echo $ACTION
echo $ARG

Kopsprerequisities_install()
{
echo "**********************PREREQUISITIES_INSTALL**************************"
echo "Here we are installing prerequisites like "
echo "python\n pip install\n "
apt-get update
apt-get install python-pip -y
}


KopsInstall(){
  echo "**********************KOPS INSTALL**************************"
echo "Here we are installing Kops Install"
curl -Lo kops https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
chmod +x ./kops
mv ./kops /usr/local/bin/
}
kubectlInstall(){
  echo "**********************Kubectl install**************************"
  echo "Here we are installing kubectl install"
  curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
  chmod +x ./kubectl
  mv ./kubectl /usr/local/bin/kubectl
}
awscliInstall(){
  echo "**********************AWS CLI**************************"
  echo "Here we are installing AWS cli"
  pip install awscli
}
awsConfigure(){
  echo "********************* Configure**************************"
  echo "Here we are configuring aws security details"
  read -p "Enter Access key: " access_key
  read -p "Enter Security key: " secret_key
  read -p "Enter Default region name: " region_name
  aws configure set aws_access_key_id $access_key
  aws configure set aws_secret_access_key $secret_key
  aws configure set default.region $region_name
}
awsS3Creation(){
  echo "**********************S3 creation**************************"
echo "Make sure we have right access to create s3 from AWS cli"
echo "• AmazonEC2FullAccess\n • AmazonRoute53FullAccess\n •     AmazonS3FullAccess\n •  IAMFullAccess\n •       AmazonVPCFullAccess"
read -p "Enter the bucket name : " bucket_name
read -p "Enter the region to create S3 bucket :" regionSpecific_name
aws s3api create-bucket --bucket ${bucket_name} --region $regionSpecific_name
echo " Enable versioning to the created bucket"
aws s3api put-bucket-versioning --bucket ${bucket_name} --versioning-configuration Status=Enabled
}
clusterCreation(){
  echo "**********************Cluster Creation**************************"
echo "Here we are Creating kubernetes Cluster"
read -p "Enter require no.of master servers : " master_count
read -p "Enter master server size require : " master_size
read -p "Enter require no of node servers : " node_code
read -p "Enter node server size require : " node_size
read -p "Enter the region  : " regionCLuster_name
read -p "Enter cluster name or DNS name : " DNS_name
read -p "Enter s3 bucket name  : " s3BucketName

kops create cluster --master-count=$master_count --master-size=$master_size --node-count=$node_code --node-size=$node_size --zones=${regionCLuster_name} --name=$DNS_name --state=s3://$s3BucketName --yes

}
validation(){
  echo "**********************Validation**************************"
  echo "Verifying whether the nodes ready "
  sleep 2m
  kubectl get nodes
  read -p "Are you sure? " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi
}
Application_nginx_configuration(){
  echo "**********************Nginx**************************"
echo "Configuring Nginx ingress controller"
kubectl create -f nginx-ingress-controller.yaml,nginx-controller-service.yaml
sleep 30s
kubectl get pods --namespace=ingress-nginx
read -p "Are you sure the pods are running? " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi
elb=`kubectl get svc --namespace=ingress-nginx|grep ingress-nginx|awk -F " " '{print $4}'`
publicIp=`nslookup $elb|grep Address|tail  -n 1|awk -F ":" '{print $2}'|tr -d ' '`
echo "Please add this Ip and hostanme of staging and production in the master kubernetes server: $elb"
}
guestbook_staging(){
  echo "**********************Staging**************************"
  echo "Here we are configuring guestbook application in staging"
  kubectl create -f staging-namespace.yaml,frontend-deployment.yaml,frontend-service.yaml,redis-master-service.yaml,redis-slave-deployment.yaml,redis-slave-service.yaml,redis-master-deployment.yaml
  kubectl get pods --namespace=staging
  kubectl get svc --namespace=staging
  echo "configuring ingress service to the frontend application"
  kubectl create -f ingress-staging.yaml
  kubectl get ingress --namespace=staging
  echo "Horizontal pod autoscaler depend on cpu "
  kubectl create -f HPA-staging.yaml
  kubectl get hpa --namespace=staging

}
guestbook_production(){
echo "**************PRODUCTION*****************"
echo "Here we are configuring guestbook application in production"
  kubectl create -f production-namespace.yaml,frontend-deployment-production.yaml,frontend-service-production.yaml,redis-master-deployment-production.yaml,redis-master-service-production.yaml,redis-slave-deployment-production.yaml,redis-slave-service-production.yaml
  kubectl get pods --namespace=production
  kubectl get svc --namespace=production
  echo "configuring ingress service to the frontend application"
  kubectl create -f ingress-prod.yaml
  kubectl get ingress --namespace=production
  echo "Horizontal pod autoscaler depend on cpu "
  kubectl create -f HPA-production.yaml
  kubectl get hpa --namespace=production

}
if [ "$ACTION" = "prerequisities-install" ];then
if [ $ARG -ne 2 ]
      then
        echo "Incorrect No. of Arguments Provided"
        print_help
        exit 1
      fi
echo  "running"
      Kopsprerequisities_install
      KopsInstall
      kubectlInstall
      awscliInstall
      awsConfigure
      awsS3Creation
      clusterCreation
      validation
      Application_nginx_configuration
      guestbook_staging
      guestbook_production

fi
