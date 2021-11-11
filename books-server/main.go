// main package for books-server
package main

import (
	"books-server/pkg/consts"
	"context"
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"strings"
	"time"

	"books-server/pkg/conf"
	"books-server/pkg/types"
	"books-server/pkg/util"

	"github.com/go-resty/resty/v2"
	"github.com/google/uuid"
	"github.com/gorilla/mux"
)

// init func called before main
func init() {
	// load environment variables
	util.LoadEnvConfig(&conf.Env)
}

// main func
func main() {

	var wait time.Duration
	flag.DurationVar(&wait, "graceful-timeout", time.Second*15, "the duration for which the server gracefully wait for existing connections to finish - e.g. 15s or 1m")
	flag.Parse()

	r := mux.NewRouter()             // create a router
	r.Use(logIncomingRequestHandler) // intercepting middleware to log each incoming request

	// add methods
	r.HandleFunc("/users", RegisterUserHandler).Methods(http.MethodPost)
	r.HandleFunc("/users", GetUserByEmailHandler).Methods(http.MethodGet).Queries("email", "{email}")
	r.HandleFunc("/users/{id}/books", AddBooksHandler).Methods(http.MethodPost)
	r.HandleFunc("/users/{id}/books", GetBooksHandler).Methods(http.MethodGet)
	r.HandleFunc("/users/{id}/books/{id}", GetBookDetailsHandler).Methods(http.MethodGet)
	r.HandleFunc("/users/{id}/books/{id}", UpdateBookDetailsHandler).Methods(http.MethodPut)
	r.HandleFunc("/users/{id}/books/{id}", DeleteBookDetailsHandler).Methods(http.MethodDelete)

	// start the server
	srv := &http.Server{
		Addr: "0.0.0.0:8080",
		// Good practice to set timeouts to avoid Slowloris attacks.
		WriteTimeout: time.Second * 15,
		ReadTimeout:  time.Second * 15,
		IdleTimeout:  time.Second * 60,
		Handler:      r, // Pass our instance of gorilla/mux in.
	}

	// Run our server in a goroutine so that it doesn't block.
	go func() {
		if err := srv.ListenAndServe(); err != nil {
			log.Println(err)
		}
	}()

	log.Println("http server started at port 8080")

	c := make(chan os.Signal, 1)
	// We'll accept graceful shutdowns when quit via SIGINT (Ctrl+C)
	// SIGKILL, SIGQUIT or SIGTERM (Ctrl+/) will not be caught.
	signal.Notify(c, os.Interrupt)

	// Block until we receive our signal.
	<-c

	// Create a deadline to wait for.
	ctx, cancel := context.WithTimeout(context.Background(), wait)
	defer cancel()
	// Doesn't block if no connections, but will otherwise wait
	// until the timeout deadline.
	srv.Shutdown(ctx)
	// Optionally, you could run srv.Shutdown in a goroutine and block on
	// <-ctx.Done() if your application should wait for other services
	// to finalize based on context cancellation.
	log.Println("shutting down")
	os.Exit(0)
}

func logIncomingRequestHandler(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Do stuff here
		log.Println("incoming request", r.Method, r.URL)
		// Call the next handler, which can be another middleware in the chain, or the final handler.
		next.ServeHTTP(w, r)
	})
}

