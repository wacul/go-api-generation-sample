package gen

import (
	"encoding/json"
	"errors"
	"fmt"
	"net/http"

	"github.com/gorilla/mux"
)

var _ = fmt.Print

type HogePostParamDataHandler func(
	vars map[string]string,
	param HogePostParam,
	r *http.Request) (Hoge, error)

func init() {
	addImplDef("/hoge", "POST")
}

func InjectHogePost(
	router *mux.Router,
	dh HogePostParamDataHandler,
	middleware func(http.HandlerFunc) http.HandlerFunc,
) {
	if dh == nil {
		panic(errors.New("Nil handler passed to InjectHogePost !!!"))
	}

	handler := hogePostParamHandler(dh)
	if middleware != nil {
		handler = middleware(handler)
	}
	router.HandleFunc("/hoge", handler).Methods("POST")
	markImpl("/hoge", "POST")
}

func hogePostParamHandler(dh HogePostParamDataHandler) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var err error
		defer handleRuntimeError(w)

		var reqData HogePostParam

		// 1. decode from json
		if r.Body != nil {
			decoder := json.NewDecoder(r.Body)
			err := decoder.Decode(&reqData)
			if err != nil {
				SendError(w, NewAPIError(http.StatusBadRequest, "json parse error"))
				return
			}
		}

		// 2. validate request
		if err := HogePostValidator.Validate(&reqData); err != nil {
			SendError(w, validateError2APIError(err))
			return
		}

		// 3. handle datas
		vars := mux.Vars(r)
		res, err := dh(vars, reqData, r)
		if err != nil {
			SendError(w, err)
			return
		}

		// 5. encode to json
		b, err := json.Marshal(&res)
		if err != nil {
			SendError(w, err)
			return
		}

		// 6. send data
		w.Header().Add("Content-Type", "application/json")
		fmt.Fprintf(w, string(b))
	}
}
