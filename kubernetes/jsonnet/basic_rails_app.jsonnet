local namespace = std.extVar('namespace');
local utils = import 'utils.jsonnet';

local obj_name = 'basic-rails-app';

local basic_rails_service = function(namespace) (
  local ports = [
    {
      name: 'web',
      port: 8080,
      targetPort: 'server-web',
      protocol: 'TCP',
    },
  ];

  utils.basic_service(obj_name, ports, service_type='NodePort', namespace=namespace)
);


local basic_rails_deployment = function(namespace) (
  local containers = [
    {
      name: obj_name,
      image: 'goyalmunish/basic-rails-app:latest',
      imagePullPolicy: 'Always',
      ports: [
        {
          name: 'server-web',
          containerPort: 3000,
        },
      ],
    },
  ];

  utils.basic_deployment(obj_name, containers, namespace=namespace)
);


[basic_rails_service(namespace=namespace), basic_rails_deployment(namespace=namespace)]
