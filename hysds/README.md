# Containerizing HySDS components/services

# Building the docker image(s)

#### Building the base `hysds` docker image

```bash
docker build . -t hysds-core:unity-v0.0.1 --progress plain
```

#### Building the base docker image for the [Mozart](https://github.com/hysds/mozart) rest API

```bash
# in the hysds/mozart/mozart_rest_api/
docker build . -t hysds-mozart:unity-v0.0.1
```

#### Building the docker image for the simplified celery worker

```bash
# in the mozart/celery directory
docker build . -t celery-tasks:unity-v0.0.1
```

```bash
$ docker images
REPOSITORY           TAG                  IMAGE ID       CREATED              SIZE
hysds-mozart         unity-v0.0.1         dad6831f1b04   4 seconds ago        1.1GB
hysds-core           unity-v0.0.1         82a09dc4a50a   About a minute ago   997MB
celery-tasks         unity-v0.0.1         a894468c7101   31 minutes ago       189MB
```

# Running HySDS (Mozart) in K8

#### Create the ConfigMap for `celeryconfig.py`

```bash
# in the hysds/ root directory
kubectl create configmap celeryconfig --from-file celeryconfig.py

# if using Docker desktop
kubectl.docker create configmap celeryconfig --from-file celeryconfig.py
```

#### Create the ConfigMap for Mozart Rest APIs `settings.cfg`

```bash
# in the hysds/ root directory
kubectl create configmap mozart-settings --from-file ./mozart/mozart_rest_api/settings.cfg

# if using Docker desktop
kubectl.docker create configmap mozart-settings --from-file ./mozart/mozart_rest_api/settings.cfg
```

#### Create ConfigMap for Logstash

```bash
# in the hysds/mozart/ directory
kubectl create configmap logstash-configs \
  --from-file=job-status=logstash/job_status.template.json \
  --from-file=event-status=logstash/event_status.template.json \
  --from-file=worker-status=logstash/worker_status.template.json \
  --from-file=task-status=logstash/task_status.template.json \
  --from-file=logstash-conf=logstash/logstash.conf \
  --from-file=logstash-yml=logstash/logstash.yml

# if using Docker desktop
kubectl.docker create configmap logstash-configs \
  --from-file=job-status=logstash/job_status.template.json \
  --from-file=event-status=logstash/event_status.template.json \
  --from-file=worker-status=logstash/worker_status.template.json \
  --from-file=task-status=logstash/task_status.template.json \
  --from-file=logstash-conf=logstash/logstash.conf \
  --from-file=logstash-yml=logstash/logstash.yml
```

```bash
$ kubectl get cm
NAME               DATA   AGE
celeryconfig       1      8m25s
logstash-configs   6      5s
mozart-settings    1      6m46s
```

#### Starting Mozart's Elasticsearch cluster with [Helm](https://github.com/elastic/helm-charts/tree/master/elasticsearch)

```bash
# downloading the helm charts from the repository
helm repo add elastic https://helm.elastic.co

# starting the cluster
helm install mozart-es elastic/elasticsearch --version 7.9.3 -f elasticsearch/values-override.yml

# tearing down the cluster
helm uninstall mozart-es
```

```bash
$ curl http://localhost:9200
# {
#   "name" : "elasticsearch-master-0",
#   "cluster_name" : "elasticsearch",
#   "cluster_uuid" : "zgdl-h2_TR68yOZwVWdUwA",
#   "version" : {
#     "number" : "7.9.3",
#     "build_flavor" : "default",
#     "build_type" : "docker",
#     "build_hash" : "c4138e51121ef06a6404866cddc601906fe5c868",
#     "build_date" : "2020-10-16T10:36:16.141335Z",
#     "build_snapshot" : false,
#     "lucene_version" : "8.6.2",
#     "minimum_wire_compatibility_version" : "6.8.0",
#     "minimum_index_compatibility_version" : "6.0.0-beta1"
#   },
#   "tagline" : "You Know, for Search"
# }
```

#### Starting the Mozart Rest API

```bash
# in the hysds/mozart/ directory
kubectl apply -f mozart_rest_api/deployment.yml

# if using Docker desktop
kubectl.docker apply -f mozart_rest_api/deployment.yml
```

![Mozart rest API](./img/mozart-rest-api.png)

#### Starting Redis

```bash
# in the hysds/mozart/ directory
kubectl apply -f redis/deployment.yml

# if using Docker desktop
kubectl.docker apply -f redis/deployment.yml
```

#### Starting Logstash

```bash
# in the hysds/moazrt/ directory
kubectl apply -f logstash/deployment.yml

# if using Docker desktop
kubectl.docker apply -f logstash/deployment.yml
```

#### Starting RabbitMQ

```bash
# in the hysds/moazrt/ directory
kubectl apply -f rabbitmq/deployment.yml

# if using Docker desktop
kubectl.docker apply -f rabbitmq/deployment.yml
```

#### Running the Celery task to publish/consume data

`celery` task to consume data

```bash
# in the hysds/mozart/ directory
kubectl apply -f celery/deployment.yml

# if using Docker desktop
kubectl.docker apply -f celery/deployment.yml
```

python script to publish data

```bash
# in the hysds/mozart/ directory
kubectl run --rm -i --tty celery-publisher \
  --image celery-tasks:unity-v0.0.1 \
  --restart=Never \
  --image-pull-policy=Never -- python tasks/publish.py

# if using Docker desktop
kubectl.docker run --rm -i --tty celery-publisher \
  --image celery-tasks:unity-v0.0.1 \
  --restart=Never \
  --image-pull-policy=Never -- python tasks/publish.py
```

