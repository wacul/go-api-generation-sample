fs = require "fs"
_ = require "lodash"
require 'coffee-script/register'
{escapeRegExp, escapeDoubleQuote, toCamelCase, defProps, defRequestStructName, defRequestName} = require './common'

doubleQuote = (str) ->
  return "\"#{escapeDoubleQuote(str)}\""

formatFuncMap =
  "email": "validateEmail"

module.exports.defValidatorName = defValidatorName = (link) ->
  defRequestName(link) + "Validator"

module.exports.generateValidator = (schemaJson, flattenDir, outputDir) ->
  packageName = outputDir.split('/').pop()
  header = """
  package #{packageName}

  import (
    "regexp"
  	"github.com/wcl48/valval"
  )
  var _ = valval.String
  var _ = regexp.Compile

  """

  body = fs.readdirSync(flattenDir)
  .map (path) ->
    definition = JSON.parse(fs.readFileSync("#{flattenDir}/#{path}"))
    definition.links.map (link) ->
      "var #{defValidatorName(link)} = " + validaterCode link.schema
    .join("\n\n")
  .join "\n\n"

  fs.writeFileSync("#{outputDir}/validators.go", header + "\n\n" + body)

commonValidates = (schema) ->
  validates = []
  typeString = "" + schema.type

  # enum
  if schema.enum?
    if typeString in ["number", "integer"]
      validates.push("valval.In(#{schema.enum.join(',')}),")
    if typeString == "string"
      validates.push("valval.In(#{schema.enum.map(doubleQuote).join(',')}),")

  # format
  if typeString == "string" and schema.format?
    vf = formatFuncMap[schema.format]
    if vf
      validates.push(vf + ",")

  return validates

validaterCode = (schema) ->
  if not schema?
    return "valval.Any()"
  typeString = "" + schema.type
  switch typeString
    when "string"
      validates = []
      if schema.minLength?
        validates.push "valval.MinLength(#{schema.minLength}),"
      if schema.maxLength?
        validates.push "valval.MaxLength(#{schema.maxLength}),"
      if schema.pattern?
        validates.push "valval.Regexp(regexp.MustCompile(`#{schema.pattern}`)),"
      validates = validates.concat commonValidates(schema)
      return """valval.String(
        #{validates.join("\n")}
      )"""
    when "number", "integer"
      validates = []
      if schema.minimum?
        if schema.exclusiveMinimum
          validates.push "valval.GreaterThan(#{schema.minimum}),"
        else
          validates.push "valval.Min(#{schema.minimum}),"
      if schema.maximum?
        if schema.exclusiveMaximum
          validates.push "valval.LessThan(#{schema.maximum}),"
        else
          validates.push "valval.Max(#{schema.maximum}),"
      validates = validates.concat commonValidates(schema)
      return """valval.Number(
        #{validates.join("\n")}
      )"""
    when "bool"
      return "valval.Bool()"
    when "array"
      if typeof schema.items.indexOf == 'function'
        throw "タプル形式の配列には未対応"
      validates = []
      if schema.minItems?
        validates.push "valval.MinSliceLength(#{schema.minItems}),"
      if schema.maxItems?
        validates.push "valval.MaxSliceLength(#{schema.maxItems}),"
      if schema.uniqueItems
        throw "uniqueItems未対応"
      return """valval.Slice(
        #{validaterCode(schema.items)},
      ).Self(
        #{validates.join('\n')}
      )"""
    when "object"
      members = _(schema.properties).map( (innerSchema, key) ->
        return """
          "#{toCamelCase(key)}" : #{validaterCode(innerSchema)},
        """.trim()
      ).value()
      validates = []
      if schema.required?
        fields = schema.required
          .map toCamelCase
          .map doubleQuote
          .join ", "
        validates.push "valval.RequiredFields(#{fields}),"
      return """valval.Object(valval.M{
        #{members.join('\n')}
      }).Self(
        #{validates.join('\n')}
      )"""
