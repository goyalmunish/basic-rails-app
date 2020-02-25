local namespace = std.extVar('namespace');
local utils = import 'utils.jsonnet';

local obj_name = 'mysql';

local mysql_service = function(namespace) (
  local ports = [
    {
      name: 'mysql',
      port: 33060,
      targetPort: 'server',
      protocol: 'TCP',
    },
  ];

  utils.basic_service(obj_name, ports, namespace=namespace)
);

local mysql_deployment = function(namespace) (
  local containers = [
    {
      name: 'mysql',
      image: 'mysql',
      imagePullPolicy: 'Always',
      env: [
        {
          name: 'MYSQL_ROOT_PASSWORD',
          value: 'root',
        },
      ],
      ports: [
        {
          name: 'server',
          containerPort: 3306,
        },
      ],
      args: ['--default-authentication-plugin=mysql_native_password'],
    },
  ];

  utils.basic_deployment('mysql', containers, namespace=namespace)
);


[mysql_service(namespace=namespace), mysql_deployment(namespace=namespace)]
