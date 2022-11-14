## SQL to NOSQL

Design a pipeline to read data from an SQL database, process the data and 
store the results in a NOSQL database. 

The data stores are on isolated docker containers for each step. 
To this end, we use 2 containers:
* PostgreSQL (SQL DB)
* MongoDB (NOSQL DB)

### Dependencies

* docker / Docker-Engine (install instructions 
  [here](https://docs.docker.com/engine/install/ubuntu/))
* conda environment (miniconda install
  [here](https://docs.conda.io/en/latest/miniconda.html))

### Setup & Usage

Before setting up, ensure that the necessary environment variables are provided
through docker env files:

***setup/.pgenv***
```
POSTGRES_PASSWORD=<postgres-password>
```

***setup/.mongoenv***
```
MONGO_INITDB_ROOT_USERNAME=<mongo-username>
MONGO_INITDB_ROOT_PASSWORD=<mongo-password>
```

Run the following command to setup and start the 3 containers using docker
```shell
cd setup && ./setup.sh 
```

Once the containers are setup, create a configuration file to provide 
the database connection URIs. We use a JSON configuration file with the 
following structure

***python/config.json***
```
{
    "PG_HOST": <postgres-host-address>,
    "MONGO_HOST": <mongo-host-address>
}
```

Run the task via:
```shell
cd .. && sh ./run.sh
```

### Description

#### Setup
* The docker containers are created and run from `setup/setup.sh`
* The database to use (`datastore`) and non-admin user (`analyst`) are 
created in both PostgreSQL and MongoDB
* A conda python environment is created from the .yml environment file

#### Run
* Step 1: Copy local data into PostgreSQL
  * Copy the local file into docker container first, then to PostgreSQL via 
  an SQL script
  * Copy the local file into a temporary table, then to the desired table after 
  removing duplicate rows
* Step 2: Compute KPIs and store in MongoDB
  * Query the KPIs using Python and pandas
  * Convert to dictionary and store each KPI as a collection in MongoDB

### Improvements

* Use Dockerfile for cleaner setup
* Use Kubernetes pods to make deployment easier
* Avoid usernames and passwords in git and store them externally
