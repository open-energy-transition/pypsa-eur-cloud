import kubernetes	
import yaml	
from kubernetes import client, config, utils	
from kubernetes.stream import stream	
import sys

input_dir = sys.argv[1]	
output_dir = sys.argv[2]	
rule=sys.argv[3]
bucket_name=sys.argv[4]

config.load_kube_config()	
yaml_file = '/home/akshat/pypsa-eur-cloud/kubernetes/k8-job.yaml'	
k8s_client = client.ApiClient()	


with open(yaml_file, 'r') as file:	
    yaml_content = yaml.safe_load(file)	

try:	
    print(yaml_content)	

    yaml_content['spec']['template']['spec']['containers'][0]['args'] = ["-c", f"{rule}"]	

    for volume_mount in yaml_content['spec']['template']['spec']['containers'][0]['volumeMounts']:	
        if volume_mount['name'] == "gcs-fuse-csi-inline-1":	
            volume_mount['mountPath'] = f"/{input_dir}"	

        if volume_mount['name'] == "gcs-fuse-csi-inline-2":	
            volume_mount['mountPath'] = f"/{output_dir}"	


    for volume in yaml_content['spec']['template']['spec']['volumes']:	

        volume['csi']['volumeAttributes']['bucketName']=bucket_name	

        if volume['name'] == "gcs-fuse-csi-inline-1":	
            volume['csi']['volumeAttributes']['mountOptions'] = f"debug_fuse,debug_fs,debug_gcs,implicit-dirs,only-dir={input_dir}"	
        if volume['name'] == "gcs-fuse-csi-inline-2":	
            volume['csi']['volumeAttributes']['mountOptions'] = f"debug_fuse,debug_fs,debug_gcs,implicit-dirs,only-dir={output_dir}"	

    print('\n')	
    print(yaml_content)	

    utils.create_from_dict(k8s_client, yaml_content)	
    job_name = yaml_content['metadata']['name']	
    namespace = yaml_content.get('metadata', {}).get('namespace', 'default')	
    print(yaml_content)
    
    
except kubernetes.client.exceptions.ApiException as e:	
    print(f"An error occurred: {e}")