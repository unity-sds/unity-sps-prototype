# Pre-requisites

- [Docker](https://www.docker.com/products/docker-desktop)
- [Kubernetes](https://kubernetes.io/)
  - enable kubernetes in [Docker for Desktop](https://docs.docker.com/desktop/kubernetes/#enable-kubernetes) or use [Minikube](https://minikube.sigs.k8s.io/docs/start/)
- `kubectl` - kubernetes command line tool
- [Helm](https://helm.sh/docs/intro/install/)
  - `brew install helm` if on Mac

> :warning: if you're a Linux user, you can create a directory called `/private`

```bash
$ sudo mkdir -p /private/tmp/data
$ sudo chown -R $UID:$(id -g) /private/tmp
```

# Docker resource settings

> :warning: **Make sure to set "Memory" to value >= 6.0GB**

<img src="./img/docker_resource_settings.png" alt="drawing" width="1000"/>

# Building the docker image(s)

#### Building the base `hysds` docker image

use the `build_imges.sh` script to build all necessary docker images at once

```bash
$ ./build_images.sh [--progress plain|--no-cache]
```

```bash
$ docker images
REPOSITORY          TAG                  IMAGE ID       CREATED         SIZE
hysds-ui            unity-v0.0.1         08d98f617351   3 hours ago     19.3MB
factotum            unity-v0.0.1         cd9eff273a89   3 hours ago     1.17GB
hysds-grq2          unity-v0.0.1         c89d99d41e3b   3 hours ago     1.08GB
hysds-mozart        unity-v0.0.1         515d0bf75e50   3 hours ago     1.04GB
hysds-core          unity-v0.0.1         e1ab6d70f58e   3 hours ago     934MB
```

# Deploying cluster on local

use the `deploy.sh` script to deploy all resources at once

```bash
$ ./deploy.sh --help
# Usage:
#   Deploys the HySDS cluster in Kubernetes (Elasticsearch, Rest API, RabbitMQ, Redis, etc.)
#   ./deploy.sh [--docker] [mozart] [grq] [--all]
#   Options:
#     --all : deploy all HySDS resources (Mozart + GRQ + factotum)
#     mozart : deploy Mozart cluster
#     grq : deploy GRQ cluster
#     factotum : deploy factotum

$ ./deploy.sh --all
```

# HySDS Resources

- [Mozart's rest API](https://github.com/hysds/mozart): `http://localhost:8888`
- [GRQ's rest API](https://github.com/hysds/grq2): `http://localhost:8878/api/v0.1/doc/`
- Elasticsearch
  - Mozart: `http://localhost:9200`
  - GRQ: `http://localhost:9201`
- [HySDS UI](https://github.com/hysds/hysds_ui): `http://localhost:3000`
- [Minio](https://min.io/) Server (local s3) - `http://localhost:9000` and `http://localhost:9001`

<img src="./img/hysds-ui-tosca.png" alt="drawing" width="1000"/>

```bash
$ kubectl get all
NAME                                       READY   STATUS      RESTARTS   AGE
pod/factotum-job-worker-7d899b4d88-885xz   1/1     Running     0          14m
pod/grq-es-master-0                        1/1     Running     0          15m
pod/grq2-cbc7bdf6f-qm769                   1/1     Running     0          14m
pod/hysds-ui-6c5d969498-pm7br              1/1     Running     0          15m
pod/logstash-f6897dbb7-f5rrs               1/1     Running     0          15m
pod/mc                                     0/1     Completed   0          14m
pod/minio-66b9cc99c8-b9qth                 1/1     Running     0          14m
pod/mozart-cd9ffc587-djmwq                 1/1     Running     0          16m
pod/mozart-es-master-0                     1/1     Running     0          16m
pod/orchestrator-d989856b9-pkptx           1/1     Running     0          14m
pod/rabbitmq-0                             1/1     Running     0          15m
pod/redis-master-0                         1/1     Running     0          15m
pod/user-rules-548485c5bb-w9k79            1/1     Running     0          14m
pod/verdi-6c4f568d4b-9d5f6                 1/1     Running     0          14m

NAME                         TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                                         AGE
service/grq-es               LoadBalancer   10.98.248.151    localhost     9201:30557/TCP,9301:30957/TCP                   15m
service/grq-es-headless      ClusterIP      None             <none>        9201/TCP,9301/TCP                               15m
service/grq2                 LoadBalancer   10.100.12.236    localhost     8878:31879/TCP                                  14m
service/hysds-ui             LoadBalancer   10.105.112.52    localhost     3000:31000/TCP                                  15m
service/kubernetes           ClusterIP      10.96.0.1        <none>        443/TCP                                         48d
service/minio                LoadBalancer   10.101.34.42     localhost     9000:30405/TCP,9001:31261/TCP                   14m
service/mozart               LoadBalancer   10.96.213.87     localhost     8888:32726/TCP                                  16m
service/mozart-es            LoadBalancer   10.108.63.3      localhost     9200:32299/TCP,9300:32083/TCP                   16m
service/mozart-es-headless   ClusterIP      None             <none>        9200/TCP,9300/TCP                               16m
service/rabbitmq             NodePort       10.110.219.153   <none>        4369:31748/TCP,5672:32150/TCP,15672:32168/TCP   15m
service/rabbitmq-mgmt        LoadBalancer   10.100.15.210    localhost     15672:31377/TCP                                 15m
service/redis-headless       ClusterIP      None             <none>        6379/TCP                                        15m
service/redis-master         ClusterIP      10.100.4.71      <none>        6379/TCP                                        15m

NAME                                  READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/factotum-job-worker   1/1     1            1           14m
deployment.apps/grq2                  1/1     1            1           14m
deployment.apps/hysds-ui              1/1     1            1           15m
deployment.apps/logstash              1/1     1            1           15m
deployment.apps/minio                 1/1     1            1           14m
deployment.apps/mozart                1/1     1            1           16m
deployment.apps/orchestrator          1/1     1            1           14m
deployment.apps/user-rules            1/1     1            1           14m
deployment.apps/verdi                 1/1     1            1           14m

NAME                                             DESIRED   CURRENT   READY   AGE
replicaset.apps/factotum-job-worker-7d899b4d88   1         1         1       14m
replicaset.apps/grq2-cbc7bdf6f                   1         1         1       14m
replicaset.apps/hysds-ui-6c5d969498              1         1         1       15m
replicaset.apps/logstash-f6897dbb7               1         1         1       15m
replicaset.apps/minio-66b9cc99c8                 1         1         1       14m
replicaset.apps/mozart-cd9ffc587                 1         1         1       16m
replicaset.apps/orchestrator-d989856b9           1         1         1       14m
replicaset.apps/user-rules-548485c5bb            1         1         1       14m
replicaset.apps/verdi-6c4f568d4b                 1         1         1       14m

NAME                                READY   AGE
statefulset.apps/grq-es-master      1/1     15m
statefulset.apps/mozart-es-master   1/1     16m
statefulset.apps/rabbitmq           1/1     15m
statefulset.apps/redis-master       1/1     15m

$ kubectl get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                                         STORAGECLASS   REASON   AGE
pvc-07542676-bd22-477e-9257-79e2ef318b2f   5Gi        RWO            Delete           Bound    default/mozart-es-master-mozart-es-master-0   hostpath                17m
pvc-0dc13c15-3063-413c-b515-ea214d5d2273   8Gi        RWO            Delete           Bound    default/redis-data-redis-master-0             hostpath                16m
pvc-cf7e1956-bf8c-4d0a-a6d5-ea83fee40b78   5Gi        RWO            Delete           Bound    default/grq-es-master-grq-es-master-0         hostpath                16m
pvc-f482b0b7-9803-42fe-88de-af7d1e6c30b5   20Gi       RWO            Delete           Bound    default/minio-pv-claim                        hostpath                15m

$ kubectl get pvc
NAME                                  STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
grq-es-master-grq-es-master-0         Bound    pvc-cf7e1956-bf8c-4d0a-a6d5-ea83fee40b78   5Gi        RWO            hostpath       16m
minio-pv-claim                        Bound    pvc-f482b0b7-9803-42fe-88de-af7d1e6c30b5   20Gi       RWO            hostpath       15m
mozart-es-master-mozart-es-master-0   Bound    pvc-07542676-bd22-477e-9257-79e2ef318b2f   5Gi        RWO            hostpath       18m
redis-data-redis-master-0             Bound    pvc-0dc13c15-3063-413c-b515-ea214d5d2273   8Gi        RWO            hostpath       17m
```

# HySDS Bucket(s)

[minio](https://min.io/) is used as an alternative to s3 as an object store

the minio console can be accessed with `http://localhost:9001`:

- user: `hysds`
- password: `password`

a bucket called `datasets` will be created when provisioning

<img src="./img/minio.png" alt="drawing" width="1000"/>

# Building PGEs

use the `build_container.py` python script to build your PGE and publish the job metadata

```bash
$ python build_container.py --help
# usage: build_container.py [-h] [-f FILE_PATH] -i IMAGE [--dry-run]

# optional arguments:
#   -h, --help            show this help message and exit
#   -f FILE_PATH, --file-path FILE_PATH
#   -i IMAGE, --image IMAGE
#   --dry-run

$ python build_container.py -i <pge_name>:<tag> -f ~/path/to/project
```

example:

```bash
python build_container.py -i hello_world:develop -f pge/hello_world
```

##### navigate to Tosca's "on demand" page

<div>
  <img src="./img/on-demand-jobs.png" alt="drawing" width="1000"/>
</div>
</br>
<div>
  <img src="./img/hello_world-job.png" alt="drawing" width="1000"/>
</div>

# Tear down HySDS cluster

use the `destroy.sh` script to tear down your HySDS cluster

```bash
$ ./destroy.sh --help
# Usage:
#   Tear down the HySDS cluster in Kubernetes
#   ./destroy.sh [--docker] [mozart] [grq] [--all]
#   Options:
#     --docker : use if running Kubernetes on Docker for Desktop; kubectl vs kubectl.docker
#     --all : destroy all HySDS resources (Mozart + GRQ + factotum)
#     mozart : destroy mozart cluster
#     grq : destroy GRQ cluster
#     factotum : destroy factotum

$ ./destroy.sh --all
```

# Commands used:

```bash
# create configMap(s)
kubectl create configmap celeryconfig --from-file celeryconfig.py
kubectl create configmap mozart-settings --from-file ./mozart/rest_api/settings.cfg
kubectl create configmap logstash-configs \
  --from-file=job-status=logstash/job_status.template.json \
  --from-file=event-status=logstash/event_status.template.json \
  --from-file=worker-status=logstash/worker_status.template.json \
  --from-file=task-status=logstash/task_status.template.json \
  --from-file=logstash-conf=logstash/logstash.conf \
  --from-file=logstash-yml=logstash/logstash.yml

# helm commands
helm repo add elastic https://helm.elastic.co
helm repo update

# start mozart's ES
helm install mozart-es elastic/elasticsearch --version 7.9.3 --timeout 150 -f elasticsearch/values-override.yml
helm install --wait --timeout 60s redis bitnami/redis -f ./mozart/redis/values.yml
kubectl apply -f ./mozart/rest_api/deployment.yml
kubectl apply -f ./grq/rest_api/deployment.yml
kubectl apply -f ./mozart/logstash/deployment.yml
kubectl apply -f ./mozart/rabbitmq/deployment.yml
kubectl apply -f ./ui/deployment.yml
kubectl apply -f ./factotum/deployment.yml
kubectl apply -f ./orchestrator/deployment.yml

# start GRQ's ES
helm install grq-es elastic/elasticsearch --version 7.9.3 --timeout 150 -f elasticsearch/values-override.yml
kubectl create configmap grq2-settings --from-file ./grq/rest_api/settings.cfg

helm uninstall mozart-es
helm uninstall grq-es
helm uninstall redis

kubectl delete all --all
kubectl delete cm --all  # deletes ConfigMap(s)
kubectl delete pvc --all  # deletes PersistentVolumeClaim(s)
kubectl delete pv --all  # deletes PersistentVolume(s)
```

# Troubleshooting

- delete `/tmp/data` and restart your docker/kubernetes if you run into this issue

```bash
Cannot start service factotum: error while creating mount source path '/host_mnt/d/project/c/test/docker': mkdir /private: file exists
```
