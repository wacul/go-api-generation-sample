require 'longjohn'
fibrous = require 'fibrous'
os = require 'os'
fs = require 'fs'
path = require 'path'
{spawn} = require 'child_process'

addtoc = require './bin/addtoc'
flatten = require './bin/flat'
{copyTemplates} = require "./bin/copy_templates"
{generateStructs} = require "./bin/struct"
{generateAPI} = require './bin/api'
{generateValidator} = require './bin/validator'

pj = path.join

option '-g', '--go_dir [dir]', "generated go files dir"
option '-s', '--source_dir [dir]', "source dir"

runInWd = (wd, cmd, args... ,cb) ->
  currentEnv = process.env
  data = ""
  p = spawn cmd, args, {
    env : currentEnv
    cwd : wd
  }

  p.stdout.on "data", (d) ->
    data += d

  p.stderr.on "data", (d) ->
    process.stderr.write d

  p.on "error", ->
    cb? "error!!!"

  p.on "close",  (code) ->
    if code > 0
      cb? "error", data
    else
      cb? null, data

run = (cmd, args..., cb) ->
  runInWd  process.cwd(), cmd, args..., cb

runInWdSync = ->
  return runInWd.sync arguments...

runSync = ->
  return run.sync arguments...

getTempDir = ->
  pj os.tmpdir(), "sure-web-doc-" + Math.floor(Math.random() * (2 << 24))

getSourcePaths = (options) ->
  s = path.resolve process.cwd(), options.source_dir
  g = path.resolve process.cwd(), options.go_dir
  tmp = getTempDir()

  return {
    tmpDir : tmp
    meta: pj s, "meta.yml"
    schemata: pj s, "schemata"
    overview: pj s, "overview.md"
    schemajson: pj s, "schema.json"
    schemamd: pj s, "schema.md"
    flattenDir: pj tmp, "flatten"
    templatesDir : pj __dirname, "templates"
    goDir: g
  }

makeDirs = (paths) ->
  [paths.tmpDir, paths.flattenDir, paths.goDir].forEach (d) ->
    try
      fs.mkdirSync d
    catch
      #ignore

task "build", "build all", (options) ->  fibrous.run ->
  if not options.source_dir?
    console.error "please set source dir (-s)"
    process.exit(1)

  if not options.go_dir?
    console.error "please set go dir (-g)"
    process.exit(1)

  paths = getSourcePaths options
  makeDirs paths

  # schema.json 生成
  sj = runSync "prmd", "combine", "-m", paths.meta, paths.schemata
  fs.writeFileSync paths.schemajson, sj

  # schema.md 生成
  smd = runSync "prmd", "doc", "-p", paths.overview, paths.schemajson
  fs.writeFileSync paths.schemamd, smd

  # 見出しをつける
  addtoc.convertToc paths.schemamd

  # 参照をフラットにした schemaを作る
  flatten.flattenSchema paths.schemajson, paths.flattenDir

  # 共通ファイルをパッケージディレクトリにコピー
  copyTemplates paths.templatesDir, paths.goDir

  # 構造体を出力
  generateStructs paths.flattenDir, paths.goDir

  # API出力
  generateAPI paths.flattenDir, paths.goDir

  # # バリデータ出力
  generateValidator paths.schemajson, paths.flattenDir, paths.goDir

  # go fmt
  runInWdSync paths.goDir, "go", "fmt", "."

  runSync "rm",  "-rf", paths.tmpdir

  console.log "go package generated in : #{paths.goDir}"
  console.log "schema.md generated in  : #{paths.schemamd}"
