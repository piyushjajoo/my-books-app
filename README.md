# my-books-app
My Books App created using Gorilla Mux go based HTTP Server, Flutter UI and Datastax Astra DB.
Here is the blog written for this repo <LINK TBD>

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

## Books HTTP Server

Here the README to go into the nitty-gritty details about the books server [books-server](books-server/README.md)

### How to test locally

1. Copy paste the Astra DB Connection details you copied earlier in Astra DB section in step #4
```shell
export ASTRA_DB_ID=<Database ID from Astra UI>
export ASTRA_DB_REGION=<Region where you created the DB>
export ASTRA_DB_KEYSPACE=my_first_crud_ks
export ASTRA_DB_APPLICATION_TOKEN=<Copy the token from the file you downloaded in Astra DB section in Step #3>
```

3. Start http server
```shell
cd books-server
go run main.go
```

4. In another terminal, make API calls to the http server to check if it's running properly

```
1. POST /users

$ curl http://localhost:8080/users -X POST -d '{"email":"pjajoo@example.com","first_name":"Piyush","last_name":"Jajoo"}'

Response:
{"id":"d91886bd-ee21-4a3e-819f-d1506414e4fe"}

2. GET /users?email=<emailId>

$ curl http://localhost:8080/users?email="pjajoo@example.com"

Response:
{"id":"d91886bd-ee21-4a3e-819f-d1506414e4fe","email":"pjajoo@example.com","first_name":"Piyush","last_name":"Jajoo","created_at":"2021-11-12T01:35:18.809Z","modified_at":"2021-11-12T01:35:18.809Z"}

3. POST /users/{userId}/books

$ curl -X POST http://localhost:8080/users/d91886bd-ee21-4a3e-819f-d1506414e4fe/books -d '{"book_name":"Zero to one", "liked":true, "started_at":"2021-11-12T01:35:18.809Z", "finished_at":"2021-11-12T01:35:18.809Z"}'

Response:
{"id":"946b11ab-c7d6-455d-97cb-2a2d9394ae19"}

4. GET /users/{userId}/books

$ curl -X GET http://localhost:8080/users/d91886bd-ee21-4a3e-819f-d1506414e4fe/books

Response:
[{"id":"946b11ab-c7d6-455d-97cb-2a2d9394ae19","book_name":"Zero to one","liked":true,"started_at":"2021-11-12T01:35:18.809Z","finished_at":"2021-11-12T01:35:18.809Z"}]

5. GET /users/{userId}/books/{bookId}

$ curl -X GET http://localhost:8080/users/d91886bd-ee21-4a3e-819f-d1506414e4fe/books/946b11ab-c7d6-455d-97cb-2a2d9394ae19

Response:
{"id":"946b11ab-c7d6-455d-97cb-2a2d9394ae19","book_name":"Zero to one","liked":true,"started_at":"2021-11-12T01:35:18.809Z","finished_at":"2021-11-12T01:35:18.809Z"}

6. PUT /users/{userId}/books/{bookId}

$ curl -X PUT http://localhost:8080/users/d91886bd-ee21-4a3e-819f-d1506414e4fe/books/946b11ab-c7d6-455d-97cb-2a2d9394ae19 -d '{"book_name":"Zero to two", "liked":true, "started_at":"2021-11-12T01:35:18.809Z", "finished_at":"2021-11-12T01:35:18.809Z"}'

Response:
{"message":"Successfully updated book details"}

7. DELETE /users/{userId}/books/{bookId}

$ curl -X DELETE http://localhost:8080/users/d91886bd-ee21-4a3e-819f-d1506414e4fe/books/946b11ab-c7d6-455d-97cb-2a2d9394ae19

Response:
{"message":"Successfully deleted book details"}
```

### How it's built

1. [Gorilla Mux](https://github.com/gorilla/mux) for the HTTP Router and URL Matching
2. [Go Resty](https://github.com/go-resty/resty) for HTTP Client code to invoke REST APIs on Astra Database.


## Books Flutter App
[books-app](books-server/README.md)

## Deploy in Kubernetes Cluster
[deploy](deploy/README.md)

