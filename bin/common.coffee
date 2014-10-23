pluralize = require 'pluralize'



formatRegexpMap =
  "email" :  "^[a-z0-9._%+\-]+@[a-z0-9.\-]+\.[a-z]{2,4}$"

defType = (prop) ->
  typeString = "" + prop.type
  "*" + (do ->
    if prop.properties?
      """
        struct {
          #{defProps(prop)}
        }
      """
    else if typeString == "array"
      "[]#{defType(prop.items)}"
    else
      if prop.format == "objectid"
        "bson.ObjectId"
      else if prop.format == "date-time"
        "time.Time"
      else if typeString == "number"
        "float64"
      else if typeString == "integer"
        "int"
      else if typeString == "object"
        "interface{}"
      else
        prop.type
  )

module.exports =
  escapeRegExp: (str) ->
    str.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&")

  escapeDoubleQuote: (str) ->
    str
      .replace /\\/g, "\\\\"
      .replace /"/g, "\\\""

  toCamelCase: (s) ->
    s.replace /^(.)(.*)$/, (all, car, cdr) ->
      car.toUpperCase() + cdr
    .replace /-([a-z])/g, (all, c) ->
      "#{c.toUpperCase()}"

  defProps: (def) ->
    if not def
      return ""

    Object.keys(def.properties ? {})
    .map (k) ->
      prop = def.properties[k]
      tagStr = escapeDoubleQuote(
        "json:\"#{k},omitempty\" schema:\"#{k}\"")

      """
      #{toCamelCase(k)} #{defType(prop)} "#{tagStr}"
      """
    .join "\n"

  defRequestName: (link) ->
    id = false
    buf = []
    hrefPartsReversed = link
    .href
    .split('/')
    .filter (s) -> s != ""
    .reverse()
    .forEach (part) ->
      if part.match /{.*}/
        id = true
      else
        if id
          single = pluralize.singular part
          if single == part
            throw "#{part} is single word! use #{pluralize.plural(part)}"
          buf.unshift single
        else
          buf.unshift part
        id = false

    buf
    .map(toCamelCase)
    .join('') + toCamelCase(link.method.toLowerCase())

  defRequestStructName: (link) ->
    defRequestName(link) + "Param"

{
  escapeRegExp
  escapeDoubleQuote,
  toCamelCase,
  defProps,
  defRequestName,
  defRequestStructName,
  validationTag
} = module.exports

if require.main == module
  console.log defRequestName {href: "/users/{abc}/reservations", method: "POST"}
  console.log defRequestName {href: "/users/{abc}/reservations/{reservationID}", method: "GET"}
  console.log defRequestName {href: "/children/{abc}/reservations", method: "GET"}
  console.log defRequestName {href: "/child/{abc}/reservations", method: "GET"}
