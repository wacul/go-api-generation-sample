package gen

import (
	"github.com/wcl48/valval"
	"regexp"
)

var _ = valval.String
var _ = regexp.Compile

var HogePostValidator = valval.Object(valval.M{
	"Name": valval.String(),
	"Code": valval.String(
		valval.MinLength(8),
		valval.MaxLength(16),
		valval.Regexp(regexp.MustCompile(`^[a-z0-9]+$`)),
	),
	"Email": valval.String(
		validateEmail,
	),
	"Password": valval.String(
		valval.Regexp(regexp.MustCompile(`^[a-zA-Z0-9_]$`)),
	),
	"StringArraySample": valval.Slice(
		valval.String(
			valval.MinLength(1),
			valval.MaxLength(50),
			validateEmail,
		),
	).Self(
		valval.MinSliceLength(1),
		valval.MaxSliceLength(10),
	),
	"HogeType": valval.String(
		valval.In("aiueo", "kakikukeko"),
	),
	"Nested1": valval.Object(valval.M{
		"IntSample": valval.Number(
			valval.Min(1),
			valval.Max(100),
		),
		"NumberSample": valval.Number(
			valval.Min(1.1),
			valval.Max(111.1),
		),
		"BoolSample": valval.Bool(),
	}).Self(),
}).Self(
	valval.RequiredFields("Email", "Password", "Name"),
)
