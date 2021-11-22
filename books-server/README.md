# books-server 

## Summary
Go Based HTTP Server built using Gorilla Mux Library. We are using GO Resty as a HTTP Client to invoke Astra DB REST APIs.

## API Specification
1. POST /users - creates a user entry in Astra DB

Request:
```json
{
    "first_name": "Piyush",
    "last_name": "Jajoo",
    "email": "pjajoo@example.com"
}
```

Response:
```json
{
 "id": "d91886bd-ee21-4a3e-819f-d1506414e4fe"
}
```

2. GET /users?email=<emailId> - get user details using email id

Request: GET /users?email="pjajoo@example.com"

Response:
```json
{
 "id": "d91886bd-ee21-4a3e-819f-d1506414e4fe",
 "email": "pjajoo@example.com",
 "first_name": "Piyush",
 "last_name": "Jajoo",
 "created_at": "2021-11-12T01:35:18.809Z",
 "modified_at": "2021-11-12T01:35:18.809Z"
}
```

3. POST /users/{userId}/books - adds a book entry for a user (userId is the id returned in POST /users response)

Request:
```json
{
 "book_name": "Zero to one",
 "liked": true,
 "started_at": "2021-11-12T01:35:18.809Z",
 "finished_at": "2021-11-12T01:35:18.809Z"
}
```

Response:
```json
{
 "id": "946b11ab-c7d6-455d-97cb-2a2d9394ae19"
}
```

4. GET /users/{userId}/books - to get all the book details for a user

Request: GET /users/d91886bd-ee21-4a3e-819f-d1506414e4fe/books

Response:
```json
[{
 "id": "946b11ab-c7d6-455d-97cb-2a2d9394ae19",
 "book_name": "Zero to one",
 "liked": true,
 "started_at": "2021-11-12T01:35:18.809Z",
 "finished_at": "2021-11-12T01:35:18.809Z"
}]
```

5. GET /users/{userId}/books/{bookId} - to get details of a single book for a user

Request: GET /users/d91886bd-ee21-4a3e-819f-d1506414e4fe/books/946b11ab-c7d6-455d-97cb-2a2d9394ae19

Response:
```json
{
 "id": "946b11ab-c7d6-455d-97cb-2a2d9394ae19",
 "book_name": "Zero to one",
 "liked": true,
 "started_at": "2021-11-12T01:35:18.809Z",
 "finished_at": "2021-11-12T01:35:18.809Z"
}
```

6. PUT /users/{userId}/books/{bookId} - to update details of single book for a user
   
Request:
```json
{
 "book_name": "Zero to two",
 "liked": true,
 "started_at": "2021-11-12T01:35:18.809Z",
 "finished_at": "2021-11-12T01:35:18.809Z"
}
```

Response:
```json
{
 "message": "Successfully updated book details"
}
```

7. DELETE /users/{userId}/books/{bookId} - to delete details of single book for a user

Request: DELETE /users/d91886bd-ee21-4a3e-819f-d1506414e4fe/books/946b11ab-c7d6-455d-97cb-2a2d9394ae19

Response:
```json
{
 "message": "Successfully deleted book details"
}
```

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

## Build and deploy in KIND Kubernetes cluster
1. Make sure you have docker installed and running
2. cd `books-server`
3. Run [./build.sh](build.sh), you will see `books-server` image built
4. Assuming you have created kind cluster as mentioned in [README.md](../README.md)
5. Push the image to local kind registry
```shell
# tag the image
docker tag books-server localhost:5000/books-server

# push to registry in kind cluster
docker push localhost:5000/books-server
```
5. Export following environment variables in a terminal
```shell
export ASTRA_DB_ID=<Database ID>
export ASTRA_DB_REGION=<Datacenter Region you want to connect to>
export ASTRA_DB_KEYSPACE=my_first_crud_ks
export ASTRA_DB_APPLICATION_TOKEN=<API R/W User token; generate in Astra UI>
```
6. Run the following commands from the same terminal as #5 above to deploy the `books-server` in kind cluster
```shell
# create books-server namespace
kubectl create ns books-server

# deploy the helm chart
helm upgrade --install -n books-server books-server charts/books-server \
--set astradb.region="${ASTRA_DB_REGION}" \
--set astradb.keyspace="${ASTRA_DB_KEYSPACE}" \
--set astradb.id=${ASTRA_DB_ID} \
--set astradb.appToken="${ASTRA_DB_APPLICATION_TOKEN}"
```
7. Wait for the `ingress` object to reflect `localhost` in ADDRESS column
```shell
kubectl get ingress -n books-server
```
```
NAME           CLASS    HOSTS   ADDRESS     PORTS   AGE
books-server   <none>   *       localhost   80      91s
```
