# Домашнее задание к занятию «Репликация и масштабирование. Часть 1»

### Задание 1

На лекции рассматривались режимы репликации master-slave, master-master, опишите их различия.

*Ответить в свободной форме.*
### Решение 1

#### Master-Slave
Принцип работы:
Ведущий сервер (Master) принимает все запросы на запись (INSERT, UPDATE, DELETE). 
Ведомые серверы (Slaves) только читают данные и получают обновления от Master. 
Данные передаются от Master к Slaves, при этом репликация может быть асинхронной (с задержкой) или синхронной. 

#### Master-Master
Принцип работы:
Каждый сервер в системе может одновременно принимать запросы на запись и чтение. 
Изменения, внесённые на любом сервере, автоматически синхронизируются со всеми остальными серверами. 

---

### Задание 2

Выполните конфигурацию master-slave репликации, примером можно пользоваться из лекции.

*Приложите скриншоты конфигурации, выполнения работы: состояния и режимы работы серверов.*

### Решение 2

Файл docker-compose-ms.yml
```yml
services:
  mysql-master:
    image: mysql:8.4
    container_name: my_mysql-master
    environment:
      MYSQL_ROOT_PASSWORD: 12345
    ports:
      - "3307:3306"
    volumes:
      - ./master-slave/master.sql:/docker-entrypoint-initdb.d/start.sql
    command:
      - --server-id=1
      - --log-bin=mysql-bin
      - --binlog-format=ROW
      - --mysql_native_password=ON
  mysql-slave:
    image: mysql:8.4
    container_name: my_mysql-slave
    environment:
      MYSQL_ROOT_PASSWORD: 12345
    ports:
      - "3308:3306"
    volumes:
      - ./master-slave/slave.sql:/docker-entrypoint-initdb.d/start.sql
    command:
      - --server-id=2
      - --read_only=1
```

Файл master.sql
```mysql
CREATE USER 'repl'@'%' IDENTIFIED BY 'slavepass'; -- создаём пользователя для реплики
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%'; -- выдаём права для репликации новому пользователю
FLUSH PRIVILEGES; -- принудительно применяем изменения
```
Файл slave.sql
```mysql
CHANGE REPLICATION SOURCE TO -- изменяем источник полученяи данных журнала в версиях до MySQL 8.0.23 ( CHANGE MASTER TO)
SOURCE_HOST='my_mysql-master', -- хост мастера
SOURCE_USER='repl', -- пользователь для репликации
SOURCE_PASSWORD='slavepass', -- пароль пользователя для репликации
SOURCE_SSL=1; -- включаем ssl
START REPLICA; -- запускаем реплику
```

![Скриншот](https://github.com/karelinsf/mysql-replica/blob/main/img/master-slave.png)
---

## Дополнительные задания (со звёздочкой*)
Эти задания дополнительные, то есть не обязательные к выполнению, и никак не повлияют на получение вами зачёта по этому домашнему заданию. Вы можете их выполнить, если хотите глубже шире разобраться в материале.

---

### Задание 3* 

Выполните конфигурацию master-master репликации. Произведите проверку.

*Приложите скриншоты конфигурации, выполнения работы: состояния и режимы работы серверов.*

### Решение 3

Файл docker-compose-mm.yml
```yml
services:
  mysql-master-1:
    image: mysql:8.4
    container_name: mysql-master-1
    environment:
      MYSQL_ROOT_PASSWORD: 12345
    ports:
      - "3307:3306"
    volumes:
      - ./master-master/master1.sql:/docker-entrypoint-initdb.d/start.sql
    command:
      - --server-id=1
      - --log-bin=mysql-bin
      - --binlog-format=ROW
      - --mysql_native_password=ON
  mysql-master-2:
    image: mysql:8.4
    container_name: mysql-master-2
    environment:
      MYSQL_ROOT_PASSWORD: 12345
    ports:
      - "3308:3306"
    volumes:
      - ./master-master/master2.sql:/docker-entrypoint-initdb.d/start.sql
    command:
      - --server-id=2
      - --log-bin=mysql-bin
      - --binlog-format=ROW
      - --mysql_native_password=ON
```

Файл master1.sql
```sql
CREATE USER 'repl_1'@'%' IDENTIFIED BY 'pass';
GRANT REPLICATION SLAVE ON *.* TO 'repl_1'@'%';
CHANGE REPLICATION SOURCE TO
SOURCE_HOST='mysql-master-2',
SOURCE_USER='repl_2',
SOURCE_PASSWORD='pass',
SOURCE_SSL=1;
START REPLICA;
```
Файл master2.sql
```sql
CREATE USER 'repl_2'@'%' IDENTIFIED BY 'pass';
GRANT REPLICATION SLAVE ON *.* TO 'repl_2'@'%';
CHANGE REPLICATION SOURCE TO
SOURCE_HOST='mysql-master-1',
SOURCE_USER='repl_1',
SOURCE_PASSWORD='pass',
SOURCE_SSL=1;
START REPLICA;
```

![Скриншот](https://github.com/karelinsf/mysql-replica/blob/main/img/master-master.png)
