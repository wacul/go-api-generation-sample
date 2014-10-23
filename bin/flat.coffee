fs = require("fs")
_ = require("lodash")

###
$refを解決してプレーンなjson-schemaを生成する
###

module.exports.flattenSchema = (schemaJson, flattenDir) ->
  doc = JSON.parse(fs.readFileSync(schemaJson))

  getRef = (s) ->
    getProp = (o, propNames) ->
      return o  unless propNames.length
      getProp o[propNames[0]], propNames.slice(1)
    propNames = s.split("/").slice(1)
    result = getProp(doc, propNames)
    return result  unless result.$ref
    getRef result.$ref

  createFlatSchema = (apiDefinition) ->
    resolveRef = (o) ->
      _.forEach o, ((v, k) ->
        return resolveRef(v)  if typeof v is "object"
        if k is "$ref"
          obj = getRef(v)
          delete @$ref

          _.merge obj, this
          _.merge this, obj
        return
      ), o
    clone = _.clone(apiDefinition)
    resolveRef clone
    clone

  _.forEach doc.definitions, (v, k) ->
    fs.writeFileSync flattenDir + "/" + k + ".json", JSON.stringify(createFlatSchema(v), null, 2)