`celery` task logs

```
tail -f celery_tasks.log

Please specify a different user using the --uid option.

User information: uid=0 euid=0 gid=0 egid=0

  warnings.warn(SecurityWarning(ROOT_DISCOURAGED.format(
[2021-11-05 19:50:26,325: INFO/MainProcess] Connected to amqp://guest:**@rabbitmq:5672//
[2021-11-05 19:50:26,340: INFO/MainProcess] mingle: searching for neighbors
[2021-11-05 19:50:27,374: INFO/MainProcess] mingle: all alone
[2021-11-05 19:50:27,406: INFO/MainProcess] celery@celery-tasks ready.
[2021-11-05 19:54:25,061: INFO/MainProcess] Task tasks.get_data[87771a5c-3f5f-4cdf-bace-67256c67004d] received
/usr/local/lib/python3.8/site-packages/celery/platforms.py:834: SecurityWarning: You're running the worker with superuser privileges: this is
absolutely not recommended!

Please specify a different user using the --uid option.

User information: uid=0 euid=0 gid=0 egid=0

  warnings.warn(SecurityWarning(ROOT_DISCOURAGED.format(
[2021-11-05 19:54:25,068: INFO/ForkPoolWorker-2] Task tasks.get_data[87771a5c-3f5f-4cdf-bace-67256c67004d] succeeded in 0.005493774999195011s: {'celery_hostname': '##############', 'type': '##########', 'payload_id': 'd1f1a5c9-fb43-46ca-911c-3aada4d800bb', 'resource': 'job', 'uuid': '3c5b2e98-93f9-4775-a872-641e281b98cf', 'dedup': True, '@version': '1', 'job_id': '##########', 'status': 'job-started', '@timestamp': '2021-11-05T19:54:24.897535'}
[2021-11-05 19:54:25,327: INFO/MainProcess] Task tasks.get_data[4fd0b4d0-bbf0-435f-ad23-5eed19aa3d77] received
[2021-11-05 19:54:25,329: INFO/ForkPoolWorker-2] Task tasks.get_data[4fd0b4d0-bbf0-435f-ad23-5eed19aa3d77] succeeded in 0.0011581799999476061s: {'celery_hostname': '##############', 'type': '##########', 'payload_id': 'f51f0a1d-fbc9-4cf2-a434-baa5a4f0b03f', 'resource': 'job', 'uuid': 'f9477534-99cb-4ece-a483-45ae32480be1', 'dedup': True, '@version': '1', 'job_id': '##########', 'status': 'job-queued', '@timestamp': '2021-11-05T19:54:25.324520'}
...
```

Data ingested into Elasticsearch

```bash
$ curl http://localhost:9200/_cat/indices?v
health status index              uuid                   pri rep docs.count docs.deleted store.size pri.store.size
yellow open   job_status-current QxnnmhokS5-Lw4t8GFxd-A   1   1         62            0     53.1kb         53.1kb
```

#### All K8 resources

```bash
$ kubectl get all
NAME                           READY   STATUS    RESTARTS   AGE
pod/celery-tasks               1/1     Running   0          5m57s
pod/elasticsearch-master-0     1/1     Running   0          74m
pod/logstash-f6897dbb7-trfcs   1/1     Running   0          14m
pod/mozart-56f7f5f4b7-kk6qf    1/1     Running   0          27m
pod/rabbitmq-0                 1/1     Running   0          6m18s
pod/redis-6f486db698-87858     1/1     Running   0          17m

NAME                         TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                         AGE
service/kubernetes           ClusterIP      10.96.0.1        <none>        443/TCP                         24d
service/mozart               LoadBalancer   10.107.138.240   localhost     8888:30726/TCP                  27m
service/mozart-es            LoadBalancer   10.106.93.11     localhost     9200:30534/TCP,9300:30732/TCP   74m
service/mozart-es-headless   ClusterIP      None             <none>        9200/TCP,9300/TCP               74m
service/rabbitmq             NodePort       10.98.122.55     <none>        4369:30294/TCP,5672:32741/TCP   6m18s
service/rabbitmq-mgmt        LoadBalancer   10.109.226.52    localhost     15672:31962/TCP                 6m18s
service/redis                NodePort       10.108.5.17      <none>        6379:30914/TCP                  17m

NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/logstash   1/1     1            1           14m
deployment.apps/mozart     1/1     1            1           27m
deployment.apps/redis      1/1     1            1           17m

NAME                                 DESIRED   CURRENT   READY   AGE
replicaset.apps/logstash-f6897dbb7   1         1         1       14m
replicaset.apps/mozart-56f7f5f4b7    1         1         1       27m
replicaset.apps/redis-6f486db698     1         1         1       17m

NAME                                    READY   AGE
statefulset.apps/elasticsearch-master   1/1     74m
statefulset.apps/rabbitmq               1/1     6m18s
```

## Deleting K8 cluster

```bash
$ helm uninstall mozart-es
$ kubectl delete all --all
$ kubectl delete cm --all  # deletes ConfigMap(s)
$ kubectl delete pvc --all  # deletes PersistentVolume(s)

# if using Docker desktop
$ helm uninstall mozart-es
$ kubectl.docker delete all --all
$ kubectl.docker delete cm --all  # deletes ConfigMap(s)
$ kubectl.docker delete pvc --all  # deletes PersistentVolume(s)
```
