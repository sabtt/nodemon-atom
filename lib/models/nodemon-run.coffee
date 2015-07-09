spawnargs = require 'spawn-args'

nodemon = require '../nodemon'
OutputView = require '../views/output-view'

NodemonRun = (repo) ->
  filePath = nodemon.filePath repo
  args = nodemon.parseArgs filePath
  view = new OutputView()
  nodemon.cmd
    name: filePath
    args: args
    cwd: repo.path
    stdout: (data) -> view.addLine(data.toString())
    stderr: (data) -> view.addLine(data.toString())
    exit: (code) => view.finish()

NodemonKill = (repo) ->
  filePath = nodemon.filePath repo
  nodemon.kill filePath

module.exports.NodemonRun = NodemonRun
module.exports.NodemonKill = NodemonKill
