VAGRANTFILE_API_VERSION = "2"
homeDir = $homeDir ||= File.expand_path(".")
confDir = $confDir ||= File.expand_path("./conf")

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.hostname = "ubuntu"

  # Provider for VirtualBox
  config.vm.provider :virtualbox do |vb|
    vb.memory = "1024"
    vb.cpus = 2
  end

  config.vm.provider :docker do |docker, override|
    override.vm.box = nil
    docker.build_dir = "."
    docker.remains_running = true
    docker.has_ssh = true
    docker.privileged = true
    docker.volumes = ["/sys/fs/cgroup:/sys/fs/cgroup:rw"]
    docker.create_args = ["--cgroupns=host"]
  end

  config.vm.network "private_network", type: "dhcp"

  config.vm.synced_folder "#{$homeDir}", "/vagrant", docker_consistency: "delegated"

  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.network "forwarded_port", guest: 3306, host: 33306

  config.vm.provision :shell, path: confDir + "/build.sh"
  config.vm.provision :shell, path: confDir + "/boot.sh", run: 'always'

end
