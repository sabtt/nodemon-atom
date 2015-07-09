nodemon = require '../nodemon'

nodemonSetArgs = (repo, {addAll}={}) ->
  if not addAll
    file = repo.relativize(atom.workspace.getActiveTextEditor()?.getPath())
  else
    file = null

  nodemon.setArgs(repo, file: file)

module.exports = nodemonSetArgs
