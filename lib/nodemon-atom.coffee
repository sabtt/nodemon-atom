nodemon = require './nodemon'
NodemonAtomCommands = require './views/nodemon-atom-menu'
NodemonProcess      = require './models/nodemon-run'
NodemonSetArgs      = require './models/nodemon-set-args'

module.exports =
  config:
    openInPane:
      type: 'boolean'
      default: true
      description: 'Allow commands to open new panes'
    splitPane:
      title: 'Split pane direction (up, right, down, or left)'
      type: 'string'
      default: 'right'
      description: 'Where should new panes go? (Defaults to right)'
    nodemonPath:
      type: 'string'
      default: 'nodemon'
      description: 'Where is your nodemon?'
    argumentsFile:
      type: 'string'
      default: 'NODEMON_ARGUMENTS'
      description: 'Arguments file name'
    maxLines:
      type: 'integer'
      default: 10
      description: 'How long is the nodemon output allowed to be'
    messageTimeout:
      type: 'integer'
      default: 5
      description: 'How long should success/error messages be shown?'

  activate: (state) ->
    atom.commands.add 'atom-workspace', 'nodemon-atom:menu', -> new NodemonAtomCommands()
    atom.commands.add 'atom-workspace', 'nodemon-atom:run', -> nodemon.setArgs().then((repo) -> NodemonProcess.NodemonRun(repo))
    atom.commands.add 'atom-workspace', 'nodemon-atom:kill', -> nodemon.setArgs().then((repo) -> NodemonProcess.NodemonKill(repo))
    atom.commands.add 'atom-workspace', 'nodemon-atom:set-args', -> nodemon.setArgs().then((repo) -> new NodemonSetArgs(repo))
