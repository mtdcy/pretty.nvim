# Copy/Yank in ssh session 

## Basis

```shell
# recv
echo $(nc -l 9999)
# send
echo "Test" | nc -w0 10.10.10.101 9999
```

## Copy with local session

- local copyd 

```shell
#!/bin/bash

COPYD_LISTEN_PORT=${COPYD_LISTEN_PORT:-9999}
while true; do
    nc -l "$COPYD_LISTEN_PORT" | $pbcopy 
done
```

- remote rcopy 

```shell
#!/bin/bash
# Copy remote text to local pasteboard

COPYD_LISTEN_PORT=${COPYD_LISTEN_PORT:-9999}
read client _ <<< "$SSH_CLIENT"
nc -w0 $client $COPYD_LISTEN_PORT 
```

## Copy with remoet session 

When work with remote session, the socket cann't be reached 
by remote host, so we need help of sshd.

### Start ssh session with 

```shell
#!/bin/bash 

SSH_SOCKET=${SSH_SOCKET:-10000}

if ! pgrep -f "pretty.copyd.sh" > /dev/null 2>&1; then
    echo "start copyd ..."
    ./pretty.copyd.sh &
    sleep 1
fi

IFS=' ' read _ LOCAL_SOCKET < /tmp/pretty.copyd.pid

ssh -t -R "$SSH_SOCKET:localhost:$LOCAL_SOCKET" "$@" " \
    export SSH_SOCKET=$SSH_SOCKET; \
    exec \$SHELL -li \
    "
```

### Copy through remote socket 

```shell
#!/bin/bash
# Copy remote text to local pasteboard

COPYD_LISTEN_PORT=${COPYD_LISTEN_PORT:-9999}

if [ -z "$SSH_SOCKET" ]; then
    read client _ <<< "$SSH_CLIENT"
    nc -w0 $client $COPYD_LISTEN_PORT 
else
    nc -w0 localhost $SSH_SOCKET 
fi
```

## How to Use 

1. Run `pretty.copyd.sh &` or put it in `rc.local`.
2. Use `pretty.ssh.sh` with remote host or `ssh` with local host.
3. `cat "your text here" | pretty.rcopy.sh` or yank inside nvim directly.
4. Paste in local machine.
