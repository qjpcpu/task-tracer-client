# task-tracer-client

## Install

```
# for osx
wget https://raw.githubusercontent.com/qjpcpu/task-tracer-client/master/dist/tt.darwin -O tt
# for linux
wget https://raw.githubusercontent.com/qjpcpu/task-tracer-client/master/dist/tt.darwin -O tt
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

## Usage
### simple command

```
tt ls
tt 'echo hello'
tt 'top'
```

### run complex command

```
tt "$(cat << 'TASKTRACERCLIENTEOF'
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
export TASK_TRACER_NAME=test
tt ls -l
# or
TASK_TRACER_NAME=test tt ls -l
```

