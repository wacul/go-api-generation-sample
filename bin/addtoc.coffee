fs = require("fs")

module.exports.convertToc = (file) ->
  text = fs.readFileSync(file,
    encoding: "utf8"
  )
  titles = text.match /^## .+$/gm

  toc = ""
  if titles?
    toc = titles.map((t) ->
      title = t.split(/\s+/).pop()
      "* [" + title + "](#" + encodeURIComponent(title.toLowerCase()) + ")"
    ).join("\n")

  text = text.replace("{toc}", toc)
  fs.writeFileSync file, text
  return
