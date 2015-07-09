nodemon = require './nodemon'

getCommands = ->
  nodemonSetArgs                 = require './models/nodemon-set-args'

  nodemon.getRepo()
    .then (repo) ->
      commands = []
      commands.push ['nodemon-atom:set-args', 'Set Args', -> nodemonSetArgs(repo)]

      return commands

module.exports = getCommands
