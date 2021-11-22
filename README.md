# my-books-app
My Books App created using Gorilla Mux go based HTTP Server, Flutter UI and Datastax Astra DB.
Here is the blog written for this repo <LINK TBD>

## Pre-Requisites
- [Git](https://git-scm.com/downloads)
- [Go](https://golang.org/doc/install)
- [Flutter](https://flutter.dev/docs/get-started/install)
- [KIND](https://kind.sigs.k8s.io/docs/user/quick-start/)
- [Docker](https://www.docker.com/get-started)
- [Editor Setup For Flutter](https://flutter.dev/docs/get-started/editor)
- Editor Setup For Go ([GoLand](https://www.jetbrains.com/go/) and [Visual Studio Code](https://code.visualstudio.com/docs/languages/go))
- [Firebase](https://console.firebase.google.com/) to integrate Login in Flutter app
- [Kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl) to interact with kubernetes KIND cluster
- [Helm](https://helm.sh/docs/intro/install/) to install components in kubernetes KIND cluster

## Components
- Astra DB
- Go based HTTP Server
- Flutter UI
- Kubernetes Cluster

## Database Schema
1. Create [Datastax Astra Serverless Database](https://astra.datastax.com) and use the keyspace name as `my_first_crud_ks`
2. Create tables using CQL Browser console
```
# users table to record the users
create table my_first_crud_ks.users(id uuid primary key, email text, first_name text, last_name text, created_at timestamp, modified_at timestamp);

# index on email field so that we can retrieve data filtered on email
create index if not exists user_email_index on my_first_crud_ks.users(email);

# table to keep record of the books for a user
create table my_first_crud_ks.my_reading_list(id uuid primary key, user_id uuid, book_name text, started_at timestamp, finished_at timestamp, liked boolean);

# index on user_id field so that we can retrieve data filtered on user_id
create index if not exists user_id_index ON my_first_crud_ks.my_reading_list(user_id);
```
3. Go to `Connect` section and generate a token with "API R/W User" permissions and download the file. We will need to token for running Books Server.
4. Go to `Connect` section and copy the environment variable details which look something like below from under "REST API" section.
```shell
export ASTRA_DB_ID=<Database ID from Astra UI>
export ASTRA_DB_REGION=<Region where you created the DB>
export ASTRA_DB_KEYSPACE=my_first_crud_ks
export ASTRA_DB_APPLICATION_TOKEN=<Copy the token from the file you downloaded in Astra DB section in Step #3>
```

### How it's built

1. [Gorilla Mux](https://github.com/gorilla/mux) for the HTTP Router and URL Matching
2. [Go Resty](https://github.com/go-resty/resty) for HTTP Client code to invoke REST APIs on Astra Database.


## Books Flutter App
[books-app](books-server/README.md)

### How to build Android App

### How to build iOS App

## Deploy in Kubernetes Cluster
[deploy](deploy/README.md)

