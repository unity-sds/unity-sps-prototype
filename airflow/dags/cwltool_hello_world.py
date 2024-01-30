from datetime import datetime
from airflow import DAG
from airflow.operators.bash_operator import BashOperator

default_args = {
    'owner': 'airflow',
    'start_date': datetime(2021, 1, 1),
}

dag = DAG(
    'cwltool_help_dag',
    default_args=default_args,
    description='A simple DAG to run cwltool --help',
    schedule_interval=None,  # This DAG is not scheduled and needs to be triggered manually
)

run_cwl_help = BashOperator(
    task_id='run_cwltool_help',
    bash_command='cwltool --help',
    dag=dag,
)

run_cwl_help
