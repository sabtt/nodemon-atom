nodemon = require './nodemon'

getCommands = ->
  NodemonSetArgs                 = require './models/nodemon-set-args'

  nodemon.getRepo()
    .then (repo) ->
      commands = []
      commands.push ['nodemon-atom:set-args', 'Set Args', -> new NodemonSetArgs(repo)]

      return commands

module.exports = getCommands
