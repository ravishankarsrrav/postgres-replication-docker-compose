# Postgres Replication Setup

Postgres supports multiple methods of replication. 
The replication method we are going to setup is Streaming Replication or Log Replication. 
Refer [this documentation](https://www.postgresql.org/docs/12/warm-standby.html#STREAMING-REPLICATION) to read more about Streaming Replication.


### Steps to set up Streaming Replication in PostgreSQL 12
 
#### MASTER SETUP

##### Step 1
```
Initialize and start PostgreSQL, if not done already on the Master.
```

##### Step 2
```
Modify the parameter listen_addresses to allow a specific IP interface or all (using *). 
Modifying this parameter requires a restart of the PostgreSQL instance to get the change into effect.
```

##### Step 3
```
Create a User for replication in the Master. 
It is discouraged to use superuser postgres in order to setup replication, though it works.
```

##### Step 4
```
Allow replication connections from Standby to Master by appending a similar line as following to the pg_hba.conf file of the Master.

# Config need to added 
host replication all 0.0.0.0/0 md5
```

----

#### SLAVE SETUP

##### Step 1
```
Initialize and start PostgreSQL, if not done already on the Master.
```

##### Step 2
```
Modify the parameter listen_addresses to allow a specific IP interface or all (using *). 
Modifying this parameter requires a restart of the PostgreSQL instance to get the change into effect.
```

#### Step 3
```
Delete everything in the data directory
```

##### Step 4
```
You may use `pg_basebackup` to backup the data directory of the Master from the Standby. 
While creating the backup, you may also tell pg_basebackup  to create the replication specific files and entries in the data directory using "-R" .
```

----

### If you think it's a lot of steps to setup the replication ???

### Answer is here

```
All the steps above mentioned has been automated into two steps. 
First step is to deploy the master stack.
Another step is to deploy the slave stack with the replication configuration.

Info: Master and slave runs on a two different machines.
Note: Please modify credentials and port before deploying it
```

#### Deploy Master
Please ensure the data volume path is correct in yml file
```
sudo docker-compose -f master-stack.yml start
# ensure master stack is up 
```

#### Deploy slave
Please ensure the data volume path is correct in yml file
```
sudo docker-compose -f slave-stack.yml start
# ensure replication works by creating a table in master node and check if the table present in slave node
```