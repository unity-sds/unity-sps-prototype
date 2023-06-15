import json
import boto3
# from requests_aws4auth import AWS4Auth
from elasticsearch import Elasticsearch, NotFoundError
import logging
import backoff
import os

region = os.environ["REGION"]
# service = "opensearch"
elasticsearch_endpoint = os.environ['ELASTICSEARCH_ENDPOINT']

# credentials = boto3.Session().get_credentials()
# awsauth = AWS4Auth(
#     credentials.access_key,
#     credentials.secret_key,
#     zregion,
#     service,
#     session_token=credentials.token,
# )

es = Elasticsearch(elasticsearch_endpoint)

logger = logging.getLogger()
logger.setLevel(logging.INFO)


# @backoff.on_exception(backoff.expo, Exception, jitter=backoff.full_jitter, max_tries=4)
# def index_document(message):
#     index = "jobs"
#     id = message["id"]
#     status = message["status"]

#     # Check if the document exists
#     try:
#         es.get(index=index, id=id)
#         doc_exists = True
#     except NotFoundError:
#         doc_exists = False

#     if doc_exists:
#         # Document exists, update it
#         update_script = {"doc": {"status": status}}
#         es.update(index=index, id=id, body=update_script)
#         logger.info(f'Successfully updated status for document: {id}')
#     else:
#         # Document does not exist, create a new one
#         es.create(index=index, id=id, body=message)
#         logger.info(f'Successfully indexed document: {id}')

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
