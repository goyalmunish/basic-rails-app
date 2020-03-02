local project_name = 'devenv';

local sub_home_dir_mount(volume_name, dir_home, sub_dir_name) = {
  mountPath: dir_home + '/' + sub_dir_name,
  name: volume_name,
  subPath: sub_dir_name,
};


local parse_ssh_auth_socket_path(path) = (
  if path != '' then
    local splits = std.split(path, '/');
    local len = std.length(splits);
    { base_dir: std.join('/', splits[0:len - 1]), file: splits[len - 1] }
  else
    { base_dir: '', file: '' }
);


local get_ps_start(ps_start, container) = (
  std.join('-', [ps_start, container.name])
);


local basic_deployment = function(obj_name, containers, init_containers=[], volumes=[], replicas=1, namespace='default') {
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: obj_name,
    namespace: namespace,
  },
  spec: {
    selector: {
      matchLabels: {
        app: obj_name,
        project: project_name,
      },
    },
    replicas: replicas,
    template: {
      metadata: {
        labels: {
          app: obj_name,
          project: project_name,
        },
      },
      spec: {
        containers: containers,
        initContainers: init_containers,
        volumes: volumes,
      },
    },
  },
};

local basic_service = function(obj_name, ports=[], service_name='', service_type='ClusterIP', namespace='default') {
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: (
      if service_name != '' then
        service_name
      else
        obj_name
    ),
    namespace: namespace,
    labels: {
      app: obj_name,
      project: project_name,
    },
  },
  spec: {
    type: service_type,
    selector: {
      app: obj_name,
      project: project_name,
    },
    ports: ports,
  },
};


local init_container_wait_for = function(host, port) (
  local port_str = std.toString(port);
  {
    name: 'wait-for-' + host + '-' + port_str,
    image: 'busybox',
    imagePullPolicy: 'Always',
    command: [
      'sh',
      '-c',
      'until nc -zv -w 2 ' + host + ' ' + port_str + '; do echo waiting for ' + host + ':' + port_str + '; sleep 2; done; echo ' + host + ':' + port_str + ' is now available!',
    ],
  }
);


// make sure to mount user's home directory to `/host_user_home` on the cluster node (if `minikube` is run without `--vm-driver=none`)
// for example, `./minikube start --mount-string="$HOME:/host_user_home" --mount`
// but if `minikube` created a docker container serving as a node, then mounting is not required, but you can just share a directory as volume to minikube node
local devenv_based_deployment = function(
  ps_start='',
  dir_host_user_home='/host_user_home',
  dir_ssh_auth_socket='',
  sub_home_dirs=['MG/cst', '.ssh', '.kube', '.aws', '.config/gcloud'],
  keychain_enabled='False',
  obj_name=project_name,
  command='',
  args='',
  init_containers=[],
  additional_envs=[],
  additional_containers=[],
  replicas=1,
  namespace='default'
                                )
  (

    local dir_home = '/root';
    local image_name = 'goyalmunish/devenv';

    local volumes = [
      {
        name: 'host-user-home',
        hostPath: {
          path: dir_host_user_home,
          type: 'Directory',
        },
      },
    ] + (
      if dir_ssh_auth_socket != '' then
        [
          {
            name: 'ssh-auth-socket',
            hostPath: {
              path: parse_ssh_auth_socket_path(dir_ssh_auth_socket).base_dir,
              type: 'Directory',
            },
          },
        ]
      else
        []
    );

    local container = {
      local current_obj = self,
      name: obj_name,
      image: image_name,
      imagePullPolicy: 'Always',
      env: [
        {
          name: 'PS_START',
          value: get_ps_start(ps_start, current_obj),
        },
        {
          name: 'KEYCHAIN_ENABLED',
          value: keychain_enabled,
        },
        {
          name: 'SSH_AUTH_SOCK',
          value: '/ssh-agent',
        },
      ] + additional_envs,
      volumeMounts: [
        sub_home_dir_mount('host-user-home', dir_home, sub_dir_name)
        for sub_dir_name in sub_home_dirs
      ] + (
        if dir_ssh_auth_socket != '' then
          [
            {
              mountPath: '/ssh-agent',
              name: 'ssh-auth-socket',
              subPath: parse_ssh_auth_socket_path(dir_ssh_auth_socket).file,
            },
          ]
        else
          []
      ),
    };

    local container_with_command = (
      if command != '' then
        container {
          command: command,
        }
      else
        container
    );

    local container_with_args = (
      if args != '' then
        container {
          args: args,
        }
      else
        container
    );

    basic_deployment(obj_name, [container_with_command] + additional_containers, init_containers, volumes, replicas, namespace)
  );


{
  project_name: project_name,
  get_ps_start: get_ps_start,
  sub_home_dir_mount: sub_home_dir_mount,
  parse_ssh_auth_socket_path: parse_ssh_auth_socket_path,
  basic_deployment: basic_deployment,
  basic_service: basic_service,
  devenv_based_deployment: devenv_based_deployment,
  init_container_wait_for: init_container_wait_for,
}
