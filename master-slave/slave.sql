CHANGE REPLICATION SOURCE TO -- изменяем источник полученяи данных журнала в версиях до MySQL 8.0.23 ( CHANGE MASTER TO)
SOURCE_HOST='my_mysql-master', -- хост мастера
SOURCE_USER='repl', -- пользователь для репликации
SOURCE_PASSWORD='slavepass', -- пароль пользователя для репликации
SOURCE_SSL=1; -- включаем ssl
START REPLICA; -- запускаем реплику