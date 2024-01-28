import json
from . import TEST_BASE_DIR


class JsonReader:
    def __init__(self):
        self.data_dir = TEST_BASE_DIR.joinpath("data")
        self.projects = "projects.json"
        self.deploy_post_request_body = "deploy_post_request_body.json"
        self.execution_post_request_body = "execution_post_request_body.json"
        self.start_prewarm_post_request_body = "start_prewarm_post_request_body.json"

    def request_body(self, project_name, process_name, request_body_filename, environment=None):
        if environment:
            data_file_path = [project_name, process_name, environment, request_body_filename]
        else:
            data_file_path = [project_name, process_name, request_body_filename]

        data_file_path = self.data_dir.joinpath(*data_file_path)

        if not data_file_path.exists():
            raise ValueError(f"Data file not found: {data_file_path}")

        if not data_file_path.is_file():
            raise ValueError(f"Data file is not a file: {data_file_path}")

        try:
            with data_file_path.open() as f:
                data = json.load(f)
        except Exception as e:
            raise ValueError(
                f"Error loading data from file: {data_file_path}, {str(e)}"
            )

        return data
