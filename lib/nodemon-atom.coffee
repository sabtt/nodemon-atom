nodemon = require './nodemon'
NodemonAtomCommands = require './views/nodemon-atom-menu'
NodemonSetArgs      = require './models/nodemon-set-args'

module.exports =
  config:
    includeStagedDiff:
      title: 'Include staged diffs?'
      description: 'description'
      type: 'boolean'
      default: true
    openInPane:
      type: 'boolean'
      default: true
      description: 'Allow commands to open new panes'
    splitPane:
      title: 'Split pane direction (up, right, down, or left)'
      type: 'string'
      default: 'right'
      description: 'Where should new panes go? (Defaults to right)'
    wordDiff:
      type: 'boolean'
      default: true
      description: 'Should word diffs be highlighted in diffs?'
    amountOfCommitsToShow:
      type: 'integer'
      default: 25
      minimum: 1
    gitPath:
      type: 'string'
      default: 'nodemon'
      description: 'Where is your nodemon?'
    messageTimeout:
      type: 'integer'
      default: 5
      description: 'How long should success/error messages be shown?'

  activate: (state) ->
    atom.commands.add 'atom-workspace', 'nodemon-atom:menu', -> new NodemonAtomCommands()
    atom.commands.add 'atom-workspace', 'nodemon-atom:set-args', -> nodemon.setArgs().then((repo) -> NodemonSetArgs(repo))
