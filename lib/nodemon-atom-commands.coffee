nodemon = require './nodemon'

getCommands = ->
  NodemonProcess                 = require './models/nodemon-run'
  NodemonSetArgs                 = require './models/nodemon-set-args'

  nodemon.getRepo()
    .then (repo) ->
      commands = []
      commands.push ['nodemon-atom:run', 'Run', -> NodemonRun(repo)]
      commands.push ['nodemon-atom:kill', 'Kill', -> NodemonKill(repo)]
      commands.push ['nodemon-atom:set-args', 'Set Args', -> new NodemonSetArgs(repo)]

      return commands

module.exports = getCommands
