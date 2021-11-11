package util

import (
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
