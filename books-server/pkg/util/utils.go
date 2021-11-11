package util

import (
	"books-server/pkg/types"
	"encoding/json"
	"github.com/go-playground/validator"
	"github.com/kelseyhightower/envconfig"
	"log"
	"net/http"
)

// LoadEnvConfig loads the env vars into the provided struct and validates them based on tags
func LoadEnvConfig(spec interface{}) {
	err := envconfig.Process("", spec)
	if err != nil {
		log.Fatal(err)
	}
	err = validator.New().Struct(spec)
	if err != nil {
		log.Fatal(err)
	}
}

// RequestValidator validates the request body against supplied interface
func RequestValidator(input interface{}, r *http.Request) error {
	// parse & validate payload
	defer r.Body.Close()
	if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
		return err
	}

	err := validator.New().Struct(input)
	if err != nil {
		return err
	}

	return nil
}

// WriteError writes an error response on the provided writer
func WriteError(w http.ResponseWriter, statusCode int, errorMsg, errorDetails string) {
	w.WriteHeader(statusCode)
	errorResponse := types.ErrorResponse{
		ErrorCode:    statusCode,
		ErrorMsg:     errorMsg,
		ErrorDetails: errorDetails,
	}
	json.NewEncoder(w).Encode(errorResponse)
}

func WriteSuccess(w http.ResponseWriter, statusCode int, responseStruct interface{}) {
	w.WriteHeader(statusCode)
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(responseStruct)
}
