fs = require "fs"
text = fs.readFileSync("schema.md", {encoding: 'utf8'})
titles = text.match(/^## .+$/gm)
toc = titles
  .map (t) ->
    title = t.split(/\s+/).pop()
    "* [#{title}](\##{encodeURIComponent(title.toLowerCase())})"
  .join("\n")
text = text.replace("{toc}", toc)
fs.writeFileSync("schema.md", text)