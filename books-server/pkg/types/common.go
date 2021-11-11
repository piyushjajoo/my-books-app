package types

type SuccessResponse struct {
	Message string `json:"message"`
}

type ErrorResponse struct {
	ErrorCode    int    `json:"errorCode"`
	ErrorMsg     string `json:"errorMsg"`
	ErrorDetails string `json:"errorDetails,omitempty"`
}
