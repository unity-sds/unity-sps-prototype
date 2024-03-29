broker_url = "amqp://guest:guest@rabbitmq:${rabbitmq_service_port}//"
result_backend = "redis://redis:${redis_service_port}"

task_serializer = "msgpack"
result_serializer = "msgpack"
accept_content = ["msgpack"]

task_acks_late = True
result_expires = 86400
worker_prefetch_multiplier = 1

event_serializer = "msgpack"
worker_send_task_events = True
task_send_sent_event = True
task_track_started = True

task_queue_max_priority = 10

task_reject_on_worker_lost = True

broker_heartbeat = 120
broker_heartbeat_checkrate = 2

broker_pool_limit = None
broker_transport_options = {"confirm_publish": True}

imports = [
    "hysds.task_worker",
    "hysds.job_worker",
    "hysds.orchestrator",
]

CELERY_SEND_TASK_ERROR_EMAILS = False
ADMINS = (("{{ ADMIN_NAME }}", "{{ ADMIN_EMAIL }}"),)
SERVER_EMAIL = "{{ HOST_STRING }}"

HYSDS_HANDLE_SIGNALS = False
HYSDS_JOB_STATUS_EXPIRES = 86400

BACKOFF_MAX_VALUE = 64
BACKOFF_MAX_TRIES = 10

HARD_TIME_LIMIT_GAP = 300

PYMONITOREDRUNNER_CFG = {
    "rabbitmq": {
        "hostname": "{{ MOZART_RABBIT_PVT_IP }}",
        "port": ${rabbitmq_service_port},
        "queue": "stdouterr",
    },
    "StreamObserverFileWriter": {
        "stdout_filepath": "_stdout.txt",
        "stderr_filepath": "_stderr.txt",
    },
    "StreamObserverMessenger": {"send_interval": 1},
}

MOZART_URL = "https://mozart:${mozart_service_port}/mozart/"
MOZART_REST_URL = "http://mozart:${mozart_service_port}/api/v0.1"
JOBS_ES_URL = "http://mozart-es:${mozart_es_port}"
JOBS_PROCESSED_QUEUE = "jobs_processed"
USER_RULES_JOB_QUEUE = "user_rules_job"
ON_DEMAND_JOB_QUEUE = "on_demand_job"
USER_RULES_JOB_INDEX = "user_rules-mozart"
STATUS_ALIAS = "job_status"

TOSCA_URL = "https://{{ GRQ_PVT_IP }}/search/"
GRQ_URL = "http://grq2:${grq2_service_port}"
GRQ_REST_URL = "http://grq2:${grq2_service_port}/api/v0.1"
GRQ_UPDATE_URL = "http://grq2:${grq2_service_port}/api/v0.1/grq/dataset/index"


GRQ_AWS_ES = False
GRQ_ES_HOST = "grq-es"
GRQ_ES_PORT = ${grq2_es_port}
GRQ_ES_PROTOCOL = "http"
GRQ_ES_URL = "%s://%s:%d" % (GRQ_ES_PROTOCOL, GRQ_ES_HOST, GRQ_ES_PORT)


DATASET_PROCESSED_QUEUE = "dataset_processed"
USER_RULES_DATASET_QUEUE = "user_rules_dataset"
ON_DEMAND_DATASET_QUEUE = "on_demand_dataset"
USER_RULES_DATASET_INDEX = "user_rules-grq"
DATASET_ALIAS = "grq"

HYSDS_IOS_MOZART = "hysds_ios-mozart"
HYSDS_IOS_GRQ = "hysds_ios-grq"

USER_RULES_TRIGGER_QUEUE = "user_rules_trigger"

PROCESS_EVENTS_TASKS_QUEUE = "process_events_tasks"

METRICS_ES_URL = "http://{{ METRICS_ES_PVT_IP }}:${mozart_es_port}"

# REDIS_JOB_STATUS_URL = "redis://:{{ MOZART_REDIS_PASSWORD }}@{{ MOZART_REDIS_PVT_IP }}"
REDIS_JOB_STATUS_URL = "redis://redis:${redis_service_port}"
REDIS_JOB_STATUS_KEY = "logstash"
REDIS_JOB_INFO_URL = "redis://redis:${redis_service_port}"
REDIS_JOB_INFO_KEY = "logstash"
REDIS_INSTANCE_METRICS_URL = (
    "redis://:{{ METRICS_REDIS_PASSWORD }}@{{ METRICS_REDIS_PVT_IP }}"
)
REDIS_INSTANCE_METRICS_KEY = "logstash"
# REDIS_UNIX_DOMAIN_SOCKET = "unix://:{{ MOZART_REDIS_PASSWORD }}@/tmp/redis.sock"
REDIS_UNIX_DOMAIN_SOCKET = "unix://:/tmp/redis.sock"

WORKER_CONTIGUOUS_FAILURE_THRESHOLD = 10
WORKER_CONTIGUOUS_FAILURE_TIME = 5.0

# ROOT_WORK_DIR = "/data/work"
ROOT_WORK_DIR = "/tmp/data/work"
WEBDAV_URL = None
WEBDAV_PORT = 8085

WORKER_MOUNT_BLACKLIST = [
    "/dev",
    "/etc",
    "/lib",
    "/proc",
    "/usr",
    "/var",
]

CONTAINER_REGISTRY = "{{ CONTAINER_REGISTRY }}"

AWS_REGION = "{{ AWS_REGION }}"
