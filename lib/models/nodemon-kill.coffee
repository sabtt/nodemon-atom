nodemon = require '../nodemon'

NodemonKill = (repo) ->
  filePath = nodemon.filePath repo
  nodemon.kill filePath

module.exports.NodemonKill = NodemonKill
