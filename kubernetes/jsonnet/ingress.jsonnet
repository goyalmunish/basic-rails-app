local namespace = std.extVar('namespace');
local utils = import 'utils.jsonnet';

local root_domain = utils.project_name + '.com';

// Notes:
// To make ingress work, you would need to issue `sudo ./minikube addons enable ingress`.
// You would need to set `<IP> jenkins.local-host.com` in `/etc/hosts` file (or similar). Here, `<IP>` is taken from `kubectl get ingress/jenkins -o wide`.
// While setup, make sure to update "Jenkins URL" as `http://jenkins.local-host.com`. Later on it can be changed through `http://jenkins.local-host.com/configure`.
// You can test your configuration using `curl` as: `curl --user username:password jenkins.local-host.com/jenkins`.
// Note that if service is created as `LoadBalancer` type, then before "Jenkins URL" is set, you can access jenkins service via url as given by
// `./minikube service jenkins --url` as well, which directly uses service using NodePort.

local subdomain_based_ingress_rule = function(root_domain, service_name, service_port) {
  host: service_name + '.' + root_domain,
  http: {
    paths: [
      {
        path: '/',
        backend: {
          serviceName: service_name,
          servicePort: service_port,
        },
      },
    ],
  },
};

local services = [
  { service_name: 'basic-rails-app', service_port: 8080 },
  { service_name: 'debug-rails-server', service_port: 8080 },
];

local devenv_ingress = function(namespace, services) {
  apiVersion: 'extensions/v1beta1',
  kind: 'Ingress',
  metadata: {
    name: utils.project_name,
    namespace: namespace,
    labels: {
      project: utils.project_name,
    },
    annotations: {
      'nginx.ingress.kubernetes.io/rewrite-target': '/',
    },
  },
  spec: {
    rules: [
      subdomain_based_ingress_rule(root_domain, service.service_name, service.service_port)
      for service in services
    ],
  },
};

[devenv_ingress(namespace=namespace, services=services)]
