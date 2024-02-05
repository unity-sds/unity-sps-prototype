from datetime import datetime
from airflow import DAG
from kubernetes.client import models as k8s
from airflow.providers.cncf.kubernetes.operators.kubernetes_pod import KubernetesPodOperator
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from airflow.models.param import Param
import json
import uuid


# Default DAG configuration
dag_default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1, 0, 0)
}

# The DAG
default_cwl_workflow = "https://raw.githubusercontent.com/unity-sds/unity-sps-prototype/cwl-docker/cwl/cwl_workflows/echo_from_docker.cwl"
dag = DAG(dag_id='say-hello-from-cwl-and-docker',
          description='Workflow to greet anybody, anytime',
          tags=["CWL", "World Peace", "The United Nations"],
          is_paused_upon_creation=True,
          catchup=False,
          schedule_interval=None,
          max_active_runs=1,
          default_args=dag_default_args,
          params={
              "cwl_workflow": Param(default_cwl_workflow, type="string"),
              "greeting": Param("Hello", type="string"),
              "name": Param("World", type="string"),
          })

# Environment variables
default_env_vars = {}


# Task that captures the DAG specific arguments
# and creates a json-formatted string for the downstream Tasks
def setup(ti=None, **context):
    task_dict = {
        'greeting': context['params']['greeting'],
        'name': context['params']['name']
    }
    ti.xcom_push(key='cwl_args', value=json.dumps(task_dict))


setup_task = PythonOperator(task_id="Setup",
                            python_callable=setup,
                            dag=dag)


stage_in_task = BashOperator(
    task_id="Stage_In",
    dag=dag,
    bash_command="echo Downloading data")

# This section defines KubernetesPodOperator
cwl_task = KubernetesPodOperator(
    namespace="airflow",
    name="CWL_Workflow",
    is_delete_operator_pod=True,
    hostnetwork=False,
    startup_timeout_seconds=1000,
    get_logs=True,
    task_id="CWL_Workflow",
    full_pod_spec=k8s.V1Pod(
        k8s.V1ObjectMeta(name=('docker-cwl-pod-' + uuid.uuid4().hex))),
    pod_template_file="/opt/airflow/dags/docker_cwl_pod.yaml",
    arguments=["{{ params.cwl_workflow }}", "{{ti.xcom_pull(task_ids='Setup', key='cwl_args')}}"],
    # resources={"request_memory": "512Mi", "limit_memory": "1024Mi"},
    dag=dag)

stage_out_task = BashOperator(
    task_id="Stage_Out",
    dag=dag,
    bash_command="echo Uploading data")

setup_task >> stage_in_task >> cwl_task >> stage_out_task
