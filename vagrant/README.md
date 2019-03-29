Start as usual

```
Host $ vagrant up
```

Then, you would need to do a ssh tunnel in your host: `nano $HOME/.ssh/config`

```
# Configure as the output say in: vagrant ssh-config

Host spinnaker-start
  HostName localhost
  User vagrant
  Port 2222
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no
  PasswordAuthentication no
  ## Put your own identity file
  IdentityFile C:/Users/caroman/Desktop/spinnaker-course/vagrant/.vagrant/machines/default/virtualbox/private_key
  IdentitiesOnly yes
  LogLevel FATAL
  ControlMaster yes
  ControlPath ~/.ssh/spinnaker-tunnel.ctl
  RequestTTY no
  LocalForward 9000 localhost:9000
  LocalForward 8084 localhost:8084
  LocalForward 8087 localhost:8087
```

After that: `ssh spinnaker-start`


And then open you browser in `127.0.0.1:9000
`
