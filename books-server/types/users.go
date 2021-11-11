package types

type CreateUserRequest struct {
	Email     string `json:"email"`
	FirstName string `json:"first_name"`
	LastName  string `json:"last_name"`
}

type GetUserResponse struct {
	Id         string `json:"id"`
	Email      string `json:"email"`
	FirstName  string `json:"first_name"`
	LastName   string `json:"last_name"`
	CreatedAt  string `json:"created_at"`
	ModifiedAt string `json:"modified_at"`
}
