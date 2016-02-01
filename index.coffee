async = require 'async'
socketio = require 'socket.io-client'
debug = require 'debug'
fs = require 'fs'
ini = require 'ini'
childprocess = require 'child_process'
moment = require 'moment'
log = debug 'tt'

app = 
  error:
    code: 1

parseCli = ->
  program = 
    env: process.env
    name: process.env.TASK_TRACER_NAME or moment().format('YYYYMMDDHHmmss')
    cmd: process.argv[2..].join(' ')
  argsList = process.argv[2..]
  unless program.cmd?.length > 0
    console.error 'no command found'
    process.exit app.error.code
  program


configInit = (appCallback) ->
  async.waterfall [
    (cb) ->
      try
        fs.statSync "#{process.env.HOME}/.tt.conf"
        return cb(null,"#{process.env.HOME}/.tt.conf")
      catch err
        true
      try 
        fs.statSync '/etc/tt.conf'
        return cb(null,'/etc/tt.conf')
      catch err
        cb('no config file found')
    (filename,cb) ->
      res = ini.parse(fs.readFileSync(filename, 'utf-8'))
      return cb("no id found in #{filename}")  unless res.id
      return cb("no token found in #{filename}") unless res.token
      return cb("no url found in #{filename}") unless res.url
      app.config = 
        id: res.id
        token: res.token
        url: res.url
      cb null
    (cb) ->
      program = parseCli()
      app.task =
        name: program.name
        env: program.env
        cmd: program.cmd
      cb null  
  ], (err) ->
    if err
      console.error err 
      process.exit app.error.code
    else
      log "app config:",app
      appCallback() if appCallback? and typeof appCallback == 'function'


taskInit = (socket,taskCallback) ->
  log "start to run task[#{app.task.name}]"
  log app.task.cmd
  job = childprocess.spawn 'bash', ['-c',app.task.cmd],app.task.env
  # capture system signal
  jobAbort = (signal) ->
    log "job abort with signal #{signal}"
    app.error.code = 2
    socket.emit 'eof',code: app.error.code,signal: signal
    process.exit app.error.code

  process.on 'SIGHUP', -> jobAbort('SIGHUP')
  process.on 'SIGINT', -> jobAbort('SIGINT')
  process.on 'SIGQUIT', -> jobAbort('SIGQUIT')
  process.on 'SIGABRT', -> jobAbort('SIGABRT')
  process.on 'SIGTERM', -> jobAbort('SIGTERM')

  job.stdout.on 'data', (data) ->
    line = new Buffer(data).toString()
    socket.emit 'data',type: 'STDOUT',data: line
    process.stdout.write line

  job.stderr.on 'data', (data) ->
    line = new Buffer(data).toString()
    socket.emit 'data',type: 'STDERR',data: line
    process.stderr.write line

  job.on 'close', (code) ->
    socket.emit 'eof',code: code
    log "#{app.task.name} exit with code #{code}"
    app.error.code = code
    setTimeout (-> process.exit app.error.code),5000

  taskCallback null,job
  

socketInit = (socketCallback) ->
  log "try to connect #{app.config.url}"
  # 防止断线重连后启动新进程
  connState = null
  socket = socketio app.config.url

  socket.on 'connect', ->
    socket.emit 'authenticate',
      type: 'client'
      token: app.config.token
      id: app.config.id
      task: app.task

    log 'ttServer connected!'
  
  socket.on 'authenticated', (data) ->
    log 'authenticated finish',data
    if data.error
      console.error data.error
      socketCallback data.error
    else
      if connState
        console.error "Reconnect ttServer OK"
      else
        console.error "View #{data.httpUrl} for task output"
        socketCallback null,socket
      connState = 'OK'
  
  socket.on 'bye', (data) ->
    log "Bye ttServer!"
    process.exit app.error.code

  socket.on 'disconnect', ->
    log 'disconnect from ttServer!'
    socketCallback 'disconnect from ttServer!'  unless connState

  socket.on 'connect_timeout', ->
    log "connect timeout"
    socketCallback "connect ttServer timeout"  unless connState

  socket.on 'connect_error', (err) ->
    log 'connect_error',err
    console.error "Can't connect to ttServer!"
    socketCallback "connect ttServer fail!"  unless connState

appInit = ->
  async.waterfall [
    (cb) ->
      configInit -> cb()
    (cb) ->
      socketInit cb
    (socket,cb) ->
      taskInit socket,cb
  ], (err) ->
    if err
      log 'fail to start tt'
      process.exit app.error.code
    else 
      log 'tt started OK!'

# start app
appInit()
