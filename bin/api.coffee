fs = require 'fs'
require 'coffee-script/register'
{toCamelCase, defProps, defRequestName, defRequestStructName} = require './common'
{defValidatorName} = require './validator'
path = require 'path'
pj = path.join

writeResponse = (responseTypes) ->
  if responseTypes.length == 1
    """
    err = dh(vars, reqData, r)
		if err != nil {
			SendError(w, err)
			return
		}

		// 6. send data
		w.Header().Add("Content-Type", "application/json")
    """
  else
    """
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
    """

parseParam = (method) ->
  if method.toLowerCase() == "get"
    """
    err = decoder.Decode(&reqData, r.URL.Query())
    if err != nil {
    	SendError(w, err)
    	return
    }
    """
  else
    """
		if r.Body != nil {
      decoder := json.NewDecoder(r.Body)
			err := decoder.Decode(&reqData)
			if err != nil {
				SendError(w, NewAPIError(http.StatusBadRequest, "json parse error"))
				return
			}
		}
    """

module.exports.generateAPI = (flattenDir, outputDir) ->
  packageName = outputDir.split('/').pop()
  fs.readdirSync(flattenDir).map (path) ->
    definition = JSON.parse(fs.readFileSync(pj flattenDir, path))

    header = """
      package #{packageName}

      import (
        "fmt"
        "encoding/json"
        "net/http"
        "errors"

        "github.com/gorilla/mux"
      )

      var _ = fmt.Print

    """

    body = definition.links
      .map (link) ->
        requestName = defRequestName link
        requestStructName = defRequestStructName link
        dataHandlerName = requestStructName.replace(/Request$/, '') + 'DataHandler'
        responseStructName = toCamelCase(path.split('.').shift())
        validatorName = defValidatorName link
        responseTypes = ["error"]
        switch link.rel
          when "self", "create", "update"
            responseTypes.unshift  responseStructName
          when "instances"
            responseTypes.unshift "[]#{responseStructName}"

        privateHandlerName = requestStructName.replace(/^./, (c) -> c.toLowerCase()) + 'Handler'
        """
          type #{dataHandlerName} func(
            vars map[string]string,
            param #{requestStructName},
            r *http.Request) (#{responseTypes.join ", "})

          func init(){
            addImplDef("#{link.href}", "#{link.method}")
          }

          func Inject#{requestName}(
            router *mux.Router,
            dh #{dataHandlerName},
            middleware func(http.HandlerFunc) http.HandlerFunc,
          ) {
            if dh == nil {
              panic(errors.New("Nil handler passed to Inject#{requestName} !!!"))
            }

          	handler := #{privateHandlerName}(dh)
           	if middleware != nil {
          		handler = middleware(handler)
          	}
          	router.HandleFunc("#{link.href}", handler).Methods("#{link.method}")
            markImpl("#{link.href}", "#{link.method}")
          }

          func #{privateHandlerName}(dh #{dataHandlerName}) http.HandlerFunc {
            return func(w http.ResponseWriter, r *http.Request) {
              var err error
              defer handleRuntimeError(w)

              var reqData #{requestStructName}

          		// 1. decode from json
              #{ parseParam(link.method) }

          		// 2. validate request
              if err := #{validatorName}.Validate(&reqData); err != nil {
          			SendError(w, validateError2APIError(err))
          			return
              }

          		// 3. handle datas
          		vars := mux.Vars(r)
              #{writeResponse(responseTypes)}
            }
          }
        """
      .join "\n"

    fs.writeFileSync("#{outputDir}/#{path.split('.').shift()}.go", header + body)
