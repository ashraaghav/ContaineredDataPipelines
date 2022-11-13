-- create database
CREATE DATABASE datastore;

-- create user & grant permissions for THIS database
CREATE USER analyst WITH PASSWORD 'ana_pass1';
GRANT ALL PRIVILEGES ON DATABASE datastore TO analyst;  --TODO: needs better privilege management
GRANT pg_read_server_files TO analyst;
