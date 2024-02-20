from setuptools import find_packages, setup

setup(
    name="jobs_data_ingest",
    version="0.1",
    packages=find_packages(),
    install_requires=["boto3==1.26.153", "backoff==2.2.1", "elasticsearch==7.17.9"],
)
