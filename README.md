# Ubuntu 20.04LTS LNMP Stack on Docker and Vagrant

This is a complete Ubuntu 20.04LTS LNMP stack built on a cominbation of Docker and Vagrant that is suitable for running on Apple M1 based computers.

- [Ubuntu 20.04LTS LNMP Stack on Docker and Vagrant](#ubuntu-2004lts-lnmp-stack-on-docker-and-vagrant)
  - [Requirements](#requirements)
  - [Installation](#installation)
  - [Post Installation Tips](#post-installation-tips)
    - [MariaDB/MySQL](#mariadbmysql)
  - [Credits](#credits)
  - [License](#license)

## Requirements

- Docker Desktop (<https://docs.docker.com/desktop/mac/install/>)
- Vagrant (<https://www.vagrantup.com/downloads>)

## Installation

    vagrant up --provider=docker

## Post Installation Tips

See [Server Build Guide: Ubuntu (20.04LTS) LNMP/LAMP](https://gist.github.com/pointybeard/bf33095f93ce3bcc8567849166d8bd11) for generally helpful information.

### MariaDB/MySQL

Allow connection as MySQL root user from outside VM

- Remove old record in ~/.ssh/known_hosts on host machine
- Add ~/.ssh/id_rsa.pub to authorized_keys on vagrant box
- Open up /etc/mysql/mariadb.conf.d/50-server.cnf and comment out lines for skip-external-locking & bind-address
- Run following SQL as root (mysql -u root -p):

```
CREATE USER 'root'@'localhost' IDENTIFIED BY 'root';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
CREATE USER 'root'@'%' IDENTIFIED BY 'root';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password USING PASSWORD('root');
FLUSH PRIVILEGES;
```

- Restart MySQL service with `sudo service mysql restart`

## Credits

- [John Rofrano](https://medium.com/nerd-for-tech/developing-on-apple-m1-silicon-with-virtual-environments-4f5f0765fd2f) for their article and Dockerfile which got the ball rolling.
- [Alannah Kearney](https://github.com/pointybeard)
- [All Contributors](../../contributors)

## License

"Ubuntu 20.04LTS LNMP Stack on Docker and Vagrant" is released under the [MIT License](http://www.opensource.org/licenses/MIT).
