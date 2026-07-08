CREATE USER 'repl'@'%' IDENTIFIED BY 'slavepass'; -- создаём пользователя для реплики
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%'; -- выдаём права для репликации новому пользователю
FLUSH PRIVILEGES; -- принудительно применяем изменения