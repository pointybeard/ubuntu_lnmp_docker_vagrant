FROM ubuntu:20.04
LABEL MAINTAINER="Alannah Kearney <hi@alannahkearney.com>"

## Credit to John Rofrano as this is based on their docker 
## image rofrano/vagrant-provider (https://hub.docker.com/r/rofrano/vagrant-provider)
## and article https://medium.com/nerd-for-tech/developing-on-apple-m1-silicon-with-virtual-environments-4f5f0765fd2f 

ENV DEBIAN_FRONTEND noninteractive

# Install packages needed for SSH and interactive OS
RUN apt-get update && \
    yes | unminimize && \
    apt-get -y install \
        openssh-server \
        passwd \
        sudo \
        man-db \
        curl \
        wget \
        vim-tiny && \
    apt-get -qq clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Enable systemd (from Matthew Warman's mcwarman/vagrant-provider)
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*; \
    rm -f /etc/systemd/system/*.wants/*; \
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*; \
    rm -f /lib/systemd/system/anaconda.target.wants/*;

# Enable ssh for vagrant
RUN systemctl enable ssh.service; 
EXPOSE 22

# Create the vagrant user
RUN useradd -m -G sudo -s /bin/bash vagrant && \
    echo "vagrant:vagrant" | chpasswd && \
    echo 'vagrant ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/vagrant && \
    chmod 440 /etc/sudoers.d/vagrant

# Establish ssh keys for vagrant
RUN mkdir -p /home/vagrant/.ssh; \
    chmod 700 /home/vagrant/.ssh
ADD https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub /home/vagrant/.ssh/authorized_keys
RUN chmod 700 /home/vagrant/.ssh; \
    chmod 600 /home/vagrant/.ssh/authorized_keys; \
    touch /home/vagrant/.ssh/known_hosts; \
    chmod 644 /home/vagrant/.ssh/known_hosts; \
    chmod 644 /home/vagrant/.ssh/*.pub; \
    chown -R vagrant:vagrant /home/vagrant/.ssh

# Run the init daemon
VOLUME [ "/sys/fs/cgroup" ]
CMD ["/usr/sbin/init"]
