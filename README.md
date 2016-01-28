# task-tracer-client

```
# simple command
tt ls
tt 'echo hello'
tt 'top'
#run complex command
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

