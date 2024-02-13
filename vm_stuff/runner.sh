INPUT_DIR_NAME=$1
OUTPUT_DIR_NAME=$2


echo "input dir: $INPUT_DIR_NAME"
echo "output dir: $OUTPUT_DIR_NAME"

echo creating your VM....
gcloud compute instances create labrat \
    --project=stately-forest-407206 \
    --zone=us-west4-b \
    --machine-type=e2-highmem-2 \
    --maintenance-policy=MIGRATE \
    --provisioning-model=STANDARD \
    --metadata=enable-guest-attributes=TRUE \
    --metadata-from-file=startup-script=vm_stuff/boot.sh \
    --create-disk=auto-delete=yes,boot=yes,device-name=instance-1,image=projects/debian-cloud/global/images/debian-12-bookworm-v20240110,mode=rw,size=100,type=projects/stately-forest-407206/zones/us-west4-b/diskTypes/pd-ssd \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --labels=goog-ec-src=vm_add-gcloud \

until gcloud compute instances get-guest-attributes labrat \
    --zone=us-west4-b \
    --query-path=vm/ready > /dev/null 2>&1
do
    sleep 5 && echo waiting for VM to boot...
done


gcloud compute ssh labrat \
    --command='sudo docker pull akshatmittaloet/pypsa-eur:v2.0'  \
    --zone=us-west4-b 


gcloud compute scp --recurse "$(pwd)"/$INPUT_DIR_NAME/ labrat:~/$INPUT_DIR_NAME/ --zone=us-west4-b

gcloud compute ssh labrat \
    --command='sudo docker images'  \
    --zone=us-west4-b 

SNAKEMAKE_COMMAND='snakemake -call results/test-elec/networks/elec_s_6_ec_lcopt_Co2L-24H.nc --configfile config/test/config.electricity.yaml'

DOCKER_COMMAND="sudo docker run -v ~/$INPUT_DIR_NAME/:/$INPUT_DIR_NAME/ -v ~/$OUTPUT_DIR_NAME:/$OUTPUT_DIR_NAME --entrypoint /bin/bash akshatmittaloet/pypsa-eur:v2.0 -c '$SNAKEMAKE_COMMAND'"

echo $DOCKER_COMMAND

gcloud compute ssh labrat \
    --command="$DOCKER_COMMAND"  \
    --zone=us-west4-b 

gcloud compute scp --recurse labrat:~/$OUTPUT_DIR_NAME/ \
    "$(pwd)"/ \
    --zone=us-west4-b

echo deleting VM this will take a while.....
gcloud compute instances delete labrat --zone=us-west4-b --quiet
