package types

type CreateBookDetailsRequest struct {
	BookName   string `validate:"required" json:"book_name"`
	Liked      bool   `json:"liked"`
	StartedAt  string `json:"started_at,omitempty"`
	FinishedAt string `json:"finished_at,omitempty"`
}

type CreateBookDetailsRequestDB struct {
	Id         string `json:"id"`
	UserId     string `json:"user_id"`
	BookName   string `json:"book_name"`
	Liked      bool   `json:"liked"`
	StartedAt  string `json:"started_at,omitempty"`
	FinishedAt string `json:"finished_at,omitempty"`
}

type CreateBookDetailsResponseDB struct {
	Id string `json:"id"`
}

type GetBookDetailsResponseDB struct {
	Data      []interface{} `json:"data"`
	Count     int           `json:"count"`
	PageState string        `json:"pageState"`
}

type GetBookDetailsResponse struct {
	Id         string `json:"id"`
	BookName   string `json:"book_name"`
	Liked      bool   `json:"liked"`
	StartedAt  string `json:"started_at,omitempty"`
	FinishedAt string `json:"finished_at,omitempty"`
}

type UpdateBookDetailsRequest struct {
	BookName   string `validate:"required" json:"book_name"`
	Liked      bool   `validate:"required" json:"liked"`
	StartedAt  string `validate:"required" json:"started_at"`
	FinishedAt string `json:"finished_at,omitempty"`
}

type UpdateBookDetailsRequestDB struct {
	UserId     string `json:"user_id"`
	BookName   string `json:"book_name"`
	Liked      bool   `json:"liked"`
	StartedAt  string `json:"started_at,omitempty"`
	FinishedAt string `json:"finished_at,omitempty"`
}

type UpdateBookDetailsResponseDB struct {
	Id string `json:"id"`
}