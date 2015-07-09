{$, ScrollView} = require 'atom-space-pen-views'

module.exports =
  class OutputView extends ScrollView
    message: ''

    @content: ->
      @div class: 'nodemon-atom info-view', =>
        @pre class: 'output'

    initialize: ->
      super
      @panel ?= atom.workspace.addBottomPanel(item: this)

    addLine: (line) ->
      @find(".output").append(line)

    reset: ->
      @message = ''

    finish: ->
      @find(".output").append(@message)
      setTimeout =>
        @destroy()
      , atom.config.get('nodemon-atom.messageTimeout') * 1000

    remove: ->
      @destroy()

    destroy: ->
      @panel?.destroy()
