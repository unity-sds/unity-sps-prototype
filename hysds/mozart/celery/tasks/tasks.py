from celery import Celery
import redis
import msgpack

app = Celery('tasks', broker='pyamqp://guest:guest@rabbitmq:5672//')
r = redis.Redis(host="redis", port=6379, db=0)

REDIS_LIST = "logstash"


@app.task
def get_data(payload):
    r.rpush(REDIS_LIST, msgpack.dumps(payload))
    return payload
