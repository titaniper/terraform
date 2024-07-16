접속
````
kubectl get pods -n streaming
kubectl exec -it mysql-0 -n streaming -- /bin/bash
mysql -u root -p rootpassword

create database ben;
create table ben.ddd_event
(
    id         int unsigned auto_increment primary key,
    type       varchar(255)                             not null,
    txId       varchar(255)                             not null,
    createdAt  datetime(6) default CURRENT_TIMESTAMP(6) not null,
    data       mediumtext                               not null
);
INSERT INTO ben.ddd_event (type, txId, createdAt, data)
VALUES  ('IndividualServiceUpdatedEvent',
         '7e8199b9fc1dcd3e3f4f0c61badbdd50',
         now(),
         '{}');

create database jerry;
create table jerry.ddd_event
(
    id         int unsigned auto_increment primary key,
    type       varchar(255)                             not null,
    txId       varchar(255)                             not null,
    createdAt  datetime(6) default CURRENT_TIMESTAMP(6) not null,
    data       mediumtext                               not null
);
INSERT INTO jerry.ddd_event (type, txId, createdAt, data)
VALUES  ('IndividualServiceUpdatedEvent',
         '7e8199b9fc1dcd3e3f4f0c61badbdd50',
         now(),
         '{}');
```