var fs = require('fs');

module.exports.convertToc = function(file){
  var text = fs.readFileSync(file, {
    encoding: 'utf8'
  });
  var titles = text.match(/^## .+$/gm);
  var toc = titles.map(function(t) {
    var title = t.split(/\s+/).pop();
    return '* [' + title + '](#' + encodeURIComponent(title.toLowerCase()) + ')';
  }).join('\n');

  text = text.replace('{toc}', toc);
  fs.writeFileSync(file, text);
};
