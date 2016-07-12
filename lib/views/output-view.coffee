{$, ScrollView} = require 'atom-space-pen-views'
ansi_up         = require 'ansi_up'

module.exports =
  class OutputView extends ScrollView
    message: ""

    @content: ->
      @div class: 'nodemon-atom info-view', =>
        @pre class: 'output'

    initialize: ->
      super
      @panel ?= atom.workspace.addBottomPanel(item: this)

    addLine: (line) ->
      @message += line
      newlines = (@message.match(/\n/g) || []).length
      while newlines > atom.config.get('nodemon-atom.maxLines')
        @message = @message.substring(@message.indexOf("\n") + 1)
        newlines = (@message.match(/\n/g) || []).length
      @find(".output").html(ansi_up.ansi_to_html(@message))

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
