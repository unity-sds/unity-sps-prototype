from uuid import uuid4
import time
from datetime import datetime
import random

from tasks import get_data

JOB_STATUSES = ["job-queued", "job-started", "job-completed"]


while True:
    payload = {
        "celery_hostname": "##############",
        "type": "##########",
        "payload_id": str(uuid4()),
        "resource": "job",
        "uuid": str(uuid4()),
        "dedup": True,
        "@version": "1",
        "job_id": "##########",
        "status": random.choice(JOB_STATUSES),
        "@timestamp": datetime.now().isoformat(),
    }
    print(payload)
    task_id = get_data.apply_async(args=[payload], queue="mozart-jobs")
    time.sleep(random.uniform(0, 0.5))
