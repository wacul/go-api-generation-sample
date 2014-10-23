package gen

import (
	"time"

	"gopkg.in/mgo.v2/bson"
)

var _ = time.Now
var _ = bson.NewObjectId

type Hoge struct {
}

type HogePostParam struct {
	Name              *string    "json:\"name,omitempty\" schema:\"name\""
	Code              *string    "json:\"code,omitempty\" schema:\"code\""
	Email             *string    "json:\"email,omitempty\" schema:\"email\""
	Password          *string    "json:\"password,omitempty\" schema:\"password\""
	StringArraySample *[]*string "json:\"stringArraySample,omitempty\" schema:\"stringArraySample\""
	HogeType          *string    "json:\"hogeType,omitempty\" schema:\"hogeType\""
	Nested1           *struct {
		IntSample    *int     "json:\"intSample,omitempty\" schema:\"intSample\""
		NumberSample *float64 "json:\"numberSample,omitempty\" schema:\"numberSample\""
		BoolSample   *bool    "json:\"boolSample,omitempty\" schema:\"boolSample\""
	} "json:\"nested1,omitempty\" schema:\"nested1\""
}
