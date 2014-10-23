package gen

import (
	"errors"
	"regexp"

	"github.com/wcl48/valval"
)

var emailRe = regexp.MustCompile(`^.+@.+\..+$`)

var validateEmail = valval.NewStringValidator(func(str string) error {
	if !emailRe.MatchString(str) {
		return errors.New("invalid email")
	}
	return nil
})
