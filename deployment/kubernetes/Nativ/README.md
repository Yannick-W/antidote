# Deploying Antidote with Kubernetes 

Here I tested to deploy antidote with kubernetes using only bash scripts and the command line tool [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/) from kubernetes.  
In the following it will be explained what is possible to do within this repository.

## Prerequisites

### kubectl
`kubectl` has to be configured, such that is has access to a kubernetes cluster.
An easy to use testenvironment for kubernetes is minikube. Installation documentation [here](https://kubernetes.io/docs/tasks/tools/install-minikube/).

Note that by default all scripts in this repository use the default namespace of the kubernetes cluster.

### antidote-image
You have to configure which antidote image to use in the deployments. This scripts are tested with antidote version 0.2.2!
You may change the value of the var IMAGE from `deployDC.sh` to the image you want to use. Make sure you escape all "/" since this is used in a sed command.  
If you want to build your own images, refere to [docker-antidote](https://github.com/AntidoteDB/docker-antidote).

### storage
You have to define a storage class object before deploying any antidote data centers. You can use the script createStorageClass.sh to deploy the storage class template from the resources/templates directory.  
Note, that the here presented approach in general does **not** provide local storage! But since minikube operates on only one node this problem is not addressed here.
More information about local storage can be found [here](https://kubernetes.io/blog/2019/04/04/kubernetes-1.14-local-persistent-volumes-ga/).

## Deployment

To deploy an Antidote data center simply use the script `deployDC.sh` with arguments $1=datacenterName
(format for names as stated [here](https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names): "The characters allowed in names are: digits (0-9), lower case letters (a-z), -, and ..")
and $2=replicas, which means the number of instances that will be generated for this dc.

Example:
```
	bash deployDC.sh dc1 2
```
Which will create a data center with name "dc1" and 2 antidote instances.

The script will automatically deploy the following kubernetes objects to the cluster:
- statefulset: this also consists of a containers template for the antidote container
- headless service: a [headless service](https://kubernetes.io/docs/concepts/services-networking/service/#headless-services) for the statefulset
- pods: made automatically by the statefulset controller (defined in the statefulset yaml)
- persistent volumen claims: made automatically by the statefulset controller (also defined in the statefulset yaml)
- pod-services: for each pod there will be created a [LoadBalancer service](https://kubernetes.io/de/docs/tutorials/kubernetes-basics/expose/expose-intro/) to allow access from outside the cluster (note that you can expose a service using minikube service <service-name> in minikube to the local network). We have to create a service for every pod, since we want all antidote instances to be accessible from outside the cluster.
- persistent volume: for each pod, where its type is depending on the storage class configurations
- jobs: to create a data center or for connecting various data centers jobs are created; this jobs may create pods.

You may find all resources that where deployed for this data center in `resources/deployments/<datacenterName>`.  
Aswell as all deployed jobs in `resources/jobs`.  
And all templates in `resources/templates`.

### Configuration
You may edit any of the templates in resources/templates.
Any expressions `${*}` will be replaced by the scripts.  
Of most importance should be the `statefulset_antidote-template.yamle`. There you may configure anything related to the antidote instances.
It is possible to configure different [lifecycle_hooks](https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/), [commands](https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/), different environment variables, resource requests, etc...

### Connecting antidote data centers
To connect different of the deployed antidote data centers use the script `connectDCs.sh` which takes a list of data center names as input.

Example:  
Assuming you have deployed two data centers `dc1` and `dc2` with the script `deployDC.sh`:
```
bash connectDCs.sh dc1 dc2
```
This will then make both data centers subscribe to each other.

### Deleting antidote data centers
To delete antidote data centers use the script `deleteDC` which takes a list of data center names and deletes them consecutively.
It will delete all kubernetes resources that are related to this names. Also, it will delete the `resources/deployments/<datacenterName>` directory.

But: It will NOT delete any persistent volumes automatically. You have to delete them manually.
Note that if you for example delete a data center with name `dc1` and then deploy a data center with the same name, the pods of this new data center will claim the persistent volumes from the old data center, since these pods share the same names as these from the old data center.
Kubernetes will assume these pods where simply restarted and therefore rebind the volumes. So you may keep that in mind.

### Misc
The script `getDeployed.sh` will simply issue the kubernetes command to fetch the statefulsets, that are labeld to have been deployed with this repository.


## Minikube

If you have used minikube as the kubernetes cluster here are a few things to note.
Note that it is necessary to delete and start minikube again (stop is not sufficient) to make sure a change to the configuration of minikube is registered.
The minikube configuration file's location is by default:
- linux: `~/.minikube/config/config.json`
- windows: `C:/user/userX/.minikube/config/config.json`

### Insecure registry flag
You may want to use a private registry that is insecure. 
For that you have to start minikube with the flag --insecure-registry: `minikube start --insecure-registry="hostname:port"`.

### Enough ressources
You may configure minikube with more cpus and memory.
Antidote needs normally 2 cpus and 2 Gig memory to run.
The default settings for minikube are around the same value, where the default cluster setup needs at least an eighth.

### Monitoring
Use `minikube dashboard` to monitor the objects and their status that where created in the minikube cluster.


You may also activate the heapster addon, or others. See [here](https://kubernetes.io/de/docs/tutorials/hello-minikube/#addons-aktivieren) how to do so.  
The heapster addon allows to monitor the kubernetes cluster and its pods traffic via grafana.
