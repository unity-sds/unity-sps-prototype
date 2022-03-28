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
pod/factotum-job-worker-7d899b4d88-x7btg   1/1     Running     0          110s
pod/grq-es-master-0                        1/1     Running     0          2m49s
pod/grq2-cbc7bdf6f-58bbj                   1/1     Running     0          116s
pod/hysds-ui-6c5d969498-r22vj              1/1     Running     0          2m52s
pod/logstash-f6897dbb7-t6m8v               1/1     Running     0          2m52s
pod/mc                                     0/1     Completed   0          109s
pod/minio-66b9cc99c8-h4d5x                 1/1     Running     0          109s
pod/mozart-cd9ffc587-bpdkh                 1/1     Running     0          3m55s
pod/mozart-es-master-0                     1/1     Running     0          4m49s
pod/orchestrator-d989856b9-q784z           1/1     Running     0          110s
pod/rabbitmq-0                             1/1     Running     0          3m26s
pod/redis-master-0                         1/1     Running     0          3m52s
pod/user-rules-548485c5bb-sq2tx            1/1     Running     0          110s
pod/verdi-6c4f568d4b-xszhz                 1/1     Running     0          110s

NAME                         TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                                                         AGE
service/grq-es               LoadBalancer   10.109.65.123    localhost     9201:31578/TCP,9301:32397/TCP                                   2m49s
service/grq-es-headless      ClusterIP      None             <none>        9201/TCP,9301/TCP                                               2m49s
service/grq2                 LoadBalancer   10.97.176.191    localhost     8878:32578/TCP                                                  116s
service/hysds-ui             LoadBalancer   10.108.128.110   localhost     3000:31000/TCP                                                  2m52s
service/kubernetes           ClusterIP      10.96.0.1        <none>        443/TCP                                                         50d
service/minio                LoadBalancer   10.108.122.255   localhost     9000:31561/TCP,9001:30195/TCP                                   109s
service/mozart               LoadBalancer   10.98.228.223    localhost     8888:32675/TCP                                                  3m55s
service/mozart-es            LoadBalancer   10.105.105.123   localhost     9200:32346/TCP,9300:31416/TCP                                   4m49s
service/mozart-es-headless   ClusterIP      None             <none>        9200/TCP,9300/TCP                                               4m49s
service/rabbitmq             LoadBalancer   10.96.112.226    localhost     5672:31720/TCP,4369:30003/TCP,25672:31914/TCP,15672:31769/TCP   3m26s
service/rabbitmq-headless    ClusterIP      None             <none>        4369/TCP,5672/TCP,25672/TCP,15672/TCP                           3m26s
service/redis-headless       ClusterIP      None             <none>        6379/TCP                                                        3m52s
service/redis-master         ClusterIP      10.108.242.145   <none>        6379/TCP                                                        3m52s

NAME                                  READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/factotum-job-worker   1/1     1            1           110s
deployment.apps/grq2                  1/1     1            1           116s
deployment.apps/hysds-ui              1/1     1            1           2m52s
deployment.apps/logstash              1/1     1            1           2m52s
deployment.apps/minio                 1/1     1            1           109s
deployment.apps/mozart                1/1     1            1           3m55s
deployment.apps/orchestrator          1/1     1            1           110s
deployment.apps/user-rules            1/1     1            1           110s
deployment.apps/verdi                 1/1     1            1           110s

NAME                                             DESIRED   CURRENT   READY   AGE
replicaset.apps/factotum-job-worker-7d899b4d88   1         1         1       110s
replicaset.apps/grq2-cbc7bdf6f                   1         1         1       116s
replicaset.apps/hysds-ui-6c5d969498              1         1         1       2m52s
replicaset.apps/logstash-f6897dbb7               1         1         1       2m52s
replicaset.apps/minio-66b9cc99c8                 1         1         1       109s
replicaset.apps/mozart-cd9ffc587                 1         1         1       3m55s
replicaset.apps/orchestrator-d989856b9           1         1         1       110s
replicaset.apps/user-rules-548485c5bb            1         1         1       110s
replicaset.apps/verdi-6c4f568d4b                 1         1         1       110s

NAME                                READY   AGE
statefulset.apps/grq-es-master      1/1     2m49s
statefulset.apps/mozart-es-master   1/1     4m49s
statefulset.apps/rabbitmq           1/1     3m26s
statefulset.apps/redis-master       1/1     3m52s

$ kubectl get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                                         STORAGECLASS   REASON   AGE
pvc-00fcc62f-6497-490f-832e-80a4248839c7   20Gi       RWO            Delete           Bound    default/minio-pv-claim                        hostpath                2m40s
pvc-02e5ed58-fca7-4ef3-b4cd-6b6eee3e3db6   5Gi        RWO            Delete           Bound    default/mozart-es-master-mozart-es-master-0   hostpath                5m33s
pvc-87d4ef80-02f4-4070-8b4f-16711931f261   8Gi        RWO            Delete           Bound    default/data-rabbitmq-0                       hostpath                4m10s
pvc-b1cc047f-35a4-48ad-8f8d-3a687a498112   5Gi        RWO            Delete           Bound    default/grq-es-master-grq-es-master-0         hostpath                3m33s
pvc-c1824981-3af1-4500-871e-0af233369d18   8Gi        RWO            Delete           Bound    default/redis-data-redis-master-0             hostpath                4m36s

$ kubectl get pvc
NAME                                  STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
data-rabbitmq-0                       Bound    pvc-87d4ef80-02f4-4070-8b4f-16711931f261   8Gi        RWO            hostpath       4m29s
grq-es-master-grq-es-master-0         Bound    pvc-b1cc047f-35a4-48ad-8f8d-3a687a498112   5Gi        RWO            hostpath       3m52s
minio-pv-claim                        Bound    pvc-00fcc62f-6497-490f-832e-80a4248839c7   20Gi       RWO            hostpath       2m59s
mozart-es-master-mozart-es-master-0   Bound    pvc-02e5ed58-fca7-4ef3-b4cd-6b6eee3e3db6   5Gi        RWO            hostpath       5m52s
redis-data-redis-master-0             Bound    pvc-c1824981-3af1-4500-871e-0af233369d18   8Gi        RWO            hostpath       4m55s
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
helm install --wait --timeout 90s rabbitmq bitnami/rabbitmq -f ./mozart/rabbitmq/values.yml
helm install --wait --timeout 90s redis bitnami/redis -f ./mozart/redis/values.yml
kubectl apply -f ./mozart/rest_api/deployment.yml
kubectl apply -f ./grq/rest_api/deployment.yml
kubectl apply -f ./mozart/logstash/deployment.yml
kubectl apply -f ./ui/deployment.yml
kubectl apply -f ./factotum/deployment.yml
kubectl apply -f ./orchestrator/deployment.yml

# start GRQ's ES
helm install grq-es elastic/elasticsearch --version 7.9.3 --timeout 150 -f elasticsearch/values-override.yml
kubectl create configmap grq2-settings --from-file ./grq/rest_api/settings.cfg

helm uninstall mozart-es
helm uninstall grq-es
helm uninstall redis
helm uninstall rabbitmq

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
