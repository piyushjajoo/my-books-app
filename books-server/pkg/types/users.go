package types

type CreateUserRequest struct {
	Email     string `validate:"required" json:"email"`
	FirstName string `validate:"required" json:"first_name"`
	LastName  string `validate:"required" json:"last_name"`
}

type CreateUserRequestDB struct {
	Id         string `json:"id"`
	Email      string `json:"email"`
	FirstName  string `json:"first_name"`
	LastName   string `json:"last_name"`
	CreatedAt  string `json:"created_at"`
	ModifiedAt string `json:"modified_at"`
}

type CreateUserResponseDB struct {
	Id string `json:"id"`
}

type GetUserResponseDB struct {
	Data      []interface{} `json:"data"`
	Count     int           `json:"count"`
	PageState string        `json:"pageState"`
}

type GetUserResponse struct {
	Id         string `json:"id"`
	Email      string `json:"email"`
	FirstName  string `json:"first_name"`
	LastName   string `json:"last_name"`
	CreatedAt  string `json:"created_at"`
	ModifiedAt string `json:"modified_at"`
}
