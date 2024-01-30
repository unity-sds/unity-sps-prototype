from datetime import datetime, timedelta
from airflow import DAG
from kubernetes.client import models as k8s
from airflow.providers.cncf.kubernetes.operators.kubernetes_pod import KubernetesPodOperator
from airflow.operators.bash import BashOperator
from airflow.models.param import Param
import uuid

default_cwl_workflow = "https://raw.githubusercontent.com/unity-sds/unity-sps-prototype/cwl-docker/cwl/cwl_workflows/hello_world_from_docker.cwl"

# Default DAG configuration
dag_default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1, 0, 0)
}

# The DAG
dag = DAG(dag_id='docker-cwl-kpo',
          description='Kubernetes Pod Oprator to execute a CWL workflow with docker-in-docker',
          tags=['cwl', 'unity-sps', "docker"],
          is_paused_upon_creation=True,
          catchup=False,
          schedule_interval=None,
          max_active_runs=1,
          default_args=dag_default_args,
          params={
            "cwl_workflow": Param(default_cwl_workflow, type="string"),
          })

# Environment variables
default_env_vars = {}

job_name = "docker-cwl-job"
meta_name = 'docker-cwl-pod-' + uuid.uuid4().hex
metadata = k8s.V1ObjectMeta(name=(meta_name))
full_pod_spec = k8s.V1Pod(
    metadata=metadata,
)

stage_in_task = BashOperator(
    task_id="stage_in",
    dag=dag,
    bash_command="echo Downloading data")

# This section defines KubernetesPodOperator
cwl_task = KubernetesPodOperator(
    namespace="airflow",
    name=job_name,
    is_delete_operator_pod=True,
    hostnetwork=False,
    startup_timeout_seconds=1000,
    get_logs=True,
    task_id=job_name,
    full_pod_spec=full_pod_spec,
    pod_template_file="/opt/airflow/dags/docker_cwl_pod.yaml",
    arguments=["{{ params.cwl_workflow }}"],
    dag=dag)

stage_out_task = BashOperator(
    task_id="stage_out",
    dag=dag,
    bash_command="echo Uploading data")

stage_in_task >> cwl_task >> stage_out_task
