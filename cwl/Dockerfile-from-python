FROM python

RUN apt-get update && apt-get install -y docker.io vim
COPY requirements.txt .
RUN pip install -r requirements.txt
