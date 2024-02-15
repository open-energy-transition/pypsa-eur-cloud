INPUT_DIR_NAME=$1
OUTPUT_DIR_NAME=$2
RULE_NAME=$3
BUCKET_NAME=$4



gcloud storage buckets create gs://$BUCKET_NAME --uniform-bucket-level-access


echo bucket $BUCKET_NAME created

sleep 5

gcloud storage cp --recursive "$(pwd)"/$INPUT_DIR_NAME/ gs://$BUCKET_NAME/ 

pwd

python kubernetes/job-executer.py "$INPUT_DIR_NAME" "$OUTPUT_DIR_NAME" "$RULE_NAME" "$BUCKET_NAME"


echo "Fetching pods..."
pods=$(kubectl get pods --no-headers -o custom-columns=":metadata.name")
echo "Available pods:"
echo "$pods"

# Ask the user to choose a pod
read -p "Enter the name of the pod to view logs: " pod_name

# Check if the selected pod has more than one container
container_count=$(kubectl get pod $pod_name -o jsonpath='{.spec.containers[*].name}' | wc -w)

if [ $container_count -gt 1 ]; then
    echo "This pod has multiple containers. Available containers:"
    kubectl get pod $pod_name -o jsonpath='{.spec.containers[*].name}'
    read -p "Enter the name of the container to view logs: " container_name
    kubectl logs $pod_name -c $container_name
else
    kubectl logs $pod_name
fi

echo downloading results from $BUCKET_NAME

sleep 5

gcloud storage cp --recursive gs://$BUCKET_NAME/$OUTPUT_DIR_NAME/ "$(pwd)"/