fs = require("fs")
path = require "path"
pj = path.join
require 'coffee-script/register'
{toCamelCase, defProps, defRequestStructName} = require './common'

module.exports.generateStructs = (flattenDir, outputDir) ->
  packageName = outputDir.split('/').pop()

  structs = fs.readdirSync(flattenDir)
    .map (path) ->
      definition = JSON.parse(fs.readFileSync( pj flattenDir, path ))
      createRequestStruct = (link) ->
        ret = []
        ret.push "type #{defRequestStructName(link)} struct {"
        ret.push defProps(link.schema)
        ret.push "}"
        ret.join "\n"

      createResponseStruct = (definition) ->
        ret = []
        ret.push "type #{toCamelCase(path.split('.').shift())} struct {"
        ret.push defProps(definition)
        ret.push "}"
        ret.join "\n"

      resStruct = createResponseStruct(definition)
      reqStructs = definition.links.map(createRequestStruct).join "\n\n"
      resStruct + "\n\n" + reqStructs
    .join "\n\n"


  fs.writeFileSync("#{outputDir}/structs.go", """
  package #{packageName}

  import (
  "time"

  "gopkg.in/mgo.v2/bson"
  )

  var _ = time.Now
  var _ = bson.NewObjectId
  #{structs}
  """)
