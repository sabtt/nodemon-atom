{CompositeDisposable} = require 'atom'
fs = require 'fs-plus'
Path = require 'path'
os = require 'os'

nodemon = require '../nodemon'
notifier = require '../notifier'

class NodemonSetArgs


  # Public: Helper method to join @repo.path
  #
  # Returns: The full path to our NODEMON_ARGUMENTS file as {String}
  filePath: -> Path.join(@repo.path, atom.config.get('nodemon-atom.argumentsFile'))

  constructor: (@repo, {@amend, @andPush}={}) ->
    @currentPane = atom.workspace.getActivePane()
    @disposables = new CompositeDisposable
    @prepFile()

  # Public: Prepares our setArgs message file by writing the status and a
  #         possible amend message to it.
  #
  # status - The current status as {String}.
  prepFile: ->
    # Create and show the file
    old_args = nodemon.getArgs @filePath()
    fs.writeFileSync @filePath(), old_args
    @showFile()

  # Public: Helper method to open the setArgs message file and to subscribe the
  #         'saved' and `destroyed` events of the underlaying text-buffer.
  showFile: ->
    atom.workspace
      .open(@filePath(), searchAllPanes: true)
      .then (textEditor) =>
        if atom.config.get('nodemon-atom.openInPane')
          @splitPane(atom.config.get('nodemon-atom.splitPane'), textEditor)
        else
          @disposables.add textEditor.onDidSave => @setArgs()
          @disposables.add textEditor.onDidDestroy => @cleanup()

  splitPane: (splitDir, oldEditor) ->
    pane = atom.workspace.paneForURI(@filePath())
    options = { copyActiveItem: true }
    hookEvents = (textEditor) =>
      oldEditor.destroy()
      @disposables.add textEditor.onDidSave => @setArgs()
      @disposables.add textEditor.onDidDestroy => @cleanup()

    directions =
      left: =>
        pane = pane.splitLeft options
        hookEvents(pane.getActiveEditor())
      right: ->
        pane = pane.splitRight options
        hookEvents(pane.getActiveEditor())
      up: ->
        pane = pane.splitUp options
        hookEvents(pane.getActiveEditor())
      down: ->
        pane = pane.splitDown options
        hookEvents(pane.getActiveEditor())
    directions[splitDir]()

  # Public: When the user is done editing the setArgs message an saves the file
  #         this method gets invoked and commits the changes.
  setArgs: ->
    options = encoding: "utf8"
    new_args = fs.readFileSync @filePath(), options
    nodemon.setArgs @filePath(), new_args
    @destroyActiveEditorView()
    # args = ['setArgs', '--cleanup=strip', "--file=#{@filePath()}"]
    # nodemon.cmd
    #   args: args,
    #   options:
    #     cwd: @repo.path
    #   stdout: (data) =>
    #     notifier.addSuccess data
    #     if @andPush
    #       new GitPush(@repo)
    #     @isAmending = false
    #     @destroyActiveEditorView()
    #     # Activate the former active pane.
    #     @currentPane.activate() if @currentPane.alive
    #     nodemon.refresh()
    #
    #   stderr: (err) =>
    #     # Destroying the active EditorView will trigger our cleanup method.
    #     @destroyActiveEditorView()

  # Public: Destroys the active EditorView to trigger our cleanup method.
  destroyActiveEditorView: ->
    if atom.workspace.getActivePane().getItems().length > 1
      atom.workspace.destroyActivePaneItem()
    else
      atom.workspace.destroyActivePane()

  # Public: Cleans up after the EditorView gets destroyed.
  cleanup: ->
    @currentPane.activate() if @currentPane.alive
    @disposables.dispose()
    try fs.unlinkSync @filePath()

module.exports = NodemonSetArgs
