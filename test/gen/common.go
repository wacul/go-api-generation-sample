package gen

import (
	"encoding/json"
	"fmt"
	"net/http"

	"github.com/gorilla/schema"
	"github.com/wcl48/valval"
)

// For Error Logging
var ErrorLogFunc func(err error)

var decoder *schema.Decoder = schema.NewDecoder()

type ErrorDescription struct {
	Field string
	Code  string
}

type APIError struct {
	Status  int
	Message string
	Errors  []ErrorDescription
}

func (e *APIError) Error() string {
	return e.Message
}

func (e *APIError) AddDescription(field, code string) {
	d := ErrorDescription{
		Field: field,
		Code:  code,
	}
	if e.Errors == nil {
		e.Errors = make([]ErrorDescription, 0, 1)
	}
	e.Errors = append(e.Errors, d)
}

func NewAPIError(status int, message string) *APIError {
	return &APIError{
		Status:  status,
		Message: message,
	}
}

type errorResponseDescription struct {
	Field string `json:"field,omitempty"`
	Code  string `json:"description,omitempty"`
}

type errorResponse struct {
	Message string                     `json:"message"`
	Errors  []errorResponseDescription `json:"errors,omitempty"`
}

func sendInternalServerError(w http.ResponseWriter, err error) {
	if ErrorLogFunc != nil {
		ErrorLogFunc(err)
	}

	w.WriteHeader(http.StatusInternalServerError)
	w.Header().Add("Content-Type", "application/json")
	fmt.Fprintf(w, `{"message" : "server error"}`)
}

func SendError(w http.ResponseWriter, err error) {
	switch err := err.(type) {
	case *APIError:
		e := errorResponse{
			Message: err.Message,
		}
		if len(err.Errors) > 0 {
			eds := make([]errorResponseDescription, 0, len(err.Errors))
			for _, innerError := range err.Errors {
				eds = append(eds, errorResponseDescription{
					Field: innerError.Field,
					Code:  innerError.Code,
				})
			}
			e.Errors = eds
		}

		bjson, je := json.Marshal(e)
		if je != nil {
			sendInternalServerError(w, je)
			return
		}

		w.Header().Add("Content-Type", "application/json")
		w.WriteHeader(err.Status)
		w.Write(bjson)
	default:
		if ErrorLogFunc != nil {
			ErrorLogFunc(err)
		}
		sendInternalServerError(w, err)
	}
}

func handleRuntimeError(w http.ResponseWriter) {
	if r := recover(); r != nil {
		switch err := r.(type) {
		case error:
			sendInternalServerError(w, err)
		default:
			panic(r)
		}
	}
}

func validateError2APIError(err error) *APIError {
	apiError := NewAPIError(400, "validation failed")
	ves := valval.JSONErrors(err)
	for _, ve := range ves {
		apiError.AddDescription(ve.Path, ve.Error.Error())
	}
	return apiError
}
