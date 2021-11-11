package conf

import "fmt"

// EnvConfig stores env vars
type EnvConfig struct {
	ASTRA_DB_ID                string `validate:"required"`
	ASTRA_DB_REGION            string `validate:"required"`
	ASTRA_DB_KEYSPACE          string `validate:"required"`
	ASTRA_DB_APPLICATION_TOKEN string `validate:"required"`
}

// Env stores env vars
var Env EnvConfig

// GetUsersTableUrl returns users table url
func GetUsersTableUrl() string {
	return fmt.Sprintf("https://%s-%s.apps.astra.datastax.com/api/rest/v2/keyspaces/%s/users",
		Env.ASTRA_DB_ID, Env.ASTRA_DB_REGION, Env.ASTRA_DB_KEYSPACE)
}

// GetMyReadingListTableUrl returns my_reading_list table url
func GetMyReadingListTableUrl() string {
	return fmt.Sprintf("https://%s-%s.apps.astra.datastax.com/api/rest/v2/keyspaces/%s/my_reading_list",
		Env.ASTRA_DB_ID, Env.ASTRA_DB_REGION, Env.ASTRA_DB_KEYSPACE)
}

// GetAstraDBApplicationToken returns value of ASTRA_DB_APPLICATION_TOKEN env variable
func GetAstraDBApplicationToken() string {
	return Env.ASTRA_DB_APPLICATION_TOKEN
}