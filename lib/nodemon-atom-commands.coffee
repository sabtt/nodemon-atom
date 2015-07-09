nodemon = require './nodemon'

getCommands = ->
  NodemonProcess                 = require './models/nodemon-run'
  NodemonSetArgs                 = require './models/nodemon-set-args'

  nodemon.getRepo()
    .then (repo) ->
      commands = []
      commands.push ['nodemon-atom:run', 'Run', -> NodemonProcess.NodemonRun(repo)]
      commands.push ['nodemon-atom:kill', 'Kill', -> NodemonProcess.NodemonKill(repo)]
      commands.push ['nodemon-atom:set-args', 'Set Args', -> new NodemonSetArgs(repo)]

      return commands

module.exports = getCommands
