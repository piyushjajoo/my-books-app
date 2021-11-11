package types

type CreateBookDetailsRequest struct {
	BookName   string `validate:"required" json:"book_name"`
	Liked      bool   `json:"liked"`
	StartedAt  string `json:"started_at,omitempty"`
	FinishedAt string `json:"finished_at,omitempty"`
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
	Liked      bool   `json:"liked"`
	StartedAt  string `json:"started_at,omitempty"`
	FinishedAt string `json:"finished_at,omitempty"`
}