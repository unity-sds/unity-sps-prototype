import json
import boto3
from elasticsearch import Elasticsearch
import logging
import backoff
import os

region = os.environ["REGION"]
elasticsearch_endpoint = os.environ['ELASTICSEARCH_ENDPOINT']
es = Elasticsearch(elasticsearch_endpoint)

logger = logging.getLogger()
logger.setLevel(logging.INFO)


@backoff.on_exception(backoff.expo, Exception, jitter=backoff.full_jitter, max_tries=4)
def index_document(message):
    index = "jobs"
    id = message["id"]

    # Index the document (create new or update existing)
    es.index(index=index, id=id, body=message)
    logger.info(f'Successfully indexed document: {id}')


def lambda_handler(event, context):
    role = boto3.client('sts').get_caller_identity().get('Arn')
    logger.info(f"Lambda function is running with AWS role: {role}")
    for record in event['Records']:
        message_body = json.loads(record['body'])
        message = json.loads(message_body['Message'])

        try:
            index_document(message)
        except Exception as e:
            logger.error(f'Failed to index document after retries: {message["id"]}')
            raise e

    return {"statusCode": 200}
