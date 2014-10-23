fs = require 'fs'
path = require 'path'

module.exports.copyTemplates = (templateDir, outputDir) ->
  packageName = outputDir.split('/').pop()

  fs.readdirSync(templateDir).map (path) ->
    template = fs.readFileSync "#{templateDir}/#{path}"
    out = String(template).replace /__package__/, packageName
    fs.writeFileSync "#{outputDir}/#{path}", out
