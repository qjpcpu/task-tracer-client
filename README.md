TaskTracer(client) - Real-time process monitoring
=================================================

Powered by [node.js](http://nodejs.org) + [socket.io](http://socket.io) + [nexe](https://jaredallard.me/nexe)

## How does it work?
*tt(task tracer client)* capture process output(both stdout & stderr) and send the data to *ttServer* via socket.io, browser or your own socketio client can get these data realtime.

## Install

```
# for osx
wget https://raw.githubusercontent.com/qjpcpu/task-tracer-client/master/dist/tt.darwin -O tt
# for linux
wget https://raw.githubusercontent.com/qjpcpu/task-tracer-client/master/dist/tt.linux -O tt
```

Or install from source:

```
# 1. install nodejs,npm,[nexe](https://jaredallard.me/nexe/) first
# 2. fetch source
git clone git@github.com:qjpcpu/task-tracer-client.git
# 3. build
cd task-tracer-client
npm install
./install
# 4. find the binary file tt.* under ./dist
```

## Configuration file

*tt* would load config file from `$HOME/.tt.conf` or `/etc/tt.conf`, the `tt.conf` is an ini config file looks like below:

```
id = 361
token = eyjkjlkl32
url = http://tt-server.com
```

1. *id*: tt client identifier
2. *token*: tt client use for authentication, which generated from ttServer
3. *url*: ttServer address

## Usage
### simple command

```
tt -n test ls
tt -n test 'echo hello'
tt -n test 'top'
```

### run complex command

```
tt -n complex "$(cat << 'TASKTRACERCLIENTEOF'
  echo "$DEBUG";echo 'a b c'|awk '{print $2" "$1}'
  a=123
if [ "$a" -gt 23 ];then
  echo "a >= 23"
else
  echo "a < 23"
fi
TASKTRACERCLIENTEOF
)"
```

### set task name

```
tt -n myname ls -l
# or
TASK_TRACER_NAME=test tt ls -l
```

