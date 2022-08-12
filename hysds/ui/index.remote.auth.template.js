// settings are changed if you want to do local development
exports.LOCAL_DEV = true;

// authentication
exports.AUTH = true;

exports.API_GATEWAY_BASE_URL =
  "https://1gp9st60gd.execute-api.us-west-2.amazonaws.com/dev";

// GRQ's ES url
exports.GRQ_ES_URL = `${this.API_GATEWAY_BASE_URL}/grq-es/`;
exports.GRQ_ES_INDICES = "grq";

// GRQ's Rest API
exports.GRQ_API_BASE = `${this.API_GATEWAY_BASE_URL}/grq-api/`; // base url for GRQ API
exports.GRQ_REST_API_V1 = `${this.GRQ_API_BASE}/api/v0.1`;
exports.GRQ_REST_API_V2 = `${this.GRQ_API_BASE}/api/v0.2`;

// used to view verdi job worker logs
exports.MOZART_BASE_URL = "";

// Mozart's ES url
exports.MOZART_ES_URL = `${this.API_GATEWAY_BASE_URL}/mozart-es/`;
exports.MOZART_ES_INDICES = "job_status";

// Mozart's Rest API
exports.MOZART_REST_API_BASE = `${this.API_GATEWAY_BASE_URL}/mozart-rest-api/`;
exports.MOZART_REST_API_V1 = `${this.MOZART_REST_API_BASE}/api/v0.1`;
exports.MOZART_REST_API_V2 = `${this.MOZART_REST_API_BASE}/api/v0.2`;

// Metrics URLS
exports.METRICS_URL = "http://localhost:9100";
exports.KIBANA_URL = `${this.METRICS_URL}/app/kibana`;

// RabbitMQ
exports.RABBIT_MQ_PORT = 15672;

// root path for app
// set to "/" if you are developing locally
exports.ROOT_PATH = "/dev/hysds_ui/";

// OAuth2 configs
exports.OAUTH2_CLIENT_ID = "71g0c73jl77gsqhtlfg2ht388c";
exports.OAUTH2_REDIRECT_URI = `${this.API_GATEWAY_BASE_URL}/hysds-ui/`;
exports.OAUTH2_PROVIDER_URL =
  "https://unitysds.auth.us-west-2.amazoncognito.com/oauth2";
exports.APP_VIEWER_GROUP_NAME = "Unity_Viewer";
exports.APP_ADMIN_GROUP_NAME = "Unity_Viewer";
