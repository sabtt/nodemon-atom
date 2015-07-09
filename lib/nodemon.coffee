{BufferedProcess, nodemonRepository} = require 'atom'
# RepoListView = require './views/repo-list-view'
notifier = require './notifier'

# Public: Execute a nodemon command.
#
# options - An {Object} with the following keys:
#   :args    - The {Array} containing the arguments to pass.
#   :cwd  - Current working directory as {String}.
#   :options - The {Object} with options to pass.
#   :stdout  - The {Function} to pass the stdout to.
#   :exit    - The {Function} to pass the exit code to.
#
# Returns nothing.
nodemonCmd = ({args, cwd, options, stdout, stderr, exit}={}) ->
  command = _getnodemonPath()
  options ?= {}
  options.cwd ?= cwd
  stderr ?= (data) -> notifier.addError data.toString()

  if stdout? and not exit?
    c_stdout = stdout
    stdout = (data) ->
      @save ?= ''
      @save += data
    exit = (exit) ->
      c_stdout @save ?= ''
      @save = null

  try
    new BufferedProcess
      command: command
      args: args
      options: options
      stdout: stdout
      stderr: stderr
      exit: exit
  catch error
    notifier.addError 'Nodemon Atom is unable to locate nodemon command. Please ensure process.env.PATH can access nodemon.'

nodemonStatus = (repo, stdout) ->
  nodemonCmd
    args: ['status', '--porcelain', '-z']
    cwd: repo.getWorkingDirectory()
    stdout: (data) -> stdout(if data.length > 2 then data.split('\0') else [])

nodemonSetArgs = (repo, {file, stdout, stderr, exit}={}) ->
  console.log "nodemonSetArgs"
  console.log repo
  # exit ?= (code) ->
  #   if code is 0
  #     notifier.addSuccess "Added #{file ? 'all files'}"
  # nodemonCmd
  #   args: ['add', '--all', file ? '.']
  #   cwd: repo.getWorkingDirectory()
  #   stdout: stdout if stdout?
  #   stderr: stderr if stderr?
  #   exit: exit

_getnodemonPath = ->
  p = atom.config.get('nodemon-plus.nodemonPath') ? 'nodemon'
  console.log "nodemon-plus: Using nodemon at", p
  return p

_prettify = (data) ->
  data = data.split('\0')[...-1]
  files = [] = for mode, i in data by 2
    {mode: mode, path: data[i+1]}

_prettifyUntracked = (data) ->
  return [] if not data?
  data = data.split('\0')[...-1]
  files = [] = for file in data
    {mode: '?', path: file}

_prettifyDiff = (data) ->
  data = data.split(/^@@(?=[ \-\+\,0-9]*@@)/gm)
  data[1..data.length] = ('@@' + line for line in data[1..])
  data

# Returns the working directory for a nodemon repo.
# Will search for submodule first if currently
#   in one or the project root
#
# @param andSubmodules boolean determining whether to account for submodules
dir = (andSubmodules=true) ->
  new Promise (resolve, reject) ->
    if andSubmodules and submodule = getSubmodule()
      resolve(submodule.getWorkingDirectory())
    else
      getRepo().then (repo) -> resolve(repo.getWorkingDirectory())

# returns filepath relativized for either a submodule or repository
#   otherwise just a full path
relativize = (path) ->
  getSubmodule(path)?.relativize(path) ? atom.project.getDirectories()[0]?.relativize(path) ? path

# returns submodule for given file or undefined
getSubmodule = (path) ->
  path ?= atom.workspace.getActiveTextEditor()?.getPath()
  repo = nodemonRepository.open(atom.workspace.getActiveTextEditor()?.getPath(), refreshOnWindowFocus: false)
  submodule = repo?.repo.submoduleForPath(path)
  repo?.destroy?()
  submodule

# Public: Get the repository of the current file or project if no current file
# Returns a {Promise} that resolves to a repository like object
getRepo = ->
  new Promise (resolve, reject) ->
    getRepoForCurrentFile().then (repo) -> resolve(repo)
    .catch (e) ->
      projects = atom.project.getDirectories().filter (r) -> r?
      if projects.length is 0
        reject("No projects found")
      # else if projects.length > 1
      #   resolve(new RepoListView(projects).result)
      else
        resolve(projects[0])

getRepoForCurrentFile = ->
  new Promise (resolve, reject) ->
    project = atom.project
    path = atom.workspace.getActiveTextEditor()?.getPath()
    directory = project.getDirectories().filter((d) -> d.contains(path))[0]
    if directory?
      resolve(directory)
    else
      reject "no current file"

module.exports.cmd = nodemonCmd
module.exports.setArgs = nodemonSetArgs
module.exports.dir = dir
module.exports.relativize = relativize
module.exports.getSubmodule = getSubmodule
module.exports.getRepo = getRepo
