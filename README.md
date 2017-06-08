Prism
=========

The prism role creates a framework for controlling a group of diverse targets
with a uniform playbook interface.  For example, you may want to provision
volumes across different kinds of storage arrays or manage VLANs on switches
made by different vendors.  Prism allows you to define backends that support a
suite of operations and configure specific targets that use those backends.
Once configured, playbooks can be generated to perform specific operations on
a target without regard for its underlying implementation.

This role is intended to serve as a base for other roles which provide their
own backends and operations.


Requirements
------------

Tested with Ansible >= 2.3.0 but may also work with older versions.


Configuration
-------------

In order to use this role effectively you must first understand its concepts of
operations, backends, and targets.  Operations represent the work you want to
perform.  Backends describe the kinds of systems that can be controlled.
Finally, targets represent specific instances of a system.  For the sake of a
simple example, let's imagine we want to abstract remote object storage.  The
operations we need are: Create, Retrieve, Update, and Delete.  A lot of
backends are possible but two obvious examples are: HTTP/REST and FTP.  Now,
let's assume we have a REST API reachable at http://api.example.com/v2 with
username 'foo' and password 'pass' and we have an FTP server at 192.168.2.47
with directory '/pub/api', username 'ftp' and password 'secret'.  Each of these
represent a target.

To configure the backends, first create a directory to store your playbook
templates. The default location is `templates/` in this role.  Next, create a
subdirectory for each backend you wish to support (eg. ftp and http).  Next
create template playbooks in each backend directory for each operation you want
to support (see example below). The files should be named `<operation>.yml.j2`.

To configure the targets, create a directory to store the target definition
files.  The default location is `/etc/prism/targets`.  For each target, create
a configuration file `<target>.yml` (see example below).


Example operation
-----------------
The following file (saved as `create.yml.j2` in the `rest/` subdirectory of
the templates directory) defines the create operation for the 'rest' backend.
```
- hosts: "{{ target_host }}"
  remote_user: "{{ target_user }}"

  tasks:
  - name: REST: Create operation
    uri:
      url: "{{ backend_config.base_url }}/{{ params.path }}"
      method: POST
      user: "{{ backend_config.auth.username }}"
      password: "{{ backend_config.auth.password }}"
      body: "{{ params.object.data }}"
```


Example target definition
-------------------------
The following file (saved as `web.yml`) defines a target called 'web'.
```
# The host and user to use when running the generated playbook
target_host: host.example.com
target_user: admin

# The backend this target uses
backend: rest

# Target specific configuration parameters
backend_config:
  base_url: http://api.example.com/v2
  auth:
    username: foo
    password: pass
```

Generating a playbook
---------------------
The following playbook can be used to generate a playbook that will store an
object using the 'web' target:
```
# Generate the playbook using the local machine
- hosts: localhost
  roles:
    - prism

  vars:
    # Optional: override if not using the default
    target_definitions_dir: /etc/prism/targets

    # Optional: override if not using the default
    playbook_templates_dir: /etc/prism/templates

    # Set the name of the output playbook.  If this variable is omitted, no
    # playbook will be generated.
    generated_playbook: /tmp/prism-playbook.yml

    # Choose a target for this operation
    target: web

    # Select the operation
    operation: create

    params:
      path: messages
      object:
        id: 1
        data: TG9yZW0gSXBzdW0gaXMgc2ltcGx5IGR1bW15IHRleHQu=

  # No task needed because the playbook generation task is defined in the role.
```

This generates a playbook in `/tmp/prism-playbook.yml` which can be executed
with `ansible-playbook` to perform the action:
```
- hosts: host.example.com
  remote_user: admin

  tasks:
  - name: REST: Create operation
    uri:
      url: "http://api.example.com/v2/messages"
      method: POST
      user: foo
      password: pass
      body: TG9yZW0gSXBzdW0gaXMgc2ltcGx5IGR1bW15IHRleHQu=
```

To switch to an 'ftp' target you only need to change one line and the generated
playbook would be configured to talk with the ftp server according to the ftp
operation template and target configuration.
```
target: ftp
```


License
-------

GPLv3


Author Information
------------------

Written by Adam Litke - alitke@redhat.com
- https://github.com/aglitke
