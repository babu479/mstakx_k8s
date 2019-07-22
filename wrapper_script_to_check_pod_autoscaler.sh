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
  printf " get-podcpu\n deploy-pod-autoscaling\n"
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
        --deployment)
            DEPLOYMENT=$2
            shift
            ;;
        --namespace)
            NAMESPACE=$2
            shift
            ;;
        --scaleup)
            SCALEUPTHRESHOLD=$2
            shift
            ;;
        --scaledown)
            SCALEDOWNTHRESHOLD=$2
            shift
            ;;
       *)
            print_help
            exit
            ;;
   esac
    shift
done
echo "$ARG"
LOG_FILE=$SCRIPT_HOME/kube-$DEPLOYMENT-$TODAY.log
touch $LOG_FILE

REPLICAS=`$KUBECTL get deployment $DEPLOYMENT --namespace=$NAMESPACE | awk '{print $3}' | grep -v "CURRENT"`
echo "current replicas is :$REPLICAS"

##########################################
#defining function to calculate pod memory

calculate_podcpu(){
pods=`$KUBECTL top pod -l tier=$DEPLOYMENT --namespace=$NAMESPACE | awk '{print $2}' | grep -o '[0-9]\+'`

TOTALCPU=`$KUBECTL describe pod -l tier=$DEPLOYMENT --namespace=$NAMESPACE| grep -A 2 "Limits:" | grep cpu | awk -F ':' '{print $2}'| head -1|tr -d ' '`
 if [[ $TOTALCPU =~ .*g.* ]]; then
    TOTALCPUINGB=${TOTALCPU//[!0-9]/}
    TOTALCPUINMB=$((TOTALCPUINGB * 1024))
    echo "Total Pod Cpu Allocated: "$TOTALCPUINMB"MB" >> $LOG_FILE
    echo "===========================" >> $LOG_FILE
elif [[ $TOTALCPU =~ .*m.* ]]; then
    TOTALCPUINMB=${TOTALCPU//[!0-9]/}
    echo "Total Pod Cpu Allocated: "$TOTALCPUINMB"MB" >> $LOG_FILE
    echo "===========================" >> $LOG_FILE
fi

for i in $pods
do
  podcpu=$((podcpu+i))
  echo "Used Pod cpu: "$podcpu >> $LOG_FILE
  UTILIZEDPODCPU=$(awk "BEGIN { pc=100*${podcpu}/${TOTALCPUINMB}; i=int(pc); print (pc-i<0.5)?i:i+1 }")
  echo "Pod Cpu Percent: "$UTILIZEDPODCPU"%" >> $LOG_FILE
  echo "===========================" >> $LOG_FILE
done
AVGPODCPU=$(( $UTILIZEDPODCPU/$REPLICAS ))
echo "Average Pod CPu: "$AVGPODCPU >> $LOG_FILE
}

##########################################
#defining function to autoscale based on pod memory

podcpu_autoscale(){
  if [ $AVGPODCPU -gt $SCALEUPTHRESHOLD ]
  then
    echo "CPu is greater than threshold" >> $LOG_FILE
    count=$((REPLICAS+1))
    echo "Updated No. of Replicas will be: "$count >> $LOG_FILE
    scale=`$KUBECTL scale --replicas=$count deployment/$DEPLOYMENT --namespace=$NAMESPACE`
    echo "Deployment Scaled Up" >> $LOG_FILE

  elif [ $AVGPODCPU -lt $SCALEDOWNTHRESHOLD ] && [ $REPLICAS -gt 2 ]
  then
    echo "CPU is less than threshold" >> $LOG_FILE
    count=$((REPLICAS-1))
    echo "Updated No. of Replicas will be: "$count >> $LOG_FILE
    scale=`$KUBECTL scale --replicas=$count deployment/$DEPLOYMENT`
    echo "Deployment Scaled Down" >> $LOG_FILE
  else
    echo "CPU is not crossing the threshold. No Scaling done." >> $LOG_FILE
  fi
}

##########################################
#Calling Functions


if [[ $REPLICAS ]]; then
  if [ "$ACTION" = "get-podcpu" ];then
      if [ $ARG -ne 10 ]
      then
        echo "Incorrect No. of Arguments Provided"
        print_help
        exit 1
      fi
      calculate_podcpu
  elif [ "$ACTION" = "deploy-pod-autoscaling" ];then
      if [ $ARG -ne 10 ]
      then
        echo "Incorrect No. of Arguments Provided"
        print_help
        exit 1
      fi
      calculate_podcpu
      podcpu_autoscale
  else
      echo "Unknown Action"
      print_help
  fi
else
  echo "No Deployment exists with name: "$DEPLOYMENT
  print_help
fi
