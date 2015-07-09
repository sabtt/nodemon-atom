{BufferedProcess, gitRepository} = require 'atom'
spawnargs = require 'spawn-args'
Path = require 'path'

notifier = require './notifier'

processes = {}
views = {}

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
nodemonCmd = ({name, args, cwd, options, stdout, stderr, exit}={}) ->
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
    process = new BufferedProcess
      command: command
      args: args
      options: options
      stdout: stdout
      stderr: stderr
      exit: exit
    if name?
      processes[name] = process
      console.log processes
  catch error
    notifier.addError 'Nodemon Atom is unable to locate nodemon command. Please ensure process.env.PATH can access nodemon.'

nodemonKill = (name) ->
  console.log "killing"
  if name in processes
    console.log processes[name]
    processes[name].kill()
  if name in views
    console.log views[name]
    views[name].destory()

filePath = (repo) ->
  Path.join(repo.path, atom.config.get('nodemon-atom.argumentsFile'))

nodemonParseArgs = (file_path) ->
  args = nodemonGetArgs(file_path)
  options = removequotes: true
  args = spawnargs(args, options)
  for i of args
    name = args[i]
    if name[0] == "\"" and name[name.length - 1] == "\""
      args[i] = name[1 ... name.length - 1]
    else if name[0] == "\'" and name[name.length - 1] == "\'"
      args[i] = name[1 ... name.length - 1]
  return args

nodemonStatus = (repo, stdout) ->
  nodemonCmd
    args: ['status', '--porcelain', '-z']
    cwd: repo.getWorkingDirectory()
    stdout: (data) -> stdout(if data.length > 2 then data.split('\0') else [])

nodemonRun = (filePath) ->
  args2 = spawnargs('-port 80 --title "this is a title"', { removequotes: true });
  # exit ?= (code) ->
  #   if code is 0
  #     notifier.addSuccess "Added #{file ? 'all files'}"
  # nodemonCmd
  #   args: ['add', '--all', file ? '.']
  #   cwd: repo.path
  #   stdout: stdout if stdout?
  #   stderr: stderr if stderr?
  #   exit: exit

nodemonSetArgs = (filePath, new_args) ->
  return atom.config.set("nodemon-atom.args_" + filePath, new_args)
# exit ?= (code) ->
#   if code is 0
#     notifier.addSuccess "Added #{file ? 'all files'}"
# nodemonCmd
#   args: ['add', '--all', file ? '.']
#   cwd: repo.path
#   stdout: stdout if stdout?
#   stderr: stderr if stderr?
#   exit: exit

nodemonGetArgs = (filePath) ->
  old_args = atom.config.get "nodemon-atom.args_" + filePath
  if old_args
    return old_args
  else
    return """Put your arguments to nodemon here
    -e py,js,html --exec "python -m module.app"
    """

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
  repo = gitRepository.open(atom.workspace.getActiveTextEditor()?.getPath(), refreshOnWindowFocus: false)
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
module.exports.filePath = filePath
module.exports.run = nodemonRun
module.exports.kill = nodemonKill
# module.exports.stop = nodemonStop
module.exports.parseArgs = nodemonParseArgs
module.exports.setArgs = nodemonSetArgs
module.exports.getArgs = nodemonGetArgs
module.exports.dir = dir
module.exports.relativize = relativize
module.exports.getSubmodule = getSubmodule
module.exports.getRepo = getRepo
module.exports.processes = processes
module.exports.views = views
