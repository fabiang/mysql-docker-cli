# mysql-docker-cli

Interactive Bash which allows you to select Docker MySQL/MariaDB instance available on a machine.

## Example

```bash
./mysql-docker-cli.sh -u root -p                                                                                                                 in nu at 20:32:03
📦 Searching for MySQL socket in any volume under: /var/lib/docker/volumes ...

Found the following MySQL socket files:
1) docker-sftpgo-database-1 (/var/lib/docker/volumes/mytest/_data/mysqld.sock)

To which instance you like to connect? (1-1): 1
🔌 Connecting to /var/lib/docker/volumes/mytest/_data/mysqld.sock ...
Enter password: 
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 17
Server version: 11.4.5-MariaDB-ubu2404 mariadb.org binary distribution

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> 
```

## Installation

    curl -o /usr/local/bin/mysql "https://raw.githubusercontent.com/fabiang/mysql-docker-cli/refs/heads/main/mysql-docker-cli.sh"

*Note:* of cause you must make run `/run/mysqld` directory available as volume. For example in a `docker-compose.yml`

```yaml
volumes:
  mariadb_data:
  mariadb_run:

services:
  database:
    image: mariadb:lts
    volumes:
      - "mariadb_data:/var/lib/mysql:Z"
      - "mariadb_run:/run/mysqld"
```

## License

BSD-3-Clause. See the [LICENSE.md](LICENSE.md).
