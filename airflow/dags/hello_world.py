"""
# DAG Name: Hello World

# Purpose

# Usage
"""  # noqa: E501
import time
from datetime import datetime

from airflow import DAG
from airflow.operators.python import PythonOperator

default_args = {
    "owner": "example",
    "start_date": datetime.utcfromtimestamp(0),
}


def hello_world():
    print("Hello World")
    time.sleep(30)


with DAG(
    dag_id="hello_world",
    doc_md=__doc__,
    default_args=default_args,
    schedule=None,
    is_paused_upon_creation=False,
    tags=["example"],
) as dag:
    hello_world_task = PythonOperator(
        task_id="hello_world",
        python_callable=hello_world
    )
    hello_world_task
