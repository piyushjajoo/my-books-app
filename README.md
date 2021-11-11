# my-books-app
My Books App created using Gorilla Mux go based HTTP Server, Flutter UI and Datastax Astra DB

## Pre-Requisites
- [Git](https://git-scm.com/downloads)
- [Go](https://golang.org/doc/install)
- [Flutter](https://flutter.dev/docs/get-started/install)

## Components
- Astra DB
- Go based HTTP Server
- Flutter UI
- Kubernetes Cluster

## Database Schema
1. Create [Datastax Astra Serverless Database](https://astra.datastax.com)
2. Create tables using CQL Browser console
```cassandraql
create table my_first_crud_ks.users(id uuid primary key, email text, first_name text, last_name text, created_at timestamp, modified_at timestamp);

create table my_first_crud_ks.my_reading_list(id uuid primary key, user_id uuid, book_name text, started_at timestamp, finished_at timestamp, liked boolean);
```
## Books HTTP Server
[books-server](books-server/README.md)

## Books Flutter App
[books-app](books-server/README.md)

## Deploy in Kubernetes Cluster
[deploy](deploy/README.md)

