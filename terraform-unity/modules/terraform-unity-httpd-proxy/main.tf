provider "aws" {
  region = var.region
}

data "aws_ssm_parameter" "proxy_registration_lambda" {
    name = "/unity/cs/management/httpd/httpd-lambda-name"
}

resource "aws_lambda_invocation" "sps_vhost_definition" {
  function_name = data.aws_ssm_parameter.proxy_registration_lambda.value 

  input = jsonencode({
    filename  = var.filename,
    template =<<EOT
<VirtualHost *:8080>

    LoadModule proxy_html_module /usr/lib/apache2/modules/mod_proxy_html.so
    # Rewrite incoming requests to /sps/airflow/ to be served by the proxy
    # Ensure mod_proxy and mod_proxy_http are enabled
    ProxyRequests Off
    ProxyPreserveHost On
    ProxyPass /sps/airflow/ http://${var.airflow_domain_and_port}/
    ProxyPassReverse /sps/airflow/ http://${var.airflow_domain_and_port}/

    # Handle WebSocket connections
    # Ensure mod_proxy_wstunnel is enabled for WebSocket support
    RewriteEngine On
    RewriteCond %%{HTTP:Upgrade} =websocket [NC]
    RewriteRule /sps/airflow/(.*) ws://${var.airflow_domain_and_port}/$1 [P,L]

    # Fallback for non-websocket connections
    RewriteCond %%{HTTP:Upgrade} !=websocket [NC]
    RewriteRule /sps/airflow/(.*) http://${var.airflow_domain_and_port}/$1 [P,L]

    <Location /sps/airflow/>
        Order allow,deny
        Allow from all
	ProxyPassReverse /
	SetOutputFilter  proxy-html
	ProxyHTMLExtended On
	ProxyHTMLURLMap /       /sps/airflow/
	ProxyHTMLURLMap /sps/airflow   /sps/airlfow
	RequestHeader    unset  Accept-Encoding
    </Location>
</VirtualHost
EOT 
})

}