// RegisterUserHandler registers an user
func RegisterUserHandler(w http.ResponseWriter, r *http.Request) {
	// validate the request
	createUserReq := &types.CreateUserRequest{}
	err := util.RequestValidator(createUserReq, r)
	if err != nil {
		log.Println("error validating the register user request", err)
		util.WriteError(w, http.StatusBadRequest, "error validating request", err.Error())
		return
	}

	// insert data into table by calling API on Astra DB
	id := uuid.New().String() // generate new UUID
	createdAt := time.Now().UTC().Format(consts.TimeFormatLayoutForAstraDb)
	modifiedAt := createdAt

	createUserReqDB := &types.CreateUserRequestDB{
		Id:         id,
		Email:      createUserReq.Email,
		FirstName:  createUserReq.FirstName,
		LastName:   createUserReq.LastName,
		CreatedAt:  createdAt,
		ModifiedAt: modifiedAt,
	}

	createUserReqDBBytes, err := json.Marshal(createUserReqDB)
	if err != nil {
		log.Println("unexpected error", err)
		util.WriteError(w, http.StatusInternalServerError, "unexpected error", err.Error())
		return
	}

	createUserRespDB := &types.CreateUserResponseDB{}
	client := resty.New()
	resp, err := client.R().
		SetHeaders(map[string]string{"content-type": "application/json", "x-cassandra-token": conf.GetAstraDBApplicationToken()}).
		SetBody(string(createUserReqDBBytes)).
		SetResult(createUserRespDB).
		Post(conf.GetUsersTableUrl())
	if err != nil {
		log.Println("unexpected error", err)
		util.WriteError(w, http.StatusInternalServerError, "unexpected error", err.Error())
		return
	}

	if resp.IsError() {
		log.Println("unexpected error", resp.String())
		util.WriteError(w, resp.StatusCode(), "unexpected error", resp.String())
		return
	}

	log.Println("success response from Astra DB", resp.String())

	// return success response
	util.WriteSuccess(w, http.StatusOK, createUserRespDB)
}

// GetUserByEmailHandler returns user details retrieved using email
func GetUserByEmailHandler(w http.ResponseWriter, r *http.Request) {
	email := strings.TrimSpace(r.URL.Query().Get("email"))
	if email == "" {
		log.Println("email query param cannot be empty")
		util.WriteError(w, http.StatusBadRequest, "email query param cannot be empty", "")
		return
	}

	getUserDBResponse := &types.GetUserResponseDB{}
	client := resty.New()
	resp, err := client.R().
		SetHeaders(map[string]string{"content-type": "application/json", "x-cassandra-token": conf.GetAstraDBApplicationToken()}).
		SetQueryParam("where", fmt.Sprintf("{\"email\":{\"$eq\": \"%s\"}}", email)).
		SetQueryParam("page-size", "1").
		SetResult(getUserDBResponse).
		Get(conf.GetUsersTableUrl())
	if err != nil {
		log.Println("unexpected error", err)
		util.WriteError(w, http.StatusInternalServerError, "unexpected error", err.Error())
		return
	}

	if resp.IsError() {
		log.Println("unexpected error", resp.String())
		util.WriteError(w, resp.StatusCode(), "unexpected error", resp.String())
		return
	}

	log.Println("success response from Astra DB", resp.String())

	userDetailsFromDB := getUserDBResponse.Data[0].(map[string]interface{})
	createdAt := userDetailsFromDB["created_at"].(map[string]interface{})
	modifiedAt := userDetailsFromDB["modified_at"].(map[string]interface{})
	getUserResp := &types.GetUserResponse{
		Id: userDetailsFromDB["id"].(string),
		Email: userDetailsFromDB["email"].(string),
		FirstName: userDetailsFromDB["first_name"].(string),
		LastName: userDetailsFromDB["last_name"].(string),
		CreatedAt: time.Unix(int64(createdAt["epochSecond"].(float64)), int64(createdAt["nano"].(float64))).UTC().Format(consts.TimeFormatLayoutForAstraDb),
		ModifiedAt: time.Unix(int64(modifiedAt["epochSecond"].(float64)), int64(modifiedAt["nano"].(float64))).UTC().Format(consts.TimeFormatLayoutForAstraDb),
	}
	// return success response
	util.WriteSuccess(w, http.StatusOK, getUserResp)
}

// AddBooksHandler adds a book entry for a user for the provided id
func AddBooksHandler(w http.ResponseWriter, r *http.Request) {

}

// GetBooksHandler returns all the books details for a user
func GetBooksHandler(w http.ResponseWriter, r *http.Request) {

}

// GetBookDetailsHandler returns a book details for a user for the provided id
func GetBookDetailsHandler(w http.ResponseWriter, r *http.Request) {

}

// UpdateBookDetailsHandler updates a book details for a user for the provided id
func UpdateBookDetailsHandler(w http.ResponseWriter, r *http.Request) {

}

// DeleteBookDetailsHandler detail a book details for a user for the provided id
func DeleteBookDetailsHandler(w http.ResponseWriter, r *http.Request) {

}